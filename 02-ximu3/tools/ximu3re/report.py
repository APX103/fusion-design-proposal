"""Auto-report generation: function inventory, constant pools, known symbols."""

from __future__ import annotations

import struct
from pathlib import Path

from . import FLASH_BASE
from .known import CONST_POOL_SEMANTICS, KNOWN_SYMBOLS, RAM_OBJECTS
from .mips_scan import FuncInfo


def _fmt_float(w: int) -> str:
    return f"{struct.unpack('<f', struct.pack('<I', w))[0]:.9g}"


def write_functions_csv(funcs: list[FuncInfo], path: Path) -> None:
    with path.open("w") as fh:
        fh.write("entry,size_bytes,fpu_instructions,fpu_density,caller_count,"
                 "name\n")
        for f in sorted(funcs, key=lambda x: x.entry):
            name = KNOWN_SYMBOLS.get(f.entry, "")
            fh.write(f"0x{f.entry:08X},{f.size},{f.fpu_count},"
                     f"{f.fpu_density:.3f},{len(f.callers)},{name}\n")


def scan_const_pools(flash: bytes) -> list[tuple[int, float, int]]:
    """Words in flash whose float interpretation looks like a round constant.

    Cheap heuristic (>= 2 significant decimal digits or a well-known value)
    used to surface literal pools for manual annotation.
    """
    out: list[tuple[int, float, int]] = []
    n = len(flash) & ~3
    ws = struct.unpack(f"<{n // 4}I", flash[:n])
    for i, w in enumerate(ws):
        if w in (0, 0xFFFFFFFF):
            continue
        f = struct.unpack("<f", struct.pack("<I", w))[0]
        if not (1e-6 < abs(f) < 1e9):
            continue
        s = f"{f:.6f}"
        if s.rstrip("0").rstrip(".").replace("-", "").replace(".", "").isdigit():
            frac = s.split(".")[1] if "." in s else ""
            if frac in ("", "5", "25", "75") or len(frac.rstrip("0")) <= 2:
                out.append((FLASH_BASE + i * 4, f, w))
    return out


def write_report(flash: bytes, funcs: list[FuncInfo], path: Path) -> None:
    known_hits = [f for f in funcs if f.entry in KNOWN_SYMBOLS]
    lines = [
        "# ximu3re 自动分析报告",
        "",
        f"- 闪存镜像: {len(flash)} 字节 @ 0x{FLASH_BASE:08X}",
        f"- 检测到函数入口: {len(funcs)}",
        f"- 已识别符号命中: {len(known_hits)}",
        "",
        "## 已确认符号（本项目逆向结论）",
        "",
        "| 地址 | 名称 |", "|---|---|",
    ]
    for a in sorted(KNOWN_SYMBOLS):
        lines.append(f"| `0x{a:08X}` | `{KNOWN_SYMBOLS[a]}` |")
    lines += ["", "## RAM 对象", "", "| 地址 | 说明 |", "|---|---|"]
    for a in sorted(RAM_OBJECTS):
        lines.append(f"| `0x{a:08X}` | {RAM_OBJECTS[a]} |")
    lines += ["", "## 已标注浮点常量池", "", "| 地址 | 值 | 语义 |", "|---|---|---|"]
    for a in sorted(CONST_POOL_SEMANTICS):
        lines.append(f"| `0x{a:08X}` | (见说明) | {CONST_POOL_SEMANTICS[a]} |")
    lines += [
        "",
        "## FPU 密度最高的 20 个函数",
        "",
        "| 入口 | 大小 | FPU 指令 | 密度 | 调用者数 | 名称 |",
        "|---|---|---|---|---|---|",
    ]
    top = sorted((f for f in funcs if f.size >= 0x40 and f.fpu_count >= 20),
                 key=lambda f: -f.fpu_count)[:20]
    for f in top:
        lines.append(f"| `0x{f.entry:08X}` | {f.size} | {f.fpu_count} | "
                     f"{f.fpu_density:.2f} | {len(f.callers)} | "
                     f"{KNOWN_SYMBOLS.get(f.entry, '')} |")
    lines += ["", "## 常量池扫描（启发式，全部候选）", "",
              "| 地址 | float 值 | 原始字 |", "|---|---|---|"]
    for a, f, w in scan_const_pools(flash):
        sem = CONST_POOL_SEMANTICS.get(a, "")
        lines.append(f"| `0x{a:08X}` | {f:.9g} | 0x{w:08X} |"
                     + (f" **{sem}**" if sem else ""))
    path.write_text("\n".join(lines), encoding="utf-8")
