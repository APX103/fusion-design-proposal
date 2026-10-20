"""参数 —— 默认值为 200 Hz 档粗整定，注释标注每项的 x-IMU3 证据来源。"""

from __future__ import annotations

import math


class Params:
    def __init__(self) -> None:
        # 采样与导航
        self.fs = 200.0
        self.g0 = 9.795502520545487      # 与 ekf7 相同
        self.amode = 9                    # 6=无磁 9=磁航向融合
        self.gyro_range = math.pi * 1.2   # P6/超量程：|w| 超限视为饱和（x-IMU3 +0x1c）

        # 过程噪声（连续时间）
        self.gyro_arw = 0.0008            # rad/sqrt(s)，角随机游走
        self.accel_vrw = 0.02             # m/s/sqrt(s)，速度随机游走
        self.bias_rw = 2e-5               # rad/s^1.5，零偏随机游走（P1：小而>0）

        # 观测噪声
        self.sigma_grav_unit = 0.03       # P3：单位重力矢量观测噪声（无量纲）
        self.sigma_zupt = 0.05            # m/s
        self.mag_hdg_err = 0.1745         # rad^2（与 ekf7 mag_hdg_error 一致）

        # 门控
        self.nis_chi2_grav = 11.35        # P3/P4：χ²(3, 0.99)
        self.nis_chi2_hdg = 6.63          # χ²(1, 0.99) × ekf7 mag_hdg_gate≈5 的折中
        self.mag_abs_gate_deg = 15.0      # 绝对航向门控（x-IMU3 为 10°；留 5° 余量）
        self.reject_step = 9              # P4：违约步进 −9（x-IMU3 0x9D036FD0 字面值）
        self.recovery_trigger = 18        # P4：恢复触发（×2 滞回）
        self.acc_norm_gate = 0.15         # P3：|‖f‖-g|/g 自适应前置检查

        # 初始化窗口（P1 对应 x-IMU3 0x9D07BFA4 状态机）
        self.init_window_s = 2.0          # 窗口长度 N = fs × init_window_s
        self.init_gyro_pp = 0.02          # 准静态陀螺峰峰值 rad/s（ekf7 auto_cal 同源）
        self.init_acc_pp = 0.10           # 准静态加计峰峰值 m/s²
        self.ramp_n = int(2.0 * self.fs)  # P6：对准后增益斜坡拍数（R ×4→×1）

        # 初始协方差
        self.p0_theta = math.radians(2.0) ** 2
        self.p0_vel = 0.5 ** 2
        self.p0_bias = math.radians(0.5) ** 2

        # P7：温度-零偏联合估计（默认关闭，保持与 9 状态路径兼容）
        self.thermal_enabled = False
        self.temp_ref = 25.0              # 参考温度 °C（通常取标定/开机温度）
        self.p0_slope = 1e-3              # 斜率初值方差 (rad/s/°C)²
        self.bias_temp_rw = 2e-5          # 斜率随机游走 (rad/s/°C)/√s

        # ZUPT 静止判据（只控制 ZUPT 开关——见 PROPOSAL P1）
        self.zupt_gyro_norm = 0.02        # rad/s
        self.zupt_acc_dev = 0.15          # m/s²（‖f‖ 偏离 g 的容差）
        self.zupt_hold_s = 0.3            # 判据持续时长

    @staticmethod
    def create_default() -> "Params":
        return Params()
