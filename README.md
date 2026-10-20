# IMU 姿态融合技术档案

三个实现 × 一次融合设计：自研 7 状态 EKF、x-IMU3（Madgwick）、ATOM-IMU（恒温 + 标定）。
本仓库收录三者的**源码、固件反编译、算法伪代码、基准数据**，以及面向端侧算力的融合方案。
第 5 节汇总学术界/工业界的混合融合证据（含“Madgwick 串联 EKF 为什么不划算”），
第 6 节给出按场景（无人机 / 机器人 / 空鼠 / 手柄）的 IMU、MCU 与算法选型。

> **先读**：[`index.html`](index.html) —— 完整的对比、融合架构、算力分档与飞控共存建议。
> 本 README 是索引与复现入口。

---

## 1. 三案速览

| | 自研 quat-zupt-ekf | x-IMU3 | ATOM-IMU |
|---|---|---|---|
| 估计器 | 7 状态全量 EKF（q + v，7×7 协方差） | Madgwick 9 轴（梯度下降，β=0.5） | Madgwick 6 轴（加计唯一观测） |
| 观测 | ZUPT 速度 + 磁航向 1 维 | 加计 + 磁，每拍修正 | 仅加计 |
| 零偏 | 静止分窗均值 + 指数平滑（滤波外） | 初始化窗口均值 + 引擎状态 | 专用零偏状态 + 温态标定 |
| 温漂 | 无 | 温度只上报，不补偿 | **硬件恒温 45°C + 0.13°C 稳定判据** |
| 鲁棒机制 | 静止检测、卡方门控、自适应 R | 抑制计数器（−9 步进 / 恢复触发）、超量程恢复、时间戳 dt | 前 3000 拍 β×50、加计零值保护 |
| 算力（400 Hz） | M4F ≈2%（float）/ 8.5%（double） | M4F ≈0.1% | 与 Madgwick 同量级；温控 10 Hz 可忽略 |
| 代表指标 | 姿态/速度/短时位移 | 静态 1° RMS heading（九轴） | yaw 零漂 <10°/h，良好 <3°/h |

## 2. 关键结论（均有证据）

1. **两家商业产品的算法内核相同**：x-IMU3 `AhrsUpdate @0x9D036AC8` 与 ATOM
   `AhrsUpdate @0x08013480` 都是 Madgwick——½q⊗ω、梯度 `s=Jᵀf`、归一化、乘 β。
   差别在观测组合与工程细节，不在算法本身。
2. **x-IMU3 的低漂移是系统工程**：出厂 15 参数标定（逐样本 `M·s·(iu−b)`）+
   初始化窗口均值 + 磁绝对航向 + 门控滞回 + 时间戳 dt；温度只测不补。
3. **ATOM 用误差源治理换零漂**：6 轴、无磁，靠恒温（目标 10–80°C，示例 45°C）、
   0.13°C 温度稳定判据、热平衡后 4 姿态标定，把零偏稳定性做到 <3°/h。
4. **板级选择同样在服务误差预算**：x-IMU3 三颗传感器分立、磁力计置板角；
   ATOM 双 6 轴 IMU（BMI088 + BMI270）共享一个加热区，没有磁/高 g。
5. **端侧按算力分档**：80 MHz 用 Madgwick；170 MHz 用 6 状态 ES-EKF（≈5%）；
   300 MHz 以上用 9/12 状态 ES-EKF（含温漂斜率），并为飞控留出余量。
6. **串联 Madgwick→EKF 有论文，但工业界不用**：Kong 2023 把 Madgwick 的四元数
   作为 EKF 观测量并报告改进，但 EKF 预测复用了同一组 IMU，信息重复、误差相关；
   Jensen 2011 证明常增益 MEKF 本来就是互补滤波的特例。PX4 / ArduPilot /
   VectorNav / x-IMU3 都是“单估计器 + IMU 只做预测 + 多速率观测 + 延迟补偿”。
7. **正确路线**：M4F/M7 直接用单 ES-EKF（400 Hz–1 kHz，算力 2–5%）；
   M0+ 用 Madgwick 快路 + 1–10 Hz 慢速零偏/温漂 EKF 反馈；
   并行双滤波器只用于监督/故障检测，不指望降低噪声底。
8. **场景决定选型**：无人机内环用原始陀螺 PID、姿态 ES-EKF；机器人要 ZUPT/轮速和温补；
   空鼠/手柄是 6 轴相对指向，不需要 EKF。IMU/MCU 选择见第 6 节。

## 3. 目录

```
imu-fusion-dossier/
├── index.html                    完整技术文档（对比 / 融合 / 混合方案 / 场景选型 / 分档 / 飞控共存）
├── README.md                     本文件
├── bench/                        HTML 的基准工程（Madgwick / ES-EKF6 / ATOM 温控）
├── 01-quat-zupt-ekf/             自研算法（原始实现 + 增强版 P1–P8）
├── 02-ximu3/                     x-IMU3 固件逆向（报告 / 反编译 / 伪代码 / 工具 / 固件）
├── 03-atom-imu/                  ATOM-IMU 逆向（解密 / 恒温 / 6 轴 Madgwick / 重建）
├── testdata/                     共享 IMU 仿真数据（含真值）+ 统一评测
├── tests/test_three_way.py       三算法自动化测试（每个子目录独立运行）
└── run_all.py                    一键：生成数据 → 跑三个算法 → 评测
```

每个子目录都有自己的 `README.md`，说明算法、证据、目录结构和复现命令。

## 4. 共享测试数据（同台对比）

`testdata/` 提供 70 s / 200 Hz 的确定性 IMU 数据（含姿态真值、恒定零偏、
磁干扰段）。三个方案各有独立运行器，`01` 的增强版也有独立运行器，读取同一份 CSV：

```bash
python3 run_all.py          # 一键跑三个 + 评测
python3 -m unittest discover -s tests -v   # 自动化测试（独立运行 + 精度阈值）
```

当前基线（合成数据，t≥22 s 评估）：

| 算法 | roll RMSE | pitch RMSE | yaw RMSE | 干扰段 yaw | 尾段漂移 |
|---|---:|---:|---:|---:|---:|
| 01-quat-zupt-ekf | 0.175° | 0.150° | 1.700° | 0.961° | −0.004 °/min |
| 01 增强版 (ekf7plus) | 0.172° | 0.149° | 1.005° | 1.252° | +0.274 °/min |
| 02-ximu3 | 0.124° | 0.114° | 0.340° | 0.439° | −2.347 °/min |
| 03-atom-imu | 0.147° | 0.146° | 0.900° | 0.906° | −0.180 °/min |

说明：合成数据的陀螺零偏恒定，03（无磁、6 轴）靠静置均值估得很准，yaw 偏乐观；
真机的温度漂移会让它退化——这正是恒温/P7 的价值。详见 `testdata/README.md`。

## 5. 融合架构：学术与工业界的真实做法

### 5.1 学术：串联确实有，但不是一个好范式

| 工作 | 做法 | 结论 |
|---|---|---|
| Kong 等, YAC 2023, [DOI](https://doi.org/10.1109/YAC59482.2023.10401414) | Madgwick 先出四元数，作为 EKF 的观测量；EKF 状态方程仍用角速度/加速度 | 报告了对加计突变/非重力加速度的抑制更好；但 EKF 预测复用同一组 IMU，信息重复、误差相关，未做协方差一致性分析 |
| Jensen 2011, [arXiv:1110.0274](https://arxiv.org/abs/1110.0274) | 广义非线性互补滤波器 | 无零偏、常增益的乘性 EKF 是互补滤波的特例——两者同属一个估计器家族 |
| Ludwig & Burnham 2018, [DOI](https://doi.org/10.1109/ICUAS.2018.8453465) | 四旋翼飞行数据上对比 EKF/Madgwick/Mahony | 同类问题的系统性对比 |
| Teague 2016, [arXiv:1602.07733](https://arxiv.org/abs/1602.07733) | 推导互补滤波/EKF/UKF 并对比 | 评估“更复杂的估计器是否值得” |
| Yamagishi & Jing 2026, [arXiv:2607.05451](https://arxiv.org/abs/2607.05451) | 四元数平均的自适应互补滤波 | 低 RMSE、算力低于 Kalman |
| Madyastha 2011, [DOI](https://doi.org/10.2514/6.2011-6615) | EKF vs 误差状态 EKF | 支持 ES-EKF |
| Feng 2024, [DOI](https://doi.org/10.23919/CCC63176.2024.10661750) | 多速率 Kalman 无人机姿态 | 多速率调度是低延迟正解之一 |

**为什么串联不划算：**

- **信息重复**：Madgwick 已用 gyro/accel/mag，EKF 再用同一组，两个估计误差相关，`R` 无法正确建模。
- **没有新增信息**：姿态可观测性来自重力（2 自由度）+ 磁航向（1 自由度），
  两个滤波器用同一份观测，稳态精度下限相同；串联最多是平滑，不会降低噪声底。
- **延迟叠加**：Madgwick 一个采样周期，EKF 再加一个。
- **理论同源**：常增益 MEKF 就是互补滤波特例，融合没有引入第二个独立传感器。

### 5.2 工业界：一个估计器，IMU 只做预测

| 产品/项目 | 架构 | 关键事实 | 外部姿态 |
|---|---|---|---|
| PX4 EKF2 | 24 状态 ES-EKF | IMU 只用于预测，不作为观测；磁力计最低 5 Hz；延迟融合时间轴 + FIFO + 前向传播 | 否 |
| ArduPilot EKF3 | 24 状态 | q、v、p、陀螺/加计零偏、地球/机体磁场、风速；多核冗余 | 否 |
| VectorNav VN-100 | VPE 2.0 | 400 Hz 导航/姿态，800 Hz IMU；外部输入为磁/速度 | 否 |
| x-IMU3 | Madgwick | AHRS 400 Hz，磁 20 Hz；静态 0.5°/1° RMS；温度只用于标定 | 否 |

来源：PX4 文档 <https://docs.px4.io/main/en/advanced_config/tuning_the_ecl_ekf.html>、
ArduPilot `AP_NavEKF3_core.h`、
VectorNav <https://www.vectornav.com/products/detail/vn-100>、
x-io <https://x-io.co.uk/x-imu3/>。

### 5.3 正确做法

| 方案 | 结构 | 延迟 | 适用 |
|---|---|---|---|
| **A 单 ES-EKF** | IMU 只做预测；重力/磁矢量/ZUPT 做观测；磁用 3D 矢量而不是 1D 航向 | ≈1 拍 | M4F/M7，最推荐 |
| **B 快慢分工** | Madgwick 快路 + 1–10 Hz 零偏/温漂 EKF 反馈 | ≈1 拍（快路） | M0+/低功耗 |
| **C 并行监督** | 两套估计器做故障检测/切换；融合用协方差交叉 | ≈1 拍 | 安全关键 |
| **D 固定滞后平滑** | 最近 N 拍优化 | 10–50 ms | 可接受滞后的高精度 |

**算力账：** 400 Hz 周期 2.5 ms；Madgwick ≈2.7 µs、EKF7 float ≈53 µs、
ES-EKF6 ≈126 µs（M4F）。M4F/M7 上单跑 EKF 完全来得及；只有 M0+ 必须用 Madgwick。
真正的延迟来自采样周期、滤波群延迟和传感器时间戳。

## 6. 场景化选型：无人机 / 机器人 / 空鼠 / 手柄

| 场景 | 传感器 | MCU | 算法 | 延迟目标 | 关键点 |
|---|---|---|---|---|---|
| 无人机 | ICM-42688-P / BMI088；磁 IST8310/RM3100；气压 | H743/H723/G4 | 内环 raw gyro PID + 姿态 ES-EKF6/9 | 速率环 <1 ms；姿态 <2.5 ms | 振动/陷波/隔振；磁只用于定位模式 |
| 机器人 | BMI088/ICM-42688；磁 RM3100；轮速/GNSS | F4/H7 | ES-EKF9/12 + ZUPT + 轮速 | 5–20 ms | 室内磁干扰；温漂；6 轴+轮速航向 |
| 空鼠/遥控器 | BMI270/LSM6DSO/ICM-42688（6 轴） | nRF52840/nRF5340/STM32L4 | Madgwick6/互补 + 零偏跟踪 | <10 ms | 无磁；相对指向；静止回中；低功耗 |
| 游戏手柄 | LSM6DSV/LSM6DSO/ICM-42688 | nRF52/STM32L4/RP2040 | 互补/Madgwick6 + 出厂校准 | 有线 <5 ms；BLE <10 ms | 成本/功耗/体感；无绝对航向 |
| AR/VR 手柄 | 6 轴 + 可选磁/光学 | nRF52/H7 | Madgwick6 + 视觉融合 | <5 ms | 遮挡；漂移回中 |
| 可穿戴/行人 | 6 轴 + 磁 | nRF52/Apollo4 | Madgwick9 + ZUPT | 10–20 ms | 功耗；磁干扰；步态 |

**无人机：** 内环 PD/PID 直接用扣除零偏/滤波后的陀螺，不经过姿态解算；姿态只用于
自稳/定高/定点外环。所以 AHRS 的 1–2 拍延迟不进入速率环，真正要保证的是 SPI/DMA、
时间戳和中断优先级。

**机器人：** 要长期稳定，ZUPT/轮速/GNSS 比“更复杂的姿态滤波器”更值钱；室内磁不可信时
用 6 轴 + 轮速/视觉航向。

**空鼠：** 6 轴、无磁、相对指向；yaw 不可测，靠静止/按键回中；Madgwick6 或互补即可，
BLE 连接间隔是主要延迟。

**游戏手柄：** 成本/功耗/延迟优先；互补或 Madgwick6，出厂零偏/灵敏度校准 +
静止零偏跟踪；不做绝对航向。

**选型顺序：** 先定观测量（要不要绝对航向/速度/位置）→ 再定内环速率 → 再定 MCU
（M0+ Madgwick / M4F ES-EKF6 / M7 ES-EKF9-12）→ 最后定 IMU（陀螺噪声密度/零偏稳定性
优先于量程；动态选高 ODR/抗振；电池设备选低功耗）→ 温度方案（恒温/P7/产线标定）。

## 7. 快速开始

```bash
# 1) HTML 文档：直接用浏览器打开
open index.html

# 2) 自研算法（原始实现）
cd 01-quat-zupt-ekf
PYTHONPATH=. python3 examples/demo_synthetic.py

# 3) 增强版：P1–P8 对比（需要与 01 同级的 ekf7/，路径已配置）
cd improved
python3 demo_compare.py          # 与原始 EKF 的同数据对比
python3 demo_thermal.py          # 温度补偿（P7）
python3 demo_atom_scheme.py      # 恒温 + 温态标定（P8）
cd ../..
python3 01-quat-zupt-ekf/run_dataset_plus.py   # 增强版跑共享数据集

# 4) x-IMU3 分析工具（需 capstone）
cd 02-ximu3/tools
python3 -m ximu3re analyze ../firmware/x-IMU3-Firmware-v2.6.0.hex --out out
cd ../..

# 5) ATOM 固件解密 + 算法重建
cd 03-atom-imu
python3 tools/xxtea_decrypt.py --help
python3 tests/diff_test.py       # Python ↔ C 差分验证
make -C reconstructed/c
cd ../..

# 6) 基准（主机计时 + ARM 交叉编译尺寸）
cd bench
make run
make size-m4    # 另有 size-m7 / size-m0
```

## 8. 证据与复现

| 内容 | 位置 |
|---|---|
| x-IMU3 逆向报告 | `02-ximu3/report/XIMU3_逆向报告.md` |
| x-IMU3 关键函数伪代码 | `02-ximu3/pseudocode/*.c` |
| x-IMU3 注释反汇编（10 个函数） | `02-ximu3/data/known_disasm/*.asm` |
| x-IMU3 符号 ELF（Ghidra 可直接打开） | `02-ximu3/ximu3_fw_sym.elf` |
| ATOM 固件解密器与密钥说明 | `03-atom-imu/tools/xxtea_decrypt.py`、`03-atom-imu/docs/ATOM_IMU_逆向笔记.md` |
| ATOM 姿态算法（逐字反编译） | `03-atom-imu/pseudo/ahrs_madgwick.ghidra.c` |
| ATOM 恒温/标定算法（Python + C99） | `03-atom-imu/reconstructed/` |
| 基准原始数据与方法学 | `bench/results.md` |

## 9. 来源与许可

- `01-quat-zupt-ekf/`：用户自有工程，保留其原始 `LICENSE` 与文档。
- `02-ximu3/`：分析对象为用户提供的 x-io x-IMU3 固件（v2.6.0）；报告与工具为本仓库产出。
- `03-atom-imu/`：分析对象为公开仓库 `xrobot-org/atom-sdk` 的固件与文档；
  上游 `README.md` 存于 `03-atom-imu/docs/atom-sdk-README.md`。固件解密仅用于自有设备的互操作分析。

## 10. 局限

- 全部结论来自静态分析与合成数据；**未执行目标固件**，周期/CPU 占用为指令级估算。
- 板级器件型号由规格、封装与固件交叉推断（CAD 无丝印），需实板读 `WHO_AM_I` 确认。
- ATOM 的加热控制律未与固件逐行对齐；标定解算未反编译确认。
- 合成数据不能替代真机数据集回归；接入项目前请复用 `01` 的差分验证方法。
- 第 5 节的论文结论来自摘要/元数据与官方文档，未逐篇复现其实验；工业产品的速率/状态数
  以厂商文档和源码为准。
- 第 6 节的 IMU/MCU 型号是工程建议，不是经过实板验证的 BOM；最终选型需按功耗、
  封装、供货和 EMC 复核。
