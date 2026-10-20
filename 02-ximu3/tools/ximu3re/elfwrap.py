"""Wrap raw flash/boot images into an ELF32 MIPS o32 executable.

Why: REA's Ghidra lane (and Ghidra's loader) only admit ELF targets for this
architecture, with strict header requirements:

* e_flags = ``0x70001000``  (EF_MIPS_ARCH_32R2 | EF_MIPS_ABI_O32; the ABI2
  bit 0x20 must stay CLEAR or REA rejects the file as non-o32)
* a ``.MIPS.abiflags`` record (SHT 0x7000002a / PT 0x70000003) with
  isa=32r2, gpr/cpr1 = 32-bit, fp_abi = FPXX(5)
* segments mapped at the KSEG0 virtual addresses the code actually uses.

Function symbols discovered by :mod:`ximu3re.mips_scan` are injected as a
symtab so Ghidra disassembles cold regions it would otherwise skip.
"""

from __future__ import annotations

import struct

from . import BOOT_BASE, FLASH_BASE

_EHDR, _PHDR, _SHDR = 52, 32, 40


def build_elf(flash: bytes, boot: bytes, symbols: list[int]) -> bytes:
    off_flash = 0x1000
    off_boot = off_flash + len(flash)
    off_abi = off_boot + len(boot)

    abiflags = struct.pack("<HBBBBBBIIII",
                           0, 32, 2, 1, 1, 0, 5, 0, 0, 0, 0)   # v0, mips32r2, FPXX

    strtab = bytearray(b"\x00")
    syms = [struct.pack("<IIIBBH", 0, 0, 0, 0, 0, 0)]
    for a in symbols:
        name = f"FUN_{a:08x}".encode()
        strtab += name + b"\x00"
        st_name = len(strtab) - len(name) - 1
        syms.append(struct.pack("<IIIBBH", st_name, a, 0, (1 << 4) | 2, 0, 1))

    sh_names = ["", ".text", ".boot", ".MIPS.abiflags", ".symtab", ".strtab",
                ".shstrtab"]
    shstr = bytearray(b"\x00")
    sh_off: dict[str, int] = {}
    for nm in sh_names[1:]:
        sh_off[nm] = len(shstr)
        shstr += nm.encode() + b"\x00"

    pad = lambda x: (x + 3) & ~3
    symtab = b"".join(syms)
    off_sym = pad(off_abi + len(abiflags))
    off_strt = pad(off_sym + len(symtab))
    off_shst = pad(off_strt + len(strtab))
    off_sh = pad(off_shst + len(shstr))

    n_ph, n_sh = 3, 7
    ehdr = b"\x7fELF" + bytes([1, 1, 1, 0]) + b"\x00" * 8
    ehdr += struct.pack("<HHIIIIIHHHHHH",
                        2, 8, 1,                 # ET_EXEC, EM_MIPS, EV_CURRENT
                        BOOT_BASE + 0x480,       # e_entry: PIC32MZ reset vector
                        _EHDR, off_sh,           # phoff, shoff
                        0x70001000,              # e_flags: 32R2 | O32
                        _EHDR, _PHDR, n_ph, _SHDR, n_sh, 6)

    def phdr(t, off, va, sz, flags):
        return struct.pack("<IIIIIIII", t, off, va, va, sz, sz, flags, 4)

    ph = (phdr(1, off_flash, FLASH_BASE, len(flash), 5)
          + phdr(1, off_boot, BOOT_BASE, len(boot), 5)
          + phdr(0x70000003, off_abi, 0, len(abiflags), 4))

    def shdr(name, typ, flags, addr, off, size, link, info, align, entsz):
        return struct.pack("<IIIIIIIIII", sh_off.get(name, 0), typ, flags,
                           addr, off, size, link, info, align, entsz)

    sh = (b"\x00" * _SHDR
          + shdr(".text", 1, 0x6, FLASH_BASE, off_flash, len(flash), 0, 0, 16, 0)
          + shdr(".boot", 1, 0x6, BOOT_BASE, off_boot, len(boot), 0, 0, 16, 0)
          + shdr(".MIPS.abiflags", 0x7000002A, 2, 0, off_abi, len(abiflags),
                 0, 0, 4, 0)
          + shdr(".symtab", 2, 0, 0, off_sym, len(symtab), 5, 1, 4, 16)
          + shdr(".strtab", 3, 0, 0, off_strt, len(strtab), 0, 0, 1, 0)
          + shdr(".shstrtab", 3, 0, 0, off_shst, len(shstr), 0, 0, 1, 0))

    out = bytearray(ehdr + ph)
    out += b"\x00" * (off_flash - len(out)) + flash + boot + abiflags
    for off, blob in ((off_sym, symtab), (off_strt, bytes(strtab)),
                      (off_shst, bytes(shstr)), (off_sh, sh)):
        out += b"\x00" * (off - len(out)) + blob
    assert len(out) == off_sh + len(sh), (len(out), off_sh + len(sh))
    out[0x20:0x24] = struct.pack("<I", off_sh)
    return bytes(out)
