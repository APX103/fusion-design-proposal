#!/usr/bin/env python3
"""生成确定性的 IMU 仿真数据集（含姿态真值），供三个算法共用。

约定：
  - 导航系 ENU（z 向上），四元数 wxyz，body→nav；
  - 欧拉角 ZYX：roll/pitch/yaw，弧度；
  - 加计单位 m/s²，陀螺 rad/s，磁力计任意单位（归一化方向有意义）；
  - 陀螺含恒定零偏 [2, -1, 1.5] mrad/s，模拟未标定残差。

场景（200 Hz，70 s）：
   0–20 s   静置（覆盖各算法初始化：EKF 自标定 / x-IMU3 窗口 / ATOM β×50）
  20–40 s   三轴正弦运动
  40–45 s   静置
  45–55 s   运动 + 磁干扰（磁场绕 z 转 40°、幅值 ×1.2）
  55–70 s   静置（漂移测量段）

运行：python3 testdata/generate_dataset.py
输出：testdata/imu_scenario.csv
"""

from __future__ import annotations

import csv
import math
import os

import numpy as np

FS = 200.0
T_TOTAL = 70.0
DT = 1.0 / FS
G0 = 9.795502520545487
BIAS = np.array([0.002, -0.001, 0.0015])       # rad/s
MAG_NAV = np.array([0.0, 1.0, -0.4])
MAG_NAV /= np.linalg.norm(MAG_NAV)
ACC_NOISE, GYRO_NOISE, MAG_NOISE = 0.02, 0.0008, 0.01
RNG = np.random.default_rng(20261020)

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "imu_scenario.csv")


def quat_from_euler(roll: float, pitch: float, yaw: float) -> np.ndarray:
    cr, sr = math.cos(roll / 2), math.sin(roll / 2)
    cp, sp = math.cos(pitch / 2), math.sin(pitch / 2)
    cy, sy = math.cos(yaw / 2), math.sin(yaw / 2)
    return np.array([
        cr * cp * cy + sr * sp * sy,
        sr * cp * cy - cr * sp * sy,
        cr * sp * cy + sr * cp * sy,
        cr * cp * sy - sr * sp * cy,
    ])


def quat_mul(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    w, x, y, z = a
    w2, x2, y2, z2 = b
    return np.array([
        w * w2 - x * x2 - y * y2 - z * z2,
        w * x2 + x * w2 + y * z2 - z * y2,
        w * y2 - x * z2 + y * w2 + z * x2,
        w * z2 + x * y2 - y * x2 + z * w2,
    ])


def quat_from_rv(rv: np.ndarray) -> np.ndarray:
    n2 = float(rv @ rv)
    if n2 < 1e-12:
        return np.array([1.0, 0.5 * rv[0], 0.5 * rv[1], 0.5 * rv[2]])
    n = math.sqrt(n2)
    s = math.sin(n / 2) / n
    return np.array([math.cos(n / 2), s * rv[0], s * rv[1], s * rv[2]])


def quat_to_dcm(q: np.ndarray) -> np.ndarray:
    w, x, y, z = q
    return np.array([
        [1 - 2 * (y * y + z * z), 2 * (x * y - w * z), 2 * (x * z + w * y)],
        [2 * (x * y + w * z), 1 - 2 * (x * x + z * z), 2 * (y * z - w * x)],
        [2 * (x * z - w * y), 2 * (y * z + w * x), 1 - 2 * (x * x + y * y)],
    ])


def nav_rate(t: float) -> np.ndarray:
    """导航系角速度（rad/s）。"""
    moving = (20.0 <= t < 40.0) or (45.0 <= t < 55.0)
    if not moving:
        return np.zeros(3)
    return np.array([
        0.15 * math.sin(2 * math.pi * 0.30 * t),
        0.10 * math.sin(2 * math.pi * 0.17 * t),
        0.80 * math.sin(2 * math.pi * 0.11 * t),
    ])


def disturbed_mag(t: float) -> np.ndarray:
    m = MAG_NAV.copy()
    if 45.0 <= t < 55.0:
        ang = math.radians(40.0)
        c, s = math.cos(ang), math.sin(ang)
        m = np.array([c * m[0] - s * m[1], s * m[0] + c * m[1], m[2]]) * 1.2
    return m / np.linalg.norm(m)


def main() -> None:
    q = quat_from_euler(math.radians(5.0), math.radians(-3.0), 0.0)
    n = int(T_TOTAL * FS)
    with open(OUT, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["t", "ax", "ay", "az", "gx", "gy", "gz",
                    "mx", "my", "mz", "qw", "qx", "qy", "qz"])
        for k in range(n):
            t = k * DT
            R = quat_to_dcm(q)
            w_nav = nav_rate(t)
            w_body = R.T @ w_nav

            acc = R.T @ np.array([0.0, 0.0, G0]) + RNG.normal(0.0, ACC_NOISE, 3)
            gyr = w_body + BIAS + RNG.normal(0.0, GYRO_NOISE, 3)
            mag = R.T @ disturbed_mag(t) + RNG.normal(0.0, MAG_NOISE, 3)

            w.writerow([f"{t:.6f}"] + [f"{v:.9f}" for v in
                       np.concatenate([acc, gyr, mag, q])])
            q = quat_mul(q, quat_from_rv(w_body * DT))
            q /= np.linalg.norm(q)

    print(f"wrote {OUT}  ({n} rows, {T_TOTAL:.0f} s @ {FS:.0f} Hz)")


if __name__ == "__main__":
    main()
