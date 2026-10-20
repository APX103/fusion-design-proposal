# x-IMU3 固件逆向工具集 (ximu3re)

针对 **x-io Technologies x-IMU3**（PIC32MZ / MIPS32r2 固件 v2.6.0）的静态分析工具集，
以及本轮逆向的正式交付物（报告 + 伪代码）。

## 这是什么

`ximu3re` 把本次逆向中手工完成的分析流程固化成可复跑的管道：

```
x-IMU3-Firmware-v2.6.0.hex
  └─ intelhex 解析 ──→ flash / boot 原始镜像（KSEG0 虚拟地址 0x9D000000 / 0x9FC00000）
  └─ 函数发现   ──→ jal 目标 + 栈帧序言扫描（~1300 个入口）+ 调用图
  └─ ELF 包装   ──→ 带符号表的 MIPS32 o32 ELF（可直接导入 Ghidra/IDA）
  └─ 注释反汇编 ──→ capstone 反汇编 + 浮点常量池解析 + 已知符号标注
  └─ 自动报告   ──→ Markdown 数据表（函数清单、常量池、已知地址）
```

## 安装与运行

```bash
cd ximu3-re
python3 -m venv .venv && source .venv/bin/activate   # 可选
pip install -r requirements.txt                      # 仅依赖 capstone
python -m ximu3re analyze ../firmware/x-IMU3-Firmware-v2.6.0.hex --out out
```

输出目录 `out/`：

| 文件 | 内容 |
|---|---|
| `flash_9D000000.bin` / `boot_9FC00000.bin` | 展平后的原始镜像 |
| `ximu3_fw_sym.elf` | 带函数符号的 ELF（Ghidra 直接打开即可复现分析） |
| `data/functions.csv` | 全部检测到的函数（地址/大小/FPU 密度/调用数） |
| `data/const_pools.md` | 闪存内浮点常量池清单及语义标注 |
| `data/known_disasm/` | 关键函数的注释反汇编（`.asm`） |
| `auto_report.md` | 自动生成的分析摘要 |

正式报告与伪代码在 `out/` 顶层（手工撰写，见下）。

## 交付物清单

- `out/XIMU3_逆向报告.md` —— 正式逆向报告（架构、零漂机制、证据表、方法学、局限）
- `out/pseudocode/*.c` —— 关键函数的 C 级重构（标注了每处证据地址）：
  - `ahrs_update.c` —— Madgwick AHRS 400 Hz 更新主函数（0x9D036AC8）
  - `ahrs_initialise_window.c` —— 初始化窗口状态机：陀螺均值→零偏、加计/磁计均值→初始姿态（0x9D07BFA4）
  - `calibration_pipeline.c` —— 15 参数标定 `ic = M·s·(iu−b)`（0x9D038848）
  - `euler_output.c` —— 四元数→欧拉角输出级（0x9D048164）
  - `ahrs_engine_init.c` —— 引擎参数装配（0x9D05C740，Ghidra 反编译整理版）
  - `ahrs_reset.c` —— AHRS 复位（0x9D07CA98）

## 关键结论（摘要）

零漂由三层机制压制：**出厂 15 参数标定**（逐样本矩阵乘）→ **上电初始化窗口的陀螺均值零偏估计**
（即设置项 `gyroscope_offset_correction_offset`，默认开启）→ **Madgwick 梯度下降 AHRS**
（β=0.5、400 Hz、加计/磁计干扰抑制 10° 阈值 + 恢复触发、超量程恢复、锚定航向）。

详细证据与地址表见报告。

## 已知符号（tools/ximu3re/known.py）

工具内置了本轮逆向确认的地址。换新版本固件时，`known.py` 里的地址需要重新定位
（推荐方法：先跑 `analyze`，再用 `data/const_pools.md` 里的特征常量锚定）。
