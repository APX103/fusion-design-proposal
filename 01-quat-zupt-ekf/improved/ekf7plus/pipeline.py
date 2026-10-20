"""P5 —— 端到端管线：初始化窗口 → ES-EKF（逐拍可选 dt）。

接口与 ekf7.ImuPipeline 对齐（多一个可选 dt 参数），便于同数据对比：
    out = pipe.calculate(acc, gyro, mag, dt=None)
"""

from __future__ import annotations

import math

import numpy as np

from .esekf import ErrorStateEkf
from .init_window import InitWindow
from .observations import Observers
from .params import Params
from .quaternion import quat_to_dcm


class ImuPlusPipeline:
    def __init__(self, fs: float = 200.0, amode: int = 9,
                 param: Params | None = None) -> None:
        self.p = param or Params()
        self.p.fs = fs
        self.p.amode = amode
        self.dt_default = 1.0 / fs
        self._reset()

    def _reset(self) -> None:
        self.init = InitWindow(self.p)
        self.ekf: ErrorStateEkf | None = None
        self.obs: Observers | None = None
        self.gyro_filt = np.zeros(3)
        self.acc_filt = np.zeros(3)
        self.filt_init = False
        self.last_temp: float | None = None
        # ZUPT 静止判据保持器（只控制 ZUPT，不驱动零偏 —— PROPOSAL P1）
        self.zupt_hold = 0.0
        self.mag_decl = 0.0
        self.last_status = {"grav": "-", "zupt": "-", "hdg": "-"}

    # -- 输出 --------------------------------------------------------------

    def get_attitude(self) -> np.ndarray:
        return self.ekf.q if self.ekf is not None else np.array([1.0, 0.0, 0.0, 0.0])

    def get_velocity(self) -> np.ndarray:
        return self.ekf.v if self.ekf is not None else np.zeros(3)

    def get_gyro_bias(self, temp: float | None = None) -> np.ndarray:
        """P7：返回当前温度下的有效零偏（未开温度估计时即常数项）。"""
        return self.ekf.bias_at(temp) if self.ekf is not None else np.zeros(3)

    # -- 主步进 ------------------------------------------------------------

    def calculate(self, acc_raw, gyro_raw, mag_raw=None, dt: float | None = None,
                  temp: float | None = None):
        """temp（°C）可选：P7 开启时用于 b(T)=b0+k·(T−T_ref) 与斜率估计。"""
        acc = np.asarray(acc_raw, dtype=float).copy()
        gyro = np.asarray(gyro_raw, dtype=float).copy()
        self.last_temp = temp
        mag = (np.asarray(mag_raw, dtype=float).copy()
               if mag_raw is not None else None)
        dt = float(dt) if dt is not None else self.dt_default

        # 输入低通（与 ekf7 同款一阶）
        if not self.filt_init:
            self.acc_filt = acc.copy(); self.gyro_filt = gyro.copy()
            self.filt_init = True
        else:
            self.acc_filt += 0.1 * (acc - self.acc_filt)
            self.gyro_filt += 0.1 * (gyro - self.gyro_filt)

        # 阶段 1：初始化窗口（x-IMU3 0x9D07BFA4 状态机）
        if self.ekf is None:
            done = self.init.step(self.acc_filt, self.gyro_filt, mag)
            if done:
                self.ekf = ErrorStateEkf(self.init.q0, np.zeros(3),
                                         self.init.gyro_bias.copy(),
                                         self.p.p0_theta, self.p.p0_vel,
                                         self.p.p0_bias, self.p.g0,
                                         thermal=self.p.thermal_enabled,
                                         temp_ref=self.p.temp_ref,
                                         p0_slope=self.p.p0_slope)
                self.obs = Observers(self.p)
                # 磁偏角置 0：与 ekf7 demo 同样不做绝对航向标定（锚定语义）
                if mag is not None:
                    self.mag_decl = 0.0
            self.last_status = {"grav": "init", "zupt": "init", "hdg": "init"}
            return self._result(dt)

        # 阶段 2：预测（P5：dt 逐拍可变）
        self.ekf.predict(self.gyro_filt, self.acc_filt, dt,
                         self.p.gyro_arw, self.p.accel_vrw, self.p.bias_rw,
                         self.p.gyro_range, temp=temp,
                         slope_rw=self.p.bias_temp_rw)

        # P3：重力矢量观测 —— 每拍尝试，门控滞回决定融合与否
        self.last_status["grav"] = self.obs.gravity_update(self.ekf, self.acc_filt)

        # ZUPT：准静态判据保持 zupt_hold_s 后启用
        gn = float(np.linalg.norm(self.gyro_filt))
        an = float(np.linalg.norm(self.acc_filt))
        if (gn < self.p.zupt_gyro_norm
                and abs(an - self.p.g0) < self.p.zupt_acc_dev):
            self.zupt_hold += dt
        else:
            self.zupt_hold = 0.0
        if self.zupt_hold >= self.p.zupt_hold_s:
            self.last_status["zupt"] = self.obs.zupt_update(self.ekf)
        else:
            self.last_status["zupt"] = "-"

        # 磁航向（九轴）
        if self.p.amode == 9 and mag is not None:
            self.last_status["hdg"] = self.obs.heading_update(
                self.ekf, mag, self.mag_decl)
        else:
            self.last_status["hdg"] = "-"

        return self._result(dt)

    def _result(self, dt: float) -> dict:
        q = self.get_attitude()
        return {
            "quat": q.copy(),
            "vel": self.get_velocity().copy(),
            "bias": self.get_gyro_bias(self.last_temp).copy(),
            "bias_slope": (self.ekf.bk.copy() if self.ekf is not None
                           else np.zeros(3)),
            "dt": dt,
            "status": dict(self.last_status),
        }


# 欧拉角输出统一走 ekf7 的约定：demo 用 ekf7.quaternion.quat_to_euler 评估双方。
def quat_to_euler_ekf7(q: np.ndarray) -> np.ndarray:  # pragma: no cover
    from ekf7.quaternion import quat_to_euler  # 仅 demo 使用
    return quat_to_euler(q)
