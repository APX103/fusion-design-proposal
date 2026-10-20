#!/usr/bin/env python3
"""用共享测试数据运行 quat-zupt-ekf（独立可跑）。

用法：
    python3 run_dataset.py [--data ../testdata/imu_scenario.csv] [--out results/ekf7.csv]

输出：t,qw,qx,qy,qz（含自标定安装矩阵的合成，直接与真值可比）
"""

from __future__ import annotations

import argparse
import csv
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from ekf7 import ImuPipeline  # noqa: E402


def quat_mul(a, b):
    w, x, y, z = a
    w2, x2, y2, z2 = b
    return np.array([
        w * w2 - x * x2 - y * y2 - z * z2,
        w * x2 + x * w2 + y * z2 - z * y2,
        w * y2 - x * z2 + y * w2 + z * x2,
        w * z2 + x * y2 - y * x2 + z * w2,
    ])


def dcm_to_quat(r):
    tr = r[0, 0] + r[1, 1] + r[2, 2]
    if tr > 0.0:
        s = np.sqrt(tr + 1.0) * 2.0
        q = [0.25 * s, (r[2, 1] - r[1, 2]) / s,
             (r[0, 2] - r[2, 0]) / s, (r[1, 0] - r[0, 1]) / s]
    elif r[0, 0] > r[1, 1] and r[0, 0] > r[2, 2]:
        s = np.sqrt(1.0 + r[0, 0] - r[1, 1] - r[2, 2]) * 2.0
        q = [(r[2, 1] - r[1, 2]) / s, 0.25 * s,
             (r[0, 1] + r[1, 0]) / s, (r[0, 2] + r[2, 0]) / s]
    elif r[1, 1] > r[2, 2]:
        s = np.sqrt(1.0 + r[1, 1] - r[0, 0] - r[2, 2]) * 2.0
        q = [(r[0, 2] - r[2, 0]) / s, (r[0, 1] + r[1, 0]) / s,
             0.25 * s, (r[1, 2] + r[2, 1]) / s]
    else:
        s = np.sqrt(1.0 + r[2, 2] - r[0, 0] - r[1, 1]) * 2.0
        q = [(r[1, 0] - r[0, 1]) / s, (r[0, 2] + r[2, 0]) / s,
             (r[1, 2] + r[2, 1]) / s, 0.25 * s]
    q = np.asarray(q, dtype=float)
    return q / np.linalg.norm(q)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", default=os.path.join(HERE, "..", "testdata",
                                                   "imu_scenario.csv"))
    ap.add_argument("--out", default=os.path.join(HERE, "results", "ekf7.csv"))
    args = ap.parse_args()

    fs = None
    prev_t = None
    rows = []
    with open(args.data, newline="") as fh:
        for row in csv.DictReader(fh):
            t = float(row["t"])
            if fs is None and prev_t is not None:
                fs = 1.0 / (t - prev_t)
            prev_t = t
            rows.append((t,
                         np.array([float(row[k]) for k in ("ax", "ay", "az")]),
                         np.array([float(row[k]) for k in ("gx", "gy", "gz")]),
                         np.array([float(row[k]) for k in ("mx", "my", "mz")])))
    if fs is None:
        fs = 1.0 / (rows[1][0] - rows[0][0])

    pipe = ImuPipeline(fs=fs, work_mode=1, amode=9)
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    with open(args.out, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["t", "qw", "qx", "qy", "qz"])
        for t, acc, gyr, mag in rows:
            out = pipe.calculate(acc, gyr, mag)
            q_abs = quat_mul(out["quat"], dcm_to_quat(pipe.rotm_install))
            q_abs /= np.linalg.norm(q_abs)
            w.writerow([f"{t:.6f}", *[f"{v:.9f}" for v in q_abs]])
    print(f"ekf7: {len(rows)} samples -> {args.out} (fs={fs:.1f} Hz)")


if __name__ == "__main__":
    main()
