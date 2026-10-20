"""P4 —— 带恢复触发的拒绝门控（x-IMU3 recovery trigger 的移植）。

x-IMU3 固件机制（0x9D036FD0 一带）：观测违约时抑制计数器按 −9 递减，
低于恢复触发限值（×2 滞回）后重新接纳观测；连续违约期间观测被整体
丢弃，而不是逐拍抖动式拒收。

本实现的映射：
    streak   ↔ 固件 +0x6c/+0x84 抑制计数器（方向取反：正计数=违约累计）
    trigger  ↔ 固件 +0x70/+0x88 恢复触发限值
"""

from __future__ import annotations


class RejectionGate:
    """NIS 门 + 违约滞回。accept() 返回该观测是否应当被融合。"""

    def __init__(self, reject_step: int, recovery_trigger: int) -> None:
        self.reject_step = int(reject_step)          # x-IMU3 字面值 9
        self.recovery_trigger = int(recovery_trigger)
        self.streak = 0                              # 违约累计（0=正常接纳）

    def accept(self, nis: float, threshold: float) -> bool:
        """NIS 超限 → 计数 +reject_step；未超限 → 计数衰减。
        streak ≥ trigger 期间强制拒绝（滞回），跌回 0 才重新接纳。"""
        if nis > threshold:
            self.streak += self.reject_step
            return False
        if self.streak >= self.recovery_trigger:
            self.streak -= 1                         # 缓慢恢复（滞回下降沿）
            return False
        self.streak = 0
        return True

    @property
    def suppressed(self) -> bool:
        return self.streak >= self.recovery_trigger
