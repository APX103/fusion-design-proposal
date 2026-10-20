/*
 * ahrs_madgwick.ghidra.c — ATOM-IMU 姿态解算的 **逐字 Ghidra 反编译输出**
 *
 * 来源：固件 v25-12-28，函数 FUN_08013480（0x08013480，6725 字符）。
 * 性质：REA/Ghidra 12.1.3 原始输出，未经任何改写（仅加了本注释头）。
 *      变量名 fVar/param_1 等为反编译器自动命名；表达式完整、无省略。
 *
 * 阅读提示：
 *   - 开头 ~40 行是双精度时间戳差（dt），调用 0x08001498/0x08001548 等软双精度助手；
 *   - 中间一大段 2.0/4.0/8.0 系数的乘加是 Madgwick 梯度 s = Jᵀf 的展开；
 *   - 0.5 系数块是 q̇ = ½q⊗ω；
 *   - if (acc != 0) 内先归一化加速度、再归一化梯度、乘 β（前 3000 拍 ×50）；
 *   - 末尾积分、归一化、atan2f/asin 输出欧拉角。
 */

void FUN_08013480(int param_1)

{
  uint uVar1;
  undefined4 uVar2;
  float fVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  float fVar15;
  float fVar16;
  float fVar17;
  float fVar18;
  float fVar19;
  float fVar20;
  float fVar21;
  float fVar22;
  undefined8 uVar23;
  undefined8 uVar24;
  undefined1 auStack_c8 [4];
  undefined1 *local_c4;
  undefined1 auStack_c0 [12];
  float local_b4;
  float local_b0;
  float local_ac;
  undefined1 auStack_a8 [12];
  undefined1 **local_9c;
  undefined4 **ppuStack_98;
  undefined1 *local_94;
  undefined1 *puStack_90;
  undefined4 **local_8c;
  int local_88;
  undefined4 **local_84;
  int iStack_80;
  undefined4 local_7c;
  undefined4 **local_78;
  undefined4 **local_74;
  undefined1 *local_70;
  float *local_6c;
  float local_68;
  float local_64;
  float local_60;
  float local_5c;
  float local_58;
  
  FUN_0800f170(auStack_c0);
  FUN_0800b034(&local_78,auStack_c0,param_1 + 0x78);
  uVar2 = FUN_0800b018(&local_78);
  uVar23 = FUN_08001498(*(undefined4 *)(param_1 + 0x80));
  uVar23 = FUN_08001548((int)uVar23,(int)((ulonglong)uVar23 >> 0x20),DAT_080138c4,DAT_080138c8);
  uVar24 = FUN_08001498(uVar2);
  uVar24 = FUN_08001548((int)uVar24,(int)((ulonglong)uVar24 >> 0x20),DAT_080138cc,DAT_080138d0);
  FUN_080011dc((int)uVar23,(int)((ulonglong)uVar23 >> 0x20),(int)uVar24,
               (int)((ulonglong)uVar24 >> 0x20));
  uVar2 = FUN_08001af8();
  *(undefined4 *)(param_1 + 0x80) = uVar2;
  FUN_0800b060(param_1 + 0x78,auStack_c0);
  local_b4 = 0.0;
  local_b0 = 0.0;
  local_ac = 0.0;
  local_88 = param_1 + 0x48;
  local_84 = (undefined4 **)(param_1 + 0x60);
  fVar22 = *(float *)(param_1 + 0x3c);
  fVar21 = *(float *)(param_1 + 0x40);
  fVar18 = *(float *)(param_1 + 0x44);
  local_9c = (undefined1 **)&local_b4;
  local_78 = &local_9c;
  local_74 = &local_8c;
  local_70 = auStack_a8;
  local_6c = &local_b4;
  FUN_08012ce8(&local_78,0);
  FUN_08012ce8(&local_78,1);
  FUN_08012ce8(&local_78,2);
  fVar15 = *(float *)(param_1 + 0x24);
  fVar17 = *(float *)(param_1 + 0x28);
  fVar14 = *(float *)(param_1 + 0x20);
  fVar12 = *(float *)(param_1 + 0x2c);
  fVar7 = fVar15 + fVar15;
  fVar11 = fVar17 + fVar17;
  fVar8 = fVar14 + fVar14;
  local_88 = param_1 + 0x54;
  local_6c = (float *)(fVar14 * fVar7 + -fVar11 * fVar12);
  local_7c = 3;
  local_74 = (undefined4 **)(fVar14 * fVar7 + fVar11 * fVar12);
  local_9c = &local_c4;
  local_60 = fVar14 * fVar11 + fVar7 * fVar12;
  local_64 = fVar15 * fVar11 + fVar8 * fVar12;
  local_5c = fVar15 * fVar11 + -fVar8 * fVar12;
  local_70 = (undefined1 *)(fVar14 * fVar11 + -fVar7 * fVar12);
  local_68 = 1.0 - (fVar17 * fVar11 + fVar14 * fVar8);
  local_58 = 1.0 - (fVar15 * fVar7 + fVar14 * fVar8);
  local_78 = (undefined4 **)(1.0 - (fVar15 * fVar7 + fVar17 * fVar11));
  local_c4 = auStack_a8;
  ppuStack_98 = &local_8c;
  local_94 = auStack_c8;
  puStack_90 = auStack_a8;
  local_8c = &local_78;
  local_84 = &local_78;
  iStack_80 = local_88;
  FUN_08013434(&local_9c,0);
  FUN_08013434(&local_9c,1);
  FUN_08013434(&local_9c,2);
  FUN_080121ac(param_1 + 0x6c,auStack_a8,&local_8c);
  local_78 = (undefined4 **)&local_b4;
  local_74 = (undefined4 **)(param_1 + 0x6c);
  FUN_0801296e(&local_b4,&local_78,&local_8c);
  fVar20 = *(float *)(param_1 + 0x24);
  fVar8 = *(float *)(param_1 + 0x2c);
  fVar7 = *(float *)(param_1 + 0x20);
  fVar17 = *(float *)(param_1 + 0x28);
  local_b4 = local_b4 - *(float *)(param_1 + 0xd8);
  local_b0 = local_b0 - *(float *)(param_1 + 0xdc);
  local_ac = local_ac - *(float *)(param_1 + 0xe0);
  fVar15 = (-(fVar20 * local_b0) + -fVar7 * local_b4 + -local_ac * fVar17) * 0.5;
  fVar14 = (local_ac * fVar20 + local_b4 * fVar8 + -local_b0 * fVar17) * 0.5;
  fVar12 = (-(fVar7 * local_ac) + local_b0 * fVar8 + local_b4 * fVar17) * 0.5;
  fVar11 = (local_b0 * fVar7 + local_ac * fVar8 + -local_b4 * fVar20) * 0.5;
  if (((fVar22 != 0.0) || (fVar21 != 0.0)) || (fVar18 != 0.0)) {
    fVar3 = (float)FUN_080157a4(fVar21 * fVar21 + fVar22 * fVar22 + fVar18 * fVar18);
    fVar3 = 1.0 / fVar3;
    fVar22 = fVar22 * fVar3;
    fVar6 = fVar7 * 4.0;
    fVar16 = fVar8 * fVar8 * 4.0;
    fVar9 = fVar7 * fVar7;
    fVar13 = -(fVar3 * fVar21);
    fVar21 = fVar20 * 4.0;
    fVar10 = fVar20 * fVar20;
    fVar19 = fVar22 * (fVar20 + fVar20) + fVar8 * 4.0 * fVar10 + fVar8 * 4.0 * fVar9 +
             (fVar7 + fVar7) * fVar13;
    fVar6 = ((-((fVar17 + fVar17) * fVar22) + fVar6 * fVar17 * fVar17 + fVar7 * fVar16 +
             (fVar8 + fVar8) * fVar13) - fVar6) + fVar7 * 8.0 * fVar9 + fVar7 * 8.0 * fVar10 +
            fVar18 * fVar3 * fVar6;
    fVar18 = ((fVar22 * (fVar8 + fVar8) + fVar20 * fVar16 + fVar21 * fVar17 * fVar17 +
              (fVar17 + fVar17) * fVar13) - fVar21) + fVar20 * 8.0 * fVar9 + fVar20 * 8.0 * fVar10 +
             fVar18 * fVar3 * fVar21;
    fVar8 = -((fVar7 + fVar7) * fVar22) + fVar17 * fVar9 * 4.0 + fVar17 * fVar10 * 4.0 +
            (fVar20 + fVar20) * fVar13;
    fVar7 = (float)FUN_080157a4(fVar6 * fVar6 + fVar19 * fVar19 + fVar18 * fVar18 + fVar8 * fVar8);
    fVar7 = 1.0 / fVar7;
    fVar22 = *(float *)(param_1 + 4);
    local_78 = (undefined4 **)FUN_0800f248();
    uVar1 = FUN_0800b078(&local_78);
    if (uVar1 < 3000) {
      fVar22 = fVar22 * DAT_080138c0;
    }
    fVar15 = fVar15 + -fVar22 * fVar7 * fVar19;
    fVar14 = fVar14 + -fVar22 * fVar7 * fVar6;
    fVar12 = fVar12 + -fVar22 * fVar7 * fVar18;
    fVar11 = fVar11 + -fVar22 * fVar7 * fVar8;
  }
  fVar7 = *(float *)(param_1 + 0x80);
  fVar14 = *(float *)(param_1 + 0x20) + fVar7 * fVar14;
  fVar22 = *(float *)(param_1 + 0x2c) + fVar7 * fVar15;
  fVar8 = *(float *)(param_1 + 0x24) + fVar7 * fVar12;
  fVar11 = *(float *)(param_1 + 0x28) + fVar7 * fVar11;
  fVar7 = (float)FUN_080157a4(fVar14 * fVar14 + fVar22 * fVar22 + fVar8 * fVar8 + fVar11 * fVar11);
  fVar7 = 1.0 / fVar7;
  fVar8 = fVar8 * fVar7;
  fVar14 = fVar14 * fVar7;
  fVar11 = fVar11 * fVar7;
  fVar22 = fVar22 * fVar7;
  fVar7 = fVar14 * fVar8 + fVar22 * fVar11;
  *(float *)(param_1 + 0x24) = fVar8;
  *(float *)(param_1 + 0x2c) = fVar22;
  *(float *)(param_1 + 0x20) = fVar14;
  *(float *)(param_1 + 0x28) = fVar11;
  uVar2 = thunk_FUN_080166f8(fVar7 + fVar7,-(fVar8 * fVar8 + fVar11 * fVar11) * 2.0 + 1.0);
  fVar7 = -(fVar11 * fVar14) + fVar22 * fVar8;
  uVar4 = FUN_08015748(fVar7 + fVar7);
  fVar7 = fVar8 * fVar11 + fVar22 * fVar14;
  uVar5 = thunk_FUN_080166f8(fVar7 + fVar7,-(fVar8 * fVar8 + fVar14 * fVar14) * 2.0 + 1.0);
  *(undefined4 *)(param_1 + 0x34) = uVar4;
  *(undefined4 *)(param_1 + 0x30) = uVar5;
  *(undefined4 *)(param_1 + 0x38) = uVar2;
  return;
}
