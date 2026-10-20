"""P3 —— 观测模型（误差状态式）：重力矢量 / ZUPT / 磁航向。

重力矢量观测是 x-IMU3 的核心机制移植：加计每拍参与（AhrsUpdate 对象 +0x48
存样本），仅在创新超限时被抑制计数器逐出（+0x6c/+0x70）。ekf7 原工程运动中
没有任何直接姿态观测，本模块补上这一环。
"""

from __future__ import annotations

import math

import numpy as np

from .esekf import ErrorStateEkf
from .gating import RejectionGate
from .quaternion import quat_to_dcm, skew


class Observers:
    def __init__(self, p) -> None:
        self.p = p
        self.gate_grav = RejectionGate(p.reject_step, p.recovery_trigger)
        self.gate_hdg = RejectionGate(p.reject_step, p.recovery_trigger)
        self.ramp_left = p.ramp_n          # P6：初始化增益斜坡剩余拍数

    # -- P3：单位重力矢量观测（运动中持续修正俯仰/横滚） ------------------

    def gravity_update(self, ekf: ErrorStateEkf, f_body: np.ndarray) -> str:
        """z = f/‖f‖，h = Rᵀ·ẑ_nav，H_att = [h×]（右乘扰动推导见 PROPOSAL）。"""
        norm = float(np.linalg.norm(f_body))
        if norm < 1e-6:
            return "skip"
        # 前置自适应：比力模值偏离重力过大 → 线加速度污染，提高 R（不直接拒）
        dev = abs(norm - self.p.g0) / self.p.g0
        if dev > self.p.acc_norm_gate:
            return "skip"                  # x-IMU3 的 rejection 前置语义

        R = quat_to_dcm(ekf.q)
        h = R.T @ np.array([0.0, 0.0, 1.0])
        z = f_body / norm
        r = z - h

        H = np.zeros((3, ekf.n))
        H[0:3, 0:3] = skew(h)              # ∂h/∂δθ = [h×]

        # P6：斜坡期 R 放大 ×4→×1（x-IMU3 初始化斜坡的保守对应）
        ramp = 1.0
        if self.ramp_left > 0:
            ramp = 1.0 + 3.0 * (self.ramp_left / self.p.ramp_n)
        Rm = (self.p.sigma_grav_unit * ramp) ** 2 * np.eye(3) \
             * (1.0 + 4.0 * dev)           # 偏离越大越不信任

        nis = ErrorStateEkf.nis(r, H, ekf.P, Rm)
        if not self.gate_grav.accept(nis, self.p.nis_chi2_grav):
            return "rejected"

        ekf.update(H, r, Rm)
        if self.ramp_left > 0:
            self.ramp_left -= 1
        return "fused"

    # -- ZUPT（静止期速度置零伪观测） --------------------------------------

    def zupt_update(self, ekf: ErrorStateEkf) -> str:
        H = np.zeros((3, ekf.n))
        H[0:3, 3:6] = np.eye(3)
        r = -ekf.v
        Rm = (self.p.sigma_zupt) ** 2 * np.eye(3)
        nis = ErrorStateEkf.nis(r, H, ekf.P, Rm)
        if nis > 3.0 * self.p.nis_chi2_grav:   # ZUPT 门放宽（与 ekf7 语义一致）
            return "rejected"
        ekf.update(H, r, Rm)
        return "fused"

    # -- 磁航向观测（1 维；解析 H 用右乘扰动推导） -------------------------

    def heading_update(self, ekf: ErrorStateEkf, m_body: np.ndarray,
                       declination: float = 0.0) -> str:
        """innov = wrap(heading(R q · m) − declination)。
        δψ = (−mN·e_row + mE·n_row)/(mE²+mN²) · δθ，其中 e/n_row 取自 −R[m×]。"""
        R = quat_to_dcm(ekf.q)
        m_nav = R @ m_body
        mE, mN = m_nav[0], m_nav[1]
        h2 = mE * mE + mN * mN
        if h2 < 1e-8:
            return "skip"

        nu = math.atan2(mE, mN) - declination
        nu = (nu + math.pi) % (2.0 * math.pi) - math.pi

        H = np.zeros((1, ekf.n))
        neg = -(R @ skew(m_body))          # δm = −R[m×]δθ
        H[0, 0:3] = (-mN * neg[0, :] + mE * neg[1, :]) / h2

        Rm = np.array([[self.p.mag_hdg_err]])
        nis = ErrorStateEkf.nis(np.array([nu]), H, ekf.P, Rm)
        if not self.gate_hdg.accept(nis, self.p.nis_chi2_hdg):
            return "rejected"
        ekf.update(H, np.array([nu]), Rm)
        return "fused"
