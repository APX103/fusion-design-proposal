"""CLI: python -m ximu3re analyze <firmware.hex> [--out DIR]"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from . import BOOT_BASE, FLASH_BASE
from . import intelhex, mips_scan, elfwrap, disasm, report
from .known import KNOWN_SYMBOLS

# functions worth dumping as annotated assembly on every run
_DISASM_TARGETS: dict[int, int] = {
    0x9D036AC8: 0x9F0,   # AhrsUpdate
    0x9D0391D0: 0x920,   # AhrsUpdate_partial
    0x9D041038: 0x6D0,   # AhrsUpdate_alt
    0x9D07BFA4: 0x0A0,   # AhrsInitialiseWindow_Step
    0x9D05C740: 0x220,   # AhrsEngine_Configure
    0x9D07CA98: 0x0B8,   # AhrsReset
    0x9D0545DC: 0x380,   # AhrsSettings_Apply
    0x9D04A270: 0x540,   # Settings_ApplyAll
    0x9D038848: 0x500,   # Pipeline_CalibrateAndEmit
    0x9D048164: 0x5A8,   # Output_QuatToEulerMessage
}


def cmd_analyze(hex_path: str, out_dir: str) -> int:
    out = Path(out_dir)
    (out / "data" / "known_disasm").mkdir(parents=True, exist_ok=True)

    print(f"[1/5] parsing {hex_path}")
    image = intelhex.parse(hex_path)
    first, last = image.nonff_range(0x1D000000, 0x1E000000)
    print(f"      flash data 0x{first:08X}..0x{last:08X}"
          f" ({(last - first) + 1} bytes spanned)")
    flash, boot = intelhex.split(image)
    (out / f"flash_{FLASH_BASE:08X}.bin").write_bytes(flash)
    (out / f"boot_{BOOT_BASE:08X}.bin").write_bytes(boot)
    print(f"      wrote flash/boot images")

    print("[2/5] discovering functions")
    funcs = mips_scan.discover(flash)
    print(f"      {len(funcs)} entries")

    print("[3/5] building symbol ELF")
    entries = [f.entry for f in funcs]
    elf = elfwrap.build_elf(flash, boot, entries)
    (out / "ximu3_fw_sym.elf").write_bytes(elf)
    print(f"      wrote ximu3_fw_sym.elf ({len(elf)} bytes, {len(entries)} symbols)")

    print("[4/5] dumping annotated disassembly of known functions")
    for va, size in _DISASM_TARGETS.items():
        name = KNOWN_SYMBOLS.get(va, f"UNK_{va:08x}")
        lines = disasm.disassemble(flash, va, size)
        (out / "data" / "known_disasm" / f"{name}.asm").write_text(
            "\n".join(lines), encoding="utf-8")
    print(f"      {len(_DISASM_TARGETS)} files")

    print("[5/5] generating data tables and report")
    report.write_functions_csv(funcs, out / "data" / "functions.csv")
    report.write_report(flash, funcs, out / "auto_report.md")
    print(f"      done -> {out}")
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="ximu3re")
    sub = ap.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("analyze", help="run the full static pipeline on a .hex")
    a.add_argument("hexfile")
    a.add_argument("--out", default="out")
    args = ap.parse_args(argv)
    if args.cmd == "analyze":
        return cmd_analyze(args.hexfile, args.out)
    return 2


if __name__ == "__main__":
    sys.exit(main())
