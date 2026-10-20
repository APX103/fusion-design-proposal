#ifndef MADGWICK_H
#define MADGWICK_H

void madgwick_update(float q[4], const float gyro[3], const float acc[3],
                     const float mag[3], float dt, float beta);

#endif
