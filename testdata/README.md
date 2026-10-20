# 共享测试数据与评测

三个算法共用同一份确定性 IMU 仿真数据，保证对比公平、结果可复现。

## 数据格式

`imu_scenario.csv`（14,000 行，200 Hz，70 s）：

| 列 | 含义 | 单位 |
|---|---|---|
| `t` | 时间戳 | s |
| `ax, ay, az` | 加速度计（比力） | m/s² |
| `gx, gy, gz` | 陀螺 | rad/s |
| `mx, my, mz` | 磁力计 | 任意单位（方向有意义） |
| `qw, qx, qy, qz` | 姿态真值（body→nav，wxyz） | — |

**约定**：导航系 ENU（x 东、y 北、z 上）；欧拉角 ZYX；加计静止时指向 +z；
陀螺含恒定零偏 `[2, −1, 1.5] mrad/s` 与噪声；磁力计含噪声与 40° 方向干扰。

## 场景时间轴

| 时段 | 内容 | 用途 |
|---|---|---|
| 0–20 s | 静置 | 初始化/零偏估计（覆盖 ATOM 前 3000 拍 β×50） |
| 20–40 s | 三轴正弦运动 | 动态跟踪 |
| 40–45 s | 静置 | — |
| 45–55 s | 运动 + 磁干扰（绕 z 转 40°、幅值 ×1.2） | 观测门控 |
| 55–70 s | 静置 | 零漂测量 |

生成脚本：`generate_dataset.py`（固定随机种子 `20261020`）。

## 运行与评测

```bash
# 一键：生成数据 → 跑三个算法 → 评测
python3 run_all.py

# 单独跑某一个（从各自目录，独立）
cd 01-quat-zupt-ekf && python3 run_dataset.py
cd 02-ximu3        && python3 run_dataset.py
cd 03-atom-imu     && python3 run_dataset.py

# 统一评测（结果 CSV 为 name=path）
python3 testdata/evaluate.py \
    --results 01=01-quat-zupt-ekf/results/ekf7.csv \
              02=02-ximu3/results/ximu3.csv \
              03=03-atom-imu/results/atom.csv
```

评测从 **t = 22 s** 开始（跳过所有初始化），指标：

- roll/pitch/yaw RMSE（°）；
- 磁干扰段（45–55 s）yaw RMSE；
- 尾段（60–70 s）yaw 漂移（°/min）；
- 结果写入 `testdata/results_summary.csv`。

## 当前基线（合成数据）

| 算法 | roll | pitch | yaw | 干扰段 | 尾段漂移 |
|---|---:|---:|---:|---:|---:|
| 01-quat-zupt-ekf | 0.175 | 0.150 | 1.700 | 0.961 | −0.004 |
| 02-ximu3 | 0.124 | 0.114 | 0.340 | 0.439 | −2.347 |
| 03-atom-imu | 0.147 | 0.146 | 0.900 | 0.906 | −0.180 |

单位：° 与 °/min。注意这是**合成数据**：陀螺零偏恒定，03（无磁、6 轴）靠静置均值
就能估得很准，因此 yaw 表现偏乐观；真机上温度漂移会让它明显退化（这正是需要
恒温或 P7 温补的原因）。01 的 yaw 略差于 02，主要来自磁航向门控的动态滞后。

## 坐标约定说明

Madgwick 9 轴推导假设导航系"北 = +x"；本数据集是 ENU（北 = +y）。
`02-ximu3/run_dataset.py` 在输出前左乘 +90° yaw 旋转统一到 ENU，
`03-atom-imu` 为 6 轴（不用磁），无此问题。
