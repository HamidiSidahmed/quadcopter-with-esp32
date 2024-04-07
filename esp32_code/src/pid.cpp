#include <pid.h>
#define max 400
#define sampling_time 0.004
#define tau 0.1
PID::PID()
{
    error = 0;
    prev_error = 0;
    output = 0;
    derivative = 0;
    integral = 0;
    proportional = 0;
    prev_angle = 0;
}
void PID::cal_pid(float kp, float ki, float kd, int angle, int setpoint)
{
    error = setpoint - angle;
    proportional = kp * error;
    integral += (ki) * (error );
    derivative = kd * (angle - prev_angle);
    if (integral > max)
        integral = max;
    if (integral < -max)
        integral = -max;

    output = integral + derivative + proportional;
    if (output > max)
        output = max;
    if (output < -max)
        output = -max;
    prev_error = error;
    prev_angle = angle;
}