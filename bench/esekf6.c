/* esekf6.c — 6 状态误差状态 EKF（float），用于融合方案的 Tier-1 基准。
 *
 * 名义状态：q(wxyz, body->nav)、bg(3)。
 * 误差状态：x = [δθ(3), δbg(3)]，q_true = q ⊗ δq(δθ)。
 * 观测：单位重力矢量、单位磁场矢量（参考方向由 init 传入并锚定）。
 */
#include <math.h>
#include <string.h>

#include "esekf6.h"

static void quat_mul(const float a[4], const float b[4], float o[4])
{
    o[0] = a[0]*b[0] - a[1]*b[1] - a[2]*b[2] - a[3]*b[3];
    o[1] = a[0]*b[1] + a[1]*b[0] + a[2]*b[3] - a[3]*b[2];
    o[2] = a[0]*b[2] - a[1]*b[3] + a[2]*b[0] + a[3]*b[1];
    o[3] = a[0]*b[3] + a[1]*b[2] - a[2]*b[1] + a[3]*b[0];
}

static void quat_norm(float q[4])
{
    float n = sqrtf(q[0]*q[0] + q[1]*q[1] + q[2]*q[2] + q[3]*q[3]);
    if (n > 1e-9f) { q[0]/=n; q[1]/=n; q[2]/=n; q[3]/=n; }
}

static void quat_from_rv(const float rv[3], float q[4])
{
    float n2 = rv[0]*rv[0] + rv[1]*rv[1] + rv[2]*rv[2];
    float w, s;
    if (n2 < 1e-8f) {
        w = 1.0f - n2*(0.125f - n2/384.0f);
        s = 0.5f - n2*(1.0f/48.0f - n2/3840.0f);
    } else {
        float n = sqrtf(n2);
        w = cosf(n*0.5f);
        s = sinf(n*0.5f)/n;
    }
    q[0]=w; q[1]=s*rv[0]; q[2]=s*rv[1]; q[3]=s*rv[2];
}

static void quat_to_dcm(const float q[4], float R[3][3])
{
    float w=q[0], x=q[1], y=q[2], z=q[3];
    float w2=w*w, x2=x*x, y2=y*y, z2=z*z;
    float xy=x*y, xz=x*z, yz=y*z, wx=w*x, wy=w*y, wz=w*z;
    R[0][0]=w2+x2-y2-z2; R[0][1]=2*(xy-wz);     R[0][2]=2*(xz+wy);
    R[1][0]=2*(xy+wz);   R[1][1]=w2-x2+y2-z2;   R[1][2]=2*(yz-wx);
    R[2][0]=2*(xz-wy);   R[2][1]=2*(yz+wx);     R[2][2]=w2-x2-y2+z2;
}

static void mat6_zero(float m[6][6]) { memset(m, 0, sizeof(float)*36); }

static void mat6_mul(const float a[6][6], const float b[6][6], float o[6][6])
{
    int i, j, k;
    for (i = 0; i < 6; i++)
        for (j = 0; j < 6; j++) {
            float s = 0.0f;
            for (k = 0; k < 6; k++) s += a[i][k]*b[k][j];
            o[i][j] = s;
        }
}

static void mat6_sym(float m[6][6])
{
    int i, j;
    for (i = 0; i < 6; i++)
        for (j = i+1; j < 6; j++) {
            float v = 0.5f*(m[i][j] + m[j][i]);
            m[i][j] = m[j][i] = v;
        }
}

/* 3×3 求逆（伴随矩阵），返回 det */
static float mat3_inv(const float a[3][3], float inv[3][3])
{
    float det = a[0][0]*(a[1][1]*a[2][2] - a[1][2]*a[2][1])
              - a[0][1]*(a[1][0]*a[2][2] - a[1][2]*a[2][0])
              + a[0][2]*(a[1][0]*a[2][1] - a[1][1]*a[2][0]);
    float id = (fabsf(det) > 1e-12f) ? 1.0f/det : 0.0f;
    inv[0][0] =  (a[1][1]*a[2][2] - a[1][2]*a[2][1])*id;
    inv[0][1] = -(a[0][1]*a[2][2] - a[0][2]*a[2][1])*id;
    inv[0][2] =  (a[0][1]*a[1][2] - a[0][2]*a[1][1])*id;
    inv[1][0] = -(a[1][0]*a[2][2] - a[1][2]*a[2][0])*id;
    inv[1][1] =  (a[0][0]*a[2][2] - a[0][2]*a[2][0])*id;
    inv[1][2] = -(a[0][0]*a[1][2] - a[0][2]*a[1][0])*id;
    inv[2][0] =  (a[1][0]*a[2][1] - a[1][1]*a[2][0])*id;
    inv[2][1] = -(a[0][0]*a[2][1] - a[0][1]*a[2][0])*id;
    inv[2][2] =  (a[0][0]*a[1][1] - a[0][1]*a[1][0])*id;
    return det;
}

void esekf6_init(esekf6_t *f, const float q0[4], const float bg0[3],
                 const float m_ref[3], float p_theta, float p_bias)
{
    int i;
    memcpy(f->q, q0, sizeof f->q);
    memcpy(f->bg, bg0, sizeof f->bg);
    memcpy(f->m_ref, m_ref, sizeof f->m_ref);
    mat6_zero(f->P);
    for (i = 0; i < 3; i++) {
        f->P[i][i] = p_theta;
        f->P[i+3][i+3] = p_bias;
    }
}

void esekf6_predict(esekf6_t *f, const float gyro[3], float dt,
                    float gyro_arw, float bias_rw)
{
    float w[3], rv[3], dq[4], qn[4], Phi[6][6], tmp[6][6], Pn[6][6];
    int i, j;

    for (i = 0; i < 3; i++) w[i] = gyro[i] - f->bg[i];
    for (i = 0; i < 3; i++) rv[i] = w[i]*dt;
    quat_from_rv(rv, dq);
    quat_mul(f->q, dq, qn);
    quat_norm(qn);
    memcpy(f->q, qn, sizeof f->q);

    /* Φ = I + Fc·dt，Fc = [[-skew(w), -I], [0, 0]] */
    mat6_zero(Phi);
    for (i = 0; i < 6; i++) Phi[i][i] = 1.0f;
    Phi[0][1] =  w[2]*dt;  Phi[0][2] = -w[1]*dt;
    Phi[1][0] = -w[2]*dt;  Phi[1][2] =  w[0]*dt;
    Phi[2][0] =  w[1]*dt;  Phi[2][1] = -w[0]*dt;
    Phi[0][3] = Phi[1][4] = Phi[2][5] = -dt;

    mat6_mul(Phi, f->P, tmp);
    {
        float PhiT[6][6];
        for (i = 0; i < 6; i++)
            for (j = 0; j < 6; j++) PhiT[i][j] = Phi[j][i];
        mat6_mul(tmp, PhiT, Pn);                  /* P = ΦPΦᵀ */
    }
    for (i = 0; i < 3; i++) {
        Pn[i][i]     += gyro_arw*gyro_arw*dt;
        Pn[i+3][i+3] += bias_rw*bias_rw*dt;
    }
    memcpy(f->P, Pn, sizeof f->P);
    mat6_sym(f->P);
}

/* 单位矢量观测：z=meas/|meas|，h=Rᵀ·ref（ref 与 meas 同量纲方向）。
 * H = [skew(h), 0]，3×6。 */
static void vector_update(esekf6_t *f, const float meas[3],
                          const float ref[3], float sigma)
{
    float mn = sqrtf(meas[0]*meas[0] + meas[1]*meas[1] + meas[2]*meas[2]);
    float rn = sqrtf(ref[0]*ref[0] + ref[1]*ref[1] + ref[2]*ref[2]);
    float R[3][3], h[3], z[3], r[3], H[3][6], S[3][3], Sinv[3][3];
    float PHt[6][3], K[6][3], dx[6], IKH[6][6], tmp[6][6], Pn[6][6];
    int i, j, k;

    if (mn < 1e-6f || rn < 1e-6f) return;
    for (i = 0; i < 3; i++) z[i] = meas[i]/mn;
    quat_to_dcm(f->q, R);
    {
        float rh[3];
        for (i = 0; i < 3; i++) rh[i] = ref[i]/rn;
        for (i = 0; i < 3; i++)                   /* h = Rᵀ·ref_hat */
            h[i] = R[0][i]*rh[0] + R[1][i]*rh[1] + R[2][i]*rh[2];
    }
    for (i = 0; i < 3; i++) r[i] = z[i] - h[i];

    memset(H, 0, sizeof H);
    H[0][1] = -h[2]; H[0][2] =  h[1];
    H[1][0] =  h[2]; H[1][2] = -h[0];
    H[2][0] = -h[1]; H[2][1] =  h[0];

    /* S = H P Hᵀ + σ²I */
    for (i = 0; i < 6; i++)
        for (j = 0; j < 3; j++) {
            float s = 0.0f;
            for (k = 0; k < 6; k++) s += f->P[i][k]*H[j][k];
            PHt[i][j] = s;
        }
    for (i = 0; i < 3; i++)
        for (j = 0; j < 3; j++) {
            float s = 0.0f;
            for (k = 0; k < 6; k++) s += H[i][k]*PHt[k][j];
            S[i][j] = s + ((i == j) ? sigma*sigma : 0.0f);
        }
    mat3_inv(S, Sinv);

    /* K = P Hᵀ S⁻¹ = PHt · S⁻¹ */
    for (i = 0; i < 6; i++)
        for (j = 0; j < 3; j++) {
            float s = 0.0f;
            for (k = 0; k < 3; k++) s += PHt[i][k]*Sinv[k][j];
            K[i][j] = s;
        }
    for (i = 0; i < 6; i++) {
        float s = 0.0f;
        for (j = 0; j < 3; j++) s += K[i][j]*r[j];
        dx[i] = s;
    }

    /* 注入 */
    {
        float dq[4], qn[4];
        quat_from_rv(dx, dq);
        quat_mul(f->q, dq, qn);
        quat_norm(qn);
        memcpy(f->q, qn, sizeof f->q);
    }
    for (i = 0; i < 3; i++) f->bg[i] += dx[i+3];

    /* Joseph: P = (I−KH)P(I−KH)ᵀ + K R Kᵀ，R=σ²I */
    memset(IKH, 0, sizeof IKH);
    for (i = 0; i < 6; i++) IKH[i][i] = 1.0f;
    for (i = 0; i < 6; i++)
        for (j = 0; j < 6; j++) {
            float s = 0.0f;
            for (k = 0; k < 3; k++) s += K[i][k]*H[k][j];
            IKH[i][j] -= s;
        }
    mat6_mul(IKH, f->P, tmp);
    {
        float IKHt[6][6];
        for (i = 0; i < 6; i++)
            for (j = 0; j < 6; j++) IKHt[i][j] = IKH[j][i];
        mat6_mul(tmp, IKHt, Pn);
    }
    for (i = 0; i < 6; i++)
        for (j = 0; j < 6; j++) {
            float s = 0.0f;
            for (k = 0; k < 3; k++) s += K[i][k]*K[j][k];
            Pn[i][j] += sigma*sigma*s;
        }
    memcpy(f->P, Pn, sizeof f->P);
    mat6_sym(f->P);
}

void esekf6_update_gravity(esekf6_t *f, const float acc[3], float sigma)
{
    const float up[3] = {0.0f, 0.0f, 1.0f};
    vector_update(f, acc, up, sigma);
}

void esekf6_update_mag(esekf6_t *f, const float mag[3], float sigma)
{
    vector_update(f, mag, f->m_ref, sigma);
}
