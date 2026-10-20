"""四元数工具 —— 与 ekf7.quaternion 完全同约定（wxyz；DCM=body→nav）。"""

from __future__ import annotations

import math

import numpy as np


def quat_multiply(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    w, x, y, z = a
    w2, x2, y2, z2 = b
    return np.array([
        w * w2 - x * x2 - y * y2 - z * z2,
        w * x2 + x * w2 + y * z2 - z * y2,
        w * y2 - x * z2 + y * w2 + z * x2,
        w * z2 + x * y2 - y * x2 + z * w2,
    ])


def quat_normalized(q: np.ndarray) -> np.ndarray:
    n = math.sqrt(float(q @ q))
    return q / n if n > 1e-12 else np.array([1.0, 0.0, 0.0, 0.0])


def quat_to_dcm(q: np.ndarray) -> np.ndarray:
    """体→导航旋转矩阵（与 ekf7.quaternion.quat_to_dcm 逐元素一致）。"""
    w, x, y, z = q
    w2, x2, y2, z2 = w * w, x * x, y * y, z * z
    xy, xz, yz = x * y, x * z, y * z
    wx, wy, wz = w * x, w * y, w * z
    return np.array([
        [w2 + x2 - y2 - z2, 2.0 * (xy - wz), 2.0 * (xz + wy)],
        [2.0 * (xy + wz), w2 - x2 + y2 - z2, 2.0 * (yz - wx)],
        [2.0 * (xz - wy), 2.0 * (yz + wx), w2 - x2 - y2 + z2],
    ])


def quat_from_rotation_vector(rv: np.ndarray) -> np.ndarray:
    n2 = float(rv @ rv)
    if n2 < 1e-8:
        w = 1.0 - n2 * (0.125 - n2 / 384.0)
        s = 0.5 - n2 * (1.0 / 48.0 - n2 / 3840.0)
    else:
        n = math.sqrt(n2)
        w = math.cos(n * 0.5)
        s = math.sin(n * 0.5) / n
    return np.array([w, s * rv[0], s * rv[1], s * rv[2]])


def quat_from_euler(phi: float, theta: float, psi: float) -> np.ndarray:
    """与 ekf7.quaternion.quat_from_euler 完全一致（同一欧拉约定）。"""
    cr, sr = math.cos(phi * 0.5), math.sin(phi * 0.5)
    cp, sp = math.cos(theta * 0.5), math.sin(theta * 0.5)
    cy, sy = math.cos(psi * 0.5), math.sin(psi * 0.5)
    return np.array([
        cr * cp * cy + sr * sp * sy,
        sr * cp * cy - cr * sp * sy,
        cr * sp * cy + sr * cp * sy,
        cr * cp * sy - sr * sp * cy,
    ])


def skew(v: np.ndarray) -> np.ndarray:
    x, y, z = v
    return np.array([[0.0, -z, y], [z, 0.0, -x], [-y, x, 0.0]])
