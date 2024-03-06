// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:myvtsproject/data/screens/singleDeviceSummary/single_document_summary.dart';
import 'package:share_plus/share_plus.dart';
import 'package:myvtsproject/config/apps/ecommerce/constant.dart';
import 'package:myvtsproject/config/apps/food_delivery/global_style.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/position_history.dart';
import 'package:myvtsproject/data/model/history.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/screens/livetrack.dart';
import 'package:myvtsproject/data/screens/playback.dart';
import 'package:myvtsproject/data/screens/playback_selection.dart';
import 'package:myvtsproject/data/screens/reports/kmdetail.dart';
import 'package:myvtsproject/data/screens/reports/report_selection.dart';
import 'package:myvtsproject/data/screens/singleDeviceSummary/single_daily_travel_summary.dart';
import 'package:myvtsproject/data/screens/singleDeviceSummary/single_distance_summary.dart';
import 'package:myvtsproject/data/screens/singleDeviceSummary/single_stop_summary.dart';
import 'package:myvtsproject/data/screens/singleDeviceSummary/single_travel_details.dart';
import 'package:myvtsproject/data/screens/singleDeviceSummary/single_trip_summary.dart';
import 'package:myvtsproject/mapconfig/common_method.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../modelold/report_model.dart';
import '../home/home_screen.dart';
import '../parking_screen.dart';
import '../singleDeviceSummary/single_device_expiry.dart';
import '../singleDeviceSummary/single_fuel_summary.dart';
import '../vechile_screen.dart';

Color blackColor = const Color(0xff000000);

class AllOptionsPage extends StatefulWidget {
  final DeviceItems productData;
  final String expiredate;
  const AllOptionsPage({
    Key? key,
    required this.productData,
    required this.expiredate,
  }) : super(key: key);

  @override
  AllOptionsPageState createState() => AllOptionsPageState();
}

class AllOptionsPageState extends State<AllOptionsPage> {
  var selectedToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var fromTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var fromTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());

  //added code by mahesh

  List icon = const [
    (Icons.location_on_sharp),
    (Icons.play_arrow),
    (Icons.circle_outlined),
    (Icons.social_distance_sharp),
    (Icons.document_scanner_outlined),
    (Icons.receipt_long_sharp),
    // (Icons.share),
    // (Icons.car_repair_sharp),
    // (Icons.play_circle_fill_sharp),
  ];
  List iconName = [
    'Live Tracking',
    'Play Back',
    'Travel',
    'Distance',
    'Documents',
    'Reports',
    // 'Share Location',
    // 'Anti Theft -PM',
    // 'Video PlayBack',
  ];

  List navigate = [
    const LiveTrack(),
    const PlayBackSelection(),
    SingleTripSummary(currentDeviceId: StaticVarMethod.deviceId),
    SingleDistanceSummary(
      currentDeviceId: StaticVarMethod.deviceId,
    ),
    const SingleDocumentScreen(),
    const ReportSelection(showDropDown: false),
    // ParkingScreen(
    //   currentDevice: [widget.productData],
    // ),
    // ParkingScreen(
    //   currentDevice: [widget.productData],
    // )
  ];
  //end of added code by mahesh

  String distanceSum = "O KM";
  String topSpeed = "O KM";
  String moveDuration = "Os";
  String stopDuration = "Os";
  String fuelConsumption = "O ltr";
  String battery = '0.0';
  String power = '0.0';
  String batteryLevel = "0.0";
  bool ignition = false;
  bool motion = false;

  bool showFuelSummary = false;
  bool showImmobilize = false;
  SharedPreferences? prefs;

  var startdate;
  var enddate;
  GPSAPIS api = GPSAPIS();
  List<TripsItems>? routes;

  search() async {
    routes = await GPSAPIS.getHistoryTripList(
      deviceId: int.parse(StaticVarMethod.deviceId),
      fromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
      toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
      fromTime: "00:00",
      toTime: DateFormat("HH:mm").format(DateTime.now()),
    );

    routes ??= [];

    log(routes.toString());

    try {
      // if (routes![routes!.length - 1].items![0].otherArr![15] != null) {
      //   battery = routes![routes!.length - 1]
      //       .items![0]
      //       .otherArr![15]
      //       .toString()
      //       .split(' ')
      //       .last;
      // }
      // if (routes![routes!.length - 1].items![0].otherArr![14] != null) {
      //   power = routes![routes!.length - 1]
      //       .items![0]
      //       .otherArr![14]
      //       .toString()
      //       .split(' ')
      //       .last;
      // }
      // if (routes![routes!.length - 1].items![0].otherArr![8] != null) {
      //   if (routes![routes!.length - 1]
      //       .items![0]
      //       .otherArr![8]
      //       .toString()
      //       .contains("battery")) {
      //     batteryLevel = routes![routes!.length - 1]
      //         .items![0]
      //         .otherArr![8]
      //         .toString()
      //         .split(' ')
      //         .last;
      //   }
      //}

      if (routes![routes!.length - 1].items?[0] != null) {
        //if container batteryLevel then value
        var data = routes![routes!.length - 1].items?[0].otherArr;
        batteryLevel = data!
                .where((element) => element.toString().contains("battery"))
                .first
                .toString()
                .split(' ')
                .last ??
            '0.0';

        ignition = data
                    .where((element) => element.toString().contains("ignition"))
                    .first
                    .toString()
                    .split(' ')
                    .last ==
                'true'
            ? true
            : false;
        motion = data
                    .where((element) => element.toString().contains("motion"))
                    .first
                    .toString()
                    .split(' ')
                    .last ==
                'true'
            ? true
            : false;
      }
    } catch (e) {
      battery = '0.0';
      power = '0.0';
      batteryLevel = '0.0';
    }

    setState(() {});
  }

  List<Items>? fuelRefills;
  List<Items>? fuelLevel;
  List<Items>? fuelDrains;
  List<FuelFillings> newFuelRefills = [];
  List<FuelFillings> newFuelDrains = [];

  List<OptionSummary> summaries = [];

  String? totalFuelRefillsLtr;
  String? totalFuelTheftsLtr;
  String? totalFuelRefills;
  String? totalFuelThefts;
  String? distanceSumFuel;
  String? engineHours;
  String? engineIdles;
  String? engineStops;
  String? mileage;
  String? currentFuelLevel;
  String? startFuelLevel;

  String? fuelConsumptionFuel;

  String? fuelTheftLat;
  String? fuelTheftLng;
  String? fuelTheftDate;
  double? currentSpeed;

  //fuelThefts
  String? totalFuelTheftsLtrOld;
  String? totalFuelTheftsOld;

  getFuelRefills() async {
    fuelRefills = null;
    totalFuelRefillsLtr = null;
    newFuelRefills = [];
    double fuelRefillsInLtr = 0.0;

    totalFuelRefills = null;

    if (fuelRefills == null || fuelRefills == []) {
      http.Response response = await http.post(
        Uri.parse(
            "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=11&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
        body: {
          "user_api_hash": StaticVarMethod.userAPiHash,
        },
      );
      log("fuel refill response ${response.request}");
      // log("fuel refill response ${response.body}");
      fuelRefills =
          ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
    } else {
      fuelRefills = fuelRefills;
      fuelRefills = null;
    }

    if (fuelRefills != null) {
      if (fuelRefills!.isNotEmpty) {
        distanceSum = fuelRefills![0].distanceSum!;
        engineHours = fuelRefills![0].engineHours;
        engineIdles = fuelRefills![0].engineIdle;
        engineStops = fuelRefills![0].engineWork;
        if (fuelRefills![0].fuelConsumption != null) {
          fuelConsumptionFuel =
              fuelRefills![0].fuelConsumption!.sensor6!.toStringAsFixed(2);
        } else {
          fuelConsumptionFuel = "0.0";
        }

        // New Logic for discard duplicate fuel tank filling

        if (fuelRefills![0].fuelTankFillings != null) {
          int dataCount =
              fuelRefills![0].fuelTankFillings!.sensor6?.length ?? 0;
          double refills = 0.0;
          double totalRefills = 0.0;
          double? lastFuelCurrent;

          for (int i = 0; i < dataCount; i++) {
            Sensor6 currentRefill =
                fuelRefills![0].fuelTankFillings!.sensor6![i];
            Sensor6? nextRefill;
            if (i + 1 < dataCount) {
              nextRefill = fuelRefills![0].fuelTankFillings!.sensor6![i + 1];
            }

            //if last is empty then skip
            if (currentRefill.last != '') {
              if (currentRefill.last != nextRefill?.last) {
                refills = currentRefill.diff!.toDouble();
                totalRefills += refills;

                FuelFillings fuel = FuelFillings(
                  date: currentRefill.time,
                  lat: currentRefill.lat,
                  lng: currentRefill.lng,
                  diff: refills.toStringAsFixed(3),
                );
                newFuelRefills.add(fuel);

                lastFuelCurrent = double.tryParse(currentRefill.current!);
              }
            }

            // if (currentRefill.last != nextRefill?.last) {
            //   refills = currentRefill.diff!.toDouble();
            //   totalRefills += refills;

            //   FuelFillings fuel = FuelFillings(
            //     date: currentRefill.time,
            //     lat: currentRefill.lat,
            //     lng: currentRefill.lng,
            //     diff: refills.toStringAsFixed(3),
            //   );
            //   newFuelRefills.add(fuel);

            //   lastFuelCurrent = double.tryParse(currentRefill.current!);
            // }
          }

          totalFuelRefillsLtr = totalRefills.toStringAsFixed(2) ?? "0.0";
          totalFuelRefills = newFuelRefills.length.toString() ?? "0";
        }
      }
    }
    getFuelThefts();
  }

  getFuelThefts() async {
    log('getFuelThefts');
    fuelDrains = null;
    totalFuelTheftsLtrOld = null;
    newFuelDrains = [];

    double fuelTheftsInLtr = 0.0;
    totalFuelTheftsOld = '0';
    totalFuelTheftsLtr = '0';
    totalFuelThefts = '0';

    if (fuelDrains == null || fuelDrains == []) {
      http.Response response = await http.post(
        Uri.parse(
            "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=12&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
        body: {
          "user_api_hash": StaticVarMethod.userAPiHash,
        },
      );
      log(response.request.toString());
      fuelDrains =
          ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
    } else {
      fuelDrains = fuelDrains;
      fuelDrains = null;
    }

    /// [New Logic] ////

    if (fuelDrains != null &&
        fuelDrains!.isNotEmpty &&
        fuelDrains![0].fuelTankThefts != null) {
      int dataCount = fuelDrains![0].fuelTankThefts!.sensor6?.length ?? 0;
      double totalDrains = 0.0;
      String? lastDrain;

      for (int i = 0; i < dataCount; i++) {
        print('item: $i');
        log("Fuel last: ${fuelDrains![0].fuelTankThefts!.sensor6![i].last}");
        log("Fuel diff: ${fuelDrains![0].fuelTankThefts!.sensor6![i].diff}");
        log("Fuel time: ${fuelDrains![0].fuelTankThefts!.sensor6![i].time}");
        Sensor6 currentDrain = fuelDrains![0].fuelTankThefts!.sensor6![i];
        Sensor6? nextDrain;
        if (i < dataCount - 1) {
          nextDrain = fuelDrains![0].fuelTankThefts!.sensor6![i + 1];
        }

        if (currentDrain.last != nextDrain?.last) {
          totalDrains += currentDrain.diff!.toDouble();

          FuelFillings fuel = FuelFillings(
            date: currentDrain.time,
            lat: currentDrain.lat,
            lng: currentDrain.lng,
            diff: currentDrain.diff!.toStringAsFixed(3),
          );
          newFuelDrains.add(fuel);

          lastDrain = currentDrain.last;
        }
      }

      totalFuelTheftsLtr = totalDrains.toStringAsFixed(2) ?? "0";
      totalFuelThefts = newFuelDrains.length.toString() ?? "0";
    }

    getCurrentFuel();
  }

  getCurrentFuel() async {
    log('getCurrentFuel');
    fuelLevel = null;
    http.Response response = await http.post(
      Uri.parse(
          "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=10&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
      body: {
        "user_api_hash": StaticVarMethod.userAPiHash,
      },
    );
    //print request url
    log('getCurrentFuel request ${response.request}');
    if (response.statusCode == 200) {
      //print response
      log('getCurrentFuel response ${response.body}');
      fuelLevel = ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
    } else {
      log('getCurrentFuel response ${response.body}');
    }

    if (fuelLevel != null) {
      if (fuelLevel!.isNotEmpty && fuelLevel![0].sensorValues != null) {
        currentFuelLevel = fuelLevel![0].sensorValues!.sensor6![0].currentFuel;
        startFuelLevel = fuelLevel![0].sensorValues!.sensor6?[1].currentFuel;
      }
    }
    setState(() {});

    // double startFuel = double.tryParse(startFuelLevel ?? "0.0") ?? 0.0;
    // double fuelConsumption =
    //     double.tryParse(fuelConsumptionFuel ?? "0.0") ?? 0.0;
    // double endFuel = double.tryParse(currentFuelLevel ?? "0.0") ?? 0.0;
    // double fuelFillings = double.tryParse(totalFuelRefillsLtr ?? "0.0") ?? 0.0;
    // calculateFuelTheft(startFuel, fuelConsumption, endFuel, fuelFillings);
  }

  calculateFuelTheft(double startFuel, double fuelConsumption, double endFuel,
      double fuelFillings) {
    totalFuelTheftsLtr = null;

    double? fuelTheft;
    double remainingFuel = (startFuel + fuelFillings) - fuelConsumption;
    if (remainingFuel != endFuel) {
      double fuelDiff = remainingFuel - endFuel;
      if (fuelDiff.abs() > 5) {
        fuelTheft = fuelDiff;
      }
    }
    fuelTheft ??= 0.0;
    totalFuelTheftsLtr = fuelTheft.abs().toStringAsFixed(3);
    totalFuelThefts = "${fuelTheft == 0.0 ? 0 : 1}";

    double pilferageDiff = fuelTheft - double.parse(totalFuelTheftsLtrOld!);
    if (pilferageDiff.abs() < 10) {
      totalFuelTheftsLtr = totalFuelTheftsLtrOld;
      totalFuelThefts = totalFuelTheftsOld;
    }
    newFuelDrains = [];
    newFuelDrains.add(FuelFillings(
      date: fuelTheftDate,
      diff: totalFuelTheftsLtr,
      lat: fuelTheftLat,
      lng: fuelTheftLng,
    ));
    currentSpeed ??= 0;
    if (currentSpeed! > 0) {
      newFuelDrains = [];
      totalFuelTheftsLtr = "0";
      totalFuelThefts = "0";
    }
    setState(() {});
  }

  void initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    showFuelSummary = prefs!.getBool("showFuelSummary") ?? false;
    showImmobilize = prefs!.getBool("Vehicle Immobilize") ?? false;
    if (showFuelSummary) {
      getFuelRefills();
    }
    setState(() {});
  }

  @override
  void initState() {
    initializePrefs();
    search();
    super.initState();
    showReport1(0, "Today");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: customFloatingSupportButton(context),
      backgroundColor: const Color(0xffdfdedf),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: GlobalStyle.appBarIconThemeColor,
        ),
        systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,
        centerTitle: true,
        title: Text(StaticVarMethod.deviceName, style: GlobalStyle.appBarTitle),
        backgroundColor: GlobalStyle.appBarBackgroundColor,
        //bottom: _reusableWidget.bottomAppBar(),
      ),
      body: ListView(
        children: [
          // _buildimeiInformation(),
          history(),
          // playBackControls(),
          _topCart(),
          // showFuelSummary ? fuelSummaryCard() : const SizedBox(),
          _buildTotalSummaryGrid(),
        ],
      ),
    );
  }

  history() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: 70,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Icon(
                    Icons.key_sharp,
                    size: 20,
                    color: ignition || motion
                        ? Colors.green
                        : widget.productData.online.toString().toLowerCase() ==
                                'ack'
                            ? Colors.green
                            : Colors.red,
                  ),
                  Text(
                    "Ignition",
                    style: TextStyle(
                        color: ignition || motion
                            ? Colors.green
                            : widget.productData.online
                                        .toString()
                                        .toLowerCase() ==
                                    'ack'
                                ? Colors.green
                                : Colors.red,
                        fontSize: 13),
                  ),
                ],
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Icon(
                    Icons.battery_charging_full_sharp,
                    size: 20,
                    color: batteryLevel != "0.0" ? Colors.green : Colors.grey,
                  ),
                  Text(
                    "GPS Battery $batteryLevel V",
                    style: TextStyle(
                        color:
                            batteryLevel != "0.0" ? Colors.green : Colors.grey,
                        fontSize: 13),
                  ),
                ],
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Icon(
                    CupertinoIcons.power,
                    size: 22,
                    color: batteryLevel != "0.0" ? Colors.green : Colors.red,
                  ),
                  // Text(
                  //   "Int Battery $battery V",
                  //   style: TextStyle(
                  //     color: battery != "0.0" || batteryLevel != "0.0"
                  //         ? Colors.green
                  //         : Colors.grey,
                  //     fontSize: 13,
                  //   ),
                  // )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget playBackControls() {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 30, bottom: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(children: [
            Expanded(
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                child: Image.asset(
                                    "assets/speedoicon/assets_images_tripinfoicon.png",
                                    height: 40,
                                    width: 40)),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('From',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        // fontFamily: 'digital_font'
                                      )),
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: Text('${startdate ?? "loading"}',
                                        style: const TextStyle(
                                          fontSize: 12,

                                          //fontWeight: FontWeight.bold,
                                          // height: 1.7,
                                          //fontFamily: 'digital_font'
                                        )),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )))),
            const SizedBox(
              width: 30,
            ),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                color: Colors.white,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          child: Image.asset(
                              "assets/speedoicon/assets_images_tripinfoicon.png",
                              height: 40,
                              width: 40)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('To',
                                style: TextStyle(
                                    fontSize: 12,
                                    //height: 0.8,
                                    // fontFamily: 'digital_font'
                                    fontWeight: FontWeight.bold)),
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              child: Text('${enddate ?? "loading"}',
                                  style: const TextStyle(
                                    fontSize: 12,

                                    //fontWeight: FontWeight.bold,
                                    //height: 1.7,
                                    //fontFamily: 'digital_font'
                                  )),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ]),
          Row(children: [
            Expanded(
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                child: Image.asset(
                                    "assets/images/routeicon.png",
                                    height: 50,
                                    width: 40)),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: const Text('Distance',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          //fontFamily: 'digital_font'
                                        )),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: Text(distanceSum,
                                        style: const TextStyle(
                                          fontSize: 12,

                                          //fontWeight: FontWeight.bold,
                                          // height: 1.7,
                                          //fontFamily: 'digital_font'
                                        )),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )))),
            const SizedBox(
              width: 30,
            ),
            Expanded(
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                child: Image.asset(
                                    "assets/images/speedometer1.png",
                                    height: 50,
                                    width: 50)),
                            const SizedBox(
                              width: 2,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Top Speed',
                                      style: TextStyle(
                                          fontSize: 12,
                                          //height: 0.8,
                                          // fontFamily: 'digital_font'
                                          fontWeight: FontWeight.bold)),
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: Text(topSpeed,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        )),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )))),
          ]),
          Row(children: [
            Expanded(
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                child: Image.asset(
                                    "assets/images/movingdurationicon.png",
                                    height: 40,
                                    width: 40)),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: const Text('Move Time' '',
                                        style: TextStyle(
                                          fontSize: 12,

                                          fontWeight: FontWeight.bold,
                                          //fontFamily: 'digital_font'
                                        )),
                                  ),
                                  Row(
                                    children: [
                                      Text(moveDuration,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.8,
                                            //color: Colors.blue
                                            fontWeight: FontWeight.bold,
                                          ))
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        )))),
            const SizedBox(
              width: 30,
            ),
            Expanded(
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                child: Image.asset(
                                    "assets/images/stopdurationicon.png",
                                    height: 40,
                                    width: 40)),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Stop Time',
                                      style: TextStyle(
                                          fontSize: 12,
                                          //height: 0.8,
                                          // fontFamily: 'digital_font'
                                          fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      /*Icon(Icons.location_on,
                                                  color: Colors.blue, size: 12),*/
                                      Text(stopDuration,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.8,
                                            //color: Colors.blue
                                            //fontWeight: FontWeight.bold,
                                          ))
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        )))),
          ]),
          Row(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                color: Colors.white,
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.car_crash,
                        size: 40,
                        color: Colors.green,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              child: const Text('Vehicle S.expiry Date',
                                  style: TextStyle(
                                    fontSize: 12,

                                    fontWeight: FontWeight.bold,
                                    //fontFamily: 'digital_font'
                                  )),
                            ),
                            Row(
                              children: [
                                Text(widget.expiredate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.8,
                                      //color: Colors.blue
                                      fontWeight: FontWeight.bold,
                                    ))
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  fuelSummaryCard() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: fuelRefills == null
            ? () {}
            : () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SingleFuelSummary(
                          currentDeviceId: StaticVarMethod.deviceId,
                          fuelDrains: fuelDrains,
                          fuelRefills: fuelRefills,
                          fuelLevel: fuelLevel,
                        )));
              },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(3, 3),
                    color: Colors.grey.shade300)
              ]),
          child: Column(
            children: [
              fuelRefills == null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.black38,
                        valueColor:
                            AlwaysStoppedAnimation(HomeScreen.primaryDark),
                        minHeight: 8,
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.green,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(
                            Icons.local_gas_station,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "  Current Fuel",
                          style: TextStyle(color: Colors.black87, fontSize: 17),
                        ),
                        Spacer(),
                        Text(
                          "${currentFuelLevel ?? "0"} ltr",
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 50.0),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red,
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: const Icon(
                                Icons.gas_meter_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text(
                              "Total Fuel thefts today",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 15),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("${totalFuelTheftsLtr ?? "0"} ltr",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text("(${totalFuelThefts ?? "0"} times)")
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 50.0),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.blue,
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: const Icon(
                                Icons.gas_meter_outlined,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text(
                              "Total Fuel fillings today",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 15),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("${totalFuelRefillsLtr ?? "0"} ltr",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text("(${totalFuelRefills ?? "0"} times)")
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSummaryGrid() {
    summaries = [
      OptionSummary(
        summaryIcon: Icons.location_on,
        summaryName: "Live",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LiveTrack()),
          );
        },
      ),
      OptionSummary(
        summaryIcon: Icons.replay_rounded,
        summaryName: "History",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlayBackSelection()),
          );
        },
      ),
      OptionSummary(
        summaryIcon: Icons.play_arrow,
        summaryName: "Today Playback",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlaybackPage()),
          );
        },
      ),
      OptionSummary(
        summaryIcon: Icons.trip_origin,
        summaryName: "Trip",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleTripSummary(
                currentDeviceId: StaticVarMethod.deviceId,
              ),
            ),
          );
        },
      ),
      // OptionSummary(
      //   summaryIcon: Icons.travel_explore,
      //   summaryName: "Daily Travel Summary",
      //   onTap: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => SingleDailyTravelSummary(
      //           currentDeviceId: StaticVarMethod.deviceId,
      //         ),
      //       ),
      //     );
      //   },
      // ),
      OptionSummary(
        summaryIcon: Icons.art_track,
        summaryName: "Travel",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SingleTravelDetail(
                      currentDeviceId: widget.productData.id,
                    )),
          );
        },
      ),
      OptionSummary(
        summaryIcon: Icons.stop_circle_rounded,
        summaryName: "Stoppage",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleStopSummary(
                currentDeviceId: StaticVarMethod.deviceId,
              ),
            ),
          );
        },
      ),
      OptionSummary(
        summaryIcon: Icons.social_distance,
        summaryName: "Distance",
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SingleDistance(
          //       device_id: StaticVarMethod.deviceId,
          //       device_name: widget.productData.name,
          //     ),
          //   ),
          // );
        },
      ),
      // OptionSummary(
      //   summaryIcon: Icons.local_gas_station,
      //   summaryName: "Fuel Summary",
      //   onTap: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => SingleFuelSummary(
      //           currentDeviceId: widget.productData.id.toString(),
      //         ),
      //       ),
      //     );
      //   },
      // ),
      // OptionSummary(
      //   summaryIcon: Icons.speed,
      //   summaryName: "Distance Travel Chart",
      //   onTap: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const TravelChart()),
      //     );
      //   },
      // ),
      OptionSummary(
        summaryIcon: Icons.document_scanner,
        summaryName: "Documents",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SingleDocumentScreen()),
          );
        },
      ),
      OptionSummary(
        summaryIcon: Icons.punch_clock,
        summaryName: "Expiry",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleVehicleExpiryScreen(
                vehicle: widget.productData,
              ),
            ),
          );
        },
      ),
      OptionSummary(
        summaryIcon: Icons.stacked_bar_chart,
        summaryName: "Reports",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportSelection()),
          );
        },
      ),
      OptionSummary(
        summaryIcon: Icons.share_location,
        summaryName: "Share",
        onTap: () async {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
                  child: AlertDialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                );
              });
          List<DeviceItems>? devices = StaticVarMethod.devicelist;
          String? latitude;
          String? longitude;
          String? geoLocation;

          try {
            for (var element in devices) {
              if (element.id.toString() == StaticVarMethod.deviceId) {
                latitude = element.lat.toString();
                longitude = element.lng.toString();
                Response response =
                    await GPSAPIS.getGeocoder(latitude, longitude);
                geoLocation = response.body;
                List<String> locations = geoLocation.split(" ");
                String finalLocation = locations.first;
                for (int i = 1; i <= locations.length - 1; i++) {
                  finalLocation = "$finalLocation+${locations[i]}";
                }
                String googleMapLink =
                    "https://www.google.com/maps?q=$finalLocation";
                Navigator.pop(context);
                Share.share(googleMapLink);
                break;
              }
            }
          } catch (e) {
            log(e.toString());
          }
          // Fluttertoast.showToast(
          //     msg: 'Comming soon ', toastLength: Toast.LENGTH_SHORT);
        },
      ),
      // OptionSummary(
      //   summaryIcon: Icons.local_parking,
      //   summaryName: "Parking Mode",
      //   onTap: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => ParkingScreen(
      //                 currentDevice: [widget.productData],
      //               )),
      //     );
      //   },
      // ),
      OptionSummary(
        summaryIcon: Icons.power_off_rounded,
        summaryName: "Immobilize",
        onTap: immobilizeVehicleDialog,
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Device Summary',
          //   style: Theme.of(context).textTheme.labelLarge!.copyWith(
          //         // fontWeight: FontWeight.w600,
          //         fontSize: 14,
          //       ),
          // ),
          // const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                // border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                  )
                ]),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: MediaQuery.of(context).size.width / 400,
                crossAxisSpacing: 0,
                mainAxisSpacing: 6,
              ),
              itemCount: summaries.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: summaries[index].onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xffE3E5FE),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            summaries[index].summaryIcon,
                            size: 24,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FittedBox(
                          child: Text(
                            summaries[index].summaryName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Center(
          //   child: Container(
          //     padding: const EdgeInsets.all(8),
          //     width: 120,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(10),
          //       border: Border.all(color: Colors.grey),
          //     ),
          //     alignment: Alignment.center,
          //     child: Row(children: [
          //       const Icon(
          //         Icons.chevron_right,
          //       ),
          //       Text(
          //         "See more",
          //         style: TextStyle(
          //           fontSize: 14,
          //           color: Colors.black54,
          //         ),
          //       ),
          //     ]),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary() {
    return Container(
      margin: const EdgeInsets.all(5).copyWith(top: 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // const SizedBox(height: 30),
            // const ContainerWithImage(image: 'assets/images/moto_traccar.png'),
            Row(
              children: [
                Expanded(
                  child: SharedContainer(
                      iconData: icon[0],
                      text: iconName[0],
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return navigate[0];
                          },
                        ));
                      }),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: SharedContainer(
                      iconData: icon[1],
                      text: iconName[1],
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return navigate[1];
                          },
                        ));
                      }),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: SharedContainer(
                      iconData: icon[2],
                      text: iconName[2],
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return navigate[2];
                          },
                        ));
                      }),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SharedContainer(
                      iconData: icon[3],
                      text: iconName[3],
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return navigate[3];
                          },
                        ));
                      }),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: SharedContainer(
                      iconData: icon[4],
                      text: iconName[4],
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return navigate[4];
                          },
                        ));
                      }),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: SharedContainer(
                      iconData: icon[5],
                      text: iconName[5],
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return navigate[5];
                          },
                        ));
                      }),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return WillPopScope(
                            onWillPop: () async {
                              return false;
                            },
                            child: AlertDialog(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          );
                        });
                    List<DeviceItems>? devices = StaticVarMethod.devicelist;
                    String? latitude;
                    String? longitude;
                    String? geoLocation;

                    try {
                      for (var element in devices) {
                        if (element.id.toString() == StaticVarMethod.deviceId) {
                          latitude = element.lat.toString();
                          longitude = element.lng.toString();
                          Response response =
                              await GPSAPIS.getGeocoder(latitude, longitude);
                          geoLocation = response.body;
                          List<String> locations = geoLocation.split(" ");
                          String finalLocation = locations.first;
                          for (int i = 1; i <= locations.length - 1; i++) {
                            finalLocation = "$finalLocation+${locations[i]}";
                          }
                          String googleMapLink =
                              "https://www.google.com/maps?q=$finalLocation";
                          Navigator.pop(context);
                          Share.share(googleMapLink);
                          break;
                        }
                      }
                    } catch (_) {}
                    // Fluttertoast.showToast(
                    //     msg: 'Comming soon ', toastLength: Toast.LENGTH_SHORT);
                  },
                  child: Container(
                      height: 110,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(7),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(
                                  10) //         <--- border radius here
                              )),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Icon(Icons.share_sharp, color: yellowColor, size: 50),
                          // const SizedBox(height: 10),
                          const Text(
                            ' \nShare',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )),
                )),
                // Expanded(child: Text('data')),
                const SizedBox(width: 5),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ParkingScreen(
                                  currentDevice: [widget.productData],
                                )),
                      );
                    },
                    child: Container(
                      height: 110,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            "assets/images/thief.jpeg",
                            height: 60,
                            width: 60,
                          ),
                          const SizedBox(height: 10),
                          const Text('Anti Theft'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: immobilizeVehicleDialog,
                    child: Container(
                      height: 110,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1, color: Colors.grey[300]!),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 10),
                          Icon(Icons.car_crash_outlined,
                              size: 50, color: yellowColor),
                          const SizedBox(height: 10),
                          const Text(
                            'Immobilize',
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),

            //added for check
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTap: immobilizeVehicleDialog,
            //   child: Container(
            //     alignment: Alignment.center,
            //     padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            //     margin: const EdgeInsets.only(bottom: 16),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       border: Border.all(width: 1, color: Colors.grey[300]!),
            //       borderRadius: const BorderRadius.all(Radius.circular(10)),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Row(
            //           children: const [
            //             Icon(Icons.car_crash_outlined, color: softBlue),
            //             SizedBox(width: 12),
            //             Text(
            //               'Immobilize',
            //               style: TextStyle(
            //                   color: charcoal, fontWeight: FontWeight.bold),
            //             ),
            //           ],
            //         ),
            //         const Icon(Icons.chevron_right, size: 20, color: softBlue),
            //       ],
            //     ),
            //   ),
            // ),
            //
            // //added for check
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => ParkingScreen(
            //                 currentDevice: [widget.productData],
            //               )),
            //     );
            //   },
            //   child: Container(
            //     alignment: Alignment.center,
            //     padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            //     margin: const EdgeInsets.only(bottom: 16),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       border: Border.all(
            //         width: 1,
            //         color: Colors.grey[300]!,
            //       ),
            //       borderRadius: const BorderRadius.all(
            //         Radius.circular(10),
            //       ),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Row(
            //           children: [
            //             Image.asset(
            //               "assets/images/thief.jpeg",
            //               height: 30,
            //               width: 30,
            //             ),
            //             const SizedBox(width: 12),
            //             const Text(
            //               'Anti theft - parking mode',
            //               style: TextStyle(
            //                   color: charcoal, fontWeight: FontWeight.bold),
            //             ),
            //           ],
            //         ),
            //         const Icon(Icons.chevron_right, size: 20, color: softBlue),
            //       ],
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 30),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const LiveTrack()),
            //     );
            //   },
            //   child: Container(
            //       alignment: Alignment.center,
            //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            //       margin: const EdgeInsets.only(bottom: 16),
            //       decoration: BoxDecoration(
            //           color: Colors.white,
            //           border: Border.all(width: 1, color: Colors.grey[300]!),
            //           borderRadius: const BorderRadius.all(
            //               Radius.circular(10) //         <--- border radius here
            //               )),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(
            //             children: const [
            //               Icon(Icons.location_pin, color: softBlue),
            //               SizedBox(width: 12),
            //               Text('Live Tracking',
            //                   style: TextStyle(
            //                       color: charcoal,
            //                       fontWeight: FontWeight.bold)),
            //             ],
            //           ),
            //           const Icon(Icons.chevron_right,
            //               size: 20, color: softBlue),
            //         ],
            //       )),
            // ),
            // const SizedBox(height: 4),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => const PlayBackSelection()),
            //     );
            //   },
            //   child: Container(
            //       alignment: Alignment.center,
            //       padding: const EdgeInsets.all(7),
            //       margin: const EdgeInsets.only(bottom: 16),
            //       decoration: BoxDecoration(
            //           color: Colors.white,
            //           border: Border.all(width: 1, color: Colors.grey[300]!),
            //           borderRadius: const BorderRadius.all(
            //               Radius.circular(10) //         <--- border radius here
            //               )),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(
            //             children: const [
            //               Icon(Icons.play_arrow, color: softBlue),
            //               SizedBox(width: 12),
            //               Text('Play Back History',
            //                   style: TextStyle(
            //                       color: charcoal,
            //                       fontWeight: FontWeight.bold)),
            //             ],
            //           ),
            //           const Icon(Icons.chevron_right,
            //               size: 20, color: softBlue),
            //         ],
            //       )),
            // ),
            // const SizedBox(height: 4),
            // // GestureDetector(
            // //   behavior: HitTestBehavior.translucent,
            // //   onTap: () {
            // //     Navigator.push(
            // //       context,
            // //       MaterialPageRoute(builder: (context) => const PlaybackPage()),
            // //     );
            // //   },
            // //   child: Container(
            // //       alignment: Alignment.center,
            // //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            // //       margin: const EdgeInsets.only(bottom: 16),
            // //       decoration: BoxDecoration(
            // //           color: Colors.white,
            // //           border: Border.all(width: 1, color: Colors.grey[300]!),
            // //           borderRadius: const BorderRadius.all(
            // //               Radius.circular(10) //         <--- border radius here
            // //               )),
            // //       child: Row(
            // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // //         children: [
            // //           Row(
            // //             children: const [
            // //               Icon(Icons.replay_rounded, color: softBlue),
            // //               SizedBox(width: 12),
            // //               Text('Today Play Back',
            // //                   style: TextStyle(
            // //                       color: charcoal, fontWeight: FontWeight.bold)),
            // //             ],
            // //           ),
            // //           const Icon(Icons.chevron_right, size: 20, color: softBlue),
            // //         ],
            // //       )),
            // // ),
            // const SizedBox(height: 4),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => SingleTripSummary(
            //                 currentDeviceId: StaticVarMethod.deviceId,
            //               )),
            //     );
            //   },
            //   child: Container(
            //       alignment: Alignment.center,
            //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            //       margin: const EdgeInsets.only(bottom: 16),
            //       decoration: BoxDecoration(
            //           color: Colors.white,
            //           border: Border.all(width: 1, color: Colors.grey[300]!),
            //           borderRadius: const BorderRadius.all(
            //               Radius.circular(10) //         <--- border radius here
            //               )),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(
            //             children: const [
            //               Icon(Icons.trip_origin, color: softBlue),
            //               SizedBox(width: 12),
            //               Text('Travel Summary',
            //                   style: TextStyle(
            //                       color: charcoal,
            //                       fontWeight: FontWeight.bold)),
            //             ],
            //           ),
            //           const Icon(Icons.chevron_right,
            //               size: 20, color: softBlue),
            //         ],
            //       )),
            // ),
            // // const SizedBox(height: 4),
            // // GestureDetector(
            // //   behavior: HitTestBehavior.translucent,
            // //   onTap: () {
            // //     Navigator.push(
            // //       context,
            // //       MaterialPageRoute(
            // //           builder: (context) => SingleDailyTravelSummary(
            // //                 currentDeviceId: StaticVarMethod.deviceId,
            // //               )),
            // //     );
            // //   },
            // //   child: Container(
            // //       alignment: Alignment.center,
            // //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            // //       margin: const EdgeInsets.only(bottom: 16),
            // //       decoration: BoxDecoration(
            // //           color: Colors.white,
            // //           border: Border.all(width: 1, color: Colors.grey[300]!),
            // //           borderRadius: const BorderRadius.all(
            // //               Radius.circular(10) //         <--- border radius here
            // //               )),
            // //       child: Row(
            // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // //         children: [
            // //           Row(
            // //             children: const [
            // //               Icon(Icons.travel_explore, color: softBlue),
            // //               SizedBox(width: 12),
            // //               Text('Daily Travel Summary',
            // //                   style: TextStyle(
            // //                       color: charcoal, fontWeight: FontWeight.bold)),
            // //             ],
            // //           ),
            // //           const Icon(Icons.chevron_right, size: 20, color: softBlue),
            // //         ],
            // //       )),
            // // ),
            // // const SizedBox(height: 4),
            // // GestureDetector(
            // //   behavior: HitTestBehavior.translucent,
            // //   onTap: () {
            // //     Navigator.push(
            // //       context,
            // //       MaterialPageRoute(
            // //           builder: (context) => SingleTravelDetail(
            // //                 currentDeviceId: widget.productData.id,
            // //               )),
            // //     );
            // //   },
            // //   child: Container(
            // //       alignment: Alignment.center,
            // //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            // //       margin: const EdgeInsets.only(bottom: 16),
            // //       decoration: BoxDecoration(
            // //           color: Colors.white,
            // //           border: Border.all(width: 1, color: Colors.grey[300]!),
            // //           borderRadius: const BorderRadius.all(
            // //               Radius.circular(10) //         <--- border radius here
            // //               )),
            // //       child: Row(
            // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // //         children: [
            // //           Row(
            // //             children: const [
            // //               Icon(Icons.drive_eta, color: softBlue),
            // //               SizedBox(width: 12),
            // //               Text('Travel Detail',
            // //                   style: TextStyle(
            // //                       color: charcoal, fontWeight: FontWeight.bold)),
            // //             ],
            // //           ),
            // //           const Icon(Icons.chevron_right, size: 20, color: softBlue),
            // //         ],
            // //       )),
            // // ),
            // // const SizedBox(height: 4),
            // // GestureDetector(
            // //   behavior: HitTestBehavior.translucent,
            // //   onTap: () {
            // //     Navigator.push(
            // //       context,
            // //       MaterialPageRoute(
            // //           builder: (context) => SingleStopSummary(
            // //                 currentDeviceId: StaticVarMethod.deviceId,
            // //               )),
            // //     );
            // //   },
            // //   child: Container(
            // //       alignment: Alignment.center,
            // //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            // //       margin: const EdgeInsets.only(bottom: 16),
            // //       decoration: BoxDecoration(
            // //           color: Colors.white,
            // //           border: Border.all(width: 1, color: Colors.grey[300]!),
            // //           borderRadius: const BorderRadius.all(
            // //               Radius.circular(10) //         <--- border radius here
            // //               )),
            // //       child: Row(
            // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // //         children: [
            // //           Row(
            // //             children: const [
            // //               Icon(Icons.stop_circle_sharp, color: softBlue),
            // //               SizedBox(width: 12),
            // //               Text('Stoppage Summary',
            // //                   style: TextStyle(
            // //                       color: charcoal, fontWeight: FontWeight.bold)),
            // //             ],
            // //           ),
            // //           const Icon(Icons.chevron_right, size: 20, color: softBlue),
            // //         ],
            // //       )),
            // // ),
            // const SizedBox(height: 4),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => SingleDistanceSummary(
            //                 currentDeviceId: StaticVarMethod.deviceId,
            //               )),
            //     );
            //   },
            //   child: Container(
            //       alignment: Alignment.center,
            //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            //       margin: const EdgeInsets.only(bottom: 16),
            //       decoration: BoxDecoration(
            //           color: Colors.white,
            //           border: Border.all(width: 1, color: Colors.grey[300]!),
            //           borderRadius: const BorderRadius.all(
            //               Radius.circular(10) //         <--- border radius here
            //               )),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(
            //             children: const [
            //               Icon(Icons.summarize, color: softBlue),
            //               SizedBox(width: 12),
            //               Text('Distance Summary',
            //                   style: TextStyle(
            //                       color: charcoal,
            //                       fontWeight: FontWeight.bold)),
            //             ],
            //           ),
            //           const Icon(Icons.chevron_right,
            //               size: 20, color: softBlue),
            //         ],
            //       )),
            // ),
            // // const SizedBox(height: 4),
            // // GestureDetector(
            // //   behavior: HitTestBehavior.translucent,
            // //   onTap: () {
            // //     Navigator.push(
            // //       context,
            // //       MaterialPageRoute(
            // //           builder: (context) => SingleFuelSummary(
            // //                 currentDeviceId: widget.productData.id.toString(),
            // //               )),
            // //     );
            // //   },
            // //   child: Container(
            // //       alignment: Alignment.center,
            // //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            // //       margin: const EdgeInsets.only(bottom: 16),
            // //       decoration: BoxDecoration(
            // //           color: Colors.white,
            // //           border: Border.all(width: 1, color: Colors.grey[300]!),
            // //           borderRadius: const BorderRadius.all(
            // //               Radius.circular(10) //         <--- border radius here
            // //               )),
            // //       child: Row(
            // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // //         children: [
            // //           Row(
            // //             children: const [
            // //               Icon(Icons.local_gas_station, color: softBlue),
            // //               SizedBox(width: 12),
            // //               Text('Fuel Summary',
            // //                   style: TextStyle(
            // //                       color: charcoal, fontWeight: FontWeight.bold)),
            // //             ],
            // //           ),
            // //           const Icon(Icons.chevron_right, size: 20, color: softBlue),
            // //         ],
            // //       )),
            // // ),
            // // const SizedBox(height: 4),
            // // GestureDetector(
            // //   behavior: HitTestBehavior.translucent,
            // //   onTap: () {
            // //     Navigator.push(
            // //       context,
            // //       MaterialPageRoute(builder: (context) => const KmDetail()),
            // //     );
            // //   },
            // //   child: Container(
            // //       alignment: Alignment.center,
            // //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            // //       margin: const EdgeInsets.only(bottom: 16),
            // //       decoration: BoxDecoration(
            // //           color: Colors.white,
            // //           border: Border.all(width: 1, color: Colors.grey[300]!),
            // //           borderRadius: const BorderRadius.all(
            // //               Radius.circular(10) //         <--- border radius here
            // //               )),
            // //       child: Row(
            // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // //         children: [
            // //           Row(
            // //             children: const [
            // //               Icon(Icons.speed, color: softBlue),
            // //               SizedBox(width: 12),
            // //               Text('Distance Travel Chart',
            // //                   style: TextStyle(
            // //                       color: charcoal, fontWeight: FontWeight.bold)),
            // //             ],
            // //           ),
            // //           const Icon(Icons.chevron_right, size: 20, color: softBlue),
            // //         ],
            // //       )),
            // // ),
            // // const SizedBox(height: 4),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => const SingleDocumentScreen()),
            //     );
            //   },
            //   child: Container(
            //       alignment: Alignment.center,
            //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            //       margin: const EdgeInsets.only(bottom: 16),
            //       decoration: BoxDecoration(
            //           color: Colors.white,
            //           border: Border.all(width: 1, color: Colors.grey[300]!),
            //           borderRadius: const BorderRadius.all(
            //               Radius.circular(10) //         <--- border radius here
            //               )),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(
            //             children: const [
            //               Icon(Icons.document_scanner, color: softBlue),
            //               SizedBox(width: 12),
            //               Text('Documents',
            //                   style: TextStyle(
            //                       color: charcoal,
            //                       fontWeight: FontWeight.bold)),
            //             ],
            //           ),
            //           const Icon(Icons.chevron_right,
            //               size: 20, color: softBlue),
            //         ],
            //       )),
            // ),
            // const SizedBox(height: 4),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => const ReportSelection(
            //                 showDropDown: false,
            //               )),
            //     );
            //   },
            //   child: Container(
            //       alignment: Alignment.center,
            //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            //       margin: const EdgeInsets.only(bottom: 16),
            //       decoration: BoxDecoration(
            //           color: Colors.white,
            //           border: Border.all(width: 1, color: Colors.grey[300]!),
            //           borderRadius: const BorderRadius.all(
            //               Radius.circular(10) //         <--- border radius here
            //               )),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(
            //             children: const [
            //               Icon(Icons.stacked_bar_chart, color: softBlue),
            //               SizedBox(width: 12),
            //               Text('Reports',
            //                   style: TextStyle(
            //                       color: charcoal,
            //                       fontWeight: FontWeight.bold)),
            //             ],
            //           ),
            //           const Icon(Icons.chevron_right,
            //               size: 20, color: softBlue),
            //         ],
            //       )),
            // ),
            // const SizedBox(height: 4),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTap: () async {
            //     showDialog(
            //         context: context,
            //         barrierDismissible: false,
            //         builder: (context) {
            //           return WillPopScope(
            //             onWillPop: () async {
            //               return false;
            //             },
            //             child: AlertDialog(
            //               backgroundColor: Colors.transparent,
            //               elevation: 0,
            //               content: Column(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: const [
            //                   CircularProgressIndicator(),
            //                 ],
            //               ),
            //             ),
            //           );
            //         });
            //     List<DeviceItems>? devices = StaticVarMethod.devicelist;
            //     String? latitude;
            //     String? longitude;
            //     String? geoLocation;
            //
            //     try {
            //       for (var element in devices) {
            //         if (element.id.toString() == StaticVarMethod.deviceId) {
            //           latitude = element.lat.toString();
            //           longitude = element.lng.toString();
            //           Response response =
            //               await GPSAPIS.getGeocoder(latitude, longitude);
            //           geoLocation = response.body;
            //           List<String> locations = geoLocation.split(" ");
            //           String finalLocation = locations.first;
            //           for (int i = 1; i <= locations.length - 1; i++) {
            //             finalLocation = "$finalLocation+${locations[i]}";
            //           }
            //           String googleMapLink =
            //               "https://www.google.com/maps?q=$finalLocation";
            //           Navigator.pop(context);
            //           Share.share(googleMapLink);
            //           break;
            //         }
            //       }
            //     } catch (_) {}
            //     // Fluttertoast.showToast(
            //     //     msg: 'Comming soon ', toastLength: Toast.LENGTH_SHORT);
            //   },
            //   child: Container(
            //       alignment: Alignment.center,
            //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            //       margin: const EdgeInsets.only(bottom: 16),
            //       decoration: BoxDecoration(
            //           color: Colors.white,
            //           border: Border.all(width: 1, color: Colors.grey[300]!),
            //           borderRadius: const BorderRadius.all(
            //               Radius.circular(10) //         <--- border radius here
            //               )),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(
            //             children: const [
            //               Icon(Icons.share_sharp, color: softBlue),
            //               SizedBox(width: 12),
            //               Text('Share Location',
            //                   style: TextStyle(
            //                       color: charcoal,
            //                       fontWeight: FontWeight.bold)),
            //             ],
            //           ),
            //           const Icon(Icons.chevron_right,
            //               size: 20, color: softBlue),
            //         ],
            //       )),
            // ),
            // const SizedBox(height: 4),
            // GestureDetector(
            //   behavior: HitTestBehavior.translucent,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => ParkingScreen(
            //                 currentDevice: [widget.productData],
            //               )),
            //     );
            //   },
            //   child: Container(
            //     alignment: Alignment.center,
            //     padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            //     margin: const EdgeInsets.only(bottom: 16),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       border: Border.all(
            //         width: 1,
            //         color: Colors.grey[300]!,
            //       ),
            //       borderRadius: const BorderRadius.all(
            //         Radius.circular(10),
            //       ),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Row(
            //           children: [
            //             Image.asset(
            //               "assets/images/thief.jpeg",
            //               height: 30,
            //               width: 30,
            //             ),
            //             const SizedBox(width: 12),
            //             const Text(
            //               'Anti theft - parking mode',
            //               style: TextStyle(
            //                   color: charcoal, fontWeight: FontWeight.bold),
            //             ),
            //           ],
            //         ),
            //         const Icon(Icons.chevron_right, size: 20, color: softBlue),
            //       ],
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 4),
            // showImmobilize == false
            //     ? const SizedBox()
            //     : GestureDetector(
            //         behavior: HitTestBehavior.translucent,
            //         onTap: immobilizeVehicleDialog,
            //         child: Container(
            //           alignment: Alignment.center,
            //           padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            //           margin: const EdgeInsets.only(bottom: 16),
            //           decoration: BoxDecoration(
            //             color: Colors.white,
            //             border: Border.all(width: 1, color: Colors.grey[300]!),
            //             borderRadius:
            //                 const BorderRadius.all(Radius.circular(10)),
            //           ),
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               Row(
            //                 children: const [
            //                   Icon(Icons.car_crash_outlined, color: softBlue),
            //                   SizedBox(width: 12),
            //                   Text(
            //                     'Immobilize',
            //                     style: TextStyle(
            //                         color: charcoal,
            //                         fontWeight: FontWeight.bold),
            //                   ),
            //                 ],
            //               ),
            //               const Icon(Icons.chevron_right,
            //                   size: 20, color: softBlue),
            //             ],
            //           ),
            //         ),
            //       ),
            //
            // Divider(
            //   height: 32,
            //   color: Colors.grey[400],
            // ),
          ],
        ),
      ),
    );
  }

  //added by mahesh for adding extra details

  Widget _topCart() {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
      decoration: const BoxDecoration(
          // color: Colors.white,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(children: [
            Expanded(
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(15, 6, 6, 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Expanded(
                                  child: Text('From',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        // fontFamily: 'digital_font'
                                      )),
                                ),
                                const SizedBox(width: 5),
                                ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    child: Image.asset(
                                        "assets/speedoicon/assets_images_tripinfoicon.png",
                                        height: 30,
                                        width: 30)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              child: Text('${startdate ?? "loading"}',
                                  style: const TextStyle(
                                    fontSize: 12,

                                    //fontWeight: FontWeight.bold,
                                    // height: 1.7,
                                    //fontFamily: 'digital_font'
                                  )),
                            ),
                          ],
                        )))),
            const SizedBox(
              width: 5,
            ),
            Expanded(
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(15, 6, 6, 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Expanded(
                                  child: Text('To',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        // fontFamily: 'digital_font'
                                      )),
                                ),
                                const SizedBox(width: 5),
                                ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    child: Image.asset(
                                        "assets/speedoicon/assets_images_tripinfoicon.png",
                                        height: 30,
                                        width: 30)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              child: Text('${enddate ?? "loading"}',
                                  style: const TextStyle(
                                    fontSize: 12,

                                    //fontWeight: FontWeight.bold,
                                    // height: 1.7,
                                    //fontFamily: 'digital_font'
                                  )),
                            ),
                          ],
                        )))),
          ]),
          Row(children: [
            Expanded(
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(15, 6, 6, 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Expanded(
                                  child: Text('Distance',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        // fontFamily: 'digital_font'
                                      )),
                                ),
                                const SizedBox(width: 5),
                                ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    child: Image.asset(
                                        "assets/images/routeicon.png",
                                        height: 30,
                                        width: 30)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              child: Text(distanceSum,
                                  style: const TextStyle(
                                    fontSize: 12,

                                    //fontWeight: FontWeight.bold,
                                    // height: 1.7,
                                    //fontFamily: 'digital_font'
                                  )),
                            ),
                          ],
                        )))),
            const SizedBox(
              width: 5,
            ),
            Expanded(
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    color: Colors.white,
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(15, 6, 6, 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Expanded(
                                  child: Text('Top Speed',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        // fontFamily: 'digital_font'
                                      )),
                                ),
                                const SizedBox(width: 5),
                                ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    child: Image.asset(
                                        "assets/images/speedometer1.png",
                                        height: 30,
                                        width: 30)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              child: Text(topSpeed,
                                  style: const TextStyle(
                                    fontSize: 12,

                                    //fontWeight: FontWeight.bold,
                                    // height: 1.7,
                                    //fontFamily: 'digital_font'
                                  )),
                            ),
                          ],
                        )))),
          ]),
          Row(
            children: [
              Expanded(
                child: Column(children: [
                  Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: Container(
                          margin: const EdgeInsets.fromLTRB(15, 6, 6, 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const Expanded(
                                    child: Text('Move Time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          // fontFamily: 'digital_font'
                                        )),
                                  ),
                                  const SizedBox(width: 5),
                                  ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4)),
                                      child: Image.asset(
                                          "assets/images/movingdurationicon.png",
                                          height: 30,
                                          width: 30)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: Text(moveDuration,
                                    style: const TextStyle(
                                      fontSize: 12,

                                      //fontWeight: FontWeight.bold,
                                      // height: 1.7,
                                      //fontFamily: 'digital_font'
                                    )),
                              ),
                            ],
                          ))),
                  const SizedBox(
                    width: 5,
                  ),
                  Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: Container(
                          margin: const EdgeInsets.fromLTRB(15, 6, 6, 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const Expanded(
                                    child: Text('Stop Time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          // fontFamily: 'digital_font'
                                        )),
                                  ),
                                  const SizedBox(width: 5),
                                  ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4)),
                                      child: Image.asset(
                                          "assets/images/stopdurationicon.png",
                                          height: 30,
                                          width: 30)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: Text(stopDuration,
                                    style: const TextStyle(
                                      fontSize: 12,

                                      //fontWeight: FontWeight.bold,
                                      // height: 1.7,
                                      //fontFamily: 'digital_font'
                                    )),
                              ),
                            ],
                          ))),
                ]),
              ),
              Expanded(
                child: SizedBox(
                  height: 150,
                  child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: Container(
                          margin: const EdgeInsets.fromLTRB(15, 6, 6, 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Vehicle Expiry Date',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    // fontFamily: 'digital_font'
                                  )),
                              const SizedBox(height: 15),
                              ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  child: Icon(
                                    Icons.car_crash,
                                    color: yellowColor,
                                    size: 30,
                                  )),
                              const SizedBox(height: 10),
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: Text(widget.expiredate,
                                    style: const TextStyle(
                                      fontSize: 15,

                                      //fontWeight: FontWeight.bold,
                                      // height: 1.7,
                                      //fontFamily: 'digital_font'
                                    )),
                              ),
                            ],
                          ))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //end of added code

  immobilizeVehicleDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Immobilize Vehicle"),
          content: const Text(
            "Are you sure that you want to immobilize the vehicle?",
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: vehicleEngineOn,
              child: Text(
                "Engine On",
              ),
            ),
            ElevatedButton(
              onPressed: immobilizeVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "Engine Off",
              ),
            )
          ],
        );
      },
    );
  }

  immobilizeVehicle() async {
    Uri sms = Uri.parse('sms:${StaticVarMethod.simno}?body=RELAY,1%23');
    if (await launchUrl(sms)) {
      //app opened
    } else {
      //app is not opened
    }
  }

  vehicleEngineOn() async {
    Uri sms = Uri.parse('sms:${StaticVarMethod.simno}?body=RELAY,0%23');
    if (await launchUrl(sms)) {
      //app opened
    } else {
      //app is not opened
    }
  }

  void showReport1(int selectedperiod, String currentday) {
    String fromDate;
    String toDate;
    String fromTime;
    String toTime;

    DateTime current = DateTime.now();

    String month;
    String day;
    if (current.month < 10) {
      month = "0${current.month}";
    } else {
      month = current.month.toString();
    }
    if (current.day < 10) {
      day = "0${current.day}";
    } else {
      day = current.day.toString();
    }
    if (selectedperiod == 0) {
      String today;
      int dayCon = current.day;
      if (dayCon < 10) {
        today = "0$dayCon";
      } else {
        today = dayCon.toString();
      }

      var date = DateTime.parse("${current.year}-"
          "$month-"
          "$today "
          "00:00:00");
      fromDate = formatDateReport(DateTime.now().toString());
      toDate = formatDateReport(DateTime.now().toString());
      fromTime = "00:00";
      toTime = "23:59";

      StaticVarMethod.fromdate = fromDate;
      StaticVarMethod.todate = toDate;
      StaticVarMethod.fromtime = fromTime;
      StaticVarMethod.totime = toTime;
    }

    // Navigator.pop(context);

    getReport1(
        StaticVarMethod.deviceId,
        StaticVarMethod.fromdate,
        StaticVarMethod.fromtime,
        StaticVarMethod.todate,
        StaticVarMethod.totime,
        currentday);
    /* Navigator.pushNamed(context, "/reportList",
        arguments: ReportArguments(device['id'], fromDate, fromTime,
            toDate, toTime, device["name"], 0));*/
  }

  Future<PositionHistory?> getReport1(String deviceID, String fromDate,
      String fromTime, String toDate, String toTime, String currentday) async {
    final response = await http.get(Uri.parse(
        "${StaticVarMethod.baseurlall}/api/get_history?lang=en&user_api_hash=${StaticVarMethod.userAPiHash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&snap_to_road=false&device_id=$deviceID"));

    if (response.statusCode == 200) {
      var value = PositionHistory.fromJson(json.decode(response.body));
      print(response.body);
      if (value.items!.isNotEmpty) {
        startdate = value.items!.first;
        enddate = value.items!.last;

        startdate = startdate['show'];
        enddate = enddate['show'];

        setState(() {
          topSpeed = value.topSpeed.toString();
          moveDuration = value.moveDuration.toString();
          stopDuration = value.stopDuration.toString();
          fuelConsumption = value.fuelConsumption.toString();
          distanceSum = value.distanceSum.toString();
        });
      }
    } else {
      return null;
    }
    return null;
  }
}

class ContainerWithImage extends StatelessWidget {
  const ContainerWithImage({
    super.key,
    this.height = 200,
    required this.image,
  });

  final double height;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25), color: Colors.grey),
          child: Image.asset(image)),
    );
  }
}

class SharedContainer extends StatelessWidget {
  const SharedContainer({
    super.key,
    required this.iconData,
    required this.text,
    required this.onTap,
  });

  final Function() onTap;
  final IconData iconData;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: whiteColor),
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(iconData, color: yellowColor, size: 50),
                const SizedBox(height: 10),
                Text(text, textAlign: TextAlign.center)
              ]),
        ),
      ),
    );
  }
}

class SharedTextWidget extends StatelessWidget {
  const SharedTextWidget(
      {super.key,
      required this.text,
      this.fontSize = 16,
      this.fontWeight = FontWeight.normal,
      this.color = const Color(0xff000000)});
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

class OptionSummary {
  String summaryName;
  IconData summaryIcon;
  VoidCallback onTap;

  OptionSummary({
    required this.summaryIcon,
    required this.summaryName,
    required this.onTap,
  });
}
