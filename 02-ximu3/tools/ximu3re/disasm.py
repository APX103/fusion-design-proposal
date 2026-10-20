"""Annotated capstone disassembly for MIPS32 with the quirks of this firmware.

Two local workarounds are baked in:

* capstone 5.x refuses a few COP1 compare encodings (``c.ule.s``/``c.eq.s``
  with predicate-register cc bits); those words are decoded manually.
* flash constants are addressed as ``lui $rX, 0x9D09`` + negative offset —
  loads through such a base are resolved against the raw image and annotated
  with the float/pointer value and, when known, its semantic name.
"""

from __future__ import annotations

import struct

from capstone import CS_ARCH_MIPS, CS_MODE_LITTLE_ENDIAN, CS_MODE_MIPS32, Cs

from . import FLASH_BASE
from .known import CONST_POOL_SEMANTICS, KNOWN_SYMBOLS, RAM_OBJECTS

_C_NAMES = {0x30: "c.f.s", 0x31: "c.un.s", 0x32: "c.eq.s", 0x33: "c.ueq.s",
            0x34: "c.olt.s", 0x35: "c.ult.s", 0x36: "c.ole.s", 0x37: "c.ule.s",
            0x38: "c.sf.s", 0x39: "c.ngle.s", 0x3A: "c.seq.s", 0x3B: "c.ngl.s",
            0x3C: "c.lt.s", 0x3D: "c.nge.s", 0x3E: "c.le.s", 0x3F: "c.ngt.s"}


def _fmt_float(w: int) -> str:
    f = struct.unpack("<f", struct.pack("<I", w))[0]
    return f"{f:.9g}"


def disassemble(flash: bytes, start_va: int, size: int) -> list[str]:
    """Disassemble [start_va, start_va+size) with annotations."""
    md = Cs(CS_ARCH_MIPS, CS_MODE_MIPS32 | CS_MODE_LITTLE_ENDIAN)
    md.skipdata = True
    code = flash[start_va - FLASH_BASE: start_va - FLASH_BASE + size]
    lines: list[str] = []
    lui_reg: dict[int, int] = {}          # register -> high half just loaded

    def resolve(base_reg: int, off16: int, op: int) -> str | None:
        hi = lui_reg.get(base_reg)
        if hi is None:
            return None
        off = off16 - 0x10000 if off16 & 0x8000 else off16
        addr = (hi << 16) + off
        note = None
        if FLASH_BASE <= addr < FLASH_BASE + len(flash) and op in (0x23, 0x31):
            w = struct.unpack("<I", flash[addr - FLASH_BASE:addr - FLASH_BASE + 4])[0]
            sem = CONST_POOL_SEMANTICS.get(addr)
            note = f"[0x{addr:08X}] = 0x{w:08X}"
            if sem:
                note += f"  /* {sem} */"
            else:
                note += f"  /* {_fmt_float(w)} */"
        elif addr in RAM_OBJECTS:
            note = f"[0x{addr:08X}]  /* {RAM_OBJECTS[addr]} */"
        if addr != (hi << 16) + off:
            pass
        return note

    for ins in md.disasm(code, start_va):
        raw = struct.unpack("<I", ins.bytes)[0] if len(ins.bytes) == 4 else 0
        op = raw >> 26

        if ins.mnemonic == ".byte":
            fc = raw & 0x3F
            nm = _C_NAMES.get(fc, f"cop1.f{fc:02x}")
            fs, ft = (raw >> 15) & 0x1F, (raw >> 10) & 0x1F
            cc = (raw >> 18) & 7
            lines.append(f"{ins.address:08x}  {nm:<9} $f{ft}, $f{fs}"
                         + (f"  ; cc={cc}" if cc else ""))
            continue

        note = ""
        if op == 0x0F and ((raw >> 21) & 0x1F) != 0:        # lui
            lui_reg[(raw >> 16) & 0x1F] = raw & 0xFFFF
        if op in (0x23, 0x24, 0x28, 0x29, 0x2B, 0x2F, 0x31, 0x35, 0x37,
                  0x39, 0x3D):
            base = (raw >> 21) & 0x1F
            if base:
                r = resolve(base, raw & 0xFFFF, op)
                if r:
                    note = "  ; " + r
        if op in (0x02, 0x03):                              # j / jal
            tgt = (ins.address + 4) & 0xF0000000 | ((raw & 0x3FFFFFF) << 2)
            if tgt in KNOWN_SYMBOLS:
                note = f"  ; {KNOWN_SYMBOLS[tgt]}"
        if op == 0x09 and ((raw >> 21) & 0x1F) == 0:         # addiu $rd,$zero
            val = raw & 0xFFFF
            if val & 0x8000:
                val -= 0x10000
            note = f"  ; {val}"

        lines.append(f"{ins.address:08x}  {ins.mnemonic:<9} {ins.op_str}{note}")
    return lines
