"""demo_compare.py —— 同数据对比：ekf7（基线） vs ekf7plus（本工程）。

公平性措施：
- 同一份合成数据流（200 Hz，与 ekf7 demo 同参数：初始倾斜 5°/−3°、恒定陀螺零偏、
  加计/陀螺/磁噪声）；
- 两场景都先静置 8 s，让 ekf7 的 10 s 自标定 + 重新初始化流程完成（其 demo
  也是从 t=8 s 起评估）；
- 基线输出按 ekf7 自己 demo 的方式合成安装矩阵：q_abs = q_filter ⊗ q_install；
- 误差统一用 ekf7 自己的 quat_to_euler（同一欧拉约定，零偏置）。

场景 A（ekf7 设计场景）：静置 8s → 往复偏航 ±60° 10s → 静置 6s，
  t=20~20.5s 磁干扰突发（场矢量 ×5）检验门控滞回。
场景 B（ekf7 README 已知局限 1）：静置 8s → 匀速旋转 30°/s 12s → 静置 4s。
  匀速旋转会被峰峰值静止检测器误判为静止 → 零偏被污染、yaw 冻结。

运行：python3 demo_compare.py   （numpy 即可；基线从 ../../quat-zupt-ekf 导入）
"""

from __future__ import annotations

import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
EKF7_ROOT = os.path.normpath(os.path.join(HERE, ".."))          # 01 根目录（含 ekf7/）
if not os.path.isdir(os.path.join(EKF7_ROOT, "ekf7")):
    EKF7_ROOT = os.path.normpath(os.path.join(HERE, "..", "..", "quat-zupt-ekf"))
for p in (EKF7_ROOT, HERE):
    if p not in sys.path:
        sys.path.insert(0, p)

from ekf7 import (ImuPipeline, quat_from_euler, quat_from_rotation_vector,
                  quat_multiply, quat_normalized, quat_to_dcm, quat_to_euler)
from ekf7plus import ImuPlusPipeline

FS = 200.0
DT = 1.0 / FS
G0 = 9.795502520545487
GYRO_BIAS = np.array([0.002, -0.001, 0.0015])
ACC_NOISE, GYRO_NOISE, MAG_NOISE = 0.02, 0.0008, 0.01
MAG_NAV = np.array([0.0, 1.0, -0.4])
RNG = np.random.default_rng(7)


# ---- 场景定义 ------------------------------------------------------------

def yaw_rate_a(t: float) -> float:
    if 8.0 <= t < 18.0:
        amp_deg, period = 60.0, 10.0
        return math.radians(amp_deg * 2.0 * math.pi / period
                            * math.cos(2.0 * math.pi * (t - 8.0) / period))
    return 0.0


def yaw_rate_b(t: float) -> float:
    if 8.0 <= t < 20.0:
        return math.radians(30.0)
    return 0.0


def mag_disturbance_a(t: float) -> float:
    return 5.0 if 20.0 <= t < 20.5 else 1.0


def simulate(yaw_rate, total_s: float, mag_scale=None):
    n = int(total_s * FS)
    q = quat_from_euler(math.radians(5.0), math.radians(-3.0), 0.0)
    accs, gyros, mags, qs_true = [], [], [], []
    for k in range(n):
        t = k * DT
        w_nav = np.array([0.0, 0.0, yaw_rate(t)])
        w_body = quat_to_dcm(q).T @ w_nav
        accs.append(quat_to_dcm(q).T @ np.array([0.0, 0.0, G0])
                    + RNG.normal(0.0, ACC_NOISE, 3))
        gyros.append(w_body + GYRO_BIAS + RNG.normal(0.0, GYRO_NOISE, 3))
        m = MAG_NAV * (mag_scale(t) if mag_scale else 1.0)
        mags.append(quat_to_dcm(q).T @ m + RNG.normal(0.0, MAG_NOISE, 3))
        q = quat_normalized(quat_multiply(q, quat_from_rotation_vector(w_body * DT)))
        qs_true.append(q.copy())
    return (np.array(accs), np.array(gyros), np.array(mags), np.array(qs_true))


# ---- 工具 ----------------------------------------------------------------

def dcm_to_quat(r: np.ndarray) -> np.ndarray:
    """旋转矩阵→四元数（wxyz）—— 与 ekf7 demo 相同的合成方式。"""
    tr = r[0, 0] + r[1, 1] + r[2, 2]
    if tr > 0.0:
        s = math.sqrt(tr + 1.0) * 2.0
        w, x, y, z = 0.25*s, (r[2,1]-r[1,2])/s, (r[0,2]-r[2,0])/s, (r[1,0]-r[0,1])/s
    elif r[0, 0] > r[1, 1] and r[0, 0] > r[2, 2]:
        s = math.sqrt(1.0 + r[0,0] - r[1,1] - r[2,2]) * 2.0
        w, x, y, z = (r[2,1]-r[1,2])/s, 0.25*s, (r[0,1]+r[1,0])/s, (r[0,2]+r[2,0])/s
    elif r[1, 1] > r[2, 2]:
        s = math.sqrt(1.0 + r[1,1] - r[0,0] - r[2,2]) * 2.0
        w, x, y, z = (r[0,2]-r[2,0])/s, (r[0,1]+r[1,0])/s, 0.25*s, (r[1,2]+r[2,1])/s
    else:
        s = math.sqrt(1.0 + r[2,2] - r[0,0] - r[1,1]) * 2.0
        w, x, y, z = (r[1,0]-r[0,1])/s, (r[0,2]+r[2,0])/s, (r[1,2]+r[2,1])/s, 0.25*s
    return quat_normalized(np.array([w, x, y, z]))


def wrap_pi(x: np.ndarray) -> np.ndarray:
    return (x + math.pi) % (2.0 * math.pi) - math.pi


# ---- 对比 ----------------------------------------------------------------

def run_case(name, data, focus=None):
    accs, gyros, mags, qs_true = data
    n = len(qs_true)
    base = ImuPipeline(fs=FS, work_mode=1, amode=9)
    plus = ImuPlusPipeline(fs=FS, amode=9)

    e_base = np.zeros((n, 3)); e_plus = np.zeros((n, 3))
    flag_base = np.zeros(n, dtype=int)
    bias_base = np.zeros((n, 3)); bias_plus = np.zeros((n, 3))

    for k in range(n):
        rb = base.calculate(accs[k], gyros[k], mags[k])
        rp = plus.calculate(accs[k], gyros[k], mags[k])
        et = quat_to_euler(qs_true[k])

        q_abs = quat_normalized(quat_multiply(rb["quat"],
                                              dcm_to_quat(base.rotm_install)))
        e_base[k] = np.degrees(wrap_pi(quat_to_euler(q_abs) - et))
        e_plus[k] = np.degrees(wrap_pi(quat_to_euler(rp["quat"]) - et))
        flag_base[k] = rb["motionless"]
        bias_base[k] = base.filter.gyro_in_bias + base.gyro_bias
        bias_plus[k] = rp["bias"]

    k0 = int(8.0 * FS)
    mask = np.ones(n, dtype=bool)
    mask[:k0] = False
    if focus:
        focus_mask = np.zeros(n, dtype=bool)
        focus_mask[int(focus[0] * FS):int(focus[1] * FS)] = True
        mask &= focus_mask

    def rms(e):
        return math.sqrt(float(np.mean(e[mask] ** 2)))

    print(f"\n=== {name} ===")
    print(f"评估窗：t>{8}s" + (f"，聚焦 {focus[0]}~{focus[1]}s" if focus else ""))
    print(f"{'指标':<14}{'ekf7 基线':>12}{'ekf7plus':>12}")
    rows = [
        ("roll RMS  °", rms(e_base[:, 0]), rms(e_plus[:, 0])),
        ("pitch RMS °", rms(e_base[:, 1]), rms(e_plus[:, 1])),
        ("yaw RMS   °", rms(e_base[:, 2]), rms(e_plus[:, 2])),
        ("yaw max   °", float(np.max(np.abs(e_base[mask, 2]))),
         float(np.max(np.abs(e_plus[mask, 2])))),
    ]
    for label, a, b in rows:
        print(f"{label:<14}{a:>12.3f}{b:>12.3f}")
    bb = bias_base[-1] * 1000.0
    bp = bias_plus[-1] * 1000.0
    print(f"零偏终值 mrad/s  基线 [{bb[0]:+.2f} {bb[1]:+.2f} {bb[2]:+.2f}]"
          f"   plus [{bp[0]:+.2f} {bp[1]:+.2f} {bp[2]:+.2f}]"
          f"   真值 [{GYRO_BIAS[0]*1000:+.1f} {GYRO_BIAS[1]*1000:+.1f} "
          f"{GYRO_BIAS[2]*1000:+.1f}]")

    # 静止误判率（仅运动段）
    if focus:
        seg = flag_base[int(focus[0] * FS):int(focus[1] * FS)]
        still_pct = 100.0 * float(np.mean(seg >= 3))
        print(f"基线静止检测在运动段的误判率（flag≥3，会冻结姿态）：{still_pct:.1f}%")
    return rows


def main() -> None:
    print("基线工程：", EKF7_ROOT)
    data_a = simulate(yaw_rate_a, 24.0, mag_disturbance_a)
    run_case("场景 A 设计场景（静置→往复偏航→静置 + 磁干扰突发）", data_a)
    run_case("场景 A 磁干扰段", data_a, focus=(19.5, 22.0))

    data_b = simulate(yaw_rate_b, 24.0)
    run_case("场景 B 匀速旋转 30°/s（ekf7 README 已知局限 1）", data_b,
             focus=(8.0, 20.0))

    print("\n说明：ekf7plus 是机制验证参考实现（PROPOSAL.md P1–P6），参数仅粗调；"
          "结论以机制行为为准：零偏是否被静止检测器污染、运动中姿态观测是否持续。")


if __name__ == "__main__":
    main()
