#!/usr/bin/env python3
"""与 C 版 test_main.c 完全相同的确定性场景，输出同格式 CSV。"""

from __future__ import annotations

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "reconstructed", "python"))

from atomimu_re.thermal import (AtomScheme, ThermalPlant,  # noqa: E402
                                _gauss_solve)  # noqa: F401  (保持与 C 的对照)

DT = 0.1
STEPS = 5000
T_AMB = 20.0
TARGET = 45.0
WINDOW = 50
THRESHOLD = 0.13
NEAR_TARGET = 0.2
SAMPLES = 200
G0 = 9.795502520545487

POSES = [
    [0.0, 0.0, G0],
    [0.0, 0.0, -G0],
    [G0, 0.0, 0.0],
    [0.0, G0, 0.0],
]
GYRO = [0.017, -0.011, 0.018]
TRUE_M = [[1.001, 0.002, 0.0], [0.0, 0.999, 0.001], [0.001, 0.0, 1.002]]
TRUE_B = [0.01, -0.02, 0.03]


def main() -> None:
    plant = ThermalPlant(t0=T_AMB, c_thermal=3.0, r_thermal=15.0, p_max=3.0)
    scheme = AtomScheme(target=TARGET, stability_window=WINDOW,
                        threshold=THRESHOLD, near_target=NEAR_TARGET,
                        samples_per_pose=SAMPLES)
    duty = 0.0
    ready_printed = False

    for k in range(STEPS):
        pose = scheme.cal.n
        if pose >= 4:
            pose = 3
        t = k * DT
        temp = plant.step(duty, DT, T_AMB)
        g = POSES[pose]
        accm = [TRUE_M[r][0] * g[0] + TRUE_M[r][1] * g[1]
                + TRUE_M[r][2] * g[2] + TRUE_B[r] for r in range(3)]
        st = scheme.step(accm, GYRO, temp, g, DT)
        duty = scheme.duty

        if k % 100 == 0:
            print(f"{k},{temp:.6f},{duty:.6f},{st}")

        if st == scheme.READY and not ready_printed:
            ready_printed = True
            bias = scheme.result[0]
            print(f"ready,{t:.6f},{scheme.time_to_stable:.6f},"
                  f"{bias[0]:.6f},{bias[1]:.6f},{bias[2]:.6f}")

    bias, M, b, res = scheme.result
    parts = ["solve"] + [f"{v:.6f}" for v in bias]
    parts += [f"{M[r][c]:.6f}" for r in range(3) for c in range(3)]
    parts += [f"{b[0]:.6f}", f"{b[1]:.6f}", f"{b[2]:.6f}", f"{res:.6f}"]
    print(",".join(parts))


if __name__ == "__main__":
    main()
