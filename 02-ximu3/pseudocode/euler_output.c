/*
 * Output_QuatToEulerMessage — 四元数 → 欧拉角消息（AHRS 输出级）
 *
 * 来源：x-IMU3 固件 v2.6.0，KSEG0 0x9D048164（frame 0x170）。
 * 性质：汇编级重构；反汇编见 out/data/known_disasm/Output_QuatToEulerMessage.asm。
 *
 * 对象：输出管理器 @ 0x8007D728（$s0 = 0x80080000−0x28D8）。
 *   +0x04  ahrs_message_type（0=四元数 1=旋转矩阵 2=欧拉角，三分支 0x9D0481D0）
 *   +0x18  分频计数器（ahrs_message_rate_divisor）
 *   四元数经小助手 0x9D086E88（AhrsGetQuaternion）取自 g_ahrs+0x38。
 */

void Output_QuatToEulerMessage(void *msg)           /* a0：消息缓冲          */
{
    /* 分频与消息类型判定 ---------------------------------- 0x9D0481A4 ---- */
    if (--out->div_counter != 0) return;            /* 速率分频              */
    switch (out->message_type) {
    case 1:  goto path_9d04858c;                    /* 旋转矩阵              */
    case 0:  goto path_9d048528;                    /* 四元数直通            */
    case 2:  break;                                 /* 欧拉角 → 继续         */
    }

    /* 取四元数并装配欧拉角 -------------------------------- 0x9D0481E8 ---- */
    AhrsGetQuaternion(&q, g_ahrs);                  /* (w,x,y,z) @ sp+0xD0   */

    /* 俯仰角 θ = asin( clamp( 2·(y·z − x·w), −1, +1 ) ) -- 0x9D048244 ---- */
    /*   msub.s  f0  = y·z − x·w                       0x9D048244            */
    /*   add.s   f12 = f0 + f0   （×2）                0x9D048248            */
    /*   c.le.s  f12, −1.0（池 0x9D0882EC）→ bc1t 钳 −90°  0x9D04824C        */
    /*   ≥ +1.0（池 0x9D0882D8=1.0 / 0x9D0882E0=90.0）→ 钳 +90°              */
    float arg = 2.0f*(q.y*q.z - q.x*q.w);
    float pitch = (arg <= -1.0f) ? -90.0f
                 : (arg >= +1.0f) ? +90.0f
                 : asinf_deg(arg);                  /* 由 asin 近似/多项式    */

    /* 横滚/航向用 atan2 ----------------------------------- 0x9D0481F0 ---- */
    /*   f29 = x² + z²（madd.s 链）                                           */
    /*   f14 = f29 − 0.5（池 0x9D0882E4，归一化四元数的常数形式）             */
    /*   jal 0x9D05D940 = atan2f(f12, f14)                                   */
    /*   再乘 57.29578（池 0x9D0882E8）rad→deg                                */
    float roll  = atan2f_deg(2.0f*(q.x*q.w + q.y*q.z),
                             1.0f - 2.0f*(q.y*q.y + q.z*q.z));
    float yaw   = atan2f_deg(2.0f*(q.x*q.y + q.w*q.z) /* 同构，NED 分支 */,
                             1.0f - 2.0f*(q.y*q.y + q.x*q.x));

    /* 轴向约定置换：NWU/ENU/NED 的符号/顺序矩阵（三分支 0x9D04858C/0x9D048528） */

    emit(EULER_MSG, roll, pitch, yaw, timestamp);

    /* 线性/地球系加速度：由同一四元数把校准加计旋转到地球系
     *（辅助输出对象 @ 0x8007BFFC，FUN_9d087F4C 三参调用），
     * 并复制 3×3 旋转矩阵到输出缓存 0x8007C448+（16 字循环拷贝 0x9D0486A4）。
     */
}

/*
 * 相关常量池 0x9D0882D8：
 *   0x9D0882D8=1.0   0x9D0882DC=−90   0x9D0882E0=90   0x9D0882E4=0.5
 *   0x9D0882E8=57.2958(rad→deg)       0x9D0882EC=−1
 * 另一池 0x9D085B7C = π/360（AhrsUpdate 积分用），0x9D085B58 = deg2rad。
 */
