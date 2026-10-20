/*
 * ahrs_madgwick.c — ATOM-IMU 姿态解算（固件 0x08013480，6 轴 Madgwick）
 *
 * 来源：ATOM-IMU v25-12-28，函数 FUN_08013480（Ghidra 反编译 + 人工注释）。
 * 性质：Ghidra 12.1.3 反编译输出整理（可读化重写）。
 *       逐字、无省略的原始反编译见同目录 ahrs_madgwick.ghidra.c。
 *
 * 结论：
 *   - 算法是 **Madgwick 梯度下降**，且是 **6 轴版本**（只用加速度计修正，
 *     固件里没有任何磁力计驱动模块，也没有磁场参考项）。
 *   - 对象布局（字节偏移）：
 *       +0x04  β（增益）
 *       +0x20..+0x2C  四元数（4×float）
 *       +0x3C/+0x40/+0x44  加速度计（参与梯度）
 *       +0x30/+0x34/+0x38  欧拉角输出
 *       +0x78 / +0x80  时间戳状态 / dt
 *       +0xD8/+0xDC/+0xE0  陀螺零偏（每拍扣除）
 *   - 初始化：线程循环里 `tick < 3000` 时 β 乘以 50（常量 0x080138C0 = 50.0f），
 *     即前 3000 拍高增益快速收敛；同时前 3000 拍不发布姿态。
 *   - 无磁力计 → 航向完全靠陀螺积分；低零漂依赖零偏稳定性 + 恒温 + 标定。
 *
 * 线程循环（0x080138E0 附近，Ghidra 归类在函数尾部）：
 *     bl 0x08013480          ; AhrsUpdate
 *     bl 0x0800F248 / b078   ; 读 tick
 *     if (tick <= 3000) return;
 *     publish(quat, 16B); publish(euler, 12B);
 */

void AhrsUpdate_Madgwick(Ahrs *a)
{
    float q0 = a->q[0], q1 = a->q[1], q2 = a->q[2], q3 = a->q[3]; /* +0x20.. */
    float ax = a->acc[0], ay = a->acc[1], az = a->acc[2];         /* +0x3C.. */

    /* ---- dt（双精度时间戳差；0x0800F170/0B034/0B060） ---- */
    double now = timestamp_now();
    a->dt = (float)(now - a->last_ts);
    a->last_ts = now;

    /* ---- 陀螺零偏扣除（+0xD8/+0xDC/+0xE0） ---- */
    float gx = a->gyro[0] - a->gyro_bias[0];
    float gy = a->gyro[1] - a->gyro_bias[1];
    float gz = a->gyro[2] - a->gyro_bias[2];

    /* ---- 四元数微分：q̇ = ½ q ⊗ ω（0x08013860 一带展开） ---- */
    float qd0 = 0.5f * (-q1*gx - q2*gy - q3*gz);
    float qd1 = 0.5f * ( q0*gx + q2*gz - q3*gy);
    float qd2 = 0.5f * ( q0*gy - q1*gz + q3*gx);
    float qd3 = 0.5f * ( q0*gz + q1*gy - q2*gx);

    /* ---- 加速度计梯度修正（Madgwick） ---- */
    if (ax != 0.0f || ay != 0.0f || az != 0.0f) {
        float n = sqrtf(ax*ax + ay*ay + az*az);
        float inv = 1.0f / n;
        ax *= inv; ay *= inv; az *= inv;

        /* ---- 梯度 s = Jᵀf 的展开（以下逐字对应 Ghidra 输出） ----
         * 记 q0..q3 = +0x20/+0x24/+0x28/+0x2C，ax/ay/az = fVar22/fVar21/fVar18。
         * 表达式中的 2.0/4.0/8.0 是 Madgwick 雅可比展开后的系数。 */
        fVar3  = 1.0f / sqrtf(fVar21*fVar21 + fVar22*fVar22 + fVar18*fVar18);
        fVar22 = fVar22 * fVar3;               /* ax 归一化 */
        fVar13 = -(fVar3 * fVar21);            /* -ay 归一化 */
        fVar6  = q0 * 4.0f;
        fVar16 = q3 * q3 * 4.0f;
        fVar9  = q0 * q0;
        fVar21 = q1 * 4.0f;
        fVar10 = q1 * q1;
        fVar19 = fVar22*(q1 + q1) + q3*4.0f*fVar10 + q3*4.0f*fVar9
               + (q0 + q0)*fVar13;
        fVar6  = ((-((q2 + q2)*fVar22) + fVar6*fVar17*fVar17 + q0*fVar16
                 + (q3 + q3)*fVar13) - fVar6) + q0*8.0f*fVar9
               + q0*8.0f*fVar10 + fVar18*fVar3*fVar6;
        fVar18 = ((fVar22*(q3 + q3) + q1*fVar16 + fVar21*fVar17*fVar17
                 + (fVar17 + fVar17)*fVar13) - fVar21) + q1*8.0f*fVar9
               + q1*8.0f*fVar10 + fVar18*fVar3*fVar21;
        fVar8  = -((q0 + q0)*fVar22) + fVar17*fVar9*4.0f
               + fVar17*fVar10*4.0f + (q1 + q1)*fVar13;

        float sn = sqrtf(fVar6*fVar6 + fVar19*fVar19 + fVar18*fVar18
                         + fVar8*fVar8);
        float sinv = 1.0f / sn;

        float beta = a->beta;                  /* +0x04 */
        if (a->tick < 3000)                    /* 0x0801391C: cmp r0,#3000 */
            beta *= 50.0f;                     /* 0x080138C0 = 50.0f */

        /* 反编译器中 fVar15/fVar14/fVar12/fVar11 即四个 q̇ 分量 */
        fVar15 -= beta * sinv * fVar19;
        fVar14 -= beta * sinv * fVar6;
        fVar12 -= beta * sinv * fVar18;
        fVar11 -= beta * sinv * fVar8;
    }

    /* ---- 积分 + 归一化（0x080138A0 一带） ---- */
    q0 += a->dt * qd0; q1 += a->dt * qd1;
    q2 += a->dt * qd2; q3 += a->dt * qd3;
    {
        float n = sqrtf(q0*q0 + q1*q1 + q2*q2 + q3*q3);
        float inv = 1.0f / n;
        a->q[0] = q0*inv; a->q[1] = q1*inv;
        a->q[2] = q2*inv; a->q[3] = q3*inv;
    }

    /* ---- 欧拉角输出（0x080138C8 之后；atan2f/asin） ----
     * 固件实际分母与标准 ZYX 公式存在轴序差异（反编译可见
     * 1-2(qx²+qy²) 等），下面是标准形式，仅示意；精确轴序未逐项校准。 */
    a->roll  = atan2f(2.0f*(q0*q1 + q2*q3), 1.0f - 2.0f*(q1*q1 + q2*q2));
    a->pitch = asinf (2.0f*(q0*q2 - q3*q1));
    a->yaw   = atan2f(2.0f*(q1*q2 + q0*q3), 1.0f - 2.0f*(q0*q0 + q1*q1));
}

/*
 * 与 x-IMU3 的对比（同为 Madgwick，差异在工程层）：
 *   - x-IMU3：9 轴（加计 + 磁），有干扰抑制/恢复、超量程恢复、时间戳 dt、
 *     启动零偏窗口；温度只测不补。
 *   - ATOM ：6 轴（仅加计），无磁；用恒温（MAD < 0.13°C）把零偏漂移压住，
 *     前 3000 拍 β×50 快速收敛，零偏来自专用状态 + 温态标定。
 *   即：同一算法内核，一个靠"观测鲁棒性"，一个靠"误差源治理"。
 */
