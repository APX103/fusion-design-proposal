# 基准构建：主机计时 + 三档 ARM 交叉编译尺寸
CC        ?= cc
ARM_CC    ?= arm-none-eabi-gcc
ARM_SIZE  ?= arm-none-eabi-size

EKF7_DIR  := ../01-quat-zupt-ekf/c
ATOM_DIR  := ../03-atom-imu/reconstructed/c
EKF7_SRC  := $(EKF7_DIR)/ekf7_math.c $(EKF7_DIR)/ekf7_jacobian.c \
             $(EKF7_DIR)/ekf7_filter.c $(EKF7_DIR)/ekf7_motion.c \
             $(EKF7_DIR)/ekf7_pipeline.c
ATOM_SRC  := $(ATOM_DIR)/thermal.c

CFLAGS    := -O2 -std=c99 -Wall -Wextra -I. -I$(EKF7_DIR) -I$(ATOM_DIR)
LDLIBS    := -lm

COMMON_SRC := bench_main.c madgwick.c esekf6.c

all: build/bench_double build/bench_float

build:
	mkdir -p build

# ---- 主机：原版（ekf7 = double） ----
build/bench_double: $(COMMON_SRC) $(EKF7_SRC) $(ATOM_SRC) | build
	$(CC) $(CFLAGS) -o $@ $(COMMON_SRC) $(EKF7_SRC) $(ATOM_SRC) $(LDLIBS)

# ---- 主机：ekf7 转 float（sed 生成副本；仅供算力对比，精度需重验） ----
build/ekf7_float/%.c: $(EKF7_DIR)/%.c | build
	mkdir -p build/ekf7_float
	perl -pe 's/\bdouble\b/float/g' $< > $@
build/ekf7_float/ekf7.h: $(EKF7_DIR)/ekf7.h | build
	mkdir -p build/ekf7_float
	perl -pe 's/\bdouble\b/float/g' $< > $@

build/bench_float: $(COMMON_SRC) build/ekf7_float/ekf7.h | build
	mkdir -p build/ekf7_float
	for f in ekf7_math ekf7_jacobian ekf7_filter ekf7_motion ekf7_pipeline; do \
	  perl -pe 's/\bdouble\b/float/g' $(EKF7_DIR)/$$f.c > build/ekf7_float/$$f.c; \
	done
	$(CC) -O2 -std=c99 -Wall -Wextra -DEKF7_FLOAT -Ibuild/ekf7_float -I. \
	  -I$(ATOM_DIR) -o $@ $(COMMON_SRC) build/ekf7_float/*.c $(ATOM_SRC) $(LDLIBS)

# ---- ARM 交叉编译尺寸（不链接） ----
M4FLAGS  := -O2 -std=c99 -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
M7FLAGS  := -O2 -std=c99 -mcpu=cortex-m7 -mthumb -mfpu=fpv5-d16 -mfloat-abi=hard
M0FLAGS  := -O2 -std=c99 -mcpu=cortex-m0plus -mthumb
XINC     := -I. -Istubs -I$(EKF7_DIR) -I$(ATOM_DIR)

size-m4: | build
	mkdir -p build/m4
	$(ARM_CC) $(M4FLAGS) $(XINC) -c madgwick.c -o build/m4/madgwick.o
	$(ARM_CC) $(M4FLAGS) $(XINC) -c esekf6.c -o build/m4/esekf6.o
	$(ARM_CC) $(M4FLAGS) $(XINC) -c $(ATOM_SRC) -o build/m4/atom_thermal.o
	for f in $(EKF7_SRC); do $(ARM_CC) $(M4FLAGS) $(XINC) -c $$f -o build/m4/ekf7_$$(basename $$f .c).o; done
	$(ARM_SIZE) -t build/m4/*.o

size-m7: | build
	mkdir -p build/m7
	$(ARM_CC) $(M7FLAGS) $(XINC) -c madgwick.c -o build/m7/madgwick.o
	$(ARM_CC) $(M7FLAGS) $(XINC) -c esekf6.c -o build/m7/esekf6.o
	$(ARM_CC) $(M7FLAGS) $(XINC) -c $(ATOM_SRC) -o build/m7/atom_thermal.o
	for f in $(EKF7_SRC); do $(ARM_CC) $(M7FLAGS) $(XINC) -c $$f -o build/m7/ekf7_$$(basename $$f .c).o; done
	$(ARM_SIZE) -t build/m7/*.o

size-m0: | build
	mkdir -p build/m0
	$(ARM_CC) $(M0FLAGS) $(XINC) -c madgwick.c -o build/m0/madgwick.o
	$(ARM_CC) $(M0FLAGS) $(XINC) -c esekf6.c -o build/m0/esekf6.o
	$(ARM_CC) $(M0FLAGS) $(XINC) -c $(ATOM_SRC) -o build/m0/atom_thermal.o
	for f in $(EKF7_SRC); do $(ARM_CC) $(M0FLAGS) $(XINC) -c $$f -o build/m0/ekf7_$$(basename $$f .c).o; done
	$(ARM_SIZE) -t build/m0/*.o

run: build/bench_double build/bench_float
	@echo "--- ekf7 double ---"
	./build/bench_double
	@echo "--- ekf7 float ---"
	./build/bench_float

clean:
	rm -rf build

.PHONY: all run size-m4 size-m7 size-m0 clean
