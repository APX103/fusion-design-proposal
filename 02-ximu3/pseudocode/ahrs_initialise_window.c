/*
 * AhrsInitialiseWindow_Step — 初始化窗口收尾：N 样本均值 → 零偏 + 初始姿态
 *
 * 来源：x-IMU3 固件 v2.6.0，KSEG0 0x9D07BFA4（148 字节，全函数）。
 * 性质：汇编级重构；原文完整反汇编见 out/data/known_disasm/AhrsInitialiseWindow_Step.asm。
 *
 * 这是"零漂三层机制"第二层的核心：上电后前 N 个样本（+0x34 = N）期间，
 * AhrsUpdate 把传感器派生量累加进 win_acc[3]（+0xa0/+0xa4/+0xa8）；
 * 窗口计满时本函数把累加器就地转为均值，状态置 2（估计完成）。
 *   - 陀螺分量的均值  → 零偏估计 → 设置项 gyroscope_offset_correction_offset，
 *                       此后从每帧陀螺中扣除（默认开启）；
 *   - 加计/磁计派生量均值 → 初始姿态/航向（与 AhrsUpdate 的轴向约定分支配合）。
 *
 * 反汇编直译（0x9D07BFA4–0x9D07C034，寄存器→变量名）：
 *
 *   lw   $v1, 8($a0)          ; v1 = a->engine_state
 *   addiu $v0, $zero, 3
 *   beq  $v1, $v0, ret1       ; engine_state==3 → 停用
 *   addiu $a2, $zero, 1
 *   lw   $a1, 0x90($a0)       ; a1 = a->win_state
 *   bne  $a1, $a2, ret2       ; win_state != 1 → 无事可做
 *   nop
 *   lw   $a3, 0x9c($a0)       ; a3 = a->win_count
 *   beqz $a3, reset_state     ; 计数为 0（异常）→ 回状态 0
 *   mtc1 $a3, $f0 ; mthc1 0   ; count → double（精度安全）
 *   lui  $t0, 0x9d08
 *   lwc1 $f2, 0x5b5c($t0)     ; f2 = 1.0f（常量池 0x9D085B5C）
 *   cvt.d.w …                 ; f1 = (double)count
 *   div.s $f4, $f2, $f1       ; f4 = 1/N（单精度化）
 *   lwc1 $f3, 0xa4($a0)       ; 累加器 y
 *   lwc1 $f5, 0xa8($a0)       ; 累加器 z
 *   lwc1 $f6, 0xa0($a0)       ; 累加器 x
 *   addiu $t1, $zero, 2
 *   sw   $t1, 0x90($a0)       ; win_state = 2
 *   sb   $a1, 0x98($a0)       ; win_flag  = 1
 *   mul.s $f7, $f4, $f3       ; y *= 1/N
 *   mul.s $f8, $f4, $f5       ; z *= 1/N
 *   mul.s $f9, $f6, $f4       ; x *= 1/N
 *   swc1 $f7, 0xa4($a0)
 *   swc1 $f8, 0xa8($a0)
 *   swc1 $f9, 0xa0($a0)
 *   jr   $ra ; v0 = 0
 * ret1:        jr $ra ; v0 = 1
 * ret2:        jr $ra ; v0 = 2
 * reset_state: sw $zero, 0x90($a0) ; sw $zero, 0x94($a0) ; jr $ra ; v0 = 0
 */

int AhrsInitialiseWindow_Step(Ahrs *a)              /* a0 = 0x8007CDC0 */
{
    if (a->engine_state == 3)                       /* 0x9D07BFAC           */
        return 1;                                   /* 校正停用             */
    if (a->win_state != 1)                          /* 0x9D07BFB8           */
        return 2;                                   /* 不在累积期           */

    uint32_t n = (uint32_t)a->win_count;            /* 0x9D07BFC0           */
    if (n == 0) {                                   /* 0x9D07BFC4 beqz      */
        a->win_state = 0;
        a->win_reserved = 0;
        return 0;
    }

    float inv_n = 1.0f / (float)(double)n;          /* 0x9D07BFC8–0x9D07BFE4
                                                      * count 经 double 转换
                                                      * 再除，避免精度损失   */
    a->win_acc[1] *= inv_n;                         /* 0x9D07C000 ($f7)     */
    a->win_acc[2] *= inv_n;                         /* 0x9D07C004 ($f8)     */
    a->win_acc[0] *= inv_n;                         /* 0x9D07C008 ($f9)     */

    a->win_state = 2;                               /* 0x9D07BFF4 估计完成  */
    a->win_flag  = 1;                               /* 0x9D07BFF8           */
    return 0;
}

/*
 * 调用点：AhrsUpdate 0x9D036E60 的尾调用 `j 0x9d07bfa4`（窗口计满时）。
 * 驱动层（0x9D038B40 一带）对返回值 2 的处理触发"零偏发布 + 初始姿态装载"，
 * 之后 win_state 保持 2，窗口不再重开（除非 AhrsReset 0x9D07CA98 清零）。
 */
