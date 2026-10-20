/* test_main.c — 确定性场景，供与 Python 版做差分验证。
 *
 * 输出格式（CSV 行）：
 *   step,t,duty,state          每 100 拍
 *   ready,t,time_to_stable,b0,b1,b2
 *   solve,b0,b1,b2,M00..M22,ab0,ab1,ab2,residual
 */
#include <stdio.h>

#include "thermal.h"

#define DT          0.1f
#define STEPS       5000
#define T_AMB       20.0f
#define TARGET      45.0f
#define WINDOW      50
#define THRESHOLD   0.13f
#define NEAR_TARGET 0.2f
#define SAMPLES     200
#define G0          9.795502520545487f

int main(void)
{
    thermal_plant_t plant;
    atom_scheme_t scheme;
    const float poses[4][3] = {
        {0.0f, 0.0f, G0},
        {0.0f, 0.0f, -G0},
        {G0, 0.0f, 0.0f},
        {0.0f, G0, 0.0f},
    };
    const float gyro[3] = {0.017f, -0.011f, 0.018f};
    /* 模拟真实 IMU 的 12 参数误差（LS 应能还原） */
    const float tm[3][3] = {{1.001f, 0.002f, 0.0f},
                            {0.0f, 0.999f, 0.001f},
                            {0.001f, 0.0f, 1.002f}};
    const float tb[3] = {0.01f, -0.02f, 0.03f};
    float duty = 0.0f, t, temp;
    int k, ready_printed = 0;

    thermal_plant_init(&plant, T_AMB, 3.0f, 15.0f, 3.0f);
    atom_scheme_init(&scheme, TARGET, WINDOW, THRESHOLD, NEAR_TARGET, SAMPLES);

    for (k = 0; k < STEPS; k++) {
        int pose = scheme.cal.n;
        int st;
        if (pose >= 4) pose = 3;
        t = (float)k * DT;
        temp = thermal_plant_step(&plant, duty, DT, T_AMB);
        float accm[3];
        for (int r = 0; r < 3; r++)
            accm[r] = tm[r][0] * poses[pose][0] + tm[r][1] * poses[pose][1]
                    + tm[r][2] * poses[pose][2] + tb[r];
        st = atom_scheme_step(&scheme, accm, gyro, temp, poses[pose], DT);
        duty = scheme.pid.duty;

        if (k % 100 == 0)
            printf("%d,%.6f,%.6f,%d\n", k, temp, duty, st);

        if (st == ST_READY && !ready_printed) {
            float bias[3], M[3][3], b[3], res;
            ready_printed = 1;
            if (cal_solve(&scheme.cal, bias, M, b, &res))
                printf("ready,%.6f,%.6f,%.6f,%.6f,%.6f\n", t,
                       scheme.time_to_stable, bias[0], bias[1], bias[2]);
        }
    }

    {
        float bias[3], M[3][3], b[3], res;
        if (cal_solve(&scheme.cal, bias, M, b, &res)) {
            printf("solve,%.6f,%.6f,%.6f", bias[0], bias[1], bias[2]);
            for (int r = 0; r < 3; r++)
                for (int c = 0; c < 3; c++) printf(",%.6f", M[r][c]);
            printf(",%.6f,%.6f,%.6f,%.6f\n", b[0], b[1], b[2], res);
        }
    }
    return 0;
}
