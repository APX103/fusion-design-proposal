"""P1 对应 —— 初始化窗口状态机（x-IMU3 0x9D07BFA4 的移植）。

x-IMU3 机制：窗口状态 0→1（准静态确认后开始累积）→2（计满 N 拍，
累加器 ×1/N 取均值）。陀螺均值→零偏，加计/磁计均值→初始姿态。
ekf7 的 auto_calibration.py + navigation_filter 阶段 0~3s 是同一思想的
更细分版本；这里保留 x-IMU3 的三态结构以便对照。
"""

from __future__ import annotations

import math

import numpy as np

from .quaternion import quat_from_euler, quat_normalized


class InitWindow:
    STATE_IDLE, STATE_ACCUM, STATE_DONE = 0, 1, 2

    def __init__(self, p) -> None:
        self.p = p
        self.state = self.STATE_IDLE
        self.n_target = int(p.fs * p.init_window_s)
        self.count = 0
        self.acc_sum = np.zeros(3)
        self.gyro_sum = np.zeros(3)
        self.mag_sum = np.zeros(3)
        self.acc_max = None
        self.acc_min = None
        self.gyro_max = None
        self.gyro_min = None
        # 结果
        self.gyro_bias = None
        self.q0 = None

    def step(self, acc: np.ndarray, gyro: np.ndarray,
             mag: np.ndarray | None) -> bool:
        """喂一拍；返回 True 表示本拍完成估计（state→2）。"""
        if self.state == self.STATE_DONE:
            return False

        # 准静态峰峰值监测（ekf7 auto_cal 同源判据）
        if self.acc_max is None:
            self.acc_max = acc.copy(); self.acc_min = acc.copy()
            self.gyro_max = gyro.copy(); self.gyro_min = gyro.copy()
        else:
            self.acc_max = np.maximum(self.acc_max, acc)
            self.acc_min = np.minimum(self.acc_min, acc)
            self.gyro_max = np.maximum(self.gyro_max, gyro)
            self.gyro_min = np.minimum(self.gyro_min, gyro)

        quasi_static = (
            np.all(self.gyro_max - self.gyro_min < self.p.init_gyro_pp)
            and np.all(self.acc_max - self.acc_min < self.p.init_acc_pp))

        if not quasi_static:               # 峰峰值突破 → 锚点重置（x-IMU3/ekf7 同款）
            self.state = self.STATE_IDLE
            self.count = 0
            self.acc_sum[:] = 0; self.gyro_sum[:] = 0; self.mag_sum[:] = 0
            self.acc_max = acc.copy(); self.acc_min = acc.copy()
            self.gyro_max = gyro.copy(); self.gyro_min = gyro.copy()
            return False

        if self.state == self.STATE_IDLE:
            self.state = self.STATE_ACCUM

        self.acc_sum += acc
        self.gyro_sum += gyro
        if mag is not None:
            self.mag_sum += mag
        self.count += 1

        if self.count >= self.n_target:
            # AhrsInitialiseWindow_Step（0x9D07BFA4）：累加器 ×= 1/N
            self.gyro_bias = self.gyro_sum / self.count
            acc_mean = self.acc_sum / self.count
            mag_mean = self.mag_sum / self.count if mag is not None else None
            self.q0 = self._initial_attitude(acc_mean, mag_mean)
            self.state = self.STATE_DONE
            return True
        return False

    @staticmethod
    def _initial_attitude(acc_mean: np.ndarray,
                          mag_mean: np.ndarray | None) -> np.ndarray:
        """加计调平（roll/pitch）+ 磁航向（若有磁），ENU/同 ekf7 欧拉约定。"""
        g = float(np.linalg.norm(acc_mean))
        if g < 1e-6:
            return np.array([1.0, 0.0, 0.0, 0.0])
        ax, ay, az = acc_mean / g
        # 静止时 f_body = Rᵀ[0,0,g] → roll = atan2(ay, az), pitch = -asin(ax)
        roll = math.atan2(ay, az)
        pitch = -math.asin(max(-1.0, min(1.0, ax)))
        yaw = 0.0
        if mag_mean is not None:
            # 简化：调平后的磁航向（未做全倾斜补偿，窗口期姿态已小）
            cy, sy = math.cos(roll), math.sin(roll)
            cp, sp = math.cos(pitch), math.sin(pitch)
            # R_body->nav 的转置把磁从体系转到"水平系"
            mx = mag_mean[0] * cp + mag_mean[1] * sy * sp + mag_mean[2] * cy * sp
            myn = mag_mean[1] * cy - mag_mean[2] * sy
            yaw = math.atan2(mx, myn)
        return quat_normalized(quat_from_euler(roll, pitch, yaw))
