import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'dart:io';

class Controller extends StatefulWidget {
  const Controller({super.key});

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  late bool altitude;
  late bool armed;
  late Offset left_position;
  late Offset right_position;
  late int throttle;
  late int yaw;
  late int pitch;
  late int roll;
  late Socket _socket;
  Future<void> _connect() async {
    try {
      _socket = await Socket.connect("192.168.4.1", 8080);
    } catch (e) {
      print("Error connecting to ESP32: $e");
    }
  }

  @override
  void initState() {
    altitude = false;
    armed = false;
    left_position = Offset(0, 0);
    right_position = Offset(0, 0);
    yaw = 0;
    pitch = 0;
    roll = 0;
    throttle = 1000;
    _connect();
    super.initState();
  }

  @override
  void dispose() {
    _socket.destroy();
    super.dispose();
  }

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      splitScreenMode: true,
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return Scaffold(
            body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 30.w),
                  child: FlutterSwitch(
                    showOnOff: true,
                    value: armed,
                    onToggle: (value) async {
                      setState(() {
                        armed = value;
                      });
                      try {
                        _socket.write(jsonEncode({"a": armed}));
                      } catch (e) {}
                    },
                    height: 30.h,
                    width: 50.w,
                    activeText: "Armed",
                    inactiveText: "Disarmed",
                    valueFontSize: 5.5.sp,
                    activeTextColor: Colors.white,
                    activeColor: Colors.deepPurple,
                    inactiveColor: Colors.white,
                    inactiveTextColor: Colors.deepPurple,
                    inactiveToggleColor: Colors.deepPurple,
                    inactiveSwitchBorder:
                        Border.all(color: Colors.deepPurple, width: 1),
                  ),
                ),
                Container(
                  child: Text(
                    "Throttle :$throttle",
                    style: TextStyle(fontSize: 8.sp),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 30.w),
                  child: FlutterSwitch(
                    showOnOff: true,
                    value: altitude,
                    onToggle: (value) {
                      setState(() {
                        altitude = value;
                      });
                      try {
                        _socket.write(jsonEncode({"d": altitude}));
                      } catch (e) {
                        print(
                            "can't send the data please check your connection");
                      }
                    },
                    height: 30.h,
                    width: 50.w,
                    activeText: "Directions",
                    inactiveText: "Altitude",
                    valueFontSize: 5.5.sp,
                    activeTextColor: Colors.white,
                    activeColor: Colors.deepPurple,
                    inactiveColor: Colors.white,
                    inactiveTextColor: Colors.deepPurple,
                    inactiveToggleColor: Colors.deepPurple,
                    inactiveSwitchBorder:
                        Border.all(color: Colors.deepPurple, width: 1),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20.w),
                  width: 200.h,
                  height: 200.h,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepPurple)),
                  child: Stack(
                    children: [
                      Positioned(
                        top: left_position.dy,
                        left: left_position.dx,
                        child: GestureDetector(
                          onPanEnd: (details) async {
                            setState(() {
                              left_position = Offset(0, left_position.dy);
                              yaw = 0;
                            });
                            try {
                              _socket.write(jsonEncode({"y": 0}));
                            } catch (e) {}
                          },
                          onPanUpdate: (details) async {
                            setState(() {
                              left_position += details.delta;
                              if (left_position.dy < (60.h - 200.h))
                                left_position =
                                    Offset(left_position.dx, (60.h - 200.h));
                              else if (left_position.dy > 0)
                                left_position = Offset(left_position.dx, 0);
                              if (left_position.dx > 70.h)
                                left_position = Offset(70.h, left_position.dy);
                              else if (left_position.dx < -70.h)
                                left_position = Offset(-70.h, left_position.dy);
                              throttle = (-left_position.dy * 7 + 1000).toInt();
                              yaw = left_position.dx.toInt();
                              print(throttle);
                            });
                            try {
                              _socket.write(jsonEncode({"t": throttle}));
                              if (armed == true) {
                                _socket.write(jsonEncode({"y": yaw}));
                              }
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 140.h, left: 70.h),
                            width: 60.h,
                            height: 60.h,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 20.w),
                  width: 200.h,
                  height: 200.h,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepPurple)),
                  child: Stack(
                    children: [
                      Positioned(
                        top: right_position.dy,
                        left: right_position.dx,
                        child: GestureDetector(
                          onPanEnd: (details) {
                            setState(() {
                              right_position = Offset(0, 0);
                              roll = right_position.dy.toInt();
                              pitch = right_position.dx.toInt();
                            });
                            try {
                              if (armed == true) {
                                _socket.write(jsonEncode({"r": 0}));
                                _socket.write(jsonEncode({"p": 0}));
                              }
                            } catch (e) {}
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              right_position += details.delta;
                              if (right_position.dy < (60.h - 200.h) / 2)
                                right_position = Offset(
                                    right_position.dx, (60.h - 200.h) / 2);
                              else if (right_position.dy > 70)
                                right_position = Offset(right_position.dx, 70);
                              if (right_position.dx > 70.h)
                                right_position =
                                    Offset(70.h, right_position.dy);
                              else if (right_position.dx < -70.h)
                                right_position =
                                    Offset(-70.h, right_position.dy);
                              roll = ((right_position.dy / 70.h) * -25).toInt();
                              pitch = ((right_position.dx / 70.h) * 25).toInt();
                              try {
                                if (armed == true) {
                                  _socket.write(jsonEncode({"r": roll}));
                                  _socket.write(jsonEncode({"p": pitch}));
                                }
                              } catch (e) {}
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 70.h, left: 70.h),
                            width: 60.h,
                            height: 60.h,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ));
      },
    );
  }
}
