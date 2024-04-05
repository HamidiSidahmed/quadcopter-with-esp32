#ifndef INITIALIZATION_H
#define INITIALIZATION_H
#include <Arduino.h>
#include <ESP32Servo.h>
#include <MPU6050_light.h>
#include "Wire.h"

extern MPU6050 mpu;
extern Servo motor1;
extern Servo motor2;
extern Servo motor3;
extern Servo motor4;
void mpu_init(int gyro_config,int acc_config,double filter_coef);
void motor_init();

#endif