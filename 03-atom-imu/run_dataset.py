#!/usr/bin/env python3
"""用共享测试数据运行 ATOM-IMU 的 6 轴 Madgwick 重建（独立可跑）。

用法：
    python3 run_dataset.py [--data ../testdata/imu_scenario.csv] [--out results/atom.csv]
输出：t,qw,qx,qy,qz
"""

from __future__ import annotations

import argparse
import csv
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from refimpl.madgwick6 import Madgwick6  # noqa: E402


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", default=os.path.join(HERE, "..", "testdata",
                                                   "imu_scenario.csv"))
    ap.add_argument("--out", default=os.path.join(HERE, "results", "atom.csv"))
    args = ap.parse_args()

    filt = Madgwick6(beta=0.5, init_samples=200, gain_boost=50.0,
                     boost_samples=3000)
    rows = list(csv.DictReader(open(args.data, newline="")))
    prev_t = None
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    with open(args.out, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["t", "qw", "qx", "qy", "qz"])
        for r in rows:
            t = float(r["t"])
            dt = 1.0 / 200.0 if prev_t is None else (t - prev_t)
            prev_t = t
            acc = [float(r[k]) for k in ("ax", "ay", "az")]
            gyr = [float(r[k]) for k in ("gx", "gy", "gz")]
            q = filt.update(gyr, acc, dt)
            w.writerow([f"{t:.6f}", *[f"{v:.9f}" for v in q]])
    print(f"atom: {len(rows)} samples -> {args.out}")


if __name__ == "__main__":
    main()
