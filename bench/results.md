# 基准原始数据（2026-10-19）

环境：
- 主机计时：Apple Silicon macOS，clang -O2，每项取 7 次运行最小值
- 交叉编译：`arm-none-eabi-gcc 16.2.0`，`-O2 -std=c99`
- 结论使用说明：主机计时仅用于相对比较（x86 对矩阵代码会 SIMD 化，
  严重低估 Cortex-M 标量成本）；周期数为 **指令级估算**，见下。

## 1. 主机计时（ns/update，min of 7）

| 实现 | ekf7=double 构建 | ekf7=float 构建 |
|---|---:|---:|
| Madgwick（9 轴，float） | 32.9 | 33.8 |
| ES-EKF 6 状态（float） | 277.5 | 285.5 |
| ekf7（7 状态全量） | 122.9 | 109.4 |
| ATOM 温控（一拍） | 22.9 | 25.1 |

## 2. ARM 代码尺寸（.text，字节）

| 实现 | M0+ (80MHz, 无 FPU) | M4F (170MHz) | M7 (480MHz) |
|---|---:|---:|---:|
| Madgwick | 2,456 | 1,164 | 1,128 |
| ES-EKF 6 状态 | 3,672 | 2,880 | 2,876 |
| ekf7（double） | 18,472 | 18,996 | 13,428 |
| ekf7（float，sed 变体） | — | 13,348 | — |
| ATOM 温控 | 2,876 | 2,672 | 2,304 |

软浮点证据：ekf7 double 版在 M4F 目标中引用 `__aeabi_d*` **792 处**，
float 版 168 处（剩余为显式 double 常量/转换）。

## 3. 指令级计数（M4F，objdump）

| 函数 | 静态指令 | 动态估算 |
|---|---:|---:|
| `madgwick_update` | 270 | ≈270 + 6×vsqrt |
| `mat6_mul`（6×6×6） | 31 | ≈1,775 |
| `esekf6_predict` | 162 | ≈4,000（含 2×mat6_mul） |
| `vector_update`（一次） | 499 | ≈6,200（含 2×mat6_mul） |
| `ekf7_filter_step`（float） | 2,023 | ≈5,000–6,000（矩阵循环展开后） |

## 4. 周期估算模型（明确标注为估算）

假设：M4F CPI≈1.3（FPU 单周期，访存占比高）；M7 CPI≈1.0 且有双发射收益；
M0+ 无 FPU，软浮点约为 M4F 的 12×。

| 实现 | M4F cycles/update | M7 cycles/update | M0+ cycles/update |
|---|---:|---:|---:|
| Madgwick | ≈460 | ≈300 | ≈5,500 |
| ES-EKF 6 状态 | ≈21,500 | ≈14,000 | ≈250,000 |
| ekf7 float | ≈9,000 | ≈6,000 | ≈110,000 |
| ekf7 double | ≈36,000（软双精度） | ≈9,000（DP FPU） | ≈430,000 |
| ATOM 温控（10Hz 控制拍） | ≈900 | ≈600 | ≈10,000 |

## 5. 400 Hz AHRS 的 CPU 占用（估算）

| 实现 | M0+ @80MHz | M4F @170MHz | M7 @480MHz |
|---|---:|---:|---:|
| Madgwick | 2.8% | 0.11% | 0.025% |
| ES-EKF 6 状态 | 125%（不可行） | 5.1% | 1.2% |
| ekf7 float | 55% | 2.1% | 0.5% |
| ekf7 double | 215%（不可行） | 8.5% | 0.75% |

## 6. 复现

```bash
cd fusion-design/bench
make run          # 主机计时
make size-m4      # 代码尺寸（另有 size-m7 / size-m0）
```
