"""P1+P2+P7 —— 误差状态 EKF 核心（9 状态；P7 开启时 12 状态）。

名义状态：q（wxyz, body→nav）、v（ENU）、b0（陀螺零偏常数项）。
误差状态：δx = [δθ(3), δv(3), δb0(3)]，右乘扰动 q_true = q ⊗ δq(δθ)。

P7（温度）：开启后增加斜率状态 k（3）——
    有效零偏 b(T) = b0 + k·(T − T_ref)
    误差状态扩展为 [δθ, δv, δb0, δk]（12 维），F 中
    δθ̇ 对 δk 的耦合项为 −(T−T_ref)·I。
    温度激励（开机自热、环境变化）使 b0 与 k 可分离，等效于在线学习每台
    设备的 b(T) 曲线，替代出厂温箱标定或硬件恒温。

对比 ekf7（全量式 7 状态，导航系四元数直接进协方差）：
- 四元数天然归一，无需逐拍修正；
- F 稀疏（δb/δk 行 ≈ 单位阵），数值条件好；
- 零偏在状态内（P1）：与静止检测器解耦。
"""

from __future__ import annotations

import numpy as np

from .quaternion import quat_from_rotation_vector, quat_multiply, quat_normalized, quat_to_dcm, skew


class ErrorStateEkf:
    def __init__(self, q: np.ndarray, v: np.ndarray, bg: np.ndarray,
                 p0_theta: float, p0_vel: float, p0_bias: float,
                 gravity: float = 9.795502520545487,
                 thermal: bool = False, temp_ref: float = 25.0,
                 p0_slope: float = 1e-3) -> None:
        self.q = q.copy()                 # 名义：姿态
        self.v = v.copy()                 # 名义：导航系速度
        self.bg = bg.copy()               # 名义：零偏常数项 b0（P1）
        self.bk = np.zeros(3)             # 名义：零偏温度斜率 k（P7）
        self.gravity = gravity
        self.thermal = bool(thermal)
        self.temp_ref = float(temp_ref)
        self.n = 12 if self.thermal else 9

        diag = np.concatenate([
            np.full(3, p0_theta), np.full(3, p0_vel), np.full(3, p0_bias),
            np.full(3, p0_slope) if self.thermal else np.empty(0),
        ])
        self.P = np.diag(diag)

    # -- P7：有效零偏 --------------------------------------------------------

    def bias_at(self, temp: float | None) -> np.ndarray:
        if not self.thermal or temp is None:
            return self.bg
        return self.bg + self.bk * (temp - self.temp_ref)

    # -- 预测 -------------------------------------------------------------

    def predict(self, gyro: np.ndarray, accel: np.ndarray, dt: float,
                gyro_arw: float, accel_vrw: float, bias_rw: float,
                gyro_range: float, temp: float | None = None,
                slope_rw: float = 0.0) -> None:
        """机械编排 + 误差状态传播。dt 逐拍可变（P5）。"""
        dtemp = 0.0
        if self.thermal and temp is not None:
            dtemp = temp - self.temp_ref
        w = gyro - self.bias_at(temp)

        # 超量程：限幅 + 本拍姿态噪声放大（x-IMU3 +0x1c 的保守版）
        overrange = float(np.linalg.norm(w)) > gyro_range
        if overrange:
            w = w * (gyro_range / float(np.linalg.norm(w)))

        R = quat_to_dcm(self.q)
        dq = quat_from_rotation_vector(w * dt)
        self.q = quat_normalized(quat_multiply(self.q, dq))
        R_new = quat_to_dcm(self.q)
        self.v = self.v + (R_new @ accel
                           - np.array([0.0, 0.0, self.gravity])) * dt

        n = self.n
        Fc = np.zeros((n, n))
        Fc[0:3, 0:3] = -skew(w)            # δθ̇ = -[w×]δθ - δb
        Fc[0:3, 6:9] = -np.eye(3)
        if self.thermal:
            Fc[0:3, 9:12] = -dtemp * np.eye(3)   # P7：b(T)=b0+kΔT 的耦合
        Fc[3:6, 0:3] = -R @ skew(accel)    # δv̇ = -R[f×]δθ
        Phi = np.eye(n) + Fc * dt

        q_theta = (gyro_arw * np.sqrt(dt)) ** 2
        q_vel = (accel_vrw * np.sqrt(dt)) ** 2
        q_bias = (bias_rw * np.sqrt(dt)) ** 2
        q_slope = (slope_rw * np.sqrt(dt)) ** 2 if self.thermal else 0.0
        if overrange:
            q_theta *= 100.0
        diag = [q_theta] * 3 + [q_vel] * 3 + [q_bias] * 3
        if self.thermal:
            diag += [q_slope] * 3
        Qd = np.diag(diag)

        # macOS Accelerate 的 sgemm 会对全有限输入误报 FP 警告；屏蔽误报，
        # 保留下方真实非有限值断言。
        with np.errstate(divide="ignore", over="ignore", invalid="ignore"):
            self.P = Phi @ self.P @ Phi.T + Qd
        self.P = 0.5 * (self.P + self.P.T)
        if not np.all(np.isfinite(self.P)):
            raise FloatingPointError("EKF covariance became non-finite in predict")

    # -- 更新 -------------------------------------------------------------

    def update(self, H: np.ndarray, r: np.ndarray, R: np.ndarray) -> None:
        """误差状态更新 + 注入回名义状态 + 一阶复位。"""
        S = H @ self.P @ H.T + R
        K = self.P @ H.T @ np.linalg.inv(S)
        dx = K @ r

        self.q = quat_normalized(quat_multiply(
            self.q, quat_from_rotation_vector(dx[0:3])))
        self.v = self.v + dx[3:6]
        self.bg = self.bg + dx[6:9]
        if self.thermal:
            self.bk = self.bk + dx[9:12]

        I_KH = np.eye(self.n) - K @ H
        with np.errstate(divide="ignore", over="ignore", invalid="ignore"):
            self.P = I_KH @ self.P @ I_KH.T + K @ R @ K.T
        self.P = 0.5 * (self.P + self.P.T)
        if not np.all(np.isfinite(self.P)):
            raise FloatingPointError("EKF covariance became non-finite in update")

    @staticmethod
    def nis(r: np.ndarray, H: np.ndarray, P: np.ndarray, R: np.ndarray) -> float:
        S = H @ P @ H.T + R
        return float(r @ np.linalg.solve(S, r))
