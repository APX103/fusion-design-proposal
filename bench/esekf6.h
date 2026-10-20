#ifndef ESEKF6_H
#define ESEKF6_H

/* 6 状态误差状态 EKF：δθ(3) + δbg(3)，四元数右乘扰动。 */
typedef struct {
    float q[4];        /* wxyz, body->nav */
    float bg[3];       /* 陀螺零偏 rad/s */
    float P[6][6];
    float m_ref[3];    /* 导航系参考磁场（初始化时锚定） */
} esekf6_t;

void esekf6_init(esekf6_t *f, const float q0[4], const float bg0[3],
                 const float m_ref[3], float p_theta, float p_bias);
void esekf6_predict(esekf6_t *f, const float gyro[3], float dt,
                    float gyro_arw, float bias_rw);
void esekf6_update_gravity(esekf6_t *f, const float acc[3], float sigma);
void esekf6_update_mag(esekf6_t *f, const float mag[3], float sigma);

#endif
