#!/usr/bin/env python3
"""用共享测试数据运行增强版 EKF（ekf7plus，P1–P6；温补关闭）。

用法：
    python3 run_dataset_plus.py [--data ../testdata/imu_scenario.csv] \
                                [--out results/ekf7plus.csv]
输出：t,qw,qx,qy,qz
"""

from __future__ import annotations

import argparse
import csv
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "improved"))
from ekf7plus import ImuPlusPipeline          # noqa: E402
from ekf7plus.params import Params           # noqa: E402


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", default=os.path.join(HERE, "..", "testdata",
                                                   "imu_scenario.csv"))
    ap.add_argument("--out", default=os.path.join(HERE, "results",
                                                  "ekf7plus.csv"))
    args = ap.parse_args()

    p = Params()
    p.thermal_enabled = False
    pipe = ImuPlusPipeline(fs=200.0, amode=9, param=p)

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
            out = pipe.calculate(acc, gyr, mag, dt=dt)
            w.writerow([f"{t:.6f}", *[f"{v:.9f}" for v in out["quat"]]])
    print(f"ekf7plus: {len(rows)} samples -> {args.out}")


if __name__ == "__main__":
    main()
