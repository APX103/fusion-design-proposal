"""ATOM-IMU AhrsUpdate 的算法重建（6 轴 Madgwick）。

依据固件 0x08013480 的反编译：
  - q̇ = ½ q⊗ω − β ŝ，只用加速度计构造目标函数（无磁力计，固件无磁驱动）；
  - 陀螺零偏：专用状态，每拍扣除（固件 +0xD8..+0xE0，由标定/线程维护）；
  - 初始化：前 3000 拍 β × 50（常量 0x080138C0 = 50.0f）快速收敛。
本实现用「静置 N 样本均值」作为零偏（对应 ATOM 的温态标定结果），
轴序/欧拉输出已对齐测试数据约定，不代表固件逐位一致。
"""

from __future__ import annotations

import math


def _norm(v):
    return math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])


def _quat_norm(q):
    n = math.sqrt(sum(v * v for v in q))
    return [v / n for v in q] if n > 1e-12 else [1.0, 0.0, 0.0, 0.0]


class Madgwick6:
    def __init__(self, beta: float = 0.5, init_samples: int = 200,
                 gain_boost: float = 50.0, boost_samples: int = 3000) -> None:
        self.q = [1.0, 0.0, 0.0, 0.0]
        self.beta = beta
        self.init_samples = int(init_samples)
        self._gyro_sum = [0.0, 0.0, 0.0]
        self._n = 0
        self.bias = [0.0, 0.0, 0.0]
        self.gain_boost = gain_boost
        self.boost_samples = int(boost_samples)
        self.tick = 0

    def update(self, gyro, acc, dt):
        # 初始化窗口：静置均值 → 零偏（对应温态标定的结果）
        if self._n < self.init_samples:
            for i in range(3):
                self._gyro_sum[i] += gyro[i]
            self._n += 1
            if self._n == self.init_samples:
                self.bias = [v / self._n for v in self._gyro_sum]
            return self.q

        g = [gyro[i] - self.bias[i] for i in range(3)]
        q0, q1, q2, q3 = self.q

        qd0 = 0.5 * (-q1 * g[0] - q2 * g[1] - q3 * g[2])
        qd1 = 0.5 * (q0 * g[0] + q2 * g[2] - q3 * g[1])
        qd2 = 0.5 * (q0 * g[1] - q1 * g[2] + q3 * g[0])
        qd3 = 0.5 * (q0 * g[2] + q1 * g[1] - q2 * g[0])

        if _norm(acc) > 1e-6:
            an = _norm(acc)
            ax, ay, az = acc[0] / an, acc[1] / an, acc[2] / an
            f1 = 2 * (q1 * q3 - q0 * q2) - ax
            f2 = 2 * (q0 * q1 + q2 * q3) - ay
            f3 = 2 * (0.5 - q1 * q1 - q2 * q2) - az
            s0 = -2 * q2 * f1 + 2 * q1 * f2
            s1 = 2 * q3 * f1 + 2 * q0 * f2 - 4 * q1 * f3
            s2 = -2 * q0 * f1 + 2 * q3 * f2 - 4 * q2 * f3
            s3 = 2 * q1 * f1 + 2 * q2 * f2
            sn = math.sqrt(s0*s0 + s1*s1 + s2*s2 + s3*s3)
            if sn > 1e-12:
                beta = self.beta
                if self.tick < self.boost_samples:   # 前 3000 拍 ×50
                    beta *= self.gain_boost
                k = beta / sn
                qd0 -= k * s0
                qd1 -= k * s1
                qd2 -= k * s2
                qd3 -= k * s3

        self.tick += 1
        self.q = _quat_norm([q0 + qd0 * dt, q1 + qd1 * dt,
                             q2 + qd2 * dt, q3 + qd3 * dt])
        return self.q
