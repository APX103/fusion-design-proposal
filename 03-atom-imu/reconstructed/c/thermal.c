/* thermal.c — 见 thermal.h。C99，零依赖、无动态分配。 */
#include <math.h>
#include <stddef.h>
#include <string.h>

#include "thermal.h"

/* ---------------- 热模型 ---------------- */

void thermal_plant_init(thermal_plant_t *p, float t0, float c, float r, float pmax)
{
    p->t = t0; p->c = c; p->r = r; p->pmax = pmax;
}

float thermal_plant_step(thermal_plant_t *p, float duty, float dt, float t_amb)
{
    if (duty < 0.0f) duty = 0.0f;
    if (duty > 1.0f) duty = 1.0f;
    p->t += (duty * p->pmax - (p->t - t_amb) / p->r) / p->c * dt;
    return p->t;
}

/* ---------------- PI ---------------- */

void pi_init(pi_ctrl_t *c, float target, float kp, float ki)
{
    if (target < 10.0f) target = 10.0f;
    if (target > 80.0f) target = 80.0f;
    c->target = target; c->kp = kp; c->ki = ki;
    c->integ = 0.0f; c->duty = 0.0f;
}

float pi_update(pi_ctrl_t *c, float t_meas, float dt)
{
    float err = c->target - t_meas;
    float duty;
    c->integ += err * dt;
    duty = c->kp * err + c->ki * c->integ;
    if (duty > 1.0f) {
        duty = 1.0f;
        c->integ -= err * dt * 0.5f;
    } else if (duty < 0.0f) {
        duty = 0.0f;
        c->integ -= err * dt * 0.5f;
    }
    c->duty = duty;
    return duty;
}

/* ---------------- 温度稳定判据 ---------------- */

void stab_init(stab_t *s, int window, float threshold, float near_target)
{
    if (window > STAB_WINDOW_MAX) window = STAB_WINDOW_MAX;
    if (window < 1) window = 1;
    memset(s, 0, sizeof(*s));
    s->window = window;
    s->threshold = threshold;
    s->near_target = near_target;
}

int stab_update(stab_t *s, float t_meas, float target,
                float *mean_out, float *mad_out)
{
    int i, count, stable;
    float mean = 0.0f, mad = 0.0f, near;

    s->buf[s->head] = t_meas;
    s->head = (s->head + 1) % s->window;
    if (s->n < s->window) s->n++;
    count = s->n;

    for (i = 0; i < count; i++) mean += s->buf[i];
    mean /= (float)count;
    for (i = 0; i < count; i++) mad += fabsf(s->buf[i] - mean);
    mad /= (float)count;

    near = fabsf(mean - target) < s->near_target;
    stable = (count >= s->window) && (mad < s->threshold) && near;
    if (stable && !s->first_stable) s->first_stable = 1;

    if (mean_out) *mean_out = mean;
    if (mad_out) *mad_out = mad;
    return stable;
}

/* ---------------- 12 参数最小二乘 ---------------- */

void cal_init(cal_t *c)
{
    memset(c, 0, sizeof(*c));
}

int cal_add_pose(cal_t *c, const float acc_mean[3],
                 const float gyro_mean[3], const float g_nav[3])
{
    int k;
    if (c->n >= CAL_MAX_POSES) return 0;
    for (k = 0; k < 3; k++) {
        c->acc[c->n][k] = acc_mean[k];
        c->gyr[c->n][k] = gyro_mean[k];
        c->g[c->n][k] = g_nav[k];
    }
    c->n++;
    return 1;
}

/* 列主元高斯消元，原地求解 n×n。返回 1=成功 */
static int gauss_solve(double a[12][12], double b[12], int n)
{
    int col, r, d, piv;
    double tmp;
    for (col = 0; col < n; col++) {
        piv = col;
        for (r = col + 1; r < n; r++)
            if (fabs(a[r][col]) > fabs(a[piv][col])) piv = r;
        if (fabs(a[piv][col]) < 1e-12) return 0;
        if (piv != col) {
            for (d = 0; d < n; d++) {
                tmp = a[col][d]; a[col][d] = a[piv][d]; a[piv][d] = tmp;
            }
            tmp = b[col]; b[col] = b[piv]; b[piv] = tmp;
        }
        for (r = col + 1; r < n; r++) {
            double f = a[r][col] / a[col][col];
            if (f == 0.0) continue;
            for (d = col; d < n; d++) a[r][d] -= f * a[col][d];
            b[r] -= f * b[col];
        }
    }
    for (r = n - 1; r >= 0; r--) {
        double s = b[r];
        for (d = r + 1; d < n; d++) s -= a[r][d] * b[d];
        b[r] = s / a[r][r];
    }
    return 1;
}

int cal_solve(cal_t *c, float bias[3], float M[3][3], float b[3],
              float *residual)
{
    double ata[12][12], aty[12], row[12];
    int i, k, r, cc, dd;
    double ss = 0.0;

    if (c->n < 4) return 0;

    for (k = 0; k < 3; k++) {
        double s = 0.0;
        for (i = 0; i < c->n; i++) s += c->gyr[i][k];
        bias[k] = (float)(s / c->n);
    }

    memset(ata, 0, sizeof(ata));
    memset(aty, 0, sizeof(aty));
    for (i = 0; i < c->n; i++) {
        for (r = 0; r < 3; r++) {
            for (cc = 0; cc < 12; cc++) row[cc] = 0.0;
            for (cc = 0; cc < 3; cc++) row[r * 3 + cc] = c->g[i][cc];
            row[9 + r] = 1.0;
            for (cc = 0; cc < 12; cc++) {
                if (row[cc] == 0.0) continue;
                aty[cc] += row[cc] * c->acc[i][r];
                for (dd = 0; dd < 12; dd++)
                    if (row[dd] != 0.0) ata[cc][dd] += row[cc] * row[dd];
            }
        }
    }
    if (!gauss_solve(ata, aty, 12)) return 0;

    for (r = 0; r < 3; r++) {
        for (cc = 0; cc < 3; cc++) M[r][cc] = (float)aty[r * 3 + cc];
        b[r] = (float)aty[9 + r];
    }

    for (i = 0; i < c->n; i++) {
        for (r = 0; r < 3; r++) {
            double pred = b[r];
            for (cc = 0; cc < 3; cc++) pred += (double)M[r][cc] * c->g[i][cc];
            ss += (pred - c->acc[i][r]) * (pred - c->acc[i][r]);
        }
    }
    if (residual) *residual = (float)sqrt(ss / (double)(c->n * 3));
    return 1;
}

/* ---------------- 状态机 ---------------- */

void atom_scheme_init(atom_scheme_t *s, float target, int window,
                      float threshold, float near_target, int samples_per_pose)
{
    memset(s, 0, sizeof(*s));
    pi_init(&s->pid, target, 0.06f, 0.0015f);
    stab_init(&s->stab, window, threshold, near_target);
    cal_init(&s->cal);
    s->samples_per_pose = samples_per_pose;
    s->state = ST_WARMUP;
}

int atom_scheme_step(atom_scheme_t *s, const float acc[3], const float gyro[3],
                     float t_meas, const float g_nav[3], float dt)
{
    int stable, k;
    s->elapsed += dt;
    pi_update(&s->pid, t_meas, dt);
    stable = stab_update(&s->stab, t_meas, s->pid.target, NULL, NULL);

    if (s->state == ST_WARMUP) {
        if (stable) {
            s->state = ST_STABILIZE;
            s->time_to_stable = s->elapsed;
            s->have_stable_time = 1;
        }
        return s->state;
    }
    if (s->state == ST_STABILIZE) {
        if (stable) {
            s->state = ST_CALIBRATE;
            memset(s->acc_sum, 0, sizeof(s->acc_sum));
            memset(s->gyro_sum, 0, sizeof(s->gyro_sum));
            s->cnt = 0;
        }
        return s->state;
    }
    if (s->state == ST_CALIBRATE) {
        for (k = 0; k < 3; k++) {
            s->acc_sum[k] += acc[k];
            s->gyro_sum[k] += gyro[k];
        }
        s->cnt++;
        if (s->cnt >= s->samples_per_pose) {
            float am[3], gm[3];
            for (k = 0; k < 3; k++) {
                am[k] = s->acc_sum[k] / (float)s->cnt;
                gm[k] = s->gyro_sum[k] / (float)s->cnt;
            }
            cal_add_pose(&s->cal, am, gm, g_nav);
            memset(s->acc_sum, 0, sizeof(s->acc_sum));
            memset(s->gyro_sum, 0, sizeof(s->gyro_sum));
            s->cnt = 0;
            if (s->cal.n >= 4) s->state = ST_READY;
        }
        return s->state;
    }
    return s->state;
}
