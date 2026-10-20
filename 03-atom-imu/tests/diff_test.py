#!/usr/bin/env python3
"""Python/C 差分验证（方法学沿用 quat-zupt-ekf 的 test/ 目录）。

比较内容：
  * 温度/占空比曲线（每 100 拍）：容差 1e-3（C=float，Python=double）
  * 状态迁移时刻：容差 5 拍
  * 标定结果（陀螺零偏、加计 M/b、残差）：容差 1e-4

运行：python3 tests/diff_test.py
"""

from __future__ import annotations

import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
C_DIR = os.path.join(ROOT, "reconstructed", "c")


def build_c() -> str:
    subprocess.run(["make", "-s"], cwd=C_DIR, check=True)
    return os.path.join(C_DIR, "atom_thermal_test")


def run(cmd, cwd=None):
    out = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True,
                         check=True).stdout
    rows, ready, solve = [], None, None
    for line in out.strip().splitlines():
        parts = line.split(",")
        if parts[0] == "ready":
            ready = [float(x) for x in parts[1:]]
        elif parts[0] == "solve":
            solve = [float(x) for x in parts[1:]]
        else:
            rows.append((int(parts[0]), float(parts[1]), float(parts[2]),
                         int(parts[3])))
    return rows, ready, solve


def close(a, b, tol):
    return abs(a - b) <= tol


def main() -> int:
    exe = build_c()
    c_rows, c_ready, c_solve = run([exe])
    py_rows, py_ready, py_solve = run(
        [sys.executable, os.path.join(HERE, "run_python.py")])

    failures = []

    if len(c_rows) != len(py_rows):
        failures.append(f"row count {len(c_rows)} vs {len(py_rows)}")
    for cr, pr in zip(c_rows, py_rows):
        if cr[0] != pr[0]:
            failures.append(f"step mismatch {cr[0]} vs {pr[0]}")
            break
        if cr[3] != pr[3]:
            failures.append(f"state mismatch at step {cr[0]}: "
                            f"C={cr[3]} py={pr[3]}")
            break
        if not close(cr[1], pr[1], 1e-3):
            failures.append(f"temp mismatch at {cr[0]}: {cr[1]} vs {pr[1]}")
            break
        if not close(cr[2], pr[2], 1e-4):
            failures.append(f"duty mismatch at {cr[0]}: {cr[2]} vs {pr[2]}")
            break

    if c_ready is None or py_ready is None:
        failures.append("no ready event")
    else:
        if not close(c_ready[1], py_ready[1], 0.5):
            failures.append(f"time_to_stable: {c_ready[1]} vs {py_ready[1]}")
        for i in range(2, 5):
            if not close(c_ready[i], py_ready[i], 1e-4):
                failures.append(f"bias[{i-2}]: {c_ready[i]} vs {py_ready[i]}")

    if c_solve is None or py_solve is None:
        failures.append("no solve result")
    else:
        for i, (a, b) in enumerate(zip(c_solve, py_solve)):
            if not close(a, b, 1e-4):
                failures.append(f"solve[{i}]: {a} vs {b}")

    print(f"C rows={len(c_rows)} python rows={len(py_rows)}")
    print(f"ready: C={c_ready} python={py_ready}")
    if failures:
        print("\nFAIL")
        for f in failures[:10]:
            print("  -", f)
        return 1
    print("\nPASS: state sequence identical, float agreement within tolerance")
    return 0


if __name__ == "__main__":
    sys.exit(main())
