import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:myvtsproject/config/notification_handle.dart';
import 'package:myvtsproject/provider/alert_provider.dart';

import 'package:myvtsproject/utils/local_notification_service.dart';
import 'package:provider/provider.dart';
import 'config/functions.dart';
import 'config/static.dart';
import 'data/screens/singleDeviceSummary/single_fuel_summary.dart';
import 'data/screens/splash_screen.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> backgroundHandler(RemoteMessage message) async {
  // LocalNotificationService.display(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void checkBaseUrlAndUpdate() async {
    final baseUrl = "http://app.merogaditracker.com";
    final isActive = await checkIfBaseUrlIsActive(baseUrl);

    if (isActive) {
      StaticVarMethod.baseurlall = baseUrl;
    } else {
      StaticVarMethod.baseurlall = "http://31.220.75.36";
    }
    print("This is url${StaticVarMethod.baseurlall}");
  }

  @override
  Widget build(BuildContext context) {
    checkBaseUrlAndUpdate();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlertProfivider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Moto Traccar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        home: const MyHomePage(title: 'Moto Traccar'),
        builder: EasyLoading.init(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    LocalNotificationService.initialize(context);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // if message contain filling or theft then navigate to the respective page
        if (message.notification != null) {
          final title = message.notification!.title;
          log("This is title ${title!}");

          // log("This is title ${title!}");
          // final body = message.notification!.body;
          // final device_id = message.data["device_id"];

          // if (body!.contains('filling')) {
          //   result = await NotificationHandle().getFuelRefills(device_id);
          // }

          // if (body.contains('theft')) {
          //   result = await NotificationHandle().getFuelThefts(device_id);
          // }

          /// check if the last data is within 10 minutes
          ///
          LocalNotificationService.display(message);

          final routeFromMessage = message.data["route"];

          Navigator.of(context).pushNamed(routeFromMessage);
        }
      }
    });

    FirebaseMessaging.onMessage.listen((message) async {
      if (message.notification != null) {
        final title = message.notification!.title;

        log("This is title ${title!}");

        // final body = message.notification!.body;
        // final device_id = message.data["device_id"];
        // List<FuelFillings> result = [];
        // // check if the message contain "fuel theft" or "fuel theft"
        // //check
        // if (body!.contains('filling')) {
        //   result = await NotificationHandle().getFuelRefills(device_id);
        //   if (result.isNotEmpty) {
        //     // log("This is result ${result.last}");
        //     log("This is result ");
        //     log("This is result ${result.last}");
        //     var lastData = result.last;
        //     var lastTime = lastData.date;
        //     var currentTime = DateTime.now().toString();
        //     var isWithinTime = isWithinTimeWindow(lastTime, currentTime, 10);
        //     if (isWithinTime) {
        //       LocalNotificationService.display(message);
        //     }
        //   }
        // } else if (body.contains('theft')) {
        //   result = await NotificationHandle().getFuelThefts(device_id);
        //   if (result.isNotEmpty) {
        //     // log("This is result ${result.last}");
        //     log("This is result ");
        //     var lastData = result.last;
        //     var lastTime = lastData.date;
        //     var currentTime = DateTime.now().toString();
        //     var isWithinTime = isWithinTimeWindow(lastTime, currentTime, 10);
        //     if (isWithinTime) {
        //       LocalNotificationService.display(message);
        //     }
        //   }
        // }

        // // if both not contain then show the notification
        // else if (!body.contains('filling') && !body.contains('theft')) {
        //   LocalNotificationService.display(message);
        // }

        /// check if the last data is within 10 minutes
        ///

        LocalNotificationService.display(message);

        print("Here ${message.data}");
        print("Here  ${message.data["device_id"]}");
      }
    });

    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   final routeFromMessage = message.data["route"];
    //   print("Here  ${routeFromMessage["device_id"]}");

    //   Navigator.of(context).pushNamed(routeFromMessage);
    // });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        if (message.notification != null) {
          log("This is backgroud ${message.notification!.title!}");
        }
      },
    );
    tokenGenerator();
  }

  Future<void> getDeviceTokenToSendNotification() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    StaticVarMethod.notificationToken = fcmToken.toString();
  }

  void tokenGenerator() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    StaticVarMethod.notificationToken = fcmToken.toString();
    log("This is token ${StaticVarMethod.notificationToken}");
  }

  @override
  Widget build(BuildContext context) {
    getDeviceTokenToSendNotification();
    return Scaffold(
      body: SplashScreen(),
    );
  }
}

Future<bool> checkIfBaseUrlIsActive(String url) async {
  try {
    final response = await http.get(
        Uri.parse("${url}/api/login/?email=abc@gmail.com&password=demo123456"));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
