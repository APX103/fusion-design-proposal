# IMU 姿态融合技术档案

三个实现 × 一次融合设计：自研 7 状态 EKF、x-IMU3（Madgwick）、ATOM-IMU（恒温 + 标定）。
本仓库收录三者的**源码、固件反编译、算法伪代码、基准数据**，以及面向端侧算力的融合方案。

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

## 3. 目录

```
imu-fusion-dossier/
├── index.html                    完整技术文档（对比 / 融合 / 分档 / 飞控共存）
├── README.md                     本文件
├── bench/                        HTML 的基准工程（Madgwick / ES-EKF6 / ATOM 温控）
├── 01-quat-zupt-ekf/             自研算法（原始实现 + 增强版 P1–P8）
├── 02-ximu3/                     x-IMU3 固件逆向（报告 / 反编译 / 伪代码 / 工具 / 固件）
└── 03-atom-imu/                  ATOM-IMU 逆向（解密 / 恒温 / 6 轴 Madgwick / 重建）
```

每个子目录都有自己的 `README.md`，说明算法、证据、目录结构和复现命令。

## 4. 快速开始

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

# 4) x-IMU3 分析工具（需 capstone）
cd 02-ximu3/tools
python3 -m ximu3re analyze ../firmware/x-IMU3-Firmware-v2.6.0.hex --out out

# 5) ATOM 固件解密 + 算法重建
cd 03-atom-imu
python3 tools/xxtea_decrypt.py --help
python3 tests/diff_test.py       # Python ↔ C 差分验证
make -C reconstructed/c

# 6) 基准（主机计时 + ARM 交叉编译尺寸）
cd bench
make run
make size-m4    # 另有 size-m7 / size-m0
```

## 5. 证据与复现

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

## 6. 来源与许可

- `01-quat-zupt-ekf/`：用户自有工程，保留其原始 `LICENSE` 与文档。
- `02-ximu3/`：分析对象为用户提供的 x-io x-IMU3 固件（v2.6.0）；报告与工具为本仓库产出。
- `03-atom-imu/`：分析对象为公开仓库 `xrobot-org/atom-sdk` 的固件与文档；
  上游 `README.md` 存于 `03-atom-imu/docs/atom-sdk-README.md`。固件解密仅用于自有设备的互操作分析。

## 7. 局限

- 全部结论来自静态分析与合成数据；**未执行目标固件**，周期/CPU 占用为指令级估算。
- 板级器件型号由规格、封装与固件交叉推断（CAD 无丝印），需实板读 `WHO_AM_I` 确认。
- ATOM 的加热控制律未与固件逐行对齐；标定解算未反编译确认。
- 合成数据不能替代真机数据集回归；接入项目前请复用 `01` 的差分验证方法。
