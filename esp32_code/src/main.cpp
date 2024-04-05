#include <Arduino.h>
#include <initialization.h>
#include <pid.h>
#include <WiFi.h>
#include <WiFiServer.h>
#include <ArduinoJson.h>
#include "controller.h"
#include <WiFiClient.h>
const char *ssid = "r";
const char *password = "mr.kadeebe";
const int port = 8080; // TCP port for receiving data
bool jsonStarted = false;
int throttle;
WiFiClient client;
String jsonMessage;
WiFiServer server(port);
int speed1, speed2, speed3, speed4;
PID roll_pid;
PID pitch_pid;
PID yaw_pid;
int yaw, pitch, roll;
long timer;
int angle;
int armed, direction;

void setup()
{
  Serial.begin(9600);
  roll_pid = PID();
  pitch_pid = PID();
  yaw_pid = PID();
  throttle = 1000;
  yaw = pitch = roll = 0;
  timer = 0;
  speed1 = speed2 = speed3 = speed4 = 1000;
  armed = false;
  direction = false;
  motor1.writeMicroseconds(1000);
  WiFi.softAP("frite", "");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  server.begin();
  Serial.println("TCP server started");
  client = server.available();
  while (!client.connected())
  {
    client = server.available();
    delay(1000); 
  }
  mpu_init(1, 0, 0.995);
  motor_init();
  Serial.println("Done !! let's flight");
}

void loop()
{
  if (client.connected())
  {
    mpu.update();
    while (client.available())
    {
      char c = client.read();
      if (c == '{' && !jsonStarted)
      {
        jsonStarted = true;
        jsonMessage = "";
      }

      if (jsonStarted)
      {
        jsonMessage += c;
      }

      if (c == '}' && jsonStarted)
      {
        jsonStarted = false;
        DynamicJsonDocument doc(1024);
        deserializeJson(doc, jsonMessage);
        if (doc.containsKey("t"))
        {
          throttle = doc["t"];
        }
        if (doc.containsKey("p"))
        {
          pitch = doc["p"];
        }
        if (doc.containsKey("r"))
        {
          roll = doc["r"];
        }
        if (doc.containsKey("y"))
        {
          yaw = doc["y"];
        }
        if (doc.containsKey("a"))
        {
          armed = doc["a"];
        }
        if (doc.containsKey("d"))
        {
          direction = doc["d"];
        }
      }
    }

    int total_angle_Z = mpu.getAngleZ();
    while (total_angle_Z > +180)
      total_angle_Z -= 360;
    while (total_angle_Z < -180)
      total_angle_Z += 360;
    roll_pid.cal_pid(1.3, 0.001, 0.01, mpu.getAngleX(), 0);
    pitch_pid.cal_pid(1.3, 0.001, 0.01, mpu.getAngleY(), 0);
    yaw_pid.cal_pid(1.3, 0.001, 0.01, total_angle_Z, 0);
    speed1 = throttle - roll_pid.output - pitch_pid.output + yaw_pid.output;
    speed2 = throttle - roll_pid.output + pitch_pid.output + yaw_pid.output;
    speed3 = throttle + roll_pid.output + pitch_pid.output - yaw_pid.output;
    speed4 = throttle + roll_pid.output - pitch_pid.output - yaw_pid.output;
    speed1 > 1800 ? speed1 = 1800 : speed1 < 1000 ? speed1 = 1000
                                                  : speed1 = speed1;
    speed2 > 1800 ? speed2 = 1800 : speed2 < 1000 ? speed2 = 1000
                                                  : speed2 = speed2;
    speed3 > 1800 ? speed3 = 1800 : speed3 < 1000 ? speed3 = 1000
                                                  : speed3 = speed3;
    speed4 > 1800 ? speed4 = 1800 : speed4 < 1000 ? speed4 = 1000
                                                  : speed4 = speed4;
    if (armed == true)
    {
      motor1.writeMicroseconds(speed1);
      motor2.writeMicroseconds(speed2);
      motor3.writeMicroseconds(speed3);
      motor4.writeMicroseconds(speed4);
    }
    else
    {
      motor1.writeMicroseconds(1000);
      motor2.writeMicroseconds(1000);
      motor3.writeMicroseconds(1000);
      motor4.writeMicroseconds(1000);
    }
  }
  else
  {
    client.stop();
    motor1.writeMicroseconds(1000);
    motor2.writeMicroseconds(1000);
    motor3.writeMicroseconds(1000);
    motor4.writeMicroseconds(1000);
    for (;;)
    {
    }
  }
}
