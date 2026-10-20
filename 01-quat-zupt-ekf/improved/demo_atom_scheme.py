"""demo_atom_scheme.py —— "抄" ATOM-IMU 恒温方案的端到端对比。

三个方案（同一颗 IMU 的仿真，100 Hz，480 s）：
  ① 无恒温：电子自热 20→38°C；开机 60 s 时室温标定（无稳定门控）；
  ② 恒温 + 稳定后标定（ATOM 方案）：目标 45°C，PI 加热；
     温度平均绝对偏差 < 0.13°C 后开始多姿态标定（固件同款判据）；
  ③ 恒温但不等稳定就标定：演示"预热"为什么必要。

指标：
  * 达到稳定耗时（②）
  * 标定后零偏误差（相对标定时刻的真实零偏）
  * 末段积分零漂（°/min）——相当于 ATOM 的 `test` 命令输出

运行：python3 demo_atom_scheme.py
"""

from __future__ import annotations

import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from ekf7plus.atom_scheme import (AtomThermalScheme, MultiPoseCalibration,  # noqa: E402
                                  ThermalPlant)

FS = 100.0
DT = 1.0 / FS
T_TOTAL = 480.0
T_AMB = 20.0
T_REF = 25.0
G0 = 9.795502520545487
B0_TRUE = np.array([0.002, -0.001, 0.0015])       # rad/s
K_TRUE = np.array([0.0006, -0.0005, 0.0008])      # rad/s/°C
GYRO_NOISE, ACC_NOISE = 0.0008, 0.02
RNG = np.random.default_rng(23)

POSES = [
    np.array([0.0, 0.0, G0]),          # 平放
    np.array([0.0, 0.0, -G0]),         # 倒置
    np.array([G0, 0.0, 0.0]),          # 侧面
    np.array([0.0, G0, 0.0]),          # 另一侧
]
SAMPLES_PER_POSE = 200                 # 2 s @ 100 Hz（README 建议 ≥1 min，仿真缩短）
CURRENT_T = T_AMB                       # _measure() 使用的当前温度


def true_bias(t_meas: float) -> np.ndarray:
    return B0_TRUE + K_TRUE * (t_meas - T_REF)


def _measure(pose_idx: int):
    gyro = true_bias(CURRENT_T) + RNG.normal(0.0, GYRO_NOISE, 3)
    acc = POSES[pose_idx % len(POSES)] + RNG.normal(0.0, ACC_NOISE, 3)
    return acc, gyro


def _drift(gyro_bias_est: np.ndarray, t_end: float) -> float:
    """末段积分零漂：标定零偏与末端真实零偏的 z 分量差（°/min）。"""
    return float((gyro_bias_est[2] - true_bias(t_end)[2])
                 * (180.0 / math.pi) * 60.0)


def run_oven_scheme(early: bool = False) -> dict:
    """②/③：ATOM 恒温状态机。"""
    global CURRENT_T
    plant = ThermalPlant(t0=T_AMB)
    scheme = AtomThermalScheme(target=45.0, samples_per_pose=SAMPLES_PER_POSE)
    bias_est = None
    bias_err = None
    cal_t = None
    duty = 0.0

    for k in range(int(T_TOTAL * FS)):
        t = k * DT
        CURRENT_T = plant.step(duty, DT, T_AMB)     # 上一拍占空比
        pose_idx = len(scheme.cal.poses)
        acc, gyro = _measure(pose_idx)

        if early and t >= 60.0 and scheme.state < AtomThermalScheme.CALIBRATE:
            scheme.state = AtomThermalScheme.CALIBRATE

        state = scheme.step(acc, gyro, CURRENT_T, POSES[pose_idx % len(POSES)], DT)
        duty = scheme.duty

        if scheme.result is not None and bias_est is None:
            bias_est = scheme.result.gyro_bias.copy()
            bias_err = float(np.linalg.norm(bias_est - true_bias(CURRENT_T))) * 1000.0
            cal_t = t

    return dict(time_to_stable=scheme.time_to_stable, cal_t=cal_t,
                bias_err=bias_err, drift=_drift(bias_est, plant.T),
                T_end=plant.T, residual=scheme.result.residual)


def run_no_oven() -> dict:
    """①：无恒温，自热 20→38°C，60 s 时室温标定。"""
    global CURRENT_T
    cal = MultiPoseCalibration()
    bias_est = None
    bias_err = None
    cal_t = None
    pose_idx = 0
    pose_acc, pose_gyro = [], []
    T_end = 38.0

    for k in range(int(T_TOTAL * FS)):
        t = k * DT
        CURRENT_T = 38.0 - 18.0 * math.exp(-t / 180.0)
        acc, gyro = _measure(pose_idx)

        if bias_est is None and 60.0 <= t < 60.0 + 4 * SAMPLES_PER_POSE * DT:
            pose_acc.append(acc)
            pose_gyro.append(gyro)
            if len(pose_acc) >= SAMPLES_PER_POSE:
                cal.add_pose(np.array(pose_acc), np.array(pose_gyro),
                             POSES[pose_idx % len(POSES)])
                pose_acc, pose_gyro = [], []
                pose_idx += 1
                if len(cal.poses) == 4:
                    res = cal.solve()
                    bias_est = res.gyro_bias
                    bias_err = float(np.linalg.norm(
                        bias_est - true_bias(CURRENT_T))) * 1000.0
                    cal_t = t

    return dict(time_to_stable=None, cal_t=cal_t, bias_err=bias_err,
                drift=_drift(bias_est, T_end), T_end=T_end, residual=0.0)


def show(name: str, r: dict) -> None:
    print(f"\n=== {name} ===")
    tts = "—" if r["time_to_stable"] is None else f"{r['time_to_stable']:.1f} s"
    print(f"温度稳定耗时        {tts}")
    print(f"标定完成时刻        {r['cal_t']:.1f} s（末端温度 {r['T_end']:.1f}°C）")
    print(f"标定后零偏误差      {r['bias_err']:.2f} mrad/s")
    print(f"末段积分零漂        {r['drift']:+.2f} °/min")


def main() -> None:
    print("ATOM-IMU 恒温方案移植验证（合成数据，100 Hz，480 s）")
    print("真值零偏 b(T)=b0+k(T−25)，k=[0.6,−0.5,0.8] mrad/s/°C")
    show("① 无恒温（自热 20→38°C，60 s 室温标定）", run_no_oven())
    show("② 恒温 45°C + 稳定后标定（ATOM 方案）", run_oven_scheme())
    show("③ 恒温 45°C 但 60 s 就标定（不等稳定）", run_oven_scheme(early=True))
    print("\n解读：")
    print("- ①③ 的共同问题：标定温度 ≠ 使用温度，零偏随 T 漂移；")
    print("- ② 用与固件同构的 0.13°C 稳定判据卡住标定入口，零漂回到 0.4°/min 量级（实测 −0.39）；")
    print("- 若不想加硬件，ekf7-plus 的 P7（温度-零偏联合估计）可在软件侧逼近该效果。")


if __name__ == "__main__":
    main()
