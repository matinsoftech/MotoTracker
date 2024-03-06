import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/modelold/events.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class StaticVarMethod {
  static bool isInitLocalNotif = false;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool isDarkMode = false;
  static String? userAPiHash =
      "\$2y\$10\$yUmXjzCeKUZ1fb8SHRZJTe7AWBmVhDAMrSmoi6DVxkicvS3rtmW6G";
  static List<DeviceItems> devicelist = [];
  static List<EventsData> eventList = [];
  static String deviceName = "";
  static String deviceId = "";
  static String imei = "";
  static String simno = "";
  static double lat = 26.46135506760892;
  static double lng = 87.0;
  static String defaultUserName = "merogaditracker@gmail.com";
  static String defaultPassword = "123456";
  static String appMobile = "+977-9819097310";
  static String appMail = "merogaditracker@gmail.com";
  static String appWhatsAppNumber = "+977-9819097310";
  static bool isSupportEnabled = true;
  static int reportType = 1;

  static String baseurlall = "http://31.220.75.36";
  // for mero gadi pro
  // static String baseurlall = "http://app.merogaditracker.com";

  static String notificationToken = "";
  static String fromdate = DateFormat('yyyy-MM-dd').format(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
  static String fromtime = "00:00";
  static String todate = DateFormat('yyyy-MM-dd').format(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
  static String totime = DateFormat('HH:mm').format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
      DateTime.now().minute));
}
