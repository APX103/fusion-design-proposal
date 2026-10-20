/* bench_main.c — 三种/五种实现的主机算力基准。
 *
 * 输出：name,ns_per_update,checksum
 * 说明：主机 x86 计时只用于相对比较；绝对周期数见 HTML 中的换算表。
 */
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "madgwick.h"
#include "esekf6.h"
#include "ekf7.h"
#include "thermal.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define N        20000
#define WARMUP   2000
#define DT       (1.0f/200.0f)
#define G0       9.795502520545487f

static uint32_t lcg_state = 0x12345678u;
static float frand(void)
{
    lcg_state = lcg_state * 1664525u + 1013904223u;
    return ((lcg_state >> 8) & 0xFFFFFF) / 16777216.0f - 0.5f;
}

static void quat_mul_f(const float a[4], const float b[4], float o[4])
{
    o[0] = a[0]*b[0] - a[1]*b[1] - a[2]*b[2] - a[3]*b[3];
    o[1] = a[0]*b[1] + a[1]*b[0] + a[2]*b[3] - a[3]*b[2];
    o[2] = a[0]*b[2] - a[1]*b[3] + a[2]*b[0] + a[3]*b[1];
    o[3] = a[0]*b[3] + a[1]*b[2] - a[2]*b[1] + a[3]*b[0];
}
static void quat_norm_f(float q[4])
{
    float n = sqrtf(q[0]*q[0]+q[1]*q[1]+q[2]*q[2]+q[3]*q[3]);
    if (n > 1e-9f) { q[0]/=n; q[1]/=n; q[2]/=n; q[3]/=n; }
}
static void quat_to_dcm_f(const float q[4], float R[3][3])
{
    float w=q[0],x=q[1],y=q[2],z=q[3];
    R[0][0]=1-2*(y*y+z*z); R[0][1]=2*(x*y-w*z);   R[0][2]=2*(x*z+w*y);
    R[1][0]=2*(x*y+w*z);   R[1][1]=1-2*(x*x+z*z); R[1][2]=2*(y*z-w*x);
    R[2][0]=2*(x*z-w*y);   R[2][1]=2*(y*z+w*x);   R[2][2]=1-2*(x*x+y*y);
}

static float g_acc[N][3], g_gyro[N][3], g_mag[N][3], g_gnav[N][3];

#if defined(EKF7_FLOAT)
typedef float ekf7_in_t;
#else
typedef double ekf7_in_t;
#endif
static ekf7_in_t e_acc[N][3], e_gyro[N][3], e_mag[N][3];

static void generate(void)
{
    float q[4] = {1, 0, 0, 0};
    float bias[3] = {0.002f, -0.001f, 0.0015f};
    float m_nav[3] = {0.0f, 1.0f, -0.4f};
    int k;
    lcg_state = 0x12345678u;
    for (k = 0; k < N; k++) {
        float t = k * DT;
        float w_nav[3] = {0.15f*sinf(2*M_PI*0.3f*t),
                          0.10f*sinf(2*M_PI*0.17f*t),
                          0.80f*sinf(2*M_PI*0.11f*t)};
        float R[3][3], w_body[3], dq[4] = {1,0,0,0};
        int i, j;
        float rv[3];
        quat_to_dcm_f(q, R);
        for (i = 0; i < 3; i++)
            w_body[i] = R[0][i]*w_nav[0] + R[1][i]*w_nav[1] + R[2][i]*w_nav[2];
        for (i = 0; i < 3; i++) rv[i] = w_body[i]*DT;
        {
            float n = sqrtf(rv[0]*rv[0]+rv[1]*rv[1]+rv[2]*rv[2]);
            float s, w;
            if (n > 1e-6f) { w = cosf(n*0.5f); s = sinf(n*0.5f)/n; }
            else { w = 1.0f; s = 0.5f; }
            dq[0]=w; dq[1]=s*rv[0]; dq[2]=s*rv[1]; dq[3]=s*rv[2];
        }
        quat_mul_f(q, dq, q); quat_norm_f(q);
        quat_to_dcm_f(q, R);
        for (i = 0; i < 3; i++) {
            float up_b = R[2][i];                 /* Rᵀ[0,0,1] */
            float mb = R[0][i]*m_nav[0] + R[1][i]*m_nav[1] + R[2][i]*m_nav[2];
            g_acc[k][i]  = up_b*G0 + frand()*0.04f;
            g_mag[k][i]  = mb + frand()*0.02f;
            g_gyro[k][i] = w_body[i] + bias[i] + frand()*0.0016f;
            g_gnav[k][i] = up_b;
            e_acc[k][i]  = (ekf7_in_t)g_acc[k][i];
            e_gyro[k][i] = (ekf7_in_t)g_gyro[k][i];
            e_mag[k][i]  = (ekf7_in_t)g_mag[k][i];
        }
    }
}

static double now_ns(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec*1e9 + (double)ts.tv_nsec;
}

static double report(const char *name, double ns, float checksum, int steps)
{
    printf("%s,%.1f,%f\n", name, ns/steps, checksum);
    return ns/steps;
}

int main(void)
{
    float qm[4] = {1,0,0,0}, qe[4] = {1,0,0,0};
    float bg0[3] = {0,0,0};
    float m_ref[3] = {0, 1, -0.4f};
    esekf6_t ekf;
    ekf7_pipeline pipe;
    ekf7_output out;
    atom_scheme_t atom;
    float checksum = 0.0f;
    double t0, ns;
    int k;

    generate();

    /* ---- Madgwick ---- */
    t0 = now_ns();
    for (k = 0; k < N; k++) {
        madgwick_update(qm, g_gyro[k], g_acc[k], g_mag[k], DT, 0.5f);
        checksum += qm[0];
    }
    ns = now_ns() - t0;
    report("madgwick_float", ns, checksum, N);

    /* ---- ES-EKF 6 ---- */
    checksum = 0.0f;
    esekf6_init(&ekf, qe, bg0, m_ref, 1e-3f, 1e-4f);
    t0 = now_ns();
    for (k = 0; k < N; k++) {
        esekf6_predict(&ekf, g_gyro[k], DT, 0.002f, 1e-4f);
        esekf6_update_gravity(&ekf, g_acc[k], 0.03f);
        esekf6_update_mag(&ekf, g_mag[k], 0.05f);
        checksum += ekf.q[0];
    }
    ns = now_ns() - t0;
    report("esekf6_float", ns, checksum, N);

    /* ---- ekf7（原版 double） ---- */
    checksum = 0.0f;
    ekf7_pipeline_init(&pipe, 200.0, 1, 9);
    for (k = 0; k < WARMUP; k++)
        ekf7_pipeline_calculate(&pipe, e_acc[k], e_gyro[k], e_mag[k], &out);
    t0 = now_ns();
    for (k = WARMUP; k < N; k++) {
        ekf7_pipeline_calculate(&pipe, e_acc[k], e_gyro[k], e_mag[k], &out);
        checksum += (float)out.quat[0];
    }
    ns = now_ns() - t0;
#if defined(EKF7_FLOAT)
    report("ekf7_float", ns, checksum, N-WARMUP);
#else
    report("ekf7_double", ns, checksum, N-WARMUP);
#endif

    /* ---- ATOM 温控（10 Hz 控制环的一拍） ---- */
    checksum = 0.0f;
    {
        thermal_plant_t plant;
        float duty = 0.0f;
        atom_scheme_init(&atom, 45.0f, 50, 0.13f, 0.2f, 200);
        thermal_plant_init(&plant, 20.0f, 3.0f, 15.0f, 3.0f);
        t0 = now_ns();
        for (k = 0; k < N; k++) {
            float temp = thermal_plant_step(&plant, duty, DT, 20.0f);
            int st = atom_scheme_step(&atom, g_acc[k], g_gyro[k], temp,
                                      g_gnav[k], DT);
            duty = atom.pid.duty;
            checksum += (float)st + temp;
        }
        ns = now_ns() - t0;
        report("atom_thermal", ns, checksum, N);
    }
    return 0;
}
