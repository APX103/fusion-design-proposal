"""ATOM-IMU 恒温/标定算法的 Python 参考实现（与 C99 版逐函数对应）。

算法依据（固件 v25-12-28，已解密；证据地址见 ../../README.md）：
  * set_temp 目标温度钳位 10–80°C（0x0800EA7C / 0x0800EE9E）
  * 温度稳定性 = 环形缓冲均值 + 平均绝对偏差 < 0.13°C（FUN_0800F444）
  * 不稳定时标定被拒绝（0x0800EC50）
  * 4 姿态静置标定（README）

纯 Python（math 即可），便于与 C 版做逐拍差分验证。
"""

from __future__ import annotations

import math

STAB_WINDOW_MAX = 64
CAL_MAX_POSES = 8


class ThermalPlant:
    """一阶热模型：C·dT/dt = P_heat − (T − T_amb)/R。仅用于验证。"""

    def __init__(self, t0=20.0, c_thermal=3.0, r_thermal=15.0, p_max=3.0):
        self.t = float(t0)
        self.c = float(c_thermal)
        self.r = float(r_thermal)
        self.pmax = float(p_max)

    def step(self, duty, dt, t_amb):
        duty = 0.0 if duty < 0.0 else (1.0 if duty > 1.0 else duty)
        p = duty * self.pmax
        self.t += (p - (self.t - t_amb) / self.r) / self.c * dt
        return self.t


class PIController:
    """恒温 PI（抗积分饱和）；目标钳位与固件一致：10–80°C。"""

    def __init__(self, target, kp=0.06, ki=0.0015):
        self.target = min(80.0, max(10.0, float(target)))
        self.kp = float(kp)
        self.ki = float(ki)
        self.integ = 0.0
        self.duty = 0.0

    def update(self, t_meas, dt):
        err = self.target - t_meas
        self.integ += err * dt
        duty = self.kp * err + self.ki * self.integ
        if duty > 1.0:
            duty = 1.0
            self.integ -= err * dt * 0.5
        elif duty < 0.0:
            duty = 0.0
            self.integ -= err * dt * 0.5
        self.duty = duty
        return duty


class TempStabilityDetector:
    """环形缓冲均值 + 平均绝对偏差；与固件判据同构（阈值 0.13°C）。

    固件只判短期波动；这里额外要求 |mean − target| < near_target，
    等价于固件"预热 10 分钟"所保证的条件。
    """

    def __init__(self, window=50, threshold=0.13, near_target=0.2):
        assert window <= STAB_WINDOW_MAX
        self.window = int(window)
        self.threshold = float(threshold)
        self.near_target = float(near_target)
        self.buf = [0.0] * self.window
        self.n = 0
        self.head = 0
        self.first_stable = False

    def update(self, t_meas, target):
        self.buf[self.head] = t_meas
        self.head = (self.head + 1) % self.window
        if self.n < self.window:
            self.n += 1
        count = self.n
        mean = sum(self.buf[:count]) / count
        mad = sum(abs(v - mean) for v in self.buf[:count]) / count
        near = abs(mean - target) < self.near_target
        stable = count >= self.window and mad < self.threshold and near
        if stable and not self.first_stable:
            self.first_stable = True
        return stable, mean, mad


def _gauss_solve(a, b, n):
    """高斯消元（列主元），a 为 n×n 行列表，b 为长度 n 的列表，原地求解。"""
    for col in range(n):
        piv = max(range(col, n), key=lambda r: abs(a[r][col]))
        if abs(a[piv][col]) < 1e-12:
            return False
        if piv != col:
            a[col], a[piv] = a[piv], a[col]
            b[col], b[piv] = b[piv], b[col]
        inv = 1.0 / a[col][col]
        for r in range(col + 1, n):
            f = a[r][col] * inv
            if f == 0.0:
                continue
            for c in range(col, n):
                a[r][c] -= f * a[col][c]
            b[r] -= f * b[col]
    x = [0.0] * n
    for r in range(n - 1, -1, -1):
        s = b[r]
        for c in range(r + 1, n):
            s -= a[r][c] * x[c]
        x[r] = s / a[r][r]
    return x


class MultiPoseCalibration:
    """多姿态静置标定：陀螺零偏均值 + 加计 12 参数最小二乘。

    加计模型：f_b = M·g_nav + b（行主序 9 + 3 = 12 个未知量）。
    """

    def __init__(self):
        self.n = 0
        self.acc = []
        self.gyr = []
        self.g = []

    def add_pose(self, acc_mean, gyro_mean, g_nav):
        if self.n >= CAL_MAX_POSES:
            return False
        self.acc.append([float(v) for v in acc_mean])
        self.gyr.append([float(v) for v in gyro_mean])
        self.g.append([float(v) for v in g_nav])
        self.n += 1
        return True

    def solve(self):
        """返回 (gyro_bias[3], M[3][3], b[3], residual)；数据不足返回 None。"""
        if self.n < 4:
            return None
        bias = [sum(p[k] for p in self.gyr) / self.n for k in range(3)]
        # 正规方程 AᵀA x = Aᵀy，A 每行对应一个姿态的一轴
        ata = [[0.0] * 12 for _ in range(12)]
        aty = [0.0] * 12
        for i in range(self.n):
            g = self.g[i]
            y = self.acc[i]
            for r in range(3):
                row = [0.0] * 12
                row[r * 3:r * 3 + 3] = g
                row[9 + r] = 1.0
                for c in range(12):
                    if row[c] == 0.0:
                        continue
                    aty[c] += row[c] * y[r]
                    for d in range(12):
                        if row[d] != 0.0:
                            ata[c][d] += row[c] * row[d]
        x = _gauss_solve(ata, aty, 12)
        if x is False:
            return None
        m = [[x[r * 3 + c] for c in range(3)] for r in range(3)]
        b = x[9:12]
        # 残差（用原始行重算）
        ss = 0.0
        cnt = 0
        for i in range(self.n):
            g = self.g[i]
            y = self.acc[i]
            for r in range(3):
                pred = sum(m[r][c] * g[c] for c in range(3)) + b[r]
                ss += (pred - y[r]) ** 2
                cnt += 1
        return bias, m, b, math.sqrt(ss / cnt)


class AtomScheme:
    WARMUP, STABILIZE, CALIBRATE, READY = 0, 1, 2, 3

    def __init__(self, target=45.0, stability_window=50, threshold=0.13,
                 near_target=0.2, samples_per_pose=200):
        self.pid = PIController(target)
        self.stab = TempStabilityDetector(stability_window, threshold, near_target)
        self.cal = MultiPoseCalibration()
        self.samples_per_pose = int(samples_per_pose)
        self.state = self.WARMUP
        self.elapsed = 0.0
        self.time_to_stable = None
        self.result = None
        self._acc = [0.0, 0.0, 0.0]
        self._gyro = [0.0, 0.0, 0.0]
        self._cnt = 0

    def step(self, acc, gyro, t_meas, g_nav, dt):
        """返回状态；CALIBRATE 期间累积样本，集满一姿态后加入标定。"""
        self.elapsed += dt
        duty = self.pid.update(t_meas, dt)
        stable, mean, _ = self.stab.update(t_meas, self.pid.target)

        if self.state == self.WARMUP:
            if stable:
                self.state = self.STABILIZE
                self.time_to_stable = self.elapsed
            return self.state

        if self.state == self.STABILIZE:
            if stable:
                self.state = self.CALIBRATE
                self._acc = [0.0, 0.0, 0.0]
                self._gyro = [0.0, 0.0, 0.0]
                self._cnt = 0
            return self.state

        if self.state == self.CALIBRATE:
            for k in range(3):
                self._acc[k] += acc[k]
                self._gyro[k] += gyro[k]
            self._cnt += 1
            if self._cnt >= self.samples_per_pose:
                n = float(self._cnt)
                self.cal.add_pose([v / n for v in self._acc],
                                  [v / n for v in self._gyro], g_nav)
                self._acc = [0.0, 0.0, 0.0]
                self._gyro = [0.0, 0.0, 0.0]
                self._cnt = 0
                if self.cal.n >= 4:
                    self.result = self.cal.solve()
                    self.state = self.READY
            return self.state

        return self.state

    @property
    def duty(self):
        return self.pid.duty
