// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myvtsproject/config/constant.dart';
import 'package:myvtsproject/data/screens/vehicle_expiry.dart';
import 'package:myvtsproject/data/screens/document%20screen/document_screen.dart';
import 'package:myvtsproject/data/screens/privacy_policy.dart';
import 'package:myvtsproject/data/screens/terms_and_conditions.dart';
import 'package:myvtsproject/ui/posts/first_post.dart';
import 'package:myvtsproject/ui/posts/post_three.dart';
import 'package:myvtsproject/ui/posts/second_post.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myvtsproject/bottom_navigation/bottom_navigation.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/user.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../config/apps/ecommerce/constant.dart';
import '../../../ui/posts/website_view.dart';
import '../contact screen/contact_screen.dart';
import '../mainmapscreen.dart';
import '../notification_screen.dart';
import '../parking_screen.dart';
import '../reports/report_selection.dart';
import '../settings_screen.dart';
import '../summary/daily_travel_details.dart';
import '../summary/distance_summary_screen.dart';
import '../summary/stop_summary.dart';
import '../summary/travel_details_screen.dart';
import '../summary/trip_summary_screen.dart';
import 'package:package_info/package_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pie_chart/pie_chart.dart';

import '../vechile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static Color primaryLight = Colors.grey.shade200;
  // static const Color primaryDark = const Color.fromARGB(255, 7, 97, 97);
  static const Color primaryDark = Color(0xfffede58);
  static const Color linearColor = Colors.blue;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List icon = ['mt_gps.png', 'mt_vehicletheft.png', 'mt_cuttingedge.png'];
  List page = [FirstPost(), SecondPost(), ThirdPost()];
  List content = [
    'Why do we need GPS devices?',
    'The power of GPS tracking devices!',
    'Introducing cutting edge GPS tracking'
  ];
  Color buttonNumberColor = Colors.white;
  Color buttonTextColor = Colors.white54;

  String filtertext = "All";

  List<DeviceItems> _vehiclesData = [];
  final List<DeviceItems> _vehiclesDataSorted = [];
  final List<DeviceItems> _vehiclesDataDuplicate = [];
  List<DeviceItems> _inactiveVehicles = [];

  List<DeviceItems> _runningVehicles = [];
  List<DeviceItems> _idleVehicles = [];
  List<DeviceItems> _stoppedVehicles = [];
  Timer? timerDummy;
  Timer? expiryTimer;
  Timer? theftTimer;

  User? user;
  bool isLoading = true;
  late SharedPreferences prefs;

  //smart refresher
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // _onLoading
  void _onRefreshing() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection("app_version");
  // Future<bool> checkForUpdate() async {
  //   final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   final String currentVersion = packageInfo.version;
  //
  //   const String packageName = "ms.pioneer.merogadi"; // Replace with your app's package name
  //   const String url = "https://play.google.com/store/apps/details?id=$packageName&hl=en";
  //   print(url);
  //
  //   final response = await http.get(Uri.parse(url));
  //   final String html = response.body;
  //   print(html);
  //
  //   final RegExp regex = RegExp('Current Version</div><span class="htlgb"><div><span class="htlgb">([0-9\\.]+)</span></div></span>');
  //   final Match? match = regex.firstMatch(html);
  //
  //   print(currentVersion);
  //   print(match!.group(1));
  //   if (match != null && match.group(1) != currentVersion) {
  //     // An update is available, prompt the user to install
  //     print("object");
  //     return true;
  //   }
  //   return false;
  // }
  // bool isUpdateRequired = false;
  // void updateChecker() async {
  //   isUpdateRequired = await checkForUpdate();
  //
  // }
  late DocumentReference _documentReference;
  String? currentAppVersion;
  getVersion() async {
    _documentReference = collectionReference.doc("kL7kVfMy3BpOoWgJ02lO");
    await _documentReference.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        currentAppVersion = data["version"];
        checkVersion();
      },
      onError: (e) => log("Error getting document: $e"),
    );
  }

  checkVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;
    if (currentVersion != currentAppVersion) {
      showUpdateAppDialog();
    }
  }

  showUpdateAppDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("Update Moto Traccar"),
            content: const Text(
                "Moto Traccar recommends that you update to the latest version. You can keep using this app while downloading the update."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("NO THANKS"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (Platform.isAndroid || Platform.isIOS) {
                    final appId = Platform.isAndroid
                        ? 'ms.pioneer.merogadi'
                        : 'YOUR_IOS_APP_ID';
                    final url = Uri.parse(
                      Platform.isAndroid
                          ? "market://details?id=$appId"
                          : "https://apps.apple.com/app/id$appId",
                    );
                    launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeScreen.primaryDark,
                ),
                child: const Text("UPDATE"),
              )
            ],
          );
        });
  }

  List homeWidgets = [];
  loadData() async {
    prefs = await SharedPreferences.getInstance();
    StaticVarMethod.isSupportEnabled =
        prefs.getBool("isSupportEnabled") ?? true;
    if (prefs.getBool("Anti theft - parking mode") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/thief.jpeg",
          label: "Anti theft parking mode", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: ParkingScreen(),
                    )));
      }));
    }
    if (prefs.getBool("Travel Summary") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/trip.jpg",
          label: "Travel Summary", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: TripSummaryScreen(),
                    )));
      }));
    }
    if (prefs.getBool("Report") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/report.png", label: "Report", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: ReportSelection(),
                    )));
      }));
    }
    if (prefs.getBool("Daily Travel Details") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/icons8-location-100.png",
          label: "Daily Travel Details", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: TodaySummary(),
                    )));
      }));
    }
    if (prefs.getBool("Travel Details") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/movingdurationicon.png",
          label: "Travel Details", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: DailySummary(),
                    )));
      }));
    }
    if (prefs.getBool("Stoppage Summary") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/stopdurationicon.png",
          label: "Travel Details", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: StoppageSummary(),
                    )));
      }));
    }
    if (prefs.getBool("Distance Summary") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/distance.png",
          label: "Distance Summary", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: DailySlider(),
                    )));
      }));
    }
    if (prefs.getBool("Live Tracking") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/markersicon.png",
          label: "Live Tracking", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: MainMapScreen(),
                    )));
      }));
    }
    if (prefs.getBool("Vehicle Status") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/icons8-info-popup-100.png",
          label: "Vehicle Status", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: MainMapScreen(),
                    )));
      }));
    }
    if (prefs.getBool("Alerts") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/alarmnotification96by96.png",
          label: "Alerts", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const BottomNavigation(
                      selectedPage: 3,
                    )));
      }));
    }
    if (prefs.getBool("Subscription Expiry") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/icons8-clock-100.png",
          label: "Subscription Expiry", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: VehicleExpiry(),
                    )));
      }));
    }
    if (prefs.getBool("Documents") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/documents.jpg",
          label: "Documents", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: DocumentScreen(),
                    )));
      }));
    }
    if (prefs.getBool("Terms and Conditions") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/termsandconditions.png",
          label: "Terms and Conditions", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: TermsAndConditions(),
                    )));
      }));
    }
    if (prefs.getBool("Privacy") == true) {
      homeWidgets.add(customHomeScreenWidget(context,
          imagePath: "assets/images/privacy.png", label: "Privacy", onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const Home(
                      currentPage: PrivacyPolicy(),
                    )));
      }));
    }
    if (homeWidgets.isEmpty) {
      prefs.setBool("Anti theft - parking mode", true);
      prefs.setBool("Travel Summary", true);
      prefs.setBool("Report", true);
      prefs.setBool("Distance Summary", true);
      homeWidgets = [
        customHomeScreenWidget(context,
            imagePath: "assets/images/thief.jpeg",
            label: "Anti theft - parking mode", onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const Home(
                        currentPage: ParkingScreen(),
                      )));
        }),
        customHomeScreenWidget(context,
            imagePath: "assets/images/trip.jpg",
            label: "Travel Summary", onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const Home(
                        currentPage: TripSummaryScreen(),
                      )));
        }),
        customHomeScreenWidget(context,
            imagePath: "assets/images/report.png", label: "Report", onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const Home(
                        currentPage: ReportSelection(),
                      )));
        }),
        customHomeScreenWidget(context,
            imagePath: "assets/images/distance.png",
            label: "Distance Summary", onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const Home(
                        currentPage: DailySlider(),
                      )));
        }),
      ];
    }
  }

  getUser() async {
    GPSAPIS
        .getUserData()
        .then((value) => {isLoading = false, user = value!, setState(() {})});
    setState(() {});
  }

  _checkExpiry() async {
    var licenseExpiryDate = prefs.getString("expiry license");
    FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
    for (DeviceItems vehicle in StaticVarMethod.devicelist) {
      var blueBookExpiryDate =
          prefs.getString("expiry Blue book ${vehicle.id}");
      var rootPermitExpiryDate =
          prefs.getString("expiry Route permit ${vehicle.id}");
      var insurenceExpiryDate =
          prefs.getString("expiry Insurance ${vehicle.id}");

      if (blueBookExpiryDate != null) {
        DateTime blueBookDate = DateTime.parse(blueBookExpiryDate);
        Duration duration = blueBookDate.difference(DateTime.now());

        if (duration.inDays < 7) {
          fln.show(
              1,
              "Bluebook is about to expire",
              "Your bluebook for ${vehicle.name} is about to expire in ${duration.inDays} days",
              const NotificationDetails(
                  android: AndroidNotificationDetails("1", "bluebook expiry",
                      playSound: true)));
        }
      }
      if (rootPermitExpiryDate != null) {
        DateTime rootPermitDate = DateTime.parse(rootPermitExpiryDate);
        Duration duration = rootPermitDate.difference(DateTime.now());
        if (duration.inDays < 7) {
          fln.show(
              1,
              "Root permit is about to expire",
              "Your route permit for ${vehicle.name} is about to expire in ${duration.inDays} days",
              const NotificationDetails(
                  android: AndroidNotificationDetails(
                      "1", "route permit expiry",
                      playSound: true)));
        }
      }
      if (insurenceExpiryDate != null) {
        DateTime insurenceDate = DateTime.parse(insurenceExpiryDate);
        Duration duration = insurenceDate.difference(DateTime.now());
        if (duration.inDays < 7) {
          fln.show(
              1,
              "Insurance is about to expire",
              "Your insurance for ${vehicle.name} is about to expire in ${duration.inDays} days",
              const NotificationDetails(
                  android: AndroidNotificationDetails(
                "1",
                "insurance expiry",
                playSound: true,
              )));
        }
      }
    }
    if (licenseExpiryDate != null) {
      DateTime licenseDate = DateTime.parse(licenseExpiryDate);
      Duration duration = licenseDate.difference(DateTime.now());

      if (duration.inDays < 7) {
        fln.show(
            1,
            "License is about to expire",
            "Your license is about to expire in ${duration.inDays} days",
            const NotificationDetails(
                android: AndroidNotificationDetails("1", "license expiry",
                    playSound: true)));
      }
    }
  }

  _checkTheft() async {
    FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
    for (DeviceItems device in StaticVarMethod.devicelist) {
      if (prefs.getBool(device.id.toString() + device.name) == true &&
          device.online.toString().toLowerCase() == "online") {
        fln.show(
            1,
            "Alert! your parked vehicle is running.",
            "Your parked vehicle ${device.name} is running",
            const NotificationDetails(
                android: AndroidNotificationDetails(
              "channel id 2",
              "vehicle theft",
              playSound: true,
              sound: RawResourceAndroidNotificationSound("alarm"),
            )));
      }
    }
  }

  @override
  void initState() {
    loadData();
    getUser();
    _getData();
    // getVersion();

    timerDummy =
        Timer.periodic(const Duration(seconds: 10), (Timer t) => _getData());
    expiryTimer =
        Timer.periodic(const Duration(days: 1), (Timer t) => _checkExpiry());
    theftTimer =
        Timer.periodic(const Duration(seconds: 20), (Timer t) => _checkTheft());
    super.initState();
  }

  @override
  void dispose() {
    timerDummy?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    Future<bool> showExitPopup() async {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Do you want to exit an App?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: const Text('Yes'),
                ),
              ],
            ),
          ) ??
          false; //if showDialouge had returned null, then return false
    }

    return WillPopScope(
      onWillPop: showExitPopup,
      child: Scaffold(
        floatingActionButton: customFloatingSupportButton(context),
        // appBar: AppBar(
        //   toolbarHeight: 70,
        //   // leading: const DrawerWidget(
        //   //   isHomeScreen: true,
        //   // ),
        //
        //   title: SizedBox(
        //     height: 40,
        //     child: Image.asset(
        //       // "assets/images/homeAppBar.png",
        //       "assets/images/moto_traccar.png",
        //       fit: BoxFit.contain,
        //       height: 170,
        //     ),
        //   ),
        //   actions: [
        //     Padding(
        //       padding: const EdgeInsets.only(right: 10),
        //       child: Row(
        //         children: [
        //           InkWell(
        //               onTap: () {
        //                 Navigator.push(context, MaterialPageRoute(
        //                   builder: (context) {
        //                     return const NotificationsPage();
        //                   },
        //                 ));
        //               },
        //               child: const Icon(Icons.notifications)),
        //           const SizedBox(width: 10),
        //           InkWell(
        //               onTap: () {
        //                 Navigator.push(context, MaterialPageRoute(
        //                   builder: (context) {
        //                     return const SettingScreen();
        //                   },
        //                 ));
        //               },
        //               child: const Icon(Icons.person)),
        //         ],
        //       ),
        //     )
        //   ],
        //   centerTitle: false,
        //   backgroundColor: HomeScreen.primaryDark.withOpacity(0.8),
        //   // elevation: 0,
        //   systemOverlayStyle: SystemUiOverlayStyle.light,
        // ),
        // // drawer: Drawer(
        //     child: Column(
        //   children: [
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //     Text('data'),
        //   ],
        // )),
        //
        backgroundColor: Color(0xffdfdedf),
        body: user?.firstName != null
            ? SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: whiteColor),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: PieChart(
                            dataMap: {
                              "All": _vehiclesData.length.toDouble(),
                              "Running": _runningVehicles.length.toDouble(),
                              "Inactive": _inactiveVehicles.length.toDouble(),
                              "Idle": _idleVehicles.length.toDouble(),
                              "Stop": _stoppedVehicles.length.toDouble(),
                            },

                            animationDuration:
                                const Duration(milliseconds: 800),
                            chartLegendSpacing: 32,
                            chartRadius: MediaQuery.of(context).size.width / 2,
                            colorList: const [
                              Color(0xff3fccf5),
                              Color(0xff53bf80),
                              Color(0xff5dace3),
                              Color(0xfff8dd6e),
                              Color(0xffed7065),
                            ],
                            initialAngleInDegree: 0,
                            chartType: ChartType.ring,

                            ringStrokeWidth: 32,

                            legendOptions: const LegendOptions(
                              showLegendsInRow: false,
                              legendPosition: LegendPosition.right,
                              showLegends: true,
                              legendShape: BoxShape.circle,
                              legendTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            chartValuesOptions: const ChartValuesOptions(
                              showChartValueBackground: true,
                              showChartValues: true,
                              showChartValuesInPercentage: false,
                              showChartValuesOutside: false,
                              decimalPlaces: 0,
                            ),
                            // gradientList: ---To add gradient colors---
                            // emptyColorGradient: ---Empty Color gradient---
                          ),
                        ),
                      ),
                    ),

                    // Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //         vertical: 15.0, horizontal: 7.0),
                    //     child: GridView.builder(
                    //       physics: const NeverScrollableScrollPhysics(),
                    //       gridDelegate:
                    //           const SliverGridDelegateWithFixedCrossAxisCount(
                    //               crossAxisCount: 4,
                    //               mainAxisSpacing: 10,
                    //               crossAxisSpacing: 10,
                    //               childAspectRatio: 1),
                    //       shrinkWrap: true,
                    //       itemCount: homeWidgets.length,
                    //       itemBuilder: (context, index) {
                    //         return homeWidgets[index];
                    //       },
                    //     )),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: InkWell(
                        onTap: () {
                          print('pressed');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebsiteWebView()));
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: whiteColor),
                          child: Row(
                            children: [
                              const SizedBox(width: 20),
                              Image.asset(
                                'assets/images/moto_traccar.png',
                                width: 80,
                                height: 80,
                              ),
                              const SizedBox(width: 30),
                              const SharedTextWidget(
                                text: 'Know more',
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward),
                              const SizedBox(width: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: whiteColor),
                                    height: 300,
                                    width: 200,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            'assets/images/${icon[index]}',
                                            width: 80,
                                            height: 80),
                                        Text(content[index],
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 16)),
                                        const SizedBox(height: 10),
                                        MaterialButton(
                                            color: blackColor,
                                            child: SharedTextWidget(
                                                text: 'Know More',
                                                color: whiteColor),
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                builder: (context) {
                                                  return page[index];
                                                },
                                              ));
                                            })
                                      ],
                                    )),
                              );
                            },
                          ),
                        )),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        height: 230,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: whiteColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                                backgroundImage: AssetImage(
                                    'assets/images/question_mark.png'),
                                radius: 30),
                            const SizedBox(height: 10),
                            const SharedTextWidget(
                                text: 'Do you have a Question?',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xff1e406d)),
                            const SizedBox(height: 10),
                            const SharedTextWidget(
                                text: 'Get 24*7 resolutions to your queries',
                                fontSize: 18,
                                color: Color(0xff1e406d)),
                            const SizedBox(height: 20),
                            MaterialButton(
                              color: const Color(0xff000000),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return const ContactScreen();
                                  },
                                ));
                              },
                              child: SharedTextWidget(
                                  text: 'Contact us',
                                  color: whiteColor,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                color: Colors.white,
              )),
      ),
    );
  }

  customButton(
      {required var onTap,
      double? bottomPos,
      double? topPos,
      double? rightPos,
      double? leftPos,
      required int numData,
      required String buttonName}) {
    return Positioned(
      bottom: bottomPos,
      left: leftPos,
      top: topPos,
      right: rightPos,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          child: Column(
            children: [
              Text(
                numData.toString(),
                style: TextStyle(
                  color: buttonNumberColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                buttonName,
                style: TextStyle(color: buttonNumberColor, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getData() async {
    _runningVehicles = [];
    _idleVehicles = [];
    _stoppedVehicles = [];
    _inactiveVehicles = [];
    GPSAPIS api = GPSAPIS();
    var hash = StaticVarMethod.userAPiHash;
    _vehiclesData = await api.getDevicesList(hash);
    if (_vehiclesData.isNotEmpty) {
      _vehiclesDataDuplicate.clear();
      _vehiclesDataSorted.clear();
      _vehiclesDataSorted.addAll(_vehiclesData);

      if (filtertext != "All") {
        for (int i = 0; i < _vehiclesDataSorted.length; i++) {
          DeviceItems model = _vehiclesDataSorted.elementAt(i);
          if (model.online.toString().toLowerCase().contains("offline")) {
            _inactiveVehicles.add(_vehiclesDataSorted.elementAt(i));
          }
          if (filtertext == "online") {
            if (model.online
                .toString()
                .toLowerCase()
                .contains(filtertext.toLowerCase())) {
              _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
            }
          } else if (filtertext == "offline") {
            if (model.online.toString().toLowerCase().contains("ack") ||
                model.online
                    .toString()
                    .toLowerCase()
                    .contains(filtertext.toLowerCase())) {
              _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
            }
          } else {
            if (model.name.toString().toLowerCase().contains(filtertext
                    .toLowerCase()) /*||
                  model.devicedata!.first.imei!.contains(query.toLowerCase())*/
                ) {
              _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
            }
          }
        }
      } else {
        for (int i = 0; i < _vehiclesDataSorted.length; i++) {
          DeviceItems model = _vehiclesDataSorted.elementAt(i);
          if (model.online.toString().toLowerCase().contains("offline") &&
              model.time.toString().toLowerCase().contains("not connected")) {
            _inactiveVehicles.add(_vehiclesDataSorted.elementAt(i));
          } else if (model.online.toString().toLowerCase().contains("online")) {
            _runningVehicles.add(_vehiclesDataSorted.elementAt(i));
          } else if (model.online.toString().toLowerCase().contains("ack") &&
              double.parse(model.speed.toString()) < 1.0) {
            _idleVehicles.add(_vehiclesDataSorted.elementAt(i));
          } else if (model.online
                  .toString()
                  .toLowerCase()
                  .contains("offline") &&
              model.time.toString().toLowerCase() != "not connected") {
            _stoppedVehicles.add(_vehiclesDataSorted.elementAt(i));
          }
        }

        _vehiclesDataDuplicate.addAll(_vehiclesData);
      }

      StaticVarMethod.devicelist = _vehiclesData;
      if (mounted) {
        setState(() {});
      }
    } else {
      _vehiclesDataDuplicate.clear();
      _vehiclesDataSorted.clear();
      if (mounted) {
        setState(() {});
      }
    }
  }
}

customHomeScreenWidget(BuildContext context,
    {required var onTap, required String imagePath, required String label}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              //offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(imagePath, height: 30, width: 30),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  // height: 1.5,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              )
            ])),
  );
}

customFloatingSupportButton(BuildContext context) {
  return StaticVarMethod.isSupportEnabled == true
      ? InkWell(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ContactScreen()));
          },
          child: Container(
            decoration: BoxDecoration(
                color: HomeScreen.primaryDark,
                borderRadius: BorderRadius.circular(100)),
            padding: const EdgeInsets.all(15),
            child: const Icon(
              Icons.message,
              color: Colors.white,
            ),
          ),
        )
      : const SizedBox();
}
