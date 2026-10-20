/* madgwick.c — 9 轴 Madgwick 梯度下降 AHRS（float）。
 *
 * 算法与 x-IMU3 固件 0x9D036AC8 同源（固件为内联展开 + 定点优化）。
 * 这里用标准矩阵形式（目标函数 f 与雅可比 J），便于阅读与算力对比。
 * 仅依赖 math.h。
 */
#include <math.h>

#include "madgwick.h"

static float norm3(const float v[3])
{
    return sqrtf(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
}

static void normalize3(float v[3])
{
    float n = norm3(v);
    if (n > 1e-9f) { v[0] /= n; v[1] /= n; v[2] /= n; }
}

static void quat_normalize(float q[4])
{
    float n = sqrtf(q[0]*q[0] + q[1]*q[1] + q[2]*q[2] + q[3]*q[3]);
    if (n > 1e-9f) { q[0] /= n; q[1] /= n; q[2] /= n; q[3] /= n; }
}

static void gyro_integrate(float q[4], const float g[3], float dt)
{
    float q0=q[0], q1=q[1], q2=q[2], q3=q[3];
    float gx=g[0], gy=g[1], gz=g[2];
    float qd0 = 0.5f*(-q1*gx - q2*gy - q3*gz);
    float qd1 = 0.5f*( q0*gx + q2*gz - q3*gy);
    float qd2 = 0.5f*( q0*gy - q1*gz + q3*gx);
    float qd3 = 0.5f*( q0*gz + q1*gy - q2*gx);
    q[0] = q0 + qd0*dt; q[1] = q1 + qd1*dt;
    q[2] = q2 + qd2*dt; q[3] = q3 + qd3*dt;
    quat_normalize(q);
}

/* q=(w,x,y,z)，右乘体坐标系角速度；a: m/s²，m: 任意单位。 */
void madgwick_update(float q[4], const float gyro[3], const float acc[3],
                     const float mag[3], float dt, float beta)
{
    float a[3] = {acc[0], acc[1], acc[2]};
    float m[3] = {mag[0], mag[1], mag[2]};
    const int use_mag = norm3(m) > 1e-3f;

    if (norm3(a) < 1e-3f) {                 /* 无加计：纯陀螺 */
        gyro_integrate(q, gyro, dt);
        return;
    }
    normalize3(a);
    if (use_mag) normalize3(m);

    float q0=q[0], q1=q[1], q2=q[2], q3=q[3];

    /* 地磁参考方向：h = q ⊗ m ⊗ q* */
    float hx = 2.0f*(m[0]*(0.5f - q2*q2 - q3*q3)
                   + m[1]*(q1*q2 - q0*q3)
                   + m[2]*(q0*q2 + q1*q3));
    float hy = 2.0f*(m[0]*(q1*q2 + q0*q3)
                   + m[1]*(0.5f - q1*q1 - q3*q3)
                   + m[2]*(q2*q3 - q0*q1));
    float hz = 2.0f*(m[0]*(q1*q3 - q0*q2)
                   + m[1]*(q2*q3 + q0*q1)
                   + m[2]*(0.5f - q1*q1 - q2*q2));
    float bx = sqrtf(hx*hx + hy*hy);
    float bz = hz;

    /* 目标函数 f（6×1） */
    float f1 = 2.0f*(q1*q3 - q0*q2) - a[0];
    float f2 = 2.0f*(q0*q1 + q2*q3) - a[1];
    float f3 = 2.0f*(0.5f - q1*q1 - q2*q2) - a[2];
    float f4 = 0.0f, f5 = 0.0f, f6 = 0.0f;
    if (use_mag) {
        f4 = 2.0f*bx*(0.5f - q2*q2 - q3*q3) + 2.0f*bz*(q1*q3 - q0*q2) - m[0];
        f5 = 2.0f*bx*(q1*q2 - q0*q3) + 2.0f*bz*(q0*q1 + q2*q3) - m[1];
        f6 = 2.0f*bx*(q0*q2 + q1*q3) + 2.0f*bz*(0.5f - q1*q1 - q2*q2) - m[2];
    }

    /* 梯度 s = Jᵀ·f（J 为 6×4 解析雅可比） */
    float s0 = -2.0f*q2*f1 + 2.0f*q1*f2
             - 2.0f*bz*q2*f4
             + (2.0f*bz*q1 - 2.0f*bx*q3)*f5
             + 2.0f*bx*q2*f6;
    float s1 =  2.0f*q3*f1 + 2.0f*q0*f2 - 4.0f*q1*f3
             + 2.0f*bz*q3*f4
             + (2.0f*bx*q2 + 2.0f*bz*q0)*f5
             + (2.0f*bx*q3 - 4.0f*bz*q1)*f6;
    float s2 = -2.0f*q0*f1 + 2.0f*q3*f2 - 4.0f*q2*f3
             + (-4.0f*bx*q2 - 2.0f*bz*q0)*f4
             + (2.0f*bx*q1 + 2.0f*bz*q3)*f5
             + (2.0f*bx*q0 - 4.0f*bz*q2)*f6;
    float s3 =  2.0f*q1*f1 + 2.0f*q2*f2
             + (-4.0f*bx*q3 + 2.0f*bz*q1)*f4
             + (2.0f*bz*q2 - 2.0f*bx*q0)*f5
             + 2.0f*bx*q1*f6;

    float sn = sqrtf(s0*s0 + s1*s1 + s2*s2 + s3*s3);
    if (sn > 1e-9f) { s0/=sn; s1/=sn; s2/=sn; s3/=sn; }

    /* q̇ = ½q⊗ω − β·ŝ */
    float gx=gyro[0], gy=gyro[1], gz=gyro[2];
    float qd0 = 0.5f*(-q1*gx - q2*gy - q3*gz) - beta*s0;
    float qd1 = 0.5f*( q0*gx + q2*gz - q3*gy) - beta*s1;
    float qd2 = 0.5f*( q0*gy - q1*gz + q3*gx) - beta*s2;
    float qd3 = 0.5f*( q0*gz + q1*gy - q2*gx) - beta*s3;

    q[0] = q0 + qd0*dt; q[1] = q1 + qd1*dt;
    q[2] = q2 + qd2*dt; q[3] = q3 + qd3*dt;
    quat_normalize(q);
}
