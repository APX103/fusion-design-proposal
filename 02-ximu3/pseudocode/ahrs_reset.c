/*
 * AhrsReset — AHRS 引擎复位（Ghidra 反编译整理版）
 *
 * 来源：x-IMU3 固件 v2.6.0，KSEG0 0x9D07CA98（144 字节）。
 * 性质：Ghidra 12.1.3 反编译输出（经 REA），仅加注释。
 * 调用点：AhrsSettings_Apply(0x9D05462C，配置变化时) 与复位命令(0x9D07F92C)。
 */

void AhrsReset(Ahrs *a)                             /* param_1 = 0x8007CDC0  */
{
    a->q[0] = 1.0f;                                 /* +0x38  四元数 → (1,0,0,0) */
    a->q[1] = 0.0f;                                 /* +0x3c                 */
    a->q[2] = 0.0f;                                 /* +0x40                 */
    a->q[3] = 0.0f;                                 /* +0x44                 */
    a->accel[0] = 0.0f;                             /* +0x48                 */
    a->accel[1] = 0.0f;                             /* +0x4c                 */
    a->accel[2] = 0.0f;                             /* +0x50                 */
    a->ramp_active = 1;                             /* +0x54  启动初始化斜坡 */
    a->overrange_limit2 = 10.0f;                    /* +0x58 (0x41200000)    */
    a->ramp_flag = 0;                               /* +0x5c                 */
    a->mag_n[0] = a->mag_n[1] = a->mag_n[2] = 0.0f; /* +0x60..+0x68          */
    a->rej_acc_count  = 0;                          /* +0x6c                 */
    a->rej_acc_limit  = 0;                          /* +0x70                 */
    a->rej_acc_ticks  = a->recovery_ticks;          /* +0x70 ← +0x30 拷贝    */
    a->ramping2 = 0;                                /* +0x74                 */
    a->mag_obs[0..2] = 0.0f;                        /* +0x78..+0x80          */
    a->rej_mag_ticks  = a->recovery_ticks;          /* +0x88 ← +0x30 拷贝    */
    a->flag_8c = 0;                                 /* +0x8c                 */
    a->rej_mag_count = 0;                           /* +0x90 区              */
    a->rej_mag_limit2 = 0;                          /* +0x94                 */
    a->win_flag = 0;                                /* +0x98                 */
    a->win_count = 0;                               /* +0x9c                 */
    a->win_acc[0] = a->win_acc[1] = a->win_acc[2] = 0.0f;   /* +0xa0..+0xa8 */

    /* 复位后 win_state 回到 0 → 下一轮 AhrsUpdate 周期重新开窗累积，
     * 即重启"零偏估计 + 初始姿态"流程（第二层机制随复位重新生效）。
     */
}

/* 伴随小函数 AhrsClearRampFlags @ 0x9D088CB0：
 *     a->flag_54 = 0; a->flag_5c = 0;   （仅清两个斜坡标志）
 */
