"""Intel HEX parser specialised for PIC32 firmware images.

PIC32 bootloaders emit records with extended linear addresses based on the
*physical* memory map (0x1Dxxxxxx flash, 0x1FC0xxxx boot flash).  This module
flattens them into two contiguous images mapped at the KSEG0 virtual bases
that the running code actually references (0x9D000000 / 0x9FC00000).
"""

from __future__ import annotations

from dataclasses import dataclass

from . import BOOT_PHYS, FLASH_PHYS


@dataclass
class HexImage:
    """Sparse byte map of every data record in the HEX file."""

    mem: dict[int, int]

    @property
    def min_addr(self) -> int:
        return min(self.mem)

    @property
    def max_addr(self) -> int:
        return max(self.mem)

    def span(self, lo: int, hi: int) -> bytes:
        """Bytes in [lo, hi) with 0xFF fill for gaps (erased flash)."""
        return bytes(self.mem.get(a, 0xFF) for a in range(lo, hi))

    def nonff_range(self, lo: int, hi: int) -> tuple[int, int]:
        last = max((a for a, b in self.mem.items() if b != 0xFF and lo <= a < hi),
                   default=lo)
        first = min((a for a, b in self.mem.items() if b != 0xFF and lo <= a < hi),
                    default=lo)
        return first, last


def parse(path: str) -> HexImage:
    mem: dict[int, int] = {}
    base = 0
    with open(path) as fh:
        for line in fh:
            line = line.strip()
            if not line.startswith(":"):
                continue
            rec = bytes.fromhex(line[1:])
            count, offset, rtype = rec[0], (rec[1] << 8) | rec[2], rec[3]
            data = rec[4:4 + count]
            if rtype == 0x00:            # data
                for i, b in enumerate(data):
                    mem[base + offset + i] = b
            elif rtype == 0x02:          # extended segment address
                base = ((data[0] << 8) | data[1]) << 4
            elif rtype == 0x04:          # extended linear address
                base = ((data[0] << 8) | data[1]) << 16
            elif rtype == 0x01:          # EOF
                break
    return HexImage(mem)


def split(image: HexImage, flash_span: int = 0x90000,
          boot_span: int = 0x10000) -> tuple[bytes, bytes]:
    """Return (flash, boot) images as contiguous 0xFF-filled byte strings."""
    flash = image.span(FLASH_PHYS, FLASH_PHYS + flash_span)
    boot = image.span(BOOT_PHYS, BOOT_PHYS + boot_span)
    return flash, boot
