#!/usr/bin/env python3
"""ATOM-IMU V5.x 固件解密器（逆向自 bootloader.bin，v25-12-28 验证通过）。

算法（与教科书 XXTEA 不同，按 bootloader 0x080004A8 的反编译逐位复刻）：
  * 8 字节块 CTR 模式：keystream = XXTEA32_variant(counter, key)
  * plaintext = ciphertext XOR keystream
  * counter 初值 {0x61852112, 0xddb69722}（bootloader flash 0x08000CB8），
    每 8 字节块低字 +1
  * key = ASCII "XRobotLconDddax-"（bootloader flash 0x08000CC1，16 字节）
  * 32 轮，delta 0x9E3779B9，循环终止于 sum == 0xC6EF3720

用法：
  python3 xxtea_decrypt.py firmware_25-12-28.elf -o app.bin
  python3 xxtea_decrypt.py firmware_25-12-28.elf -o app.elf --elf 0x08001000
"""

from __future__ import annotations

import argparse
import struct

M = 0xFFFFFFFF
DELTA = 0x9E3779B9
STOP = 0xC6EF3720                  # DELTA * 32 (mod 2^32)
KEY = b"XRobotLconDddax-"
CTR0 = (0x61852112, 0xDDD69722 & 0xFFFFFFFF)  # 0xddb69722
CTR0 = (0x61852112, 0xDDB69722)


def _ks_block(v0: int, v1: int, k: tuple[int, int, int, int]) -> tuple[int, int]:
    s = 0
    while True:
        # v0 += (((v1>>5)^(v1<<4))+v1) ^ (k[s&3] + s)      [s before increment]
        e1 = ((((v1 >> 5) ^ ((v1 << 4) & M)) + v1) & M) ^ ((k[s & 3] + s) & M)
        v0 = (v0 + e1) & M
        s = (s + DELTA) & M
        # v1 += (((v0>>5)^(v0*16))+v0) ^ (k[idx] + s), idx = (s>>11)&3
        idx = ((s * 0x80000) & M) >> 30
        e2 = ((((v0 >> 5) ^ ((v0 * 0x10) & M)) + v0) & M) ^ ((k[idx] + s) & M)
        v1 = (v1 + e2) & M
        if s == STOP:
            return v0, v1


def decrypt(data: bytes, key: bytes = KEY,
            ctr0: tuple[int, int] = CTR0) -> bytes:
    if len(key) != 16:
        raise ValueError("XXTEA key must be 16 bytes")
    k = struct.unpack("<4I", key)
    out = bytearray(len(data) - (len(data) % 8))
    for i in range(0, len(out), 8):
        c0, c1 = struct.unpack_from("<2I", data, i)
        s0, s1 = _ks_block((ctr0[0] + i // 8) & M, ctr0[1], k)
        struct.pack_into("<2I", out, i, c0 ^ s0, c1 ^ s1)
    return bytes(out)


def build_elf(image: bytes, base: int, entry: int | None = None) -> bytes:
    """把裸镜像包装为 Cortex-M ELF（供 Ghidra/IDA 直接加载）。"""
    if entry is None:
        entry = struct.unpack_from("<I", image, 4)[0]
    ehdr, phdr, off = 52, 32, 0x1000
    h = b"\x7fELF" + bytes([1, 1, 1, 0]) + b"\x00" * 8
    h += struct.pack("<HHIIIIIHHHHHH", 2, 40, 1, entry, ehdr, 0,
                     0x05000000, ehdr, phdr, 1, 0, 0, 0)
    ph = struct.pack("<IIIIIIII", 1, off, base, base, len(image),
                     len(image), 7, 0x1000)
    out = bytearray(h + ph)
    out += b"\x00" * (off - len(out)) + image
    return bytes(out)


def sanity(image: bytes) -> str:
    sp, rv = struct.unpack_from("<2I", image, 0)
    ok_sp = 0x20000000 <= sp <= 0x20040000
    ok_rv = 0x08000000 <= (rv & ~1) <= 0x08200000 and (rv & 1) == 1
    printable = sum(32 <= b < 127 for b in image[:65536]) / 65536
    return (f"SP=0x{sp:08X} reset=0x{rv:08X} "
            f"vector_ok={ok_sp and ok_rv} printable={printable:.2%}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("-o", "--output", required=True)
    ap.add_argument("--elf", metavar="BASE", type=lambda x: int(x, 0),
                    help="同时输出 ELF，参数为加载基址（如 0x08001000）")
    ap.add_argument("--key", default=KEY.decode())
    args = ap.parse_args()

    data = open(args.input, "rb").read()
    img = decrypt(data, args.key.encode())
    open(args.output, "wb").write(img)
    print(f"decrypted {len(img)} bytes -> {args.output}")
    print("sanity:", sanity(img))
    if args.elf is not None:
        elf_path = args.output.rsplit(".", 1)[0] + ".elf"
        open(elf_path, "wb").write(build_elf(img, args.elf))
        print("ELF ->", elf_path)


if __name__ == "__main__":
    main()
