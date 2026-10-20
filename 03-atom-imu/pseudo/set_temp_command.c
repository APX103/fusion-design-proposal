/*
 * set_temp_command.c — 温度设置命令（固件 0x0800EA7C / 0x0800EE9E）
 *
 * 来源：ATOM-IMU v25-12-28。两处代码分别对应 IMU1/IMU2（对象偏移
 * +0x110 / +0x17C）。性质：**按反汇编人工重写**（Ghidra 对该大函数只
 * 部分恢复；以下保持原始控制流与常量）。
 *
 * 关键常量：
 *   0x50 = 80，0xA = 10   → 目标温度钳位 [10, 80] °C
 *   字符串 "set_temp" @0x0801A52B、"Temp:%d" @0x0801A534
 */

/* --- IMU1 版本，0x0800EA7C --- */
int cmd_set_temp_imu1(Args *argv, ImuObject *imu)
{
    int value;

    if (strcmp(argv->arg1, "set_temp") != 0)      /* ldr r1,[pc]; bl strcmp */
        return 0;                                  /* 非本命令 */

    value = atoi(argv->arg2);                      /* bl 0x8017496 */
    if (value > 80) value = 80;                    /* cmp #0x50; it ge */
    if (value < 10) value = 10;                    /* cmp #0xA;  it lt */

    imu_set_temperature(&imu->dev, value);         /* add r0,sl,#0x110; bl 0x800E3E0
                                                    * → 虚表写入（对象 +0x10 的
                                                    *   方法 +4，length=4） */
    printf("Temp:%d\r\n", value);                  /* "Temp:%d" */
    return 1;
}

/* --- IMU2 版本，0x0800EE9E ---
 * 与 IMU1 完全相同，唯一区别是对象偏移 +0x17C（而非 +0x110）。
 * README 的 "两个IMU温度同步，修改一个即可" 是上层命令层做的同步。
 */

/* --- 目标温度参数注册（驱动构造函数 0x0801258C） ---
 * 字符串 "imu_target_temp" @0x0801AEF5 在该函数内被注册到参数数据库，
 * 并以 FUN_08010C50(param_obj, imu + 0x4C) 绑定到 IMU 对象（字节偏移 0x130）。
 */
