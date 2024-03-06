import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/screens/livetrack.dart';

import '../data/modelold/devices.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"));

    _notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? deviceId) async {
        if (deviceId != null) {
          StaticVarMethod.deviceId = deviceId;
          DeviceItems? alertedVehicle;
          for (var element in StaticVarMethod.devicelist) {
            if (element.id.toString() == deviceId) {
              alertedVehicle = element;
            }
          }
          if (alertedVehicle != null) {
            StaticVarMethod.imei = alertedVehicle.deviceData!.imei;
            Navigator.of(navigatorKey.currentContext!).push(
              MaterialPageRoute(
                builder: (_) => const LiveTrack(),
              ),
            );
          }
        }
      },
    );
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        "easyapproach",
        "easyapproach channel",
        importance: Importance.max,
        priority: Priority.high,
        //temporarily disabled
        playSound: true,
        sound: RawResourceAndroidNotificationSound("alarm"),
      ));

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data["vehicle_id"],
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
