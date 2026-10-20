# 02 · x-IMU3 固件逆向

x-io Technologies x-IMU3 固件 v2.6.0 的静态逆向：架构、AHRS、零偏机制、标定、
数据流水线与传感器推断。全部结论有地址级证据，配套可复跑工具与带符号 ELF。

---

## 固件身份

| 项 | 值 |
|---|---|
| MCU | Microchip PIC32MZ（MIPS32r2 + 单精度 FPU，小端） |
| 程序闪存 | 物理 0x1D000000 / KSEG0 0x9D000000，有效 ≈546 KiB |
| Boot Flash | 0x1FC00000 / 0x9FC00000，复位入口 0x9FC00480 |
| 构建 | Microchip Harmony 风格 + FatFs + USB MSD/CDC + RS9116 Wi-Fi 协处理器 |
| 函数 | 1,235 个符号（jal 目标 + 栈帧序言扫描） |

## 核心发现

**1. 姿态解算：Madgwick 9 轴**（`AhrsUpdate @0x9D036AC8`）

- `q̇ = ½q⊗ω`，π/360 把 ½ 与 deg→rad 合并；
- 加计 + 磁目标函数/雅可比梯度，5 处 `sqrt.s` 归一化；
- 干扰抑制计数器（违约 −9 步进 + 恢复触发）、超量程恢复、初始化增益斜坡、锚定航向；
- 时间戳 dt（±0.3%），400 Hz。

**2. 零漂机制（四层）**

1. 出厂 15 参数标定：`ic = M·s·(iu−b)`，逐样本应用（`0x9D038848`）；
2. 初始化窗口：静置 N 样本均值 → 零偏/初始姿态（`0x9D07BFA4`），
   对应设置项 `gyroscope_offset_correction_offset`（默认开启）；
3. AHRS 闭环：加计/磁持续修正，残余零偏不会无限积分；
4. 观测保护：抑制计数器、恢复触发、超量程、时间戳。

**温度只测不补**：固件只上报温度（5 Hz），标定参数无温度系数；手册明确
"精度只在标定温度有效"。

**3. 传感器推断**（规格 + 封装 + 布局交叉推断，CAD 无丝印）

| 传感器 | 推断 | 置信度 |
|---|---|---|
| 陀螺 + 加计（±24g / ±2000dps / 0.014°/s/√Hz） | Bosch BMI088 | 高 |
| 磁力计（±1300/±2500 µT） | Bosch BMM150 | 很高 |
| 高 g（±200g / 5 mg/√Hz / 1600Hz） | ADI ADXL375 | 中高 |
| 温度（−104~150°C） | 独立温度 IC / 热敏 | 推断 |

## 目录

```
02-ximu3/
├── README.md                  本文件
├── report/
│   ├── XIMU3_逆向报告.md      完整报告（架构/零漂/证据/方法学）
│   └── auto_report.md         自动生成的数据表（函数清单/常量池）
├── pseudocode/                关键函数 C 级伪代码（AHRS/窗口/标定/输出/设置）
├── data/
│   ├── functions.csv          1,235 个函数（地址/大小/FPU 密度/调用数）
│   └── known_disasm/          10 个关键函数的注释反汇编
├── firmware/
│   └── x-IMU3-Firmware-v2.6.0.hex
├── flash_9D000000.bin         展平后的程序闪存镜像
├── boot_9FC00000.bin          展平后的 Boot Flash
├── ximu3_fw_sym.elf           带 1,235 个 FUN_* 符号的 ELF（Ghidra 直接打开）
├── tools/                     ximu3re Python 分析工具（解析/函数发现/ELF 包装/注释反汇编）
└── docs/                      用户手册 v1.11、板级 CAD 图
```

## 算法重建与共享数据集

`refimpl/madgwick9.py` 是 `AhrsUpdate` 的 9 轴 Madgwick 重建（含初始化窗口、
磁方向门控、−9 步进/恢复触发）。运行：

```bash
python3 run_dataset.py        # 读取 ../testdata/imu_scenario.csv，输出 results/ximu3.csv
```

当前基线：roll 0.124° / pitch 0.114° / yaw 0.340°（t≥22 s），干扰段 yaw 0.439°。
注意：Madgwick 推导假设导航系"北 = +x"，数据集是 ENU（北 = +y），运行器输出前
左乘 +90° yaw 统一到 ENU；这是重建实现的对齐处理，不代表固件轴序。

## 复现

```bash
cd tools
pip install -r requirements.txt        # 仅 capstone
python3 -m ximu3re analyze ../firmware/x-IMU3-Firmware-v2.6.0.hex --out out
```

ELF 包装已处理 REA/Ghidra 的 MIPS 通道约束（e_flags=0x70001000、`.MIPS.abiflags`、
o32 ABI）。Ghidra 冷区覆盖不足时，工具通过注入函数符号触发反汇编。

## 局限

- 静态分析，未执行固件；关键函数的轴序/常量语义为人工判读。
- 传感器型号为推断，实板可读 `WHO_AM_I`（BMI088 0x1E/0x0F、BMM150 0x50、ADXL375 0xE5）。
- 运行时零偏校正的减法位置未逐指令确认（推断为并入标定偏置）。
