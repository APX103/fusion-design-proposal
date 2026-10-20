/*
 * sxtea_ctr.c — 固件镜像解密（bootloader FUN_080004A8，DFU DNLOAD 路径）
 *
 * 来源：ATOM-IMU bootloader.bin（明文，0x08000000）。性质：Ghidra 反编译
 * 输出的整理版 + 逐位复刻的 Python 实现（tools/xxtea_decrypt.py）。
 *
 * 参数：
 *   key = "XRobotLconDddax-"（16B，flash 0x08000CC1 → RAM 0x20000924）
 *   ctr = {0x61852112, 0xddb69722}（flash 0x08000CB8 → RAM 0x20000934）
 *   delta = 0x9E3779B9；32 轮；sum 终止值 0xC6EF3720 (= delta×32)
 *
 * 注意：MX / 键索引与教科书 XXTEA 不同——以下为固件实际算术。
 */

void dfu_download_decrypt(uint8_t *payload, int length)
{
    uint32_t *ctr = (uint32_t *)0x20000934;       /* {v0, v1} */
    uint32_t *k   = (uint32_t *)0x20000924;       /* key[4]    */

    for (int off = 0; off + 8 <= length; off += 8) {
        uint32_t v0 = ctr[0];
        uint32_t v1 = ctr[1];
        uint32_t sum = 0;

        do {
            /* v0 += (((v1>>5) ^ (v1<<4)) + v1) ^ (k[sum & 3] + sum) */
            uint32_t e1 = (((v1 >> 5) ^ (v1 << 4)) + v1)
                        ^ (k[sum & 3] + sum);
            v0 += e1;
            sum += 0x9E3779B9;

            /* idx = (sum >> 11) & 3（固件由 (sum*0x80000)>>30 得到） */
            uint32_t idx = (sum >> 11) & 3;
            /* v1 += (((v0>>5) ^ (v0*16)) + v0) ^ (k[idx] + sum) */
            uint32_t e2 = (((v0 >> 5) ^ (v0 * 16)) + v0)
                        ^ (k[idx] + sum);
            v1 += e2;
        } while (sum != 0xC6EF3720);               /* 32 轮 */

        /* keystream XOR ciphertext，就地写回 */
        *(uint32_t *)(payload + off)     ^= v0;
        *(uint32_t *)(payload + off + 4) ^= v1;

        ctr[0] += 1;                               /* 每 8 字节块低字 +1 */
    }
}

/*
 * (Ghidra 原始片段，0x080004A8，保留供对照)
 *
 *   uVar8 = 0;
 *   do {
 *     uVar13 = *(int *)(iVar6 + (uVar8 & 3) * 4) + uVar8;
 *     uVar8 = uVar8 + 0x9e3779b9;
 *     local_30 = local_30 +
 *       (((uint)pbStack_2c >> 5 ^ (int)pbStack_2c << 4) + (int)pbStack_2c ^ uVar13);
 *     pbStack_2c = (byte *)((int)pbStack_2c +
 *       ((local_30 >> 5 ^ local_30 * 0x10) + local_30 ^
 *        *(int *)(iVar6 + (uVar8 * 0x80000 >> 0x1e) * 4) + uVar8));
 *   } while (uVar8 != uVar3);                  // uVar3 = 0xC6EF3720
 *   ...
 *   *puVar2 = uVar8_old + 1;                   // 计数器递增
 */
