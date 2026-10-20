/*
 * temp_stability_detector.c — 温度稳定性检测（固件 FUN_0800F444）
 *
 * 来源：ATOM-IMU v25-12-28，地址 0x0800F444（ARM Thumb，STM32G431KB）。
 * 性质：**Ghidra 12.1.3 反编译输出**（经 REA），仅重命名变量、补注释，
 *       未改动表达式与控制流。证据常量：
 *         0x0800F5A4 = 0.0f
 *         0x0800F5A8 = 0.13f   ← 稳定阈值（平均绝对偏差）
 *         0x0800F5B0 = 0.003f
 *         0x20000028           ← 全局 "首次稳定" 标志（RAM）
 *
 * 语义：对温度环形缓冲求均值与平均绝对偏差；偏差 < 0.13°C 且
 * （首次）时复位若干滤波状态。校准入口用对象 +0x2C 的稳定标志门控
 * （0x0800EC50：不稳定打印 "Temperature is not stable!" 并返回 -1）。
 */

void FUN_0800f444(int param_1)                       /* IMU 对象基址 */
{
    char *first_stable_flag;
    int iVar2, iVar3;
    unsigned int uVar6;
    int iVar7, iVar8;
    float fMean, fDev, fSum, fCount;

    /* 两个采样缓冲（+0xEC 与 +0x108）及其长度（+0xF0、+0x10C） */
    iVar7 = param_1 + 0xec;
    iVar2 = FUN_0800b50c(iVar7);                     /* 环形缓冲是否已满 */
    if (iVar2 == 0)
        FUN_0800b4d2(iVar7, 0);                      /* 复位读指针 */
    iVar8 = param_1 + 0x108;
    iVar2 = FUN_0800b50c(iVar8);
    if (iVar2 == 0)
        FUN_0800b4d2(iVar8, 0);

    FUN_0800b47e(iVar7, param_1 + 0x28);             /* push 温度样本 A */
    local_24[0] = *(undefined4 *)(param_1 + 0xdc);
    FUN_0800b47e(iVar8, local_24);                   /* push 温度样本 B */

    /* --- 缓冲 B 的均值 → 对象 +0x30 --- */
    iVar2 = FUN_0800b50c(iVar8);
    if (iVar2 == 0) {
        fMean = 0.0f;                                 /* DAT_0800f5a4 */
        for (iVar2 = 0; iVar3 = FUN_0800b4ba(iVar8), iVar2 < iVar3; iVar2++) {
            uVar6 = *(int *)(param_1 + 0x110) + iVar2;
            fMean += *(float *)((uVar6 % *(uint *)(param_1 + 0x11c)) * 2
                                + *(int *)(param_1 + 0x108));
        }
        fCount = (float)FUN_0800b4ba(iVar8);
        *(float *)(param_1 + 0x30) = fMean / fCount;   /* ← 平均温度 */
    }

    /* --- 缓冲 A：平均绝对偏差 → 稳定标志 --- */
    iVar2 = FUN_0800b50c(iVar7);
    fSum = 0.0f;
    if (iVar2 == 0) {
        fCount = 0.0f;
        for (iVar2 = 0; iVar8 = FUN_0800b4ba(iVar7), iVar2 < iVar8; iVar2++) {
            uVar6 = *(int *)(param_1 + 0xf4) + iVar2;
            fCount += fabsf(*(float *)((uVar6 % *(uint *)(param_1 + 0x100)) * 2
                                       + *(int *)(param_1 + 0xec))
                            - *(float *)(param_1 + 0x30));   /* |x − mean| */
        }
        iVar2 = FUN_0800b4ba(iVar7);
        first_stable_flag = DAT_0800f5ac;                      /* 0x20000028 */
        fDev = (float)FUN_0800b4ba(iVar7);
        /* avg_dev < 0.13f ? */
        if (fCount / fDev < 0.13f) {
            if (*first_stable_flag != '\0') {                  /* 首次稳定 */
                *(undefined4 *)(param_1 + 0xe0) = *(undefined4 *)(param_1 + 0x30);
                *(undefined4 *)(param_1 + 0xb4) = 0x41000000;  /* 8.0f */
                *(undefined4 *)(param_1 + 0xb8) = 0.003f;      /* 0x0800F5B0 */
                *(float *)(param_1 + 0xcc) = 0.0f;             /* 复位滤波状态 */
                *(float *)(param_1 + 0xd0) = 0.0f;
                *(float *)(param_1 + 0xd4) = 0.0f;
                *(float *)(param_1 + 0xdc) = 0.0f;
                *(float *)(param_1 + 0xd8) = 0.0f;
                *first_stable_flag = '\0';
            }
            stable = 1;
        } else {
            stable = 0;
        }
        *(undefined1 *)(param_1 + 0x2c) = stable;              /* ← 校准门控标志 */
    }
}
