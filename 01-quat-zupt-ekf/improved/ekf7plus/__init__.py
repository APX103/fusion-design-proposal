"""ekf7plus — quat-zupt-ekf 的机制增强参考实现（误差状态 EKF）。

设计来源见 ../PROPOSAL.md；每个机制标注了对应的 x-IMU3 固件证据地址。
四元数约定与 ekf7 完全一致：wxyz，DCM 为 body→nav，静止时加计读 [0,0,+g]。
"""

__version__ = "0.1.0"

from .pipeline import ImuPlusPipeline  # noqa: F401
