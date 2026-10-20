/*
 * Pipeline_CalibrateAndEmit — 400 Hz 传感器标定与消息发射（函数头部）
 *
 * 来源：x-IMU3 固件 v2.6.0，KSEG0 0x9D038848（序言；函数主体延伸至消息分发）。
 * 性质：汇编级重构（头部 15 参数标定 + 时间戳差分段）；
 *       完整反汇编见 out/data/known_disasm/Pipeline_CalibrateAndEmit.asm。
 *
 * 上游：SPI 惯性传感器状态机（0x9D0384B0 一带）与 I2C 中断（0x9D06F550，
 * 含硬件时间戳）。本函数每个采样周期被驱动调用一次。
 *
 * 对象：
 *   g_calibration @ 0x8007C448（由 Settings_ApplyAll 0x9D04A270 装载）
 *     +0x04..+0x2C  陀螺失准矩阵 M 行主/次对角元素（逐字段见下）
 *     +0x24/+0x28   陀螺灵敏度 s（x/y；z 在 +0x38 槽位参与）
 *     +0x30/+0x34/+0x38  陀螺偏置 b（x/y/z）
 *     +0x3c…+0x68   加计 M/s/b（同构）
 *     +0xe8…        高 g 与磁力计（软铁 3×3 @+0x118，硬铁 @+0x13c）
 *   g_calibrated_samples @ 0x8007D950（+8 陀螺、+0x14 加计）
 *   g_mag_samples @ 0x8007DB98（+8 三轴）
 */

void Pipeline_CalibrateAndEmit(Sample *s)           /* a0：原始样本 + 时间戳 */
{
    /* ---- 第一层：15 参数标定  ic = M·s·(iu − b) --------- 0x9D038858 ---- */
    /* 以陀螺为例（加计/高 g 同构，偏移不同）：                                */
    /*   sub.s  f6  = gyro_y − b_y        ; 0x9D038868  (b @+0x34)           */
    /*   sub.s  f7  = gyro_x − b_x        ; 0x9D03887C  (b @+0x30)           */
    /*   sub.s  f17 = gyro_z − b_z        ; 0x9D0388A0  (b @+0x38)           */
    /*   mul.s  f9  = (gyro_y−b_y)·s_y    ; 0x9D038878  (s @+0x28)           */
    /*   mul.s  f13 = (gyro_x−b_x)·s_x    ; 0x9D03888C  (s @+0x24)           */
    /*   mul.s  f25 = (gyro_z−b_z)·s_z    ; 0x9D0388B4                        */
    /*   行乘累加（熔合乘加）：                                               */
    /*   mul.s  f15 = f9·M[0][0]           ; 0x9D038894  (M @+0x10 行元素)   */
    /*   mul.s  f16 = f9·M[1][0]           ; 0x9D038898  (M @+0x04)          */
    /*   mul.s  f18 = f9·M[2][0]           ; 0x9D03889C  (M @+0x1c)          */
    /*   madd.s f29 = f15 + f13·M[0][1]    ; 0x9D0388B8                        */
    /*   madd.s f31 = f16 + f13·M[1][1]    ; 0x9D0388BC                        */
    /*   madd.s f5  = f18 + f13·M[2][1]    ; 0x9D0388C0                        */
    /*   madd.s f3  = f29 + f25·M[0][2]    ; 0x9D0388D4                        */
    /*   madd.s f2  = f31 + f25·M[1][2]    ; 0x9D0388D8                        */
    /*   madd.s f1  = f5  + f25·M[2][2]    ; 0x9D0388DC                        */
    for (int i = 0; i < 3; i++)                     /* 三个惯性传感器循环     */
        for (int r = 0; r < 3; r++)
            cal[r] = M[r][0]*sx*(iu_x-bx) + M[r][1]*sy*(iu_y-by)
                   + M[r][2]*sz*(iu_z-bz);
    /* 磁力计：软铁（含失准/灵敏度合并）与硬铁偏置同构应用                     */

    /* ---- 第二层：扣除运行时零偏（由初始化窗口估计）------------------------------ */
    /* 驱动在调用 AhrsUpdate 前用 g_mag/校正对象完成；陀螺零偏见
     * ahrs_initialise_window.c 的说明（设置项 gyroscope_offset_correction_offset）。 */

    /* ---- 时间戳差分（64 位 + 双精度）-------------------- 0x9D038AB0 ---- */
    /* t2 = sample_ts;  a1 = last_ts (GP 缓存 -0x7d70/-0x7d6c)                */
    /* subu + sltu 借位链实现 64 位减法 → jal 0x9D0862A4（除法辅助）          */
    /* cvt.d.w（0x46A095E1）转 double，与双精度常数池运算 → 秒                */
    /* 这就是手册"±0.3% 采样率误差、独立时间基准"的实现                        */

    /* ---- 陀螺超量程判定并选择 AHRS 更新变体 ------------- 0x9D038B1C ---- */
    /* jal 0x9D0890DC/0x9D0890E4（状态查询），返回 1 → jal 0x9D041038         */

    /* ---- 消息速率分频/平均 ------------------------------ 0x9D0389E4 ---- */
    /* 各 *_message_rate_divisor 设置：分频低于采样率时对样本求平均           */

    /* ---- AHRS 更新调度 ---------------------------------- 0x9D038D48 ---- */
    /* AhrsUpdate(g_ahrs, cal_gyro, cal_accel, g_mag_samples)                */

    /* ---- 消息发射（24 种消息类型跳转表 ------------------ 0x9D038A2C ---- */
    /* lwx $v0, idx*4(0x9D088A2C 表基) + jr → 各格式化器                     */
    /* 浮点符号翻转用 XOR 0x80000000（0x9D038A98）；输出目标：USB/串口/Wi-Fi/  */
    /* 蓝牙/SD 由各 *_data_messages_enabled 设置控制                          */
}
