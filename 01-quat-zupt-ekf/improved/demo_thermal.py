"""demo_thermal.py —— P7 温度-零偏联合估计 vs 无补偿 vs 硬件恒温（理想炉）。

背景（证据见 PROPOSAL.md P7）：
- x-IMU3 固件只**上报**温度（5 Hz），标定参数无温度系数；手册明说精度
  只在标定温度有效 —— 商业产品也未做温漂补偿；
- quat-zupt-ekf 全仓库无任何温度处理。

场景（100 Hz，120 s）：
  T(t) = 25 + 20·(1−e^(−t/45)) + 0.8·sin(2πt/90)   （开机自热 + 环境波动）
  真值零偏 b(T) = b0 + k·(T−T_ref)，k = [0.6, −0.5, 0.8] mrad/s/°C
  0–15 s 静置初始化；15–120 s 往复偏航 ±60°；
  45–75 s 磁干扰（场 ×5，磁航向观测被门控拒绝）——
  这段时间零偏变化只能靠模型预测，是 P7 的决胜段。

对比：
  1) 无温度补偿：零偏状态照常估计，但不知道 T 的作用；
  2) P7 软件补偿：零偏模型 b0 + k·(T−T_ref)，k 在线学习；
  3) 理想恒温炉：把 T 固定在 45°C（硬件方案的上限参照）。

运行：python3 demo_thermal.py
"""

from __future__ import annotations

import math
import sys
import os

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
EKF7_ROOT = os.path.normpath(os.path.join(HERE, ".."))          # 01 根目录（含 ekf7/）
if not os.path.isdir(os.path.join(EKF7_ROOT, "ekf7")):
    EKF7_ROOT = os.path.normpath(os.path.join(HERE, "..", "..", "quat-zupt-ekf"))
for pth in (HERE, EKF7_ROOT):
    if pth not in sys.path:
        sys.path.insert(0, pth)

from ekf7plus import ImuPlusPipeline
from ekf7plus.params import Params
from ekf7plus.quaternion import (quat_from_euler, quat_from_rotation_vector,
                                 quat_multiply, quat_normalized, quat_to_dcm)
from ekf7.quaternion import quat_to_euler  # 统一欧拉约定

FS = 100.0
DT = 1.0 / FS
T_TOTAL = 120.0
G0 = 9.795502520545487
T_REF = 25.0
B0_TRUE = np.array([0.002, -0.001, 0.0015])       # rad/s
K_TRUE = np.array([0.0006, -0.0005, 0.0008])      # rad/s/°C
ACC_NOISE, GYRO_NOISE, MAG_NOISE = 0.02, 0.0008, 0.01
MAG_NAV = np.array([0.0, 1.0, -0.4])
RNG = np.random.default_rng(11)


def temperature(t: float, oven: bool = False) -> float:
    if oven:
        return 45.0
    return 25.0 + 20.0 * (1.0 - math.exp(-t / 45.0)) \
        + 0.8 * math.sin(2.0 * math.pi * t / 90.0)


def yaw_rate(t: float) -> float:
    if 15.0 <= t < 120.0:
        amp_deg, period = 60.0, 10.0
        return math.radians(amp_deg * 2.0 * math.pi / period
                            * math.cos(2.0 * math.pi * (t - 15.0) / period))
    return 0.0


def mag_scale(t: float) -> float:
    return 5.0 if 45.0 <= t < 75.0 else 1.0


def simulate(oven: bool = False):
    n = int(T_TOTAL * FS)
    q = quat_from_euler(math.radians(5.0), math.radians(-3.0), 0.0)
    accs, gyros, mags, temps, qs, biases = [], [], [], [], [], []
    for k in range(n):
        t = k * DT
        T = temperature(t, oven)
        b_eff = B0_TRUE + K_TRUE * (T - T_REF)
        w_nav = np.array([0.0, 0.0, yaw_rate(t)])
        w_body = quat_to_dcm(q).T @ w_nav
        accs.append(quat_to_dcm(q).T @ np.array([0.0, 0.0, G0])
                    + RNG.normal(0.0, ACC_NOISE, 3))
        gyros.append(w_body + b_eff + RNG.normal(0.0, GYRO_NOISE, 3))
        mags.append(quat_to_dcm(q).T @ (MAG_NAV * mag_scale(t))
                    + RNG.normal(0.0, MAG_NOISE, 3))
        temps.append(T)
        biases.append(b_eff)
        q = quat_normalized(quat_multiply(q, quat_from_rotation_vector(w_body * DT)))
        qs.append(q.copy())
    return (np.array(accs), np.array(gyros), np.array(mags),
            np.array(temps), np.array(qs), np.array(biases))


def wrap_pi(x):
    return (x + math.pi) % (2.0 * math.pi) - math.pi


def run_case(name: str, data, thermal: bool):
    accs, gyros, mags, temps, qs, biases = data
    p = Params()
    p.thermal_enabled = thermal
    p.temp_ref = T_REF
    pipe = ImuPlusPipeline(fs=FS, amode=9, param=p)

    n = len(qs)
    yaw_err = np.zeros(n)
    bias_err = np.zeros(n)
    for k in range(n):
        out = pipe.calculate(accs[k], gyros[k], mags[k], temp=temps[k])
        yaw_err[k] = math.degrees(wrap_pi(quat_to_euler(out["quat"])[2]
                                          - quat_to_euler(qs[k])[2]))
        bias_err[k] = float(np.linalg.norm(out["bias"] - biases[k])) * 1000.0

    m = int(15.0 * FS)                    # 初始化完成后
    out_mask = slice(int(45.0 * FS), int(75.0 * FS))
    rms = lambda a: math.sqrt(float(np.mean(a ** 2)))
    slope = pipe.ekf.bk * 1000.0 if pipe.ekf is not None else np.zeros(3)
    k_err = float(np.linalg.norm(pipe.ekf.bk - K_TRUE)) * 1000.0 \
        if (thermal and pipe.ekf is not None) else float("nan")

    print(f"\n=== {name} ===")
    print(f"yaw RMS 全程            {rms(yaw_err[m:]):8.3f} °")
    print(f"yaw RMS 磁干扰段(45-75s) {rms(yaw_err[out_mask]):8.3f} °")
    print(f"yaw max 磁干扰段         {np.max(np.abs(yaw_err[out_mask])):8.3f} °")
    print(f"末端有效零偏误差        {bias_err[-1]:8.2f} mrad/s")
    if thermal:
        print(f"斜率估计 k [mrad/s/°C]  [{slope[0]:+.3f} {slope[1]:+.3f} {slope[2]:+.3f}]"
              f"   真值 [{K_TRUE[0]*1000:+.3f} {K_TRUE[1]*1000:+.3f} {K_TRUE[2]*1000:+.3f}]"
              f"   误差 {k_err:.3f}")
    return rms(yaw_err[m:]), rms(yaw_err[out_mask]), bias_err[-1]


def main() -> None:
    data = simulate(oven=False)
    data_oven = simulate(oven=True)

    print("温度剖面：25→45°C 开机自热 + 环境波动；磁干扰段 45–75 s")
    run_case("① 无温度补偿（T 变化被当作普通慢漂）", data, thermal=False)
    run_case("② P7 软件补偿（b0 + k·ΔT 在线估计）", data, thermal=True)
    run_case("③ 理想恒温炉（T≡45°C，硬件方案上限参照）", data_oven, thermal=False)

    print("\n解读：")
    print("- 磁干扰段内磁航向被拒，yaw 只能靠陀螺积分；①拿不到温度信息，"
          "零偏随 T 的变化只能靠滞后估计；②用 T 预测零偏变化，漂移显著更小；")
    print("- ③说明硬件恒温能到什么水平，但代价是功耗/预热/体积；"
          "软件补偿以纯计算代价换来接近（但不等同）的稳定性。")
    print("- 两者可叠加：恒温把 T 压成常数后，②的斜率状态自动失效但不添乱。")


if __name__ == "__main__":
    main()
