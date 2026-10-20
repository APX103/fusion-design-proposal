/*
 * AhrsUpdate — Madgwick 梯度下降 AHRS 更新（400 Hz 主循环）
 *
 * 来源：x-IMU3 固件 v2.6.0，KSEG0 0x9D036AC8（真实入口，带 1 字前导 `lw $v0,8($a0)`；
 *       序言 `addiu $sp,$sp,-0x90` 在 0x9D036ACC）。
 * 性质：**人工汇编级重构**（非 Ghidra 逐字反编译）。每段标注证据地址；
 *       行为语义已核对，寄存器级细节见 out/data/known_disasm/AhrsUpdate.asm。
 *
 * 调用约定（MIPS o32）：a0=对象，陀螺三轴走 a1..a3（整数寄存器传浮点位型），
 * 加计/磁计三轴走调用方栈帧 0x10..0x18 / 0x1c..0x24。
 */

/* AHRS 引擎对象（RAM 0x8007CDC0），布局为逆向复原（证据：AhrsReset 0x9D07CA98
 * 逐字段清零 + AhrsUpdate/AhrsEngine_Configure 的访问偏移） */
typedef struct {
    float    dt;                 /* +0x00  1/rate = 0.0025 s（由 Configure 写入）   */
    int      axes_convention;    /* +0x04  0=NWU 1=ENU 2=NED（手册表 43）          */
    int      engine_state;       /* +0x08  0=运行 3=停用                           */
    float    ramp_a;             /* +0x0c  初始化斜坡参数                          */
    float    overrange_en;       /* +0x18  超量程恢复使能（字节读出）              */
    float    overrange_limit;    /* +0x1c  |ω| 上限（运行时=2000°/s, 0x44FA0000）  */
    float    ramp_b;             /* +0x14                                            */
    float    rej_limit_a;        /* +0x2c  加计抑制恢复触发                         */
    float    rej_limit_b;        /* +0x30  磁力计抑制恢复触发                       */
    int      init_window_n;      /* +0x34  初始化窗口长度 N（样本数）               */

    float    q[4];               /* +0x38  四元数 (w,x,y,z)，复位为 (1,0,0,0)      */
    float    accel[3];           /* +0x48  当前加计样本                             */
    uint8_t  ramp_active;        /* +0x54                                            */
    int32_t  ramp_count;         /* +0x58  斜坡倒计时                               */
    uint8_t  ramp_flag;          /* +0x5c                                            */
    float    mag_n[3];           /* +0x60  归一化磁计观测                           */

    int32_t  rej_acc_count;      /* +0x6c  加计抑制计数（-9 步进, 见 0x9D036FD0）    */
    int32_t  rej_acc_limit;      /* +0x70                                            */
    uint8_t  ramping2;           /* +0x74                                            */
    float    mag_obs[3];        /* +0x78  磁计观测缓存                             */
    int32_t  rej_mag_count;      /* +0x84  磁力计抑制计数                           */
    int32_t  rej_mag_limit;      /* +0x88                                            */
    uint8_t  flag_8c;            /* +0x8c                                            */

    int      win_state;          /* +0x90  初始化窗口状态 0/1/2（见 *_step.c）      */
    int      win_reserved;       /* +0x94                                            */
    uint8_t  win_flag;           /* +0x98                                            */
    int32_t  win_count;          /* +0x9c  窗口计数器                               */
    float    win_acc[3];         /* +0xa0  窗口累加器 → 窗口均值（顺序 a4/a8/a0 映射 x/y/z） */
} Ahrs;

/* 常量池 0x9D085Bxx（float）：
 *   +0x54=0.5   +0x58=deg2rad   +0x5C=1.0   +0x60=10.0(抑制阈值)
 *   +0x68=2π    +0x6C=0.98(抑制斜坡系数)    +0x7C=π/360=½·deg2rad
 */

int AhrsUpdate(Ahrs *a, const float gyro[3],     /* 已标定、已扣零偏, °/s */
               const float accel[3], const float mag[3])
{
    /* ---- 入口与引擎状态 ---------------------------------- 0x9D036AC8 ---- */
    if (a->engine_state != 0)                       /* bnez $v0, 0x9D037220  */
        return 1;                                   /* 停用：直接返回 1       */

    a->accel[0..2] = accel;                         /* 0x9D036B10             */

    /* ---- 超量程恢复判定 ---------------------------------- 0x9D036B18 ---- */
    /* ext rt,rs,31 取 |gyro|（清除符号位），与 overrange_limit 比较          */
    if (a->overrange_en && (|gyro| > a->overrange_limit)) {
        helper_9d08252c(a);                         /* 进入恢复：置 ramp_flag */
        a->ramp_flag = 1;                           /* 0x9D036B6C             */
    }

    /* ---- 初始化增益斜坡倒计时 ---------------------------- 0x9D036B74 ---- */
    if (a->ramp_active && a->ramp_count > a->ramp_b) {
        a->ramp_count -= a->ramp_a;                 /* 0x9D036B8C             */
        if (!(a->ramp_count > a->ramp_b)) {         /* 斜坡结束               */
            a->ramp_active = 0; a->ramp_flag = 0;
        }
    }

    /* ---- 陀螺积分增量（编译器把 ½ 并入 deg→rad） ---------- 0x9D036BAC ---- */
    /* half_domega[i] = gyro[i] * (π/360)   [rad/s × ½]                       */
    float half_dw[3] = { gyro[0]*K_PI_360, gyro[1]*K_PI_360, gyro[2]*K_PI_360 };

    /* ---- 按轴向约定选择目标函数路径 ---------------------- 0x9D036BC8 ---- */
    /* mode 0/1 (NWU/ENU) → 仅加计 Jacobian 装配 (0x9D036F34)                 */
    /* mode 2   (NED)     → 完整 磁力计路径 (0x9D036BEC)                      */

    /* ---- (mode 2 路径示例) 四元数二次型与 Jacobian -------- 0x9D036BEC ---- */
    /* q = (w,x,y,z); 乘积项 madd/msub 熔合；符号翻转用 XOR 0x80000000        */
    /* （0x9D036C2C：mfc1 取位型后 xor 0x80000000 再回写——取负的位技巧）      */
    ... /* 展开 Madgwick 标准目标函数 f 与梯度 s 的各项；
           与开源 MadgwickAHRS.c 的 Update 步骤逐项对应 */

    /* ---- 零观测保护 -------------------------------------- 0x9D036C44 ---- */
    /* c.eq.s 逐轴比较：accel 或 mag 任一轴非零才继续（Madgwick 同款守卫）    */

    /* ---- 归一化（共 5 处 sqrt.s+div.s）------------------- 0x9D036DA0 等 -- */
    /*  1) 0x9D036DA0  加计归一化                                            */
    /*  2) 0x9D036EA8  梯度 s 归一化                                          */
    /*  3) 0x9D036F88  （变体路径的 s 归一化）                                */
    /*  4) 0x9D037070  磁计参考向量 h 归一化（叉积 0x9D037034-0x9D037054）   */
    /*  5) 0x9D03712C  四元数归一化                                           */

    /* ---- 锚定航向判定 ------------------------------------ 0x9D0370EC ---- */
    /* c.lt.s 与 cos²(截止角/2) 比较，越过锚点则重算参考航向（含 2π 常量）    */

    /* ---- 干扰抑制状态机 ---------------------------------- 0x9D036FC8 ---- */
    /* 加计抑制：|观测-预测| 超阈值 → rej_acc_count -= 9 并丢弃观测；          */
    /*           计数 < 恢复触发限值后重新接纳（0x9D036FD0–0x9D037004）        */
    /* 磁力计抑制：同构，rej_mag_count @+0x84（0x9D03716C–0x9D0371C4）         */
    /* 阈值默认 10°（cos² 比较），恢复期用 0.98 系数斜坡（Configure 写入）     */

    /* ---- 积分与四元数更新 -------------------------------- 0x9D036CD8 ---- */
    /* qDot = ½·q⊗ω − β·ŝ ;  q += qDot·dt ;  q /= |q|  → 写回 +0x38..0x44     */
    /* （0x9D036DD8–0x9D036DE8 sw 写回四分量）                                */

    /* ---- 初始化窗口累加 ---------------------------------- 0x9D036E1C ---- */
    /* 仅 win_state==1 时：win_acc[3] += 本周期派生量; win_count++            */
    if (++a->win_count >= a->init_window_n)          /* 0x9D036E44 sltu 比较   */
        return AhrsInitialiseWindow_Step(a);         /* 尾调用 0x9D07BFA4      */
                                                     /* j 0x9d07bfa4          */
    return 0;
}

/*
 * 返回值约定（由调用方 Pipeline 驱动 0x9D038B40 的 beq 分发证实）：
 *   0 = 正常；1 = 引擎停用/恢复触发；2 = 初始化窗口均值就绪（零偏+初始姿态可用）
 *
 * 变体：0x9D0391D0（部分更新）、0x9D041038（重置路径更新）由驱动按状态选择。
 */
