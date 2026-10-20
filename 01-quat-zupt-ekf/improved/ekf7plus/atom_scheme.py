"""P8 —— ATOM-IMU 恒温方案移植（抄自 xrobot-org/atom-sdk，见 ATOM_IMU_逆向笔记.md）。

固件证据（STM32G431KB，固件 v25-12-28，已解密）：
  * set_temp 钳位 10–80°C（0x0800EA7C / 0x0800EE9E）
  * 目标温度参数 "imu_target_temp"，每颗 IMU 独立绑定
  * 温度稳定性判据：环形缓冲均值 + 平均绝对偏差 < 0.13°C（FUN_0800F444）
  * 不稳定时标定直接拒绝："Temperature is not stable!"（0x0800EC50）
  * 标定流程：预热 10 min → 多姿态静置 ≥1 min/姿态 → 保存零偏/安装（README）

本模块提供可运行的仿真/集成组件：
  ThermalPlant           一阶热模型（加热功率、散热、环境温度）
  PIController           恒温 PI（抗积分饱和，输出 0–1 占空比）
  TempStabilityDetector  与固件同构的稳定性判据（阈值默认 0.13°C）
  MultiPoseCalibration   多姿态静态标定（陀螺零偏 + 加计 12 参数 LS）
  AtomThermalScheme      预热→稳定→标定→就绪 状态机
"""

from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np


# ---------------------------------------------------------------------------
# 硬件与控制器模型
# ---------------------------------------------------------------------------

class ThermalPlant:
    """一阶热模型：C·dT/dt = P_heat − (T − T_amb)/R。

    C [J/K]、R [K/W]、Pmax [W] 按小板 + 加热电阻的典型量级取默认值，
    仅用于算法验证；实机应辨识。
    """

    def __init__(self, t0: float = 20.0, c_thermal: float = 3.0,
                 r_thermal: float = 15.0, p_max: float = 3.0) -> None:
        self.T = float(t0)
        self.C = float(c_thermal)
        self.R = float(r_thermal)
        self.Pmax = float(p_max)

    def step(self, duty: float, dt: float, t_amb: float) -> float:
        p = max(0.0, min(1.0, duty)) * self.Pmax
        dT = (p - (self.T - t_amb) / self.R) / self.C
        self.T += dT * dt
        return self.T


class PIController:
    """恒温 PI；目标温度钳位与固件一致（10–80°C）。"""

    def __init__(self, target: float, kp: float = 0.06,
                 ki: float = 0.0015) -> None:
        self.target = float(np.clip(target, 10.0, 80.0))
        self.kp, self.ki = kp, ki
        self.integ = 0.0

    def update(self, t_meas: float, dt: float) -> float:
        err = self.target - t_meas
        self.integ += err * dt
        duty = self.kp * err + self.ki * self.integ
        if duty > 1.0:                 # 抗积分饱和
            duty = 1.0
            self.integ -= err * dt * 0.5
        elif duty < 0.0:
            duty = 0.0
            self.integ -= err * dt * 0.5
        return duty


# ---------------------------------------------------------------------------
# 温度稳定性判据（与固件 FUN_0800F444 同构）
# ---------------------------------------------------------------------------

class TempStabilityDetector:
    """环形缓冲均值 + 平均绝对偏差；MAD < threshold 视为稳定。

    固件常量：threshold = 0.13（float @0x0800F5A8）。
    固件只判短期波动；工程上再加 |mean − target| < near_target 以免
    升温途中误判（固件靠"预热 10 分钟"解决同一问题）。
    """

    def __init__(self, window: int = 50, threshold: float = 0.13,
                 near_target: float = 0.2) -> None:
        self.window = int(window)
        self.threshold = float(threshold)
        self.near_target = float(near_target)
        self.buf: list[float] = []
        self.first_stable = False

    def update(self, t_meas: float, target: float | None = None):
        self.buf.append(float(t_meas))
        if len(self.buf) > self.window:
            self.buf.pop(0)
        mean = float(np.mean(self.buf))
        mad = float(np.mean(np.abs(np.array(self.buf) - mean)))
        near = True if target is None else abs(mean - target) < self.near_target
        stable = (len(self.buf) >= self.window
                  and mad < self.threshold and near)
        if stable and not self.first_stable:
            self.first_stable = True
        return stable, mean, mad


# ---------------------------------------------------------------------------
# 多姿态静态标定
# ---------------------------------------------------------------------------

@dataclass
class CalibrationResult:
    gyro_bias: np.ndarray
    acc_M: np.ndarray
    acc_b: np.ndarray
    residual: float


@dataclass
class MultiPoseCalibration:
    """多姿态静置标定。

    陀螺：所有姿态静置样本均值 = 零偏（静止时真值为 0）。
    加计：f_b = M·g_nav + b，12 个未知量，最少 4 个姿态；用最小二乘。
    """
    poses: list = field(default_factory=list)   # (acc_mean, gyro_mean, g_nav)

    def add_pose(self, acc_samples: np.ndarray, gyro_samples: np.ndarray,
                 g_nav: np.ndarray) -> None:
        self.poses.append((np.mean(acc_samples, axis=0),
                           np.mean(gyro_samples, axis=0),
                           np.asarray(g_nav, dtype=float)))

    def solve(self) -> CalibrationResult:
        if len(self.poses) < 4:
            raise ValueError("need >=4 poses")
        gyro_bias = np.mean([p[1] for p in self.poses], axis=0)
        # 线性最小二乘：f = (g^T ⊗ I3) vec(M) + b
        A, y = [], []
        for acc_m, _, g in self.poses:
            blk = np.zeros((3, 12))
            for r in range(3):
                blk[r, r * 3:(r + 1) * 3] = g
                blk[r, 9 + r] = 1.0
            A.append(blk)
            y.append(acc_m)
        A = np.vstack(A)
        y = np.concatenate(y)
        x, *_ = np.linalg.lstsq(A, y, rcond=None)
        M = x[:9].reshape(3, 3)
        b = x[9:12]
        residual = float(np.sqrt(np.mean((A @ x - y) ** 2)))
        return CalibrationResult(gyro_bias, M, b, residual)


# ---------------------------------------------------------------------------
# 状态机
# ---------------------------------------------------------------------------

class AtomThermalScheme:
    """预热 → 稳定判定 → 多姿态标定 → 就绪。"""

    WARMUP, STABILIZE, CALIBRATE, READY = 0, 1, 2, 3

    def __init__(self, target: float = 45.0, stability_window: int = 50,
                 threshold: float = 0.13, samples_per_pose: int = 200) -> None:
        self.target = float(np.clip(target, 10.0, 80.0))
        self.pid = PIController(self.target)
        self.detector = TempStabilityDetector(stability_window, threshold)
        self.cal = MultiPoseCalibration()
        self.samples_per_pose = samples_per_pose
        self.state = self.WARMUP
        self.result: CalibrationResult | None = None
        self._pose_acc: list[np.ndarray] = []
        self._pose_gyro: list[np.ndarray] = []
        self.time_to_stable: float | None = None
        self.elapsed = 0.0

    def step(self, acc: np.ndarray, gyro: np.ndarray, t_meas: float,
             g_nav: np.ndarray, dt: float) -> str:
        """返回状态名；CALIBRATE 期间按姿态累积样本。"""
        self.elapsed += dt
        duty = self.pid.update(t_meas, dt)          # 记录/驱动外部热模型
        self.duty = duty
        stable, mean, _ = self.detector.update(t_meas, self.target)

        if self.state == self.WARMUP:
            if stable:
                self.state = self.STABILIZE
                self.time_to_stable = self.elapsed
            return "WARMUP"

        if self.state == self.STABILIZE:
            if stable:
                self.state = self.CALIBRATE
                return "CALIBRATE"
            return "STABILIZE"

        if self.state == self.CALIBRATE:
            self._pose_acc.append(np.asarray(acc, dtype=float))
            self._pose_gyro.append(np.asarray(gyro, dtype=float))
            if len(self._pose_acc) >= self.samples_per_pose:
                self.cal.add_pose(np.array(self._pose_acc),
                                  np.array(self._pose_gyro), g_nav)
                self._pose_acc, self._pose_gyro = [], []
                if len(self.cal.poses) >= 4:
                    self.result = self.cal.solve()
                    self.state = self.READY
                    return "READY"
            return "CALIBRATE"

        return "READY"
