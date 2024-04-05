#ifndef PID_H
#define PID_H
class PID{
    public:
       float error;
       float prev_error;
       float proportional;
       float integral;
       float derivative;
       float output;
       int max;
       float prev_angle;
    public:
     PID();
     void cal_pid(float kp,float ki,float kd,int angle,int setpoint);
     

};

#endif
