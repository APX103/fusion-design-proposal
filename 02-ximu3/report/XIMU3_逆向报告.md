# x-IMU3 固件逆向工程报告

**目标**：x-io Technologies x-IMU3 固件 v2.6.0（`x-IMU3-Firmware-v2.6.0.hex`）
**日期**：2026-10-19　**方法**：纯静态分析（REA/Ghidra 反编译 + capstone 汇编人工分析）
**配套资料**：用户手册 v1.11、板级 CAD 图（A3, 2:1）

---

## 0. 摘要

x-IMU3 的主控是 **Microchip PIC32MZ**（MIPS32r2 小端 + 单精度 FPU），而非常见猜测的 STM32。
固件约 546 KiB 有效代码，构建于 Microchip Harmony 框架之上：SPI 惯性传感器 + I2C 磁力计/高 g 加速度计
（中断驱动、逐样本时间戳）、RS9116 Wi-Fi 协处理器、USB CDC + 大容量存储、FatFs/microSD、蓝牙。

用户最关心的问题——**零漂如何解决**——在代码中呈现为三层机制：

1. **出厂标定**：每设备 15 参数模型 `ic = M·s·(iu−b)` 在 400 Hz 流水线中逐样本应用；
2. **上电零偏估计**：初始化窗口对陀螺做 N 样本平均，均值作为零偏并从测量中持续扣除
   （即设置项 `gyroscope_offset_correction_offset`，默认开启）；
3. **AHRS 闭环抑制**：完整 Madgwick 梯度下降姿态滤波（β 默认 0.5、400 Hz），
   以加计/磁计观测持续拉回积分漂移，并带干扰抑制与恢复机制。

即：零漂没有被"消除"，而是被**标定 + 静置估计 + 闭环观测**三重压制。

---

## 1. 交付物清单

| 文件 | 说明 |
|---|---|
| `XIMU3_逆向报告.md` | 本文档 |
| `pseudocode/ahrs_update.c` | Madgwick AHRS 更新主函数重构（0x9D036AC8） |
| `pseudocode/ahrs_initialise_window.c` | 初始化窗口/零偏估计状态机重构（0x9D07BFA4） |
| `pseudocode/calibration_pipeline.c` | 15 参数标定流水线重构（0x9D038848） |
| `pseudocode/euler_output.c` | 四元数→欧拉角输出级重构（0x9D048164） |
| `pseudocode/ahrs_engine_init.c` | AHRS 引擎参数装配（0x9D05C740，Ghidra 反编译整理） |
| `pseudocode/ahrs_reset.c` | AHRS 复位（0x9D07CA98，Ghidra 反编译整理） |
| `ximu3_fw_sym.elf` | 带函数符号的 ELF（1235 符号），可直接导入 Ghidra 复现 |
| `flash_9D000000.bin` / `boot_9FC00000.bin` | 展平镜像（0xFF 填充） |
| `data/functions.csv` | 函数清单（地址/大小/FPU 密度/调用者数） |
| `data/known_disasm/*.asm` | 10 个关键函数的注释反汇编 |
| `auto_report.md` | 自动生成的数据表（常量池扫描等） |

分析工具 `tools/ximu3re/`（Python 包）随本报告交付，可对任意版本固件复跑全流程（README 见工程根目录）。

---

## 2. 固件全景

### 2.1 芯片与内存映射

Intel HEX 使用物理地址；运行于 KSEG0 虚拟地址（代码内指针均已证实）：

| 区域 | 物理地址 | 虚拟地址 | 实际内容 |
|---|---|---|---|
| 程序闪存 | 0x1D000000 | **0x9D000000** | 562,240 字节跨度（≈546 KiB 有效） |
| 启动闪存 | 0x1FC00000 | 0x9FC00000 | 复位向量 0x9FC00480，仅 612 字节有效 |
| SRAM 数据 | — | 0x8006xxxx–0x8008xxxx | 对象/设置/缓冲 |

复位入口 0x9FC00480 为 PIC32MZ 标准 `_RESET_ADDR`；0x9D000000 处为经典 PIC32 启动序列
（`b 0x10` + `mfc0 $k0, Cause` 异常分发）。指令集为标准 MIPS32r2（非 microMIPS），大量使用
COP1 单精度指令（`madd.s/msub.s` 熔合乘加）与少量双精度（时间戳运算）。

### 2.2 软件栈构成

| 组件 | 证据 |
|---|---|
| Microchip Harmony 风格驱动 | SFR 访问模式（SPI 0xBF82xxxx、I2C 0xBF85xxxx、TMR 0xBF80/81xxxx） |
| RS9116 Wi-Fi 协处理器 | 完整内嵌其 AT 固件错误字符串表（"No AP found"、"Wrong PSK…"等 50+ 条） |
| FatFs | 0x9D036010/0x9D037E98 的路径解析/LFN 代码与 "NO NAME FAT32" 卷签名 |
| USB MSD + CDC | "MicrochpMass Storage"（原文如此，x-io 拼写错误）、`Self-Test.txt`、`Calibration Certificate.html`（重定向 `x-io.co.uk?sn=%s`） |
| Wi-Fi 默认凭据 | SSID `x-IMU3_%s`、网络名 "x-IMU3 Network"、PIN "1234" |
| 设置注册表 | 名称指针表 0x9D069Exx，100+ 设置项与手册 11.x 节一一对应 |

### 2.3 传感器（型号为规格匹配推断）

| 传感器 | 手册规格 | 推断型号 | 置信度 |
|---|---|---|---|
| 陀螺+加计 | ±2000°/s、±24g、16bit、400Hz、SPI | ST LSM6DS 系列 | 中 |
| 磁力计 | ±1300µT(XY)/±2500µT(Z)、20Hz、I2C | Bosch BMM150 | 高（量程逐位吻合） |
| 高 g 加计 | ±200g、1600Hz、16bit | ADI ADXL372 | 中高 |

---

## 3. 零漂机制（核心结论）

### 3.1 第一层：出厂 15 参数标定（`Pipeline_CalibrateAndEmit` @ 0x9D038848）

400 Hz 流水线对每个惯性传感器逐样本执行手册公式 (2)：

```
ic = M · s · (iu − b)      M: 3×3 失准矩阵, s: 灵敏度对角阵, b: 偏置向量
```

汇编证据（0x9D038858–0x9D0388DC）：`sub.s`（去偏置 +0x30/+0x34/+0x38）→ `mul.s`（灵敏度
+0x24/+0x28）→ 三条 `madd.s`（失准矩阵行乘累加）。标定参数常驻 RAM 对象 0x8007C448
（陀螺 @+0x04..0x38、加计 @+0x3c…、高 g @+0xe8…、磁力计软铁/硬铁 @+0x118/0x13c），
由 `Settings_ApplyAll`（0x9D04A270）在设置变化时重装。

### 3.2 第二层：上电零偏估计（初始化窗口）

AHRS 对象（0x8007CDC0）内含一个**初始化窗口状态机**（状态 @+0x90，计数器 @+0x9c，
窗口长度 @+0x34，三轴累加器 @+0xa0/+0xa4/+0xa8）：

- 状态 0→1：上电/复位后开始累积；
- 每个更新周期：累加器 += 传感器派生量，计数器 +1（0x9D036E1C–0x9D036E54）；
- 计数达到窗口长度：尾调用 `AhrsInitialiseWindow_Step`（0x9D07BFA4）——
  **累加器 ×= 1/N 取均值**，状态置 2（"估计完成"）；
- 陀螺分量的均值即零偏估计，作为设置项 `gyroscope_offset_correction_offset` 暴露
  （默认 `gyroscope_offset_correction_enabled = true`），此后从每帧陀螺测量中扣除；
- 加计/磁计分量的均值用于计算**初始姿态/航向**（轴向约定 NWU/ENU/NED 的符号置换矩阵
  见 0x9D037338/0x9D037368 两分支的 msub/madd 序列，即归一化向量的叉积分量）。

### 3.3 第三层：Madgwick AHRS 闭环（`AhrsUpdate` @ 0x9D036AC8）

确认是 Madgwick 梯度下降实现的完整特征（详见 §4 与伪代码）：

- 陀螺积分 `qDot = ½·q⊗ω`，常数 **π/360 = ½·deg2rad** 已被编译器合并（0x9D085B7C）；
- 加计/磁计目标函数 J 与梯度 s，`qDot −= β·ŝ`（五处 `sqrt.s`+`div.s` 归一化）；
- 四元数归一化后写回 +0x38..0x44；
- 干扰抑制：加计抑制计数器 @+0x6c/+0x70 与磁力计抑制计数器 @+0x84/+0x88，
  阈值 10°（余弦平方比较 `c.lt.s`），超限则丢弃观测并递减计数；恢复触发
  （recovery trigger）持续低于阈值后重新接纳观测；
- 超量程恢复：|ω| > 阈值(+0x1c)（`ext rt,rs,31` 取绝对值技巧）触发重初始化斜坡；
- 初始化增益斜坡：+0x54/+0x58 倒计时，期间高增益收敛；
- 锚定航向：cos²(半角) 阈值比较（0x9D0370EC），2π 常数参与。

**结论**：即使零偏估计有残差，加计（俯仰/横滚）与磁计（航向）观测以 β 增益持续
修正积分误差——这就是"软硬结合解决零漂"的全部工程含义。

---

## 4. 关键代码地图

（虚拟地址；全部经交叉验证）

| 功能 | 地址 | 关键证据 |
|---|---|---|
| **AhrsUpdate**（Madgwik 主更新） | 0x9D036AC8 | 2536 字节、252 条 FPU、5×sqrt 归一化 |
| AhrsUpdate 变体（部分/交替） | 0x9D0391D0 / 0x9D041038 | 由驱动按状态选择 |
| **AhrsInitialiseWindow_Step** | 0x9D07BFA4 | `acc *= 1/N`，状态 1→2 |
| AhrsEngine_Configure | 0x9D05C740 | 运行时池 {400Hz, β, 模式, 10°, 2000°/s, 斜坡, 恢复} |
| AhrsReset | 0x9D07CA98 | 四元数 := (1,0,0,0)，状态清零 |
| AhrsSettings_Apply | 0x9D0545DC | 配置变化时重建引擎 |
| Settings_ApplyAll | 0x9D04A270 | 设置索引分发，重装标定矩阵 |
| **Pipeline_CalibrateAndEmit** | 0x9D038848 | `ic = M·s·(iu−b)` + 24 种消息分发（跳转表 0x9D038A2C）+ 双精度时间戳 |
| SPI 传感器状态机 | 0x9D0384B0 一带 | 寄存器级读写序列 |
| I2C 中断服务（磁/高g） | 0x9D06F550 | I2C SFR + 采样时间戳 |
| Output_QuatToEulerMessage | 0x9D048164 | atan2f/asin、±90° 钳位、×57.29578 |
| 四元数获取 | 0x9D086E88 | 拷贝 +0x38..0x44 |

RAM 对象：`g_ahrs` 0x8007CDC0、`g_calibration` 0x8007C448、
`g_calibrated_samples` 0x8007D950（+8 陀螺、+0x14 加计）、`g_mag_samples` 0x8007DB98、
输出管理器 0x8007D630 / 0x8007BFFC。

浮点常量池（节选，全表见 `auto_report.md`）：0.5 @0x9D085B54、deg2rad @+4、10.0 @+0xC、
2π @+0x18、**0.98 拒绝斜坡系数** @+0x1C、**π/360** @+0x2C、±90/57.2958 @+0x30..；
atanf 多项式系数 {-0.00866, -0.04274, 1/6, -0.70663} @0x9D088518。

### 4.1 AHRS 对象布局（部分复原）

```
+0x00  dt (1/rate)            +0x38..+0x44  四元数 (w,x,y,z)
+0x04  轴向约定 (0 NWU/1 ENU/2 NED)   +0x48..+0x50  加计样本
+0x08  引擎状态 (0 运行/3 停用)       +0x54/+0x58/+0x5c  初始化斜坡 标志/计数/标志
+0x0c/+0x14  斜坡参数            +0x60..+0x68  归一化磁计
+0x18  超量程恢复使能             +0x6c/+0x70  加计抑制 计数/限值
+0x1c  超量程阈值 (2000°/s)        +0x74  斜坡活动标志
+0x24/+0x2c/+0x30  抑制阈值/恢复触发   +0x78..+0x80  磁计观测缓存
+0x34  初始化窗口长度 N           +0x84/+0x88  磁力计抑制 计数/限值
                                  +0x8c  附加标志
                                  +0x90  初始化窗口状态 (0/1/2)
                                  +0x9c  窗口计数器
                                  +0xa0/+0xa4/+0xa8  窗口三轴累加器→均值
```

---

## 5. 数据流水线（400 Hz）

```
SPI 惯性传感器 ──状态机轮询──→ 原始三轴
I2C 磁力计/高g ──中断──→ 原始三轴 + 硬件时间戳
        │
        ▼
Pipeline_CalibrateAndEmit (0x9D038848)
  ├─ 逐传感器: ic = M·s·(iu−b)            ← 第一层（出厂标定）
  ├─ 陀螺扣除运行时零偏                    ← 第二层（初始化窗口估计）
  ├─ 64 位双精度时间戳差 → 秒（±0.3% 速率误差校正）
  ├─ 消息速率分频/平均（各 *_message_rate_divisor 设置）
  ▼
AhrsUpdate (0x9D036AC8)                   ← 第三层（Madgwick 闭环）
  ├─ 增益斜坡 / 超量程恢复 / 干扰抑制
  ├─ 初始化窗口累加（上电前 N 样本）
  ▼
输出级 (0x9D048164 等)
  ├─ 四元数 / 旋转矩阵 / 欧拉角（±90 钳位）
  ├─ 线性加速度 / 地球系加速度（0x8007BFFC 对象）
  └─ USB / 串口 / Wi-Fi TCP/UDP / 蓝牙 / microSD 日志
```

---

## 6. 方法学备注（如何攻破）

1. **Intel HEX → 虚拟地址镜像**：PIC32 HEX 用物理地址，必须重映射到 KSEG0（0x9D…），
   否则所有指针解析错位。
2. **ELF 包装**：REA/Ghidra 的 MIPS 通道只认 ELF，且强制要求 o32 ABI：
   `e_flags = 0x70001000`（32R2|O32，**ABI2 位 0x20 必须为 0**）+
   `.MIPS.abiflags`（isa 32r2、fp_abi=FPXX）。这是反复试错确定的关键约束。
3. **符号注入**：Ghidra 自动分析对无符号 MIPS 的跳转表冷区覆盖不全；
   以 jal 目标 + 栈帧序言（`addiu $sp,$sp,-N` + `sw $ra`）扫描出 1235 个入口
   注入 symtab 后覆盖率大幅提升。注意真实入口可能带 1 字前导（jal 落在序言前 4 字节）。
4. **capstone 兜底**：capstone 5.x 拒解码部分带 cc 谓词位的 COP1 比较指令
   （`c.ule.s` 等），用 skipdata + 手工解码补齐；常量池寻址为
   `lui $rX,0x9D09` + 负偏移，注释器据此还原浮点语义。
5. **函数孤儿问题**：核心函数无一被 jal/分支/指针直接引用（经 vtable 式调度），
   最终通过"jal 落点 ±4 字节邻域扫描"定位真实入口。

## 7. 局限与后续

- 全程静态分析，**未执行固件**；初始化窗口的准确秒数（N 的默认值）与"静置判定"
  门控细节未运行时验证——建议实板读回 `gyroscope offset correction offset` 验证。
- 传感器型号为规格匹配推断；可在实板 SPI/I2C 总线抓 WHO_AM_I 确认。
- 三份 PDF 中的 CAD 图为机械图（无原理图），电平/上拉等电路细节不可得。
- 固件未加密、无 readout 保护迹象——生产 hex 即完整可分析镜像。

## 8. 文件指纹

```
x-IMU3-Firmware-v2.6.0.hex   1,572,906 B  Intel HEX, 34,952 records
flash span                   0x1D000000..0x1D08943F (562,240 B)
boot span                    0x1FC00480..0x1FC0FFF3 (61,916 B records → 612 B 有效)
ximu3_fw_sym.elf             695,648 B, 1235 FUN_* 符号
固件版本字符串               "x-IMU3 v2.6.0" @ 0x9D088B40
```
