# ATOM-IMU V5.x 固件逆向笔记（恒温方案分析）

对象：`firmware/firmware_25-12-28.elf`、`firmware/bootloader.bin`
方法：明文 bootloader 反汇编 + 固件 XXTEA 解密 + REA/Ghidra 反编译（ARM Cortex-M4F，STM32G431KB）

---

## 0. 结论速览

ATOM-IMU 的温漂方案是**硬件恒温 + 温态标定**：

1. 每颗 IMU 配加热电阻，由 STM32 定时器 PWM 驱动；目标温度可设（命令 `set_temp`，
   固件钳位 **10–80°C**，README 示例为 **45°C**，两颗 IMU 目标同步）。
2. 温度来自 BMI088/BMI270 内部温度传感器（整数原始值，`Temp:%d`）。
3. 固件内**温度稳定性判据**：温度环形缓冲的**平均绝对偏差 < 0.13°C** 才置"稳定"标志；
   标定流程在稳定标志为 0 时直接报 `Temperature is not stable!` 并拒绝校准。
4. 标定流程（README）：上电预热 10 分钟 → 4 个姿态（平放/倒置/侧放/平放），
   每个姿态静置 ≥1 分钟 → 估算零偏/安装 → 保存；另提供 `test` 零漂测量、
   `list_offset` 查看零偏。
5. 指标：yaw 零漂 **< 10°/h，良好环境 < 3°/h**；另有 `bmi270_gyro_bias` 线程做在线零偏。

**这就是用户提出的"电热管 + 测温 + 稳在 45°C"方案的商品化实现**，且比单纯恒温多了
"温度稳定后再标定"这一关键步骤。

---

## 1. 固件镜像解密

`firmware_*.elf` 没有 ELF 头（熵 ≈ 8.0），实为加密应用镜像。

### 1.1 解密算法（bootloader 0x080004A8 DFU DNLOAD 路径）

- 算法：**XXTEA 变体 + 8 字节块 CTR**
  - `keystream = xxtea32_variant(counter_block, key)`
  - `plaintext = ciphertext XOR keystream`
  - 计数器初值 `{0x61852112, 0xddb69722}`，每块低字 +1
  - 32 轮，`delta = 0x9E3779B9`，循环终止 `sum == 0xC6EF3720`
- 密钥：**ASCII `"XRobotLconDddax-"`**（16 字节；bootloader flash 0x08000CC1 拷到 RAM 0x20000924）
- 注意：该变体的 MX 运算与教科书 XXTEA 不同——键索引用 `sum&3` 与
  `(sum>>11)&3`，第二项为 `((v0>>5)^(v0*16)+v0) ^ (k[idx]+sum)`；
  直接套教科书实现会失败。已按反编译逐位复刻于 `firmware/xxtea_decrypt.py`。

解密后镜像：SP=0x20008000（32KB SRAM），复位向量 0x0800DEE9，加载基址 **0x08001000**
（bootloader 校验区间 0x08001000–0x0801F000，FNV-1a 校验：offset basis 0x811C9DC5，
prime 0x01000193，函数 0x080006A8）。

### 1.2 可复现命令

```bash
cd firmware
python3 xxtea_decrypt.py firmware_25-12-28.elf -o app.bin --elf 0x08001000
```

两版固件（12-21 / 12-28）均验证通过（向量表合法、字符串可读、代码可反编译）。

---

## 2. 温度链路（证据地址）

| 功能 | 地址 | 说明 |
|---|---|---|
| `set_temp` 命令处理 | 0x0800EA7C / 0x0800EE9E | 两处分别对应 IMU1/IMU2：`strcmp("set_temp")` → `atoi` → **钳位 10…80** → 写对象 +0x110/+0x17C → 打印 `Temp:%d` |
| 目标温度参数 | 字符串 `imu_target_temp` @0x0801AEF5 | 在 IMU 驱动构造函数中注册/绑定（0x0801258C, 0x08012908 两处） |
| 温度原始值 | 对象 +0x188（uint）→ 转 float 存 +0x190 | 0x080127C2 `vldr s15,[r4,#0x188]; vcvt.f32.u32` |
| **温度稳定性检测** | FUN_0800F444 | 环形缓冲均值 + 平均绝对偏差；`avg_dev < 0.13` 置稳定标志（对象 +0x2C）；首次稳定时复位滤波器状态（+0xCC..+0xDC 清零） |
| 稳定阈值常量 | 0x0800F5A8 = **0.13** | `float 0.13` |
| 校准拒绝 | 0x0800EC50 | `ldrb [r4,#0x2C]; cbnz` → 不稳定则打印 `Temperature is not stable!` 并返回 −1 |
| 校验收敛判据 | 0x0800EF04 = 0.95 | 标定残差比较 |
| 加热 PWM | TIM1 驱动簇 0x08002D80–0x08003300 | STM32G4 高级定时器 PWM；GPIOA/GPIOB 配置见 0x08008730 等 |

其他相关：`bmi088_thread`、`bmi270_gyro_bias`、`ahrs_calibration`、`ahrs_euler`、
`ahrs_quaternion`、`imu_accl`、`imu_gyro`、`power_manager` 等线程/模块名（libxr 框架）。

工具链：RT-Thread + `libxr`（作者自研框架）+ 自有 shell。

---

## 3. 可"抄"的方案定义（已移植到 ../xio/ekf7-plus）

| 环节 | ATOM-IMU 做法（证据） | 移植实现 |
|---|---|---|
| 加热控制 | PWM 加热，目标可设，10–80°C 钳位 | `ThermalPlant` + `PIController`（抗积分饱和、占空比 0–1） |
| 温度稳定判据 | 均值 + 平均绝对偏差 < **0.13°C** | `TempStabilityDetector`（窗口、阈值均可配，默认 0.13） |
| 标定门控 | 不稳定 → 拒绝标定 | 状态机 `WARMUP → STABILIZE → CALIBRATE → READY` |
| 多姿态标定 | 4 姿态、每姿态静置 ≥1 min | `MultiPoseCalibration`：gyro 零偏均值 + accel 12 参数最小二乘 |
| 标定后验证 | `test` 测零漂 | demo 中计算积分零漂（°/min） |

移植代码与对比实验见：

```
../xio/ekf7-plus/ekf7plus/atom_scheme.py
../xio/ekf7-plus/demo_atom_scheme.py
```

对比（合成数据，480 s）：恒温+稳定后标定 vs 不恒温室温标定 vs 恒温但不等稳定就标定。
详见 `../xio/ekf7-plus/PROPOSAL.md` 的 P8 一节。

---

## 4. 局限

- 加热 PWM 的**具体控制律**未逐行提取（TIM1 驱动簇为 HAL 层；应用层控制循环
  未完整定位）。移植实现采用标准 PI，参数按热模型整定，未声称与固件逐位一致。
- 固件标定流程的**内部算法**（4 姿态解算的具体模型）未反编译确认；移植版采用
  标准的零偏均值 + 12 参数加速度计模型。
- 目标温度默认值是 45°C 的依据是 README 示例与产品行为，未在固件中确认唯一默认值
  （固件中 0x08014B98 处的 45.0 位于 AHRS 初始化块，用途不唯一）。
- 本文只做互操作/研究分析；解密工具仅用于分析自己持有的设备固件。
