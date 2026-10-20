#!/usr/bin/env python3
"""三算法统一评测：读取真值与三个结果 CSV，输出姿态误差与零漂。

用法：
    python3 testdata/evaluate.py \
        --results 01=01-quat-zupt-ekf/results/ekf7.csv \
                  02=02-ximu3/results/ximu3.csv \
                  03=03-atom-imu/results/atom.csv

指标（t ≥ 22 s，跳过各算法初始化）：
  roll/pitch/yaw RMSE（度）
  末段 yaw 漂移（60–70 s，度/分钟）
  磁干扰段（45–55 s）的 yaw RMSE
"""

from __future__ import annotations

import argparse
import csv
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))


def wrap(a: float) -> float:
    return (a + math.pi) % (2 * math.pi) - math.pi


def euler(q):
    w, x, y, z = q
    roll = math.atan2(2 * (w * x + y * z), 1 - 2 * (x * x + y * y))
    pitch = -math.asin(max(-1.0, min(1.0, 2 * (x * z - w * y))))
    yaw = math.atan2(2 * (x * y + w * z), 1 - 2 * (y * y + z * z))
    return roll, pitch, yaw


def load_truth(path):
    out = []
    with open(path, newline="") as fh:
        for r in csv.DictReader(fh):
            out.append((float(r["t"]),
                        [float(r[k]) for k in ("qw", "qx", "qy", "qz")]))
    return out


def load_result(path):
    out = []
    with open(path, newline="") as fh:
        for r in csv.DictReader(fh):
            out.append((float(r["t"]),
                        [float(r[k]) for k in ("qw", "qx", "qy", "qz")]))
    return out


def metrics(truth, result, t0=22.0, tail=(60.0, 70.0), disturb=(45.0, 55.0)):
    n = min(len(truth), len(result))
    errs = []
    for i in range(n):
        et = euler(truth[i][1])
        er = euler(result[i][1])
        errs.append((truth[i][0], *[math.degrees(wrap(a - b))
                                    for a, b in zip(er, et)]))
    mask = [e for e in errs if e[0] >= t0]
    rmse = [math.sqrt(sum(e[k] ** 2 for e in mask) / len(mask))
            for k in (1, 2, 3)]
    dm = [e for e in errs if disturb[0] <= e[0] < disturb[1]]
    yaw_dm = math.sqrt(sum(e[3] ** 2 for e in dm) / len(dm)) if dm else float("nan")
    tm = [e for e in errs if tail[0] <= e[0] <= tail[1]]
    if len(tm) >= 2:
        span = tm[-1][0] - tm[0][0]
        drift = (tm[-1][3] - tm[0][3]) / span * 60.0
    else:
        drift = float("nan")
    return dict(roll=rmse[0], pitch=rmse[1], yaw=rmse[2],
                yaw_disturb=yaw_dm, yaw_drift=drift)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", default=os.path.join(HERE, "imu_scenario.csv"))
    ap.add_argument("--results", nargs="+", required=True,
                    help="name=path 形式的多个结果文件")
    ap.add_argument("--summary", default=os.path.join(HERE, "results_summary.csv"))
    args = ap.parse_args()

    truth = load_truth(args.data)
    rows = []
    print(f"{'算法':<14}{'roll RMSE':>10}{'pitch RMSE':>11}"
          f"{'yaw RMSE':>10}{'干扰段 yaw':>12}{'尾段漂移':>12}")
    print("-" * 72)
    for item in args.results:
        name, path = item.split("=", 1)
        m = metrics(truth, load_result(path))
        rows.append((name, m))
        print(f"{name:<14}{m['roll']:>10.3f}{m['pitch']:>11.3f}"
              f"{m['yaw']:>10.3f}{m['yaw_disturb']:>12.3f}"
              f"{m['yaw_drift']:>12.3f}")
    print("-" * 72)
    print("单位：RMSE/干扰段为度（°），尾段漂移为 °/min；评估从 t=22 s 开始。")

    with open(args.summary, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["algorithm", "roll_rmse_deg", "pitch_rmse_deg",
                    "yaw_rmse_deg", "yaw_disturb_deg", "yaw_drift_deg_per_min"])
        for name, m in rows:
            w.writerow([name, f"{m['roll']:.4f}", f"{m['pitch']:.4f}",
                        f"{m['yaw']:.4f}", f"{m['yaw_disturb']:.4f}",
                        f"{m['yaw_drift']:.4f}"])
    print(f"summary -> {args.summary}")


if __name__ == "__main__":
    main()
