#include <initialization.h>
Servo motor1;
Servo motor2;
Servo motor3;
Servo motor4;
MPU6050 mpu(Wire);
void mpu_init(int gyro_config, int acc_config, double filter_coef)
{
    Wire.begin();
    byte status = mpu.begin(gyro_config, acc_config);
    mpu.setGyroConfig(filter_coef);
    Wire.beginTransmission(0x68); // now we want to setup our gyro coefficient
    Wire.write(0x1A);             // the config address
    Wire.write(0x05);             // the config value
    Wire.endTransmission();
    Serial.print(F("MPU6050 status: "));
    Serial.println(status);

    while (status != 0)
    {
    } // stop everything if could not connect to MPU6050

    Serial.println(F("Calculating offsets, do not move MPU6050"));
    delay(1000);
    mpu.calcOffsets(true, true); // gyro and accelero offsets calculations
    Serial.println("Done!\n");
}
void motor_init() // attaching the motors to there pins
{
    Serial.println("Done!\n");
    motor1.attach(13, 1000, 2000); // attaching the motors to there pins
    motor2.attach(14, 1000, 2000);
    motor3.attach(26, 1000, 2000);
    motor4.attach(32, 1000, 2000);
    delay(1000);
    motor1.writeMicroseconds(1000);
    motor2.writeMicroseconds(1000);
    motor3.writeMicroseconds(1000);
    motor4.writeMicroseconds(1000);
    delay(1000);
}
