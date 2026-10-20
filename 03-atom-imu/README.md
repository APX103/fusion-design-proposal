# 03 · ATOM-IMU 逆向与算法重建

`xrobot-org/atom-sdk` 的 ATOM-IMU V5.x（STM32G431KB）固件逆向：镜像解密、恒温方案、
6 轴 Madgwick 姿态算法，以及恒温/标定算法的 Python + C99 双实现（含差分验证）。

---

## 固件与解密

- 应用镜像 `firmware_*.elf` 没有 ELF 头，实为 **XXTEA 变体 + 8 字节块 CTR** 加密；
- 密钥：ASCII `"XRobotLconDddax-"`（bootloader flash 0x08000CC1）；
- 计数器初值 `{0x61852112, 0xdDB69722}`，32 轮，delta 0x9E3779B9，
  终止 `sum == 0xC6EF3720`；键索引与教科书 XXTEA 不同，标准实现会解出乱码；
- 解密后加载基址 0x08001000，bootloader 用 FNV-1a 校验应用区
  （0x811C9DC5 / 0x01000193，`0x080006A8`）。

解密器：`tools/xxtea_decrypt.py`，两版固件均已验证。

## 恒温方案（固件证据）

| 环节 | 实现 | 地址 / 常量 |
|---|---|---|
| 温度设置 | `set_temp`，目标钳位 **10–80°C** | `0x0800EA7C` / `0x0800EE9E` |
| 目标参数 | `imu_target_temp`，每颗 IMU 绑定 | 字符串 `0x0801AEF5` |
| 稳定判据 | 环形缓冲均值 + 平均绝对偏差 **< 0.13°C** | `FUN_0800F444`，常量 `0x0800F5A8` |
| 标定门控 | 不稳定直接拒绝："Temperature is not stable!" | `0x0800EC50` |
| 流程 | 预热 10 min → 4 姿态静置 ≥1 min → 保存零偏/安装 | 上游 README |
| 指标 | yaw 零漂 <10°/h，良好环境 <3°/h | 上游 README |

板级：**双 6 轴 IMU（BMI088 + BMI270）**、单一加热区（黄色功率电阻 + 220µF/16V
储能电容）、**没有磁力计、没有高 g**。固件驱动模块仅见这两个 IMU。

## 姿态算法：6 轴 Madgwick

`FUN_08013480`（0x08013480）为姿态更新：

- 状态：四元数 `+0x20..+0x2C`、陀螺零偏 `+0xD8..+0xE0`、dt `+0x80`、增益 β `+0x04`；
- `q̇ = ½q⊗ω`；加速度计归一化后计算梯度 `s = Jᵀf`，归一化并乘 β；
- **前 3000 拍 β × 50**（常量 0x080138C0 = 50.0f）快速收敛，期间不发布姿态；
- 输出欧拉角（atan2f/asin）并发布四元数（16B）与欧拉角（12B）；
- **无任何磁力计项** → 航向靠陀螺积分，零漂完全取决于零偏稳定性（因此必须恒温）。

逐字反编译：`pseudo/ahrs_madgwick.ghidra.c`；注释版：`pseudo/ahrs_madgwick.c`。

## 算法重建（恒温 + 标定）

`reconstructed/` 提供与 C 版逐函数对应的 Python 参考实现：

| 模块 | 行为 |
|---|---|
| `ThermalPlant` | 一阶热模型（验证用） |
| `PIController` | 恒温 PI，抗积分饱和，目标 10–80°C 钳位 |
| `TempStabilityDetector` | 均值 + 平均绝对偏差 < 0.13°C（固件同构） |
| `MultiPoseCalibration` | 陀螺零偏均值 + 加计 12 参数最小二乘 |
| `AtomScheme` | `WARMUP → STABILIZE → CALIBRATE → READY` |

Python 与 C99 经过同场景差分验证（状态序列逐拍一致，温度/零偏在容差内），
且 12 参数标定能还原注入的真值模型。

## 目录

```
03-atom-imu/
├── README.md                  本文件
├── pseudo/                    反编译伪代码（逐字 + 注释版）
│   ├── ahrs_madgwick.ghidra.c 姿态更新：Ghidra 原始输出
│   ├── ahrs_madgwick.c        姿态更新：注释版
│   ├── temp_stability_detector.c
│   ├── set_temp_command.c
│   ├── sxtea_ctr.c            镜像解密循环
│   └── bootloader_app_check.c FNV-1a 应用校验
├── reconstructed/
│   ├── python/atomimu_re/     Python 参考实现（纯标准库）
│   └── c/                     C99 实现 + Makefile + 确定性测试
├── tests/
│   ├── run_python.py          与 C 同场景
│   └── diff_test.py           Python ↔ C 差分验证
├── tools/xxtea_decrypt.py     固件解密器（含 ELF 包装）
├── firmware/                  解密后的应用镜像 + ELF + bootloader
├── docs/                      逆向笔记、上游 README、焊接记录 PDF
└── img/                       板级照片（双 IMU、加热电阻、储能电容）
```

## 复现

```bash
# 解密自己的固件
python3 tools/xxtea_decrypt.py ../../atom-sdk/firmware/firmware_25-12-28.elf \
        -o firmware/app.bin --elf 0x08001000

# C 版构建与运行
make -C reconstructed/c
./reconstructed/c/atom_thermal_test

# 差分验证
python3 tests/diff_test.py
```

## 局限

- 加热控制律未与固件逐行对齐（应用层控制循环未完整定位，重建用标准 PI）；
- 4 姿态标定的内部解算未反编译确认（重建用标准 12 参数加计模型）；
- AHRS 线程实际频率与 β 默认值未确认（3000 拍对应的绝对时间取决于线程周期）；
- 所有行为结论来自静态分析与合成数据，未执行固件。
