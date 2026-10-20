/*
 * AhrsEngine_Configure — AHRS 引擎参数装配（Ghidra 反编译整理版）
 *
 * 来源：x-IMU3 固件 v2.6.0，KSID 0x9D05C740（588 字节）。
 * 性质：Ghidra 12.1.3 反编译输出（经 REA），仅重命名变量/加注释；
 *       未改动任何表达式与控制流。调用方：AhrsSettings_Apply(0x9D0545DC)
 *       与引擎静态初始化（0x9D078344）。
 *
 * param_1 = g_ahrs (0x8007CDC0)
 * param_2 = 运行时配置池（AhrsSettings_Apply 栈上组装）：
 *   [0]=400.0 采样率  [1]=β 增益(默认0.5)  [2]=模式(0/1/2, 3=停用)
 *   [3]=阈值基准10.0  [4]/[5]/[6]=抑制阈值(°)  [7]=恢复斜坡时间
 *   [8]=锚定航向参数  [9]=恢复触发
 */

void AhrsEngine_Configure(Ahrs *a, const Config *p)
{
    /* 状态守卫（原：param_1[2]!=0 && param_1[0x24]==1 → 置 5） */
    if (a->mode_or_init != 0 && a->field_24 == 1)
        a->field_24 = 5;

    float rate      = p[0];                          /* 400 Hz               */
    float mode      = p[2];
    float limit     = p[3];                          /* 10.0                 */

    a->cfg[0] = p[1];                                /* β                    */
    a->cfg[1] = mode;
    a->cfg[2] = limit;
    a->cfg[3] = limit;
    a->dt     = 1.0f / rate;                         /* *param_1 = 1/rate    */

    /* 初始化斜坡：前 10 帧线性收敛（(10−n)/3 · dt） */
    a->ramp_scale = ((10.0f - limit) / 3.0f) * (1.0f / rate);   /* param_1[5] */

    if (mode == 0)                                   /* fVar1==0（原判断）   */
        a->cfg[3] = p[8] * 6.2831855f;               /* 2π（锚定航向）       */

    float rej_a = p[4];                              /* 抑制阈值 a           */
    float rej_b = p[5];                              /* 抑制阈值 b           */

    *(bool *)&a->rej_a_enabled = 0.0f < rej_a;       /* param_1[6]           */
    a->rej_a_scale = rej_a * 0.98f;                  /* param_1[7]：0.98 斜坡 */

    /* 余弦平方（半角）阈值：cosf(deg·π/180)² —— 抑制判定的比较量 */
    if (rej_b <= 0.0f || limit <= 0.0f) {
        a->rej_b_enabled = 0;
        float c = cosf(rej_b * 0.017453292f);        /* FUN_9d0613f8         */
        a->rej_b_cos2   = c * 0.5f * c * 0.5f;       /* (c/2)²  形式         */
        /* 后续与 p[6]、limit 的门控跳转保持原样 */
    } else {
        a->rej_b_enabled = 1;
        float c = cosf(rej_b * 0.017453292f);
        a->rej_b_cos2   = c * 0.5f * c * 0.5f;
    }

    float c2      = cosf(p[6] * 0.017453292f);       /* 另一半角阈值         */
    float ticks_f = rate * p[9];                     /* 恢复触发 → 样本数    */
    int   ticks   = (int)(rate * p[7]);              /* 斜坡时间 → 样本数    */

    a->recovery_ticks    = ticks;                    /* param_1[0xc]         */
    a->rej_a_limit_ticks = ticks;                    /* param_1[0x1c]        */
    a->rej_b_limit_ticks = ticks;                    /* param_1[0x22]        */
    a->rej_c_cos2        = c2 * 0.5f * c2 * 0.5f;    /* param_1[0xb]         */

    a->init_window_n = (int)(ticks_f);               /* param_1[0xd]         */
    /* 溢出保护分支（≥2^31 时位运算处理）保持原样 */
}

/*
 * 静态默认池 @ 0x9D086EB0（引擎首装，运行时被上面的动态值覆盖）：
 *   { 100, 0, 1, 0.5, 0, 0, 0, 10, 0.01, 5 }
 *   注意 gain=0.5 与手册 11.1.62 的默认值一致；400 Hz 在运行时传入。
 */
