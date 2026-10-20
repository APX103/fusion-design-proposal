/*
 * bootloader_app_check.c — 应用镜像有效性校验（bootloader FUN_080006A8 与 entry）
 *
 * 来源：ATOM-IMU bootloader.bin，0x080006A8（校验）与 0x08000748（入口）。
 * 性质：Ghidra 反编译输出的整理版。
 *
 * 算法：FNV-1a 32（offset basis 0x811C9DC5，prime 0x01000193）。
 * 语义：从 app 基址 0x08001000 起扫描，寻找某个 4 字节位置，使该处 4 字节
 *       等于此前所有字节的 FNV-1a 哈希值；找到即视为合法镜像。
 *       （即镜像内嵌一个"自校验哈希"；返回非 0 = 有效。）
 */

#define FNV_OFFSET 0x811C9DC5u
#define FNV_PRIME  0x01000193u

/* 返回匹配位置相对 start 的偏移 + 1（非 0 = 有效），0 = 无效 */
uint32_t app_hash_check(const uint8_t *start, uint32_t length)
{
    uint32_t h = FNV_OFFSET;

    for (uint32_t i = 0; i + 4 <= length; i++) {
        /* 比较当前位置的 4 字节与当前哈希（小端） */
        if (memcmp(start + i, &h, 4) == 0)
            return i + 1;
        h = FNV_PRIME * (h ^ start[i]);
    }
    return 0;
}

/* entry 中的关键流程（0x08000748）：
 *   - 读 RCC/FLASH 寄存器、初始化时钟（0x40021000 / 0x40022000）
 *   - 校验区间：app 基址 0x08001000，长度 0x1E000（到 0x0801F000）
 *   - 校验通过：设置 MSP = *(uint32_t*)0x08001000，
 *              跳转 *(uint32_t*)(0x08001000 + 4)（复位向量，Thumb）
 *   - 校验失败：进入 DFU（USB DFU，VID:PID 0483:DF11，WinUSB，
 *              产品名 "Atom IMU Updater"）
 */
