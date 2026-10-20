"""ximu3re — x-IMU3 (PIC32MZ / MIPS32r2) firmware static-analysis toolkit."""

__version__ = "1.0.0"

FLASH_BASE = 0x9D000000   # KSEG0 virtual address of program flash
BOOT_BASE = 0x9FC00000    # KSEG0 virtual address of boot flash
FLASH_PHYS = 0x1D000000   # physical address used by the Intel HEX records
BOOT_PHYS = 0x1FC00000
