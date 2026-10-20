"""MIPS32 function discovery and call-graph extraction.

Two complementary detectors, tuned against this firmware (XC32 -O2 output):

1. ``jal``/``bal`` instruction targets — always real function entries.
2. Stack-frame prologues: ``addiu $sp, $sp, -N`` followed within 8 words by
   ``sw $ra, off($sp)``.  The linker places a 1-word preamble before some
   prologues, so entries are also reported at ``prologue-4`` when a ``jal``
   lands there.
"""

from __future__ import annotations

import bisect
import collections
import struct
from dataclasses import dataclass

from . import FLASH_BASE

_JAL, _BAL = 0x0C000000, 0x04110003
_LUI = 0x3C000000


def words(flash: bytes) -> list[int]:
    n = len(flash) & ~3
    return list(struct.unpack(f"<{n // 4}I", flash[:n]))


def jal_sites(ws: list[int]) -> dict[int, list[int]]:
    """Map {target virtual address -> [call site addresses]}."""
    callers: dict[int, list[int]] = collections.defaultdict(list)
    for i, w in enumerate(ws):
        if (w & 0xFC000000) == _JAL or w == _BAL:
            pc = FLASH_BASE + i * 4
            tgt = (pc & 0xF0000000) | ((w & 0x3FFFFFF) << 2)
            if FLASH_BASE <= tgt < FLASH_BASE + len(ws) * 4:
                callers[tgt].append(pc)
    return callers


def prologue_entries(ws: list[int]) -> set[int]:
    entries: set[int] = set()
    limit = len(ws) - 10
    for i in range(limit):
        w = ws[i]
        if (w & 0xFFFF8000) != 0x27BD8000:      # addiu $sp,$sp,-N
            continue
        for j in range(i + 1, i + 9):
            w2 = ws[j]
            # sw $ra, off($sp)  →  opcode 0x2B, base $sp(29), rt $ra(31)
            if (w2 & 0xFC1F0000) == 0xAC1F0000 and ((w2 >> 21) & 0x1F) == 29:
                entries.add(FLASH_BASE + i * 4)
                break
    return entries


@dataclass
class FuncInfo:
    entry: int
    size: int
    fpu_count: int
    callers: list[int]

    @property
    def fpu_density(self) -> float:
        return self.fpu_count / max(1, self.size // 4)


def discover(flash: bytes) -> list[FuncInfo]:
    """Union of both detectors; sizes from the next-higher entry."""
    ws = words(flash)
    callers = jal_sites(ws)
    entries = set(callers)
    # A jal that lands 4 bytes before a prologue proves a 1-word preamble.
    for p in prologue_entries(ws):
        entries.add(p)
        entries.add(p - 4)          # keep both candidates; dedup by ordering below
    entries.add(FLASH_BASE)         # reset stub
    entries = sorted(a for a in entries
                     if FLASH_BASE <= a < FLASH_BASE + len(flash) - 8)
    # Collapse the +-4 duplicates: prefer the exact jal target when present.
    collapsed: list[int] = []
    for a in entries:
        if collapsed and a - collapsed[-1] <= 4:
            if a in callers and collapsed[-1] not in callers:
                collapsed[-1] = a            # jal proves the 1-word preamble
            elif a not in callers and collapsed[-1] not in callers:
                collapsed[-1] = a            # keep the prologue itself
            continue
        collapsed.append(a)

    out: list[FuncInfo] = []
    for k, a in enumerate(collapsed):
        size = (collapsed[k + 1] - a) if k + 1 < len(collapsed) else 0x40
        fpu = sum(1 for w in ws[(a - FLASH_BASE) // 4:
                                (a - FLASH_BASE + size) // 4]
                  if (w >> 26) in (0x11, 0x13))
        out.append(FuncInfo(a, size, fpu, callers.get(a, [])))
    return out


def owner_of(funcs: list[int], addr: int) -> int | None:
    k = bisect.bisect_right(funcs, addr) - 1
    return funcs[k] if k >= 0 else None
