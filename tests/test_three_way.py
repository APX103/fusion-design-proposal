#!/usr/bin/env python3
"""三算法共享数据集测试（unittest）。

验证：
  1. 每个子目录的 run_dataset.py 能**从自己的目录独立运行**（默认路径）；
  2. 三个结果与数据集行数一致、四元数单位长度；
  3. 姿态跟踪精度在阈值内（roll/pitch/yaw RMSE、磁干扰段、尾段漂移）；
  4. 三个算法使用同一份数据、同一套评测。

运行：python3 -m unittest discover -s tests -v
"""

from __future__ import annotations

import csv
import math
import os
import subprocess
import sys
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "testdata", "imu_scenario.csv")
SUMMARY = os.path.join(ROOT, "testdata", "results_summary.csv")

CASES = [
    ("01-quat-zupt-ekf", os.path.join(ROOT, "01-quat-zupt-ekf"),
     os.path.join(ROOT, "01-quat-zupt-ekf", "results", "ekf7.csv")),
    ("02-ximu3", os.path.join(ROOT, "02-ximu3"),
     os.path.join(ROOT, "02-ximu3", "results", "ximu3.csv")),
    ("03-atom-imu", os.path.join(ROOT, "03-atom-imu"),
     os.path.join(ROOT, "03-atom-imu", "results", "atom.csv")),
]


def rows_of(path):
    with open(path, newline="") as fh:
        return list(csv.DictReader(fh))


class ThreeWayTest(unittest.TestCase):
    metrics = {}

    @classmethod
    def setUpClass(cls):
        if not os.path.exists(DATA):
            subprocess.run([sys.executable,
                            os.path.join(ROOT, "testdata", "generate_dataset.py")],
                           check=True)
        # 每个算法从自己的目录、用默认参数独立运行
        for name, cwd, out in CASES:
            subprocess.run([sys.executable, "run_dataset.py"], cwd=cwd,
                           check=True, stdout=subprocess.DEVNULL)
            if not os.path.exists(out):
                raise RuntimeError(f"{name}: missing {out}")
        # 统一评测
        results = [f"{name}={out}" for name, _, out in CASES]
        subprocess.run([sys.executable,
                        os.path.join(ROOT, "testdata", "evaluate.py"),
                        "--data", DATA, "--results", *results],
                       check=True, stdout=subprocess.DEVNULL)
        for r in rows_of(SUMMARY):
            cls.metrics[r["algorithm"]] = {k: float(v) for k, v in r.items()
                                           if k != "algorithm"}

    # -- 数据与输出完整性 --------------------------------------------------
    def test_01_dataset(self):
        rows = rows_of(DATA)
        self.assertGreater(len(rows), 10000)
        t = [float(r["t"]) for r in rows]
        self.assertAlmostEqual(1.0 / (t[1] - t[0]), 200.0, places=3)
        for r in rows[:100]:
            q = [float(r[k]) for k in ("qw", "qx", "qy", "qz")]
            self.assertAlmostEqual(sum(v * v for v in q), 1.0, places=6)

    def test_02_outputs_complete_and_normalized(self):
        n = len(rows_of(DATA))
        for name, _, out in CASES:
            res = rows_of(out)
            self.assertEqual(len(res), n, f"{name}: row count")
            worst = 0.0
            for r in res:
                q = [float(r[k]) for k in ("qw", "qx", "qy", "qz")]
                worst = max(worst, abs(sum(v * v for v in q) - 1.0))
            self.assertLess(worst, 1e-6, f"{name}: quaternion norm drift")

    # -- 精度阈值（基于当前合成数据；真机需重新整定） ----------------------
    def test_03_roll_pitch_tracking(self):
        for name in self.metrics:
            m = self.metrics[name]
            self.assertLess(m["roll_rmse_deg"], 1.5, f"{name}: roll")
            self.assertLess(m["pitch_rmse_deg"], 1.5, f"{name}: pitch")

    def test_04_yaw_tracking(self):
        for name in self.metrics:
            m = self.metrics[name]
            self.assertLess(m["yaw_rmse_deg"], 5.0, f"{name}: yaw")
            self.assertLess(m["yaw_disturb_deg"], 4.0, f"{name}: yaw 干扰段")

    def test_05_yaw_drift_tail(self):
        for name in self.metrics:
            m = self.metrics[name]
            self.assertLess(abs(m["yaw_drift_deg_per_min"]), 8.0,
                            f"{name}: tail drift")

    def test_06_cross_algorithm_consistency(self):
        # 三者 roll/pitch 都应接近；03 无磁，yaw 允许与 01/02 有差异
        rolls = [self.metrics[n]["roll_rmse_deg"] for n in self.metrics]
        self.assertLess(max(rolls) - min(rolls), 0.5)

    @classmethod
    def tearDownClass(cls):
        print("\n=== 三算法共享数据集结果 ===")
        print(f"{'算法':<14}{'roll':>8}{'pitch':>8}{'yaw':>8}"
              f"{'干扰段':>9}{'尾段漂移':>11}")
        for name, m in cls.metrics.items():
            print(f"{name:<14}{m['roll_rmse_deg']:>8.3f}"
                  f"{m['pitch_rmse_deg']:>8.3f}{m['yaw_rmse_deg']:>8.3f}"
                  f"{m['yaw_disturb_deg']:>9.3f}"
                  f"{m['yaw_drift_deg_per_min']:>11.3f}")


if __name__ == "__main__":
    unittest.main(verbosity=2)
