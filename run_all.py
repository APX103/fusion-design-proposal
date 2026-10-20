#!/usr/bin/env python3
"""一键运行三个算法并评测（共享测试数据）。

    python3 run_all.py            # 生成数据（若缺失）→ 跑三个 → 评测
    python3 run_all.py --keep     # 不重新生成数据（复用已有 CSV）
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "testdata", "imu_scenario.csv")

RUNNERS = [
    ("01-quat-zupt-ekf", os.path.join(HERE, "01-quat-zupt-ekf", "run_dataset.py"),
     os.path.join(HERE, "01-quat-zupt-ekf", "results", "ekf7.csv")),
    ("02-ximu3", os.path.join(HERE, "02-ximu3", "run_dataset.py"),
     os.path.join(HERE, "02-ximu3", "results", "ximu3.csv")),
    ("03-atom-imu", os.path.join(HERE, "03-atom-imu", "run_dataset.py"),
     os.path.join(HERE, "03-atom-imu", "results", "atom.csv")),
]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--keep", action="store_true", help="复用已有数据集")
    args = ap.parse_args()

    if not args.keep or not os.path.exists(DATA):
        subprocess.run([sys.executable, os.path.join(HERE, "testdata",
                                                     "generate_dataset.py")],
                       check=True)

    results = []
    for name, runner, out in RUNNERS:
        print(f"\n=== {name} ===")
        subprocess.run([sys.executable, runner, "--data", DATA, "--out", out],
                       check=True)
        results.append(f"{name}={out}")

    print("\n=== 评测 ===")
    subprocess.run([sys.executable, os.path.join(HERE, "testdata", "evaluate.py"),
                    "--data", DATA, "--results", *results], check=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
