/* thermal.h — ATOM-IMU 恒温/标定算法的 C99 参考实现。
 *
 * 与 reconstructed/python/atomimu_re/thermal.py 逐函数对应，供嵌入式集成
 * 与 Python/C 差分验证。算法依据见 ../../README.md。
 */
#ifndef ATOM_THERMAL_H
#define ATOM_THERMAL_H

#define STAB_WINDOW_MAX 64
#define CAL_MAX_POSES   8

/* ---- 一阶热模型（仅验证用） ---- */
typedef struct {
    float t, c, r, pmax;
} thermal_plant_t;

void  thermal_plant_init(thermal_plant_t *p, float t0, float c, float r, float pmax);
float thermal_plant_step(thermal_plant_t *p, float duty, float dt, float t_amb);

/* ---- 恒温 PI（目标钳位 10–80°C，与固件一致） ---- */
typedef struct {
    float target, kp, ki, integ, duty;
} pi_ctrl_t;

void  pi_init(pi_ctrl_t *c, float target, float kp, float ki);
float pi_update(pi_ctrl_t *c, float t_meas, float dt);

/* ---- 温度稳定性判据（固件 FUN_0800F444 同构） ---- */
typedef struct {
    float buf[STAB_WINDOW_MAX];
    int   window, n, head;
    float threshold, near_target;
    int   first_stable;
} stab_t;

void stab_init(stab_t *s, int window, float threshold, float near_target);
/* 返回 1=稳定；mean_out/mad_out 可为 NULL */
int  stab_update(stab_t *s, float t_meas, float target,
                 float *mean_out, float *mad_out);

/* ---- 多姿态标定（陀螺零偏 + 加计 12 参数 LS） ---- */
typedef struct {
    int   n;
    float acc[CAL_MAX_POSES][3];
    float gyr[CAL_MAX_POSES][3];
    float g[CAL_MAX_POSES][3];
} cal_t;

void cal_init(cal_t *c);
int  cal_add_pose(cal_t *c, const float acc_mean[3],
                  const float gyro_mean[3], const float g_nav[3]);
/* 返回 1=成功；bias[3], M[3][3] 行主序, b[3], *residual */
int  cal_solve(cal_t *c, float bias[3], float M[3][3], float b[3],
               float *residual);

/* ---- 状态机：预热 → 稳定 → 标定 → 就绪 ---- */
typedef enum {
    ST_WARMUP = 0, ST_STABILIZE = 1, ST_CALIBRATE = 2, ST_READY = 3
} scheme_state_t;

typedef struct {
    pi_ctrl_t  pid;
    stab_t     stab;
    cal_t      cal;
    int        samples_per_pose;
    int        state;
    float      elapsed;
    float      time_to_stable;
    int        have_stable_time;
    float      acc_sum[3], gyro_sum[3];
    int        cnt;
} atom_scheme_t;

void atom_scheme_init(atom_scheme_t *s, float target, int window,
                      float threshold, float near_target, int samples_per_pose);
/* 返回 scheme_state_t */
int  atom_scheme_step(atom_scheme_t *s, const float acc[3], const float gyro[3],
                      float t_meas, const float g_nav[3], float dt);

#endif /* ATOM_THERMAL_H */
