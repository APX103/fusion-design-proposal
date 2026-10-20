#!/usr/bin/env python3
"""用共享测试数据运行 x-IMU3 的 Madgwick 9 轴重建（独立可跑）。

用法：
    python3 run_dataset.py [--data ../testdata/imu_scenario.csv] [--out results/ximu3.csv]
输出：t,qw,qx,qy,qz
"""

from __future__ import annotations

import argparse
import csv
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from refimpl.madgwick9 import Madgwick9, quat_from_yaw, quat_mul  # noqa: E402


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", default=os.path.join(HERE, "..", "testdata",
                                                   "imu_scenario.csv"))
    ap.add_argument("--out", default=os.path.join(HERE, "results", "ximu3.csv"))
    args = ap.parse_args()

    filt = Madgwick9(beta=0.5, init_samples=200)
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
            mag = [float(r[k]) for k in ("mx", "my", "mz")]
            # 算法内部参考系为 north=+x；数据集是 ENU（north=+y），
            # 输出前左乘 +90° yaw 旋转，统一到 ENU。
            q_mw = filt.update(gyr, acc, mag, dt)
            q = quat_mul(quat_from_yaw(math.pi / 2), q_mw)
            w.writerow([f"{t:.6f}", *[f"{v:.9f}" for v in q]])
    print(f"ximu3: {len(rows)} samples -> {args.out}")


if __name__ == "__main__":
    main()
