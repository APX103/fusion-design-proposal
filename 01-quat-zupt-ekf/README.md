# 01 · quat-zupt-ekf（自研算法）

七状态全量 EKF 姿态解算：四元数 + 导航系速度，ZUPT 零速观测 + 磁航向观测，
含静止检测、陀螺零偏在线估计与安装矩阵自标定。Python 参考实现 + C99 移植，
两者经过逐拍差分验证。

本目录同时收录我们做的增强版 `improved/`（P1–P8）：误差状态 EKF、重力矢量观测、
门控滞回、温度补偿、恒温 + 温态标定。

---

## 目录

```
01-quat-zupt-ekf/
├── README.md              本文件
├── ekf7/                  Python 参考实现（11 个模块，仅依赖 numpy）
├── c/                     C99 移植（零依赖、无动态分配）
├── examples/              demo_synthetic.py（合成数据行为验证）
├── test/                  差分黑盒测试（Python 参考 vs C 移植）
├── benchmarks/            C 微基准
├── data_*.csv             测试数据
├── docs/                  原工程文档（README-original.md / EKF7_SUMMARY.md / BENCHMARK.md）
└── improved/              增强版（本仓库新增，见下）
```

## 原算法

- 状态：`x = [q0,q1,q2,q3, vE,vN,vU]`（7 维，全量协方差）
- 预测：陀螺角增量右乘传播；比力旋转到导航系积分减重力
- 观测 1：ZUPT（静止速度为零），四档自适应 R
- 观测 2：磁航向 1 维，解析雅可比 + 卡方门控 + 静止超时重对准
- 零偏：静止分窗均值 + 指数平滑（滤波器外）
- 初始化：0.1 s 单位四元数 → 3 s 静置均值 → 粗对准

**已知局限**（原工程文档）：匀速旋转会被静止检测误判，导致 yaw 冻结、零偏污染；
全量四元数协方差数值稳定性弱于 ES-EKF。

## 增强版（`improved/`）

| 文件 | 内容 |
|---|---|
| `improved/ekf7plus/esekf.py` | P1+P2：9 状态 / 12 状态（含温漂斜率）误差状态 EKF |
| `improved/ekf7plus/observations.py` | P3：重力矢量观测；ZUPT；磁航向（误差状态式） |
| `improved/ekf7plus/gating.py` | P4：带恢复触发的拒绝门控（照抄 x-IMU3 的 −9 步进） |
| `improved/ekf7plus/init_window.py` | x-IMU3 初始化窗口的移植（均值 ×1/N） |
| `improved/ekf7plus/atom_scheme.py` | P8：恒温 PI + 0.13°C 稳定判据 + 多姿态标定 |
| `improved/demo_compare.py` | 同数据对比：原始 EKF vs 增强版（场景 A/B） |
| `improved/demo_thermal.py` | P7：无补偿 vs 软件补偿 vs 理想恒温炉 |
| `improved/demo_atom_scheme.py` | P8：无恒温 vs 恒温+稳定后标定 vs 提前标定 |
| `improved/PROPOSAL.md` | P1–P8 的动机、证据、实现与实测数据 |

实测摘要（详见 `improved/PROPOSAL.md`）：

- 匀速旋转 30°/s：原始 EKF yaw RMS 102.7°/max 180°，增强版 0.42°/1.24°；
- 磁干扰段：yaw RMS 1.37° → 0.019°；
- P7 软件温补：yaw RMS 3.79° → 2.38°，零偏误差 5.26 → 0.12 mrad/s；
- P8 恒温方案：积分零漂 −34.6 → −0.39 °/min。

## 共享数据集测试

```bash
python3 run_dataset.py        # 读取 ../testdata/imu_scenario.csv，输出 results/ekf7.csv
```

当前基线：roll 0.175° / pitch 0.150° / yaw 1.700°（t≥22 s RMSE），
磁干扰段 yaw 0.961°，尾段漂移 −0.004 °/min。

## 运行

```bash
# 原始实现
PYTHONPATH=. python3 examples/demo_synthetic.py

# 差分验证（Python 参考 vs C99）
cd test && python3 run_py.py && python3 compare.py

# 增强版
cd improved
python3 demo_compare.py
python3 demo_thermal.py
python3 demo_atom_scheme.py
```

## 来源与局限

原始代码为用户自有工程（保留其 `LICENSE` 与文档）；`improved/` 为本仓库新增。
增强版是机制验证参考实现，参数仅粗调；合成数据结论需用真机数据回归。
