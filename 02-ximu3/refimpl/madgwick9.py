"""x-IMU3 AhrsUpdate 的算法重建（9 轴 Madgwick），供共享数据集测试。

依据固件 0x9D036AC8 的反编译/反汇编：
  - q̇ = ½ q⊗ω − β ŝ，β = 0.5；
  - 加计 + 磁的梯度 s = Jᵀf（标准 Madgwick 9 轴展开）；
  - 初始化窗口：静置 N 样本均值作为陀螺零偏，之后逐拍扣除；
  - 观测抑制：磁方向偏差超过阈值时拒收，计数器 −9 步进、恢复触发后重接纳
    （固件的 10° 阈值 / −9 步进的简化重建；固件还含加计抑制与超量程恢复）。
本实现为算法重建，轴序/欧拉输出已对齐测试数据约定，不代表固件逐位一致。
"""

from __future__ import annotations

import math


def _norm(v):
    return math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])


def _normalize(v):
    n = _norm(v)
    return [v[0] / n, v[1] / n, v[2] / n] if n > 1e-12 else [0.0, 0.0, 0.0]


def quat_mul(a, b):
    w, x, y, z = a
    w2, x2, y2, z2 = b
    return [
        w * w2 - x * x2 - y * y2 - z * z2,
        w * x2 + x * w2 + y * z2 - z * y2,
        w * y2 - x * z2 + y * w2 + z * x2,
        w * z2 + x * y2 - y * x2 + z * w2,
    ]


def quat_from_yaw(yaw: float):
    return [math.cos(yaw / 2), 0.0, 0.0, math.sin(yaw / 2)]


def _quat_norm(q):
    n = math.sqrt(sum(v * v for v in q))
    return [v / n for v in q] if n > 1e-12 else [1.0, 0.0, 0.0, 0.0]


def _rot(q, v):
    """体→导航旋转矩阵作用于 v。"""
    w, x, y, z = q
    return [
        (1 - 2 * (y * y + z * z)) * v[0] + 2 * (x * y - w * z) * v[1]
        + 2 * (x * z + w * y) * v[2],
        2 * (x * y + w * z) * v[0] + (1 - 2 * (x * x + z * z)) * v[1]
        + 2 * (y * z - w * x) * v[2],
        2 * (x * z - w * y) * v[0] + 2 * (y * z + w * x) * v[1]
        + (1 - 2 * (x * x + y * y)) * v[2],
    ]


def _rot_t(q, v):
    """导航→体（转置）。"""
    w, x, y, z = q
    return [
        (1 - 2 * (y * y + z * z)) * v[0] + 2 * (x * y + w * z) * v[1]
        + 2 * (x * z - w * y) * v[2],
        2 * (x * y - w * z) * v[0] + (1 - 2 * (x * x + z * z)) * v[1]
        + 2 * (y * z + w * x) * v[2],
        2 * (x * z + w * y) * v[0] + 2 * (y * z - w * x) * v[1]
        + (1 - 2 * (x * x + y * y)) * v[2],
    ]


class Madgwick9:
    def __init__(self, beta: float = 0.5, init_samples: int = 200,
                 mag_gate_deg: float = 10.0, mag_ref_alpha: float = 0.02,
                 mref_warmup: int = 200) -> None:
        self.q = [1.0, 0.0, 0.0, 0.0]
        self.beta = beta
        self.init_samples = int(init_samples)
        self._gyro_sum = [0.0, 0.0, 0.0]
        self._n = 0
        self.bias = [0.0, 0.0, 0.0]
        self.mag_gate = math.radians(mag_gate_deg)
        self.mag_reject = 0
        self.m_ref_nav = None
        self.mag_alpha = mag_ref_alpha
        self.mref_warmup = int(mref_warmup)
        self._mref_n = 0

    # -- 观测门控 ---------------------------------------------------------
    def _accept_mag(self, q, mag):
        """与固件同构的抑制计数器：违约 +9，恢复期逐拍衰减。"""
        m_b = _normalize(mag)
        # 初始化后先用 1 s 让姿态收敛，再锚定参考场方向；期间不做门控。
        if self._mref_n < self.mref_warmup:
            self._mref_n += 1
            self.m_ref_nav = _normalize(_rot(q, m_b))
            self.mag_reject = 0
            return True
        m_pred = _normalize(_rot_t(q, self.m_ref_nav))
        dot = max(-1.0, min(1.0, sum(a * b for a, b in zip(m_b, m_pred))))
        angle = math.acos(dot)
        if angle > self.mag_gate:
            self.mag_reject = min(self.mag_reject + 9, 180)
        else:
            self.mag_reject = max(self.mag_reject - 1, 0)
        if self.mag_reject >= 18:
            return False
        # 接纳后缓慢更新参考方向（等效固件的参考场跟踪）
        m_nav = _rot(q, m_b)
        self.m_ref_nav = _normalize([
            (1 - self.mag_alpha) * self.m_ref_nav[i] + self.mag_alpha * m_nav[i]
            for i in range(3)])
        return True

    # -- 更新 -------------------------------------------------------------
    def update(self, gyro, acc, mag, dt):
        # 初始化窗口：静置均值 → 零偏（固件 0x9D07BFA4 的对应）
        if self._n < self.init_samples:
            for i in range(3):
                self._gyro_sum[i] += gyro[i]
            self._n += 1
            if self._n == self.init_samples:
                self.bias = [v / self._n for v in self._gyro_sum]
            return self.q

        g = [gyro[i] - self.bias[i] for i in range(3)]
        q0, q1, q2, q3 = self.q

        # q̇ = ½ q⊗ω
        qd0 = 0.5 * (-q1 * g[0] - q2 * g[1] - q3 * g[2])
        qd1 = 0.5 * (q0 * g[0] + q2 * g[2] - q3 * g[1])
        qd2 = 0.5 * (q0 * g[1] - q1 * g[2] + q3 * g[0])
        qd3 = 0.5 * (q0 * g[2] + q1 * g[1] - q2 * g[0])

        if _norm(acc) > 1e-6:
            a = _normalize(acc)
            use_mag = mag is not None and _norm(mag) > 1e-6 and \
                self._accept_mag(self.q, mag)
            if use_mag:
                m = _normalize(mag)
                # 参考磁场方向 h = q⊗m⊗q*
                hx = 2 * (m[0] * (0.5 - q2 * q2 - q3 * q3)
                          + m[1] * (q1 * q2 - q0 * q3)
                          + m[2] * (q0 * q2 + q1 * q3))
                hy = 2 * (m[0] * (q1 * q2 + q0 * q3)
                          + m[1] * (0.5 - q1 * q1 - q3 * q3)
                          + m[2] * (q2 * q3 - q0 * q1))
                hz = 2 * (m[0] * (q1 * q3 - q0 * q2)
                          + m[1] * (q2 * q3 + q0 * q1)
                          + m[2] * (0.5 - q1 * q1 - q2 * q2))
                bx = math.sqrt(hx * hx + hy * hy)
                bz = hz

                f1 = 2 * (q1 * q3 - q0 * q2) - a[0]
                f2 = 2 * (q0 * q1 + q2 * q3) - a[1]
                f3 = 2 * (0.5 - q1 * q1 - q2 * q2) - a[2]
                f4 = 2 * bx * (0.5 - q2 * q2 - q3 * q3) + 2 * bz * (q1 * q3 - q0 * q2) - m[0]
                f5 = 2 * bx * (q1 * q2 - q0 * q3) + 2 * bz * (q0 * q1 + q2 * q3) - m[1]
                f6 = 2 * bx * (q0 * q2 + q1 * q3) + 2 * bz * (0.5 - q1 * q1 - q2 * q2) - m[2]

                s0 = -2*q2*f1 + 2*q1*f2 - 2*bz*q2*f4 + (2*bz*q1 - 2*bx*q3)*f5 + 2*bx*q2*f6
                s1 = 2*q3*f1 + 2*q0*f2 - 4*q1*f3 + 2*bz*q3*f4 \
                    + (2*bx*q2 + 2*bz*q0)*f5 + (2*bx*q3 - 4*bz*q1)*f6
                s2 = -2*q0*f1 + 2*q3*f2 - 4*q2*f3 \
                    + (-4*bx*q2 - 2*bz*q0)*f4 + (2*bx*q1 + 2*bz*q3)*f5 \
                    + (2*bx*q0 - 4*bz*q2)*f6
                s3 = 2*q1*f1 + 2*q2*f2 + (-4*bx*q3 + 2*bz*q1)*f4 \
                    + (2*bz*q2 - 2*bx*q0)*f5 + 2*bx*q1*f6
            else:
                f1 = 2 * (q1 * q3 - q0 * q2) - a[0]
                f2 = 2 * (q0 * q1 + q2 * q3) - a[1]
                f3 = 2 * (0.5 - q1 * q1 - q2 * q2) - a[2]
                s0 = -2 * q2 * f1 + 2 * q1 * f2
                s1 = 2 * q3 * f1 + 2 * q0 * f2 - 4 * q1 * f3
                s2 = -2 * q0 * f1 + 2 * q3 * f2 - 4 * q2 * f3
                s3 = 2 * q1 * f1 + 2 * q2 * f2

            sn = math.sqrt(s0*s0 + s1*s1 + s2*s2 + s3*s3)
            if sn > 1e-12:
                k = self.beta / sn
                qd0 -= k * s0
                qd1 -= k * s1
                qd2 -= k * s2
                qd3 -= k * s3

        self.q = _quat_norm([q0 + qd0 * dt, q1 + qd1 * dt,
                             q2 + qd2 * dt, q3 + qd3 * dt])
        return self.q
