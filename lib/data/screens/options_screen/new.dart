// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';
// import 'dart:developer';

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
// import 'package:intl/intl.dart';
// import 'package:myvtsproject/config/colors_assets.dart';

// import 'package:myvtsproject/config/static.dart';
// import 'package:myvtsproject/data/datasources.dart';
// import 'package:myvtsproject/data/model/history.dart';
// import 'package:myvtsproject/data/model/position_history.dart';
// import 'package:myvtsproject/data/modelold/devices.dart';
// import 'package:myvtsproject/mapconfig/common_method.dart';
// import 'package:myvtsproject/screens/livetrack.dart';
// import 'package:myvtsproject/screens/playback.dart';
// import 'package:myvtsproject/screens/playbackselection.dart';
// import 'package:myvtsproject/screens/reports/report_selection.dart';
// import 'package:myvtsproject/screens/singleDeviceSummary/single_distance.dart';
// import 'package:myvtsproject/screens/singleDeviceSummary/single_document_screen.dart';
// import 'package:myvtsproject/screens/singleDeviceSummary/single_stop_summary.dart';
// import 'package:myvtsproject/screens/singleDeviceSummary/single_travel_detail.dart';
// import 'package:myvtsproject/screens/singleDeviceSummary/single_trip_summary.dart';
// import 'package:myvtsproject/screens/singleDeviceSummary/single_vehicle_expiry.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../config/app_text_style.dart';
// import '../../data/modelold/report_model.dart';
// import '../common/CustomPieChart.dart';
// import '../common/details_page_card.dart';
// import '../home/home_screen.dart';
// import '../singleDeviceSummary/single_fuel_summary.dart';

// class AllOptionsPage extends StatefulWidget {
//   final DeviceItems productData;
//   final String expiredate;
//   const AllOptionsPage({
//     Key? key,
//     required this.productData,
//     required this.expiredate,
//   }) : super(key: key);

//   @override
//   AllOptionsPageState createState() => AllOptionsPageState();
// }

// class AllOptionsPageState extends State<AllOptionsPage> {
//   final DateTime _selectedFromDate = DateTime.now();
//   final DateTime _selectedToDate = DateTime.now();

//   var selectedToTime = TimeOfDay.fromDateTime(DateTime.now());
//   var selectedTripInfoToTime = TimeOfDay.fromDateTime(DateTime.now());
//   var selectedFromTime = TimeOfDay.fromDateTime(DateTime.now());
//   var selectedTripInfoFromTime = TimeOfDay.fromDateTime(DateTime.now());
//   var fromTime = DateFormat("HH:mm:ss").format(DateTime.now());
//   var fromTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
//   var toTime = DateFormat("HH:mm:ss").format(DateTime.now());
//   var toTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());

//   String distanceSum = "O KM";
//   String topSpeed = "O KM";
//   String moveDuration = "Os";
//   String stopDuration = "Os";
//   String fuelConsumption = "O ltr";
//   String battery = '0.0';
//   String power = '0.0';
//   String batteryLevel = "0.0";

//   bool isLoading = false;

//   var startdate;
//   var enddate;
//   GPSAPIS api = GPSAPIS();
//   List<TripsItems>? routes;

//   search() async {
//     routes = await GPSAPIS.getHistoryTripList(
//       deviceId: int.parse(StaticVarMethod.deviceId),
//       fromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
//       toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
//       fromTime: "00:00",
//       toTime: "${DateTime.now().hour}:${DateTime.now().minute}",
//     );
//     routes ??= [];

//     try {
//       if (routes![routes!.length - 1].items![0].otherArr![15] != null) {
//         battery = routes![routes!.length - 1]
//             .items![0]
//             .otherArr![15]
//             .toString()
//             .split(' ')
//             .last;
//       }
//       if (routes![routes!.length - 1].items![0].otherArr![14] != null) {
//         power = routes![routes!.length - 1]
//             .items![0]
//             .otherArr![14]
//             .toString()
//             .split(' ')
//             .last;
//       }
//       if (routes![routes!.length - 1].items![0].otherArr![8] != null) {
//         if (routes![routes!.length - 1]
//             .items![0]
//             .otherArr![8]
//             .toString()
//             .contains("battery")) {
//           batteryLevel = routes![routes!.length - 1]
//               .items![0]
//               .otherArr![8]
//               .toString()
//               .split(' ')
//               .last;
//         }
//       }
//     } catch (e) {
//       battery = '0.0';
//       power = '0.0';
//       batteryLevel = '0.0';
//     }

//     setState(() {});
//   }

//   List<OptionSummary> summaries = [];

//   List<Items>? fuelRefills;
//   List<Items>? fuelLevel;
//   List<Items>? fuelDrains;
//   List<FuelFillings> newFuelRefills = [];
//   List<FuelFillings> newFuelDrains = [];

//   String? totalFuelRefillsLtr;
//   String? totalFuelTheftsLtr;
//   String? totalFuelRefills;
//   String? totalFuelThefts;
//   String? distanceSumFuel;
//   String? engineHours;
//   String? engineIdles;
//   String? engineStops;
//   String? mileage;
//   String? currentFuelLevel;
//   String? startFuelLevel;

//   String? fuelConsumptionFuel;

//   bool showFuelSummary = false;
//   bool showImmobilize = false;

//   SharedPreferences? prefs;

//   String? fuelTheftLat;
//   String? fuelTheftLng;
//   String? fuelTheftDate;
//   double? currentSpeed;

//   //fuelThefts
//   String? totalFuelTheftsLtrOld;
//   String? totalFuelTheftsOld;

//   getFuelRefills() async {
//     StaticVarMethod.fromdate = formatDateReport(DateTime.now().toString());
//     StaticVarMethod.todate = formatDateReport(DateTime.now().toString());
//     StaticVarMethod.fromtime = "00:00";
//     StaticVarMethod.totime = "${DateTime.now().hour}:${DateTime.now().minute}";

//     fuelRefills = null;
//     totalFuelRefillsLtr = null;
//     newFuelRefills = [];
//     double fuelRefillsInLtr = 0.0;

//     totalFuelRefills = null;

//     if (fuelRefills == null || fuelRefills == []) {
//       http.Response response = await http.post(
//         Uri.parse(
//             "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=11&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
//         body: {
//           "user_api_hash": StaticVarMethod.userApiHash,
//         },
//       );
//       log("fuel refill response ${response.request}");
//       log("fuel refill response ${response.body}");
//       fuelRefills =
//           ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
//     } else {
//       fuelRefills = fuelRefills;
//       fuelRefills = null;
//     }

//     if (fuelRefills != null) {
//       if (fuelRefills!.isNotEmpty) {
//         distanceSum = fuelRefills![0].distanceSum!;
//         engineHours = fuelRefills![0].engineHours;
//         engineIdles = fuelRefills![0].engineIdle;
//         engineStops = fuelRefills![0].engineWork;
//         if (fuelRefills![0].fuelConsumption != null) {
//           fuelConsumptionFuel =
//               fuelRefills![0].fuelConsumption!.sensor6!.toStringAsFixed(2);
//         } else {
//           fuelConsumptionFuel = "0.0";
//         }

//         // New Logic for discard duplicate fuel tank filling

//         if (fuelRefills![0].fuelTankFillings != null) {
//           int dataCount =
//               fuelRefills![0].fuelTankFillings!.sensor6?.length ?? 0;
//           double refills = 0.0;
//           double totalRefills = 0.0;
//           double? lastFuelCurrent;

//           for (int i = 0; i < dataCount; i++) {
//             Sensor6 currentRefill =
//                 fuelRefills![0].fuelTankFillings!.sensor6![i];
//             Sensor6? nextRefill;
//             if (i + 1 < dataCount) {
//               nextRefill = fuelRefills![0].fuelTankFillings!.sensor6![i + 1];
//             }

//             if (currentRefill.last != nextRefill?.last) {
//               refills = currentRefill.diff!.toDouble();
//               totalRefills += refills;

//               FuelFillings fuel = FuelFillings(
//                 date: currentRefill.time,
//                 lat: currentRefill.lat,
//                 lng: currentRefill.lng,
//                 diff: refills.toStringAsFixed(3),
//               );
//               newFuelRefills.add(fuel);

//               lastFuelCurrent = double.tryParse(currentRefill.current!);
//             }
//           }

//           totalFuelRefillsLtr = totalRefills.toStringAsFixed(2) ?? "0.0";
//           totalFuelRefills = newFuelRefills.length.toString() ?? "0";
//         }
//       }
//     }
//     getFuelThefts();
//   }

//   getFuelThefts() async {
//     log('getFuelThefts');
//     fuelDrains = null;
//     totalFuelTheftsLtrOld = null;
//     newFuelDrains = [];

//     double fuelTheftsInLtr = 0.0;
//     totalFuelTheftsOld = '0';
//     totalFuelTheftsLtr = '0';
//     totalFuelThefts = '0';

//     if (fuelDrains == null || fuelDrains == []) {
//       http.Response response = await http.post(
//         Uri.parse(
//             "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=12&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
//         body: {
//           "user_api_hash": StaticVarMethod.userApiHash,
//         },
//       );
//       log(response.request.toString());
//       fuelDrains =
//           ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
//     } else {
//       fuelDrains = fuelDrains;
//       fuelDrains = null;
//     }

//     /// [New Logic] ////

//     if (fuelDrains != null &&
//         fuelDrains!.isNotEmpty &&
//         fuelDrains![0].fuelTankThefts != null) {
//       int dataCount = fuelDrains![0].fuelTankThefts!.sensor6?.length ?? 0;
//       double totalDrains = 0.0;
//       String? lastDrain;

//       for (int i = 0; i < dataCount; i++) {
//         print('item: $i');
//         log("Fuel last: ${fuelDrains![0].fuelTankThefts!.sensor6![i].last}");
//         log("Fuel diff: ${fuelDrains![0].fuelTankThefts!.sensor6![i].diff}");
//         log("Fuel time: ${fuelDrains![0].fuelTankThefts!.sensor6![i].time}");
//         Sensor6 currentDrain = fuelDrains![0].fuelTankThefts!.sensor6![i];
//         Sensor6? nextDrain;
//         if (i < dataCount - 1) {
//           nextDrain = fuelDrains![0].fuelTankThefts!.sensor6![i + 1];
//         }

//         if (currentDrain.last != nextDrain?.last) {
//           totalDrains += currentDrain.diff!.toDouble();

//           FuelFillings fuel = FuelFillings(
//             date: currentDrain.time,
//             lat: currentDrain.lat,
//             lng: currentDrain.lng,
//             diff: currentDrain.diff!.toStringAsFixed(3),
//           );
//           newFuelDrains.add(fuel);

//           lastDrain = currentDrain.last;
//         }
//       }

//       totalFuelTheftsLtr = totalDrains.toStringAsFixed(2) ?? "0";
//       totalFuelThefts = newFuelDrains.length.toString() ?? "0";
//     }

//     getCurrentFuel();
//   }

//   getCurrentFuel() async {
//     log('getCurrentFuel');
//     fuelLevel = null;
//     http.Response response = await http.post(
//       Uri.parse(
//           "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=10&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
//       body: {
//         "user_api_hash": StaticVarMethod.userApiHash,
//       },
//     );
//     //print request url
//     log('getCurrentFuel request ${response.request}');
//     if (response.statusCode == 200) {
//       //print response
//       log('getCurrentFuel response ${response.body}');
//       print(
//           "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=10&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}");

//       fuelLevel = ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
//     } else {
//       log('getCurrentFuel response ${response.body}');
//     }

//     if (fuelLevel != null) {
//       if (fuelLevel!.isNotEmpty && fuelLevel![0].sensorValues != null) {
//         currentFuelLevel = fuelLevel![0].sensorValues!.sensor6![0].currentFuel;
//         startFuelLevel = fuelLevel![0].sensorValues!.sensor6?[1].currentFuel;
//       }
//     }
//     setState(() {});

//     // double startFuel = double.tryParse(startFuelLevel ?? "0.0") ?? 0.0;
//     // double fuelConsumption =
//     //     double.tryParse(fuelConsumptionFuel ?? "0.0") ?? 0.0;
//     // double endFuel = double.tryParse(currentFuelLevel ?? "0.0") ?? 0.0;
//     // double fuelFillings = double.tryParse(totalFuelRefillsLtr ?? "0.0") ?? 0.0;
//     // calculateFuelTheft(startFuel, fuelConsumption, endFuel, fuelFillings);
//   }

//   calculateFuelTheft(double startFuel, double fuelConsumption, double endFuel,
//       double fuelFillings) {
//     totalFuelTheftsLtr = null;

//     double? fuelTheft;
//     double remainingFuel = (startFuel + fuelFillings) - fuelConsumption;
//     if (remainingFuel != endFuel) {
//       double fuelDiff = remainingFuel - endFuel;
//       if (fuelDiff.abs() > 5) {
//         fuelTheft = fuelDiff;
//       }
//     }
//     fuelTheft ??= 0.0;
//     totalFuelTheftsLtr = fuelTheft.abs().toStringAsFixed(3);
//     totalFuelThefts = "${fuelTheft == 0.0 ? 0 : 1}";

//     double pilferageDiff = fuelTheft - double.parse(totalFuelTheftsLtrOld!);
//     if (pilferageDiff.abs() < 10) {
//       totalFuelTheftsLtr = totalFuelTheftsLtrOld;
//       totalFuelThefts = totalFuelTheftsOld;
//     }
//     newFuelDrains = [];
//     newFuelDrains.add(FuelFillings(
//       date: fuelTheftDate,
//       diff: totalFuelTheftsLtr,
//       lat: fuelTheftLat,
//       lng: fuelTheftLng,
//     ));
//     currentSpeed ??= 0;
//     if (currentSpeed! > 0) {
//       newFuelDrains = [];
//       totalFuelTheftsLtr = "0";
//       totalFuelThefts = "0";
//     }
//     setState(() {});
//   }

//   void initializePrefs() async {
//     prefs = await SharedPreferences.getInstance();
//     showFuelSummary = prefs!.getBool("showFuelSummary") ?? false;
//     showImmobilize = prefs!.getBool("Vehicle Immobilize") ?? false;
//     if (showFuelSummary) {
//       getFuelRefills();
//     }
//     setState(() {});
//   }

//   @override
//   void initState() {
//     initializePrefs();
//     search();
//     super.initState();
//     showReport1(0, "Today");
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorAssets.primaryColor,
//       appBar: AppBar(
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),

//         centerTitle: true,
//         title: Text('Summary',
//             style: AppTextStyle.titleStyle.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.w300,
//             )),
//         backgroundColor: ColorAssets.primaryColor,
//         //bottom: _reusableWidget.bottomAppBar(),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: ListView(
//           physics: const BouncingScrollPhysics(),
//           shrinkWrap: true,
//           children: [
//             const SizedBox(
//               height: 50,
//             ),
//             // history(),
//             Center(
//               child: isLoading
//                   ? Column(
//                       children: const [
//                         CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Loading...",
//                           style: TextStyle(color: Colors.white),
//                         )
//                       ],
//                     )
//                   : CustomPieChart(
//                       sections: [
//                         PieChartSectionData(
//                           color: Colors.green,
//                           value: double.tryParse(moveDuration
//                                   .replaceAll('min', '')
//                                   .replaceAll('h ', '')) ??
//                               0.0,
//                           title: "Moving",
//                           radius: 50,
//                           titleStyle: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         PieChartSectionData(
//                           color: Colors.red,
//                           value: double.tryParse(stopDuration
//                                 ..replaceAll('min', '').replaceAll('h ', '')) ??
//                               0.0,
//                           title: "Parked",
//                           radius: 50,
//                           titleStyle: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         PieChartSectionData(
//                           color: Colors.orange,
//                           value: double.tryParse(stopDuration
//                                   .replaceAll('min', '')
//                                   .replaceAll('h ', '')) ??
//                               0.0,
//                           title: "Parked",
//                           radius: 50,
//                           titleStyle: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//             const SizedBox(
//               height: 50,
//             ),

//             //Device Name with Emi and expire date and data of activate date

//             Column(
//               children: [
//                 //Name of Device
//                 Text(
//                   StaticVarMethod.deviceName ?? "N/A",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),

//                 //Emi Number
//                 Text(
//                   "IMEI: ${widget.productData.deviceData?.imei ?? "N/A"}",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//               ],
//             ),

//             playBackControls(),
//             showFuelSummary ? fuelSummaryCard() : const SizedBox(),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//               child: _buildTotalSummaryGrid(),
//             ),
//           ],
//         ),
//       ),
//       // bottomNavigationBar: _buildTotalSummaryGrid(),
//     );
//   }

//   history() {
//     return Padding(
//       padding: const EdgeInsets.all(5.0),
//       child: SizedBox(
//         height: 70,
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           elevation: 2,
//           color: Colors.white,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Column(
//                 children: [
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Icon(
//                     Icons.key_sharp,
//                     size: 20,
//                     color: widget.productData.online.toString().toLowerCase() ==
//                             "online"
//                         ? Colors.green
//                         : widget.productData.online.toString().toLowerCase() ==
//                                 'ack'
//                             ? Colors.green
//                             : Colors.red,
//                   ),
//                   Text(
//                     "Ignition",
//                     style: TextStyle(
//                         color: widget.productData.online
//                                     .toString()
//                                     .toLowerCase() ==
//                                 "online"
//                             ? Colors.green
//                             : widget.productData.online
//                                         .toString()
//                                         .toLowerCase() ==
//                                     'ack'
//                                 ? Colors.green
//                                 : Colors.red,
//                         fontSize: 13),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Icon(
//                     Icons.battery_charging_full_sharp,
//                     size: 20,
//                     color: power != "0.0" ? Colors.green : Colors.grey,
//                   ),
//                   Text(
//                     "Battery $power V",
//                     style: TextStyle(
//                         color: power != "0.0" ? Colors.green : Colors.grey,
//                         fontSize: 13),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Icon(
//                     CupertinoIcons.power,
//                     size: 22,
//                     color: battery != "0.0" || batteryLevel != "0.0"
//                         ? Colors.green
//                         : Colors.red,
//                   ),
//                   // Text(
//                   //   "Int Battery $battery V",
//                   //   style: TextStyle(
//                   //     color: battery != "0.0" || batteryLevel != "0.0"
//                   //         ? Colors.green
//                   //         : Colors.grey,
//                   //     fontSize: 13,
//                   //   ),
//                   // )
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget playBackControls() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: <Widget>[
//         const SizedBox(
//           height: 10,
//         ),
//         DetailsPageCard(
//           image: "assets/images/home/trip.png",
//           title: "Distance Travelled",
//           value: distanceSum,
//           subTitle: "Max Speed",
//           subValue: topSpeed,
//           color: ColorAssets.primaryColor,
//         ),
//         DetailsPageCard(
//           image: "assets/icons/exchange.png",
//           title: "Hours Moving",
//           value: moveDuration,
//           subTitle: "Start At",
//           subValue: startdate ?? "N/A",
//           color: Colors.green,
//         ),
//         DetailsPageCard(
//           image: "assets/icons/parking.png",
//           title: "Hours Parked",
//           value: stopDuration,
//           subTitle: "End At",
//           subValue: enddate ?? "N/A",
//           color: Colors.red,
//         ),
//         DetailsPageCard(
//           image: "assets/icons/timer.png",
//           title: "Expiry Date",
//           value: "${widget.productData.deviceData!.expirationDate ?? "N/A"}",
//           subTitle: "",
//           subValue: "",
//           color: Colors.orange,
//         ),

//         // Row(
//         //   children: [
//         //     Card(
//         //       shape: RoundedRectangleBorder(
//         //         borderRadius: BorderRadius.circular(10),
//         //       ),
//         //       elevation: 2,
//         //       color: Colors.white,
//         //       child: Container(
//         //         width: 150,
//         //         margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
//         //         child: Row(
//         //           mainAxisAlignment: MainAxisAlignment.start,
//         //           crossAxisAlignment: CrossAxisAlignment.start,
//         //           children: [
//         //             const Icon(
//         //               Icons.car_crash,
//         //               size: 40,
//         //               color: Color(0XFF063744),
//         //             ),
//         //             const SizedBox(
//         //               width: 10,
//         //             ),
//         //             Expanded(
//         //               child: Column(
//         //                 crossAxisAlignment: CrossAxisAlignment.start,
//         //                 children: [
//         //                   Container(
//         //                     margin: const EdgeInsets.only(top: 5),
//         //                     child: const Text('Expiry  Date',
//         //                         style: TextStyle(
//         //                           fontSize: 12,

//         //                           fontWeight: FontWeight.bold,
//         //                           //fontFamily: 'digital_font'
//         //                         )),
//         //                   ),
//         //                   Row(
//         //                     children: [
//         //                       Text(widget.expiredate,
//         //                           style: const TextStyle(
//         //                             fontSize: 12,
//         //                             height: 1.8,
//         //                             //color: Colors.blue
//         //                             fontWeight: FontWeight.bold,
//         //                           ))
//         //                     ],
//         //                   ),
//         //                 ],
//         //               ),
//         //             )
//         //           ],
//         //         ),
//         //       ),
//         //     ),
//         //   ],
//         // )
//       ],
//     );
//   }

//   fuelSummaryCard() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
//       child: InkWell(
//         onTap: fuelRefills == null
//             ? () {}
//             : () {
//                 Navigator.of(context).push(MaterialPageRoute(
//                     builder: (_) => SingleFuelSummary(
//                           currentDeviceId: StaticVarMethod.deviceId,
//                           fuelDrains: fuelDrains,
//                           fuelRefills: fuelRefills,
//                           fuelLevel: fuelLevel,
//                         )));
//               },
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Column(
//             children: [
//               fuelRefills == null
//                   ? ClipRRect(
//                       borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12)),
//                       child: LinearProgressIndicator(
//                         backgroundColor: Colors.amber.shade300,
//                         valueColor:
//                             AlwaysStoppedAnimation(HomeScreen.primaryDark),
//                         minHeight: 8,
//                       ),
//                     )
//                   : const SizedBox(),
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           "Fuel Summary",
//                           style: TextStyle(color: Colors.black87, fontSize: 17),
//                         ),
//                         Text(
//                           "${currentFuelLevel ?? "0"} ltr",
//                           style: const TextStyle(
//                               fontSize: 17, fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.only(left: 50.0),
//                       child: Divider(),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 color: Colors.red,
//                               ),
//                               padding: const EdgeInsets.all(8.0),
//                               child: const Icon(
//                                 Icons.gas_meter_rounded,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 8,
//                             ),
//                             const Text(
//                               "Total Fuel thefts today",
//                               style: TextStyle(
//                                   color: Colors.black54, fontSize: 15),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text("${totalFuelTheftsLtr ?? "0"} ltr",
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold)),
//                                 Text("(${totalFuelThefts ?? "0"} times)")
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.only(left: 50.0),
//                       child: Divider(),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 color: Colors.blue,
//                               ),
//                               padding: const EdgeInsets.all(8.0),
//                               child: const Icon(
//                                 Icons.gas_meter_outlined,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 8,
//                             ),
//                             const Text(
//                               "Total Fuel fillings today",
//                               style: TextStyle(
//                                   color: Colors.black54, fontSize: 15),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text("${totalFuelRefillsLtr ?? "0"} ltr",
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold)),
//                                 Text("(${totalFuelRefills ?? "0"} times)")
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTotalSummaryGrid() {
//     summaries = [
//       OptionSummary(
//         summaryIcon: Icons.location_on,
//         summaryName: "Live",
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const LiveTrack()),
//           );
//         },
//       ),
//       OptionSummary(
//         summaryIcon: Icons.replay_rounded,
//         summaryName: "History",
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const PlayBackSelection()),
//           );
//         },
//       ),
//       OptionSummary(
//         summaryIcon: Icons.play_arrow,
//         summaryName: "Today Playback",
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const PlaybackPage()),
//           );
//         },
//       ),
//       OptionSummary(
//         summaryIcon: Icons.trip_origin,
//         summaryName: "Trip",
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SingleTripSummary(
//                 currentDeviceId: StaticVarMethod.deviceId,
//               ),
//             ),
//           );
//         },
//       ),
//       // OptionSummary(
//       //   summaryIcon: Icons.travel_explore,
//       //   summaryName: "Daily Travel Summary",
//       //   onTap: () {
//       //     Navigator.push(
//       //       context,
//       //       MaterialPageRoute(
//       //         builder: (context) => SingleDailyTravelSummary(
//       //           currentDeviceId: StaticVarMethod.deviceId,
//       //         ),
//       //       ),
//       //     );
//       //   },
//       // ),
//       OptionSummary(
//         summaryIcon: Icons.art_track,
//         summaryName: "Travel",
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => SingleTravelDetail(
//                       currentDeviceId: widget.productData.id,
//                     )),
//           );
//         },
//       ),
//       OptionSummary(
//         summaryIcon: Icons.stop_circle_rounded,
//         summaryName: "Stoppage",
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SingleStopSummary(
//                 currentDeviceId: StaticVarMethod.deviceId,
//               ),
//             ),
//           );
//         },
//       ),
//       OptionSummary(
//         summaryIcon: Icons.social_distance,
//         summaryName: "Distance",
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SingleDistance(
//                 device_id: StaticVarMethod.deviceId,
//                 device_name: widget.productData.name,
//               ),
//             ),
//           );
//         },
//       ),
//       // OptionSummary(
//       //   summaryIcon: Icons.local_gas_station,
//       //   summaryName: "Fuel Summary",
//       //   onTap: () {
//       //     Navigator.push(
//       //       context,
//       //       MaterialPageRoute(
//       //         builder: (context) => SingleFuelSummary(
//       //           currentDeviceId: widget.productData.id.toString(),
//       //         ),
//       //       ),
//       //     );
//       //   },
//       // ),
//       // OptionSummary(
//       //   summaryIcon: Icons.speed,
//       //   summaryName: "Distance Travel Chart",
//       //   onTap: () {
//       //     Navigator.push(
//       //       context,
//       //       MaterialPageRoute(builder: (context) => const TravelChart()),
//       //     );
//       //   },
//       // ),
//       OptionSummary(
//         summaryIcon: Icons.document_scanner,
//         summaryName: "Documents",
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => const SingleDocumentScreen()),
//           );
//         },
//       ),
//       OptionSummary(
//         summaryIcon: Icons.punch_clock,
//         summaryName: "Expiry",
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SingleVehicleExpiryScreen(
//                 vehicle: widget.productData,
//               ),
//             ),
//           );
//         },
//       ),
//       OptionSummary(
//         summaryIcon: Icons.stacked_bar_chart,
//         summaryName: "Reports",
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const ReportSelection()),
//           );
//         },
//       ),
//       OptionSummary(
//         summaryIcon: Icons.share_location,
//         summaryName: "Share",
//         onTap: () async {
//           showDialog(
//               context: context,
//               barrierDismissible: false,
//               builder: (context) {
//                 return WillPopScope(
//                   onWillPop: () async {
//                     return false;
//                   },
//                   child: AlertDialog(
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: const [
//                         CircularProgressIndicator(),
//                       ],
//                     ),
//                   ),
//                 );
//               });
//           List<DeviceItems>? devices = StaticVarMethod.devicelist;
//           String? latitude;
//           String? longitude;
//           String? geoLocation;

//           try {
//             for (var element in devices) {
//               if (element.id.toString() == StaticVarMethod.deviceId) {
//                 latitude = element.lat.toString();
//                 longitude = element.lng.toString();
//                 Response response =
//                     await GPSAPIS.getGeocoder(latitude, longitude);
//                 geoLocation = response.body;
//                 List<String> locations = geoLocation.split(" ");
//                 String finalLocation = locations.first;
//                 for (int i = 1; i <= locations.length - 1; i++) {
//                   finalLocation = "$finalLocation+${locations[i]}";
//                 }
//                 String googleMapLink =
//                     "https://www.google.com/maps?q=$finalLocation";
//                 Navigator.pop(context);
//                 Share.share(googleMapLink);
//                 break;
//               }
//             }
//           } catch (e) {
//             log(e.toString());
//           }
//           // Fluttertoast.showToast(
//           //     msg: 'Comming soon ', toastLength: Toast.LENGTH_SHORT);
//         },
//       ),
//       // OptionSummary(
//       //   summaryIcon: Icons.local_parking,
//       //   summaryName: "Parking Mode",
//       //   onTap: () {
//       //     Navigator.push(
//       //       context,
//       //       MaterialPageRoute(
//       //           builder: (context) => ParkingScreen(
//       //                 currentDevice: [widget.productData],
//       //               )),
//       //     );
//       //   },
//       // ),
//       OptionSummary(
//         summaryIcon: Icons.power_off_rounded,
//         summaryName: "Immobilize",
//         onTap: immobilizeVehicleDialog,
//       ),
//     ];
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: GridView.builder(
//           physics: const BouncingScrollPhysics(),
//           shrinkWrap: true,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 6,
//             childAspectRatio: 1.0,
//             crossAxisSpacing: 0,
//             mainAxisSpacing: 16,
//           ),
//           itemCount: summaries.length,
//           itemBuilder: (context, index) {
//             return InkWell(
//               onTap: summaries[index].onTap,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 5),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       summaries[index].summaryIcon,
//                       size: 24,
//                       color: Colors.black,
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Text(
//                       summaries[index].summaryName,
//                       style: const TextStyle(
//                         fontSize: 8,
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 2,
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

  
  
  
  
//   immobilizeVehicleDialog() {
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Immobilize Vehicle"),
//           content: const Text(
//             "Are you sure that you want to immobilize the vehicle?",
//           ),
//           actions: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//               ),
//               onPressed: vehicleEngineOn,
//               child: const Text(
//                 "Engine On",
//               ),
//             ),
//             ElevatedButton(
//               onPressed: immobilizeVehicle,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               child: const Text(
//                 "Engine Off",
//               ),
//             )
//           ],
//         );
//       },
//     );
//   }

//   immobilizeVehicle() async {
//     Uri sms = Uri.parse('sms:${StaticVarMethod.simno}?body=RELAY,1%23');
//     if (await launchUrl(sms)) {
//       //app opened
//     } else {
//       //app is not opened
//     }
//   }

//   vehicleEngineOn() async {
//     Uri sms = Uri.parse('sms:${StaticVarMethod.simno}?body=RELAY,0%23');
//     if (await launchUrl(sms)) {
//       //app opened
//     } else {
//       //app is not opened
//     }
//   }

//   void showReport1(int selectedperiod, String currentday) {
//     String fromDate;
//     String toDate;
//     String fromTime;
//     String toTime;

//     DateTime current = DateTime.now();

//     String month;
//     String day;
//     if (current.month < 10) {
//       month = "0${current.month}";
//     } else {
//       month = current.month.toString();
//     }
//     if (current.day < 10) {
//       day = "0${current.day}";
//     } else {
//       day = current.day.toString();
//     }
//     if (selectedperiod == 0) {
//       String today;
//       int dayCon = current.day;
//       if (dayCon < 10) {
//         today = "0$dayCon";
//       } else {
//         today = dayCon.toString();
//       }

//       var date = DateTime.parse("${current.year}-"
//           "$month-"
//           "$today "
//           "00:00:00");
//       fromDate = formatDateReport(DateTime.now().toString());
//       toDate = formatDateReport(DateTime.now().toString());
//       fromTime = "00:00";
//       toTime = "23:59";

//       StaticVarMethod.fromdate = fromDate;
//       StaticVarMethod.todate = toDate;
//       StaticVarMethod.fromtime = fromTime;
//       StaticVarMethod.totime = toTime;
//     }

//     // Navigator.pop(context);

//     getReport1(
//         StaticVarMethod.deviceId,
//         StaticVarMethod.fromdate,
//         StaticVarMethod.fromtime,
//         StaticVarMethod.todate,
//         StaticVarMethod.totime,
//         currentday);
//     /* Navigator.pushNamed(context, "/reportList",
//         arguments: ReportArguments(device['id'], fromDate, fromTime,
//             toDate, toTime, device["name"], 0));*/
//   }

//   Future<PositionHistory?> getReport1(String deviceID, String fromDate,
//       String fromTime, String toDate, String toTime, String currentday) async {
//     setState(() {
//       isLoading = true;
//     });

//     final response = await http.get(Uri.parse(
//         "${StaticVarMethod.baseurlall}/api/get_history?lang=en&user_api_hash=${StaticVarMethod.userApiHash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&snap_to_road=false&device_id=$deviceID"));
//     if (response.statusCode == 200) {
//       var value = PositionHistory.fromJson(json.decode(response.body));
//       if (value.items!.isNotEmpty) {
//         startdate = value.items!.first;
//         enddate = value.items!.last;

//         startdate = startdate['show'];
//         enddate = enddate['show'];

//         setState(() {
//           isLoading = false;
//           topSpeed = value.topSpeed.toString();
//           moveDuration = value.moveDuration.toString();
//           stopDuration = value.stopDuration.toString();
//           fuelConsumption = value.fuelConsumption.toString();
//           distanceSum = value.distanceSum.toString();
//         });
//       }
//     } else {
//       return null;
//     }
//     setState(() {
//       isLoading = false;
//     });
//     return null;
//   }
// }

// class OptionSummary {
//   String summaryName;
//   IconData summaryIcon;
//   VoidCallback onTap;

//   OptionSummary({
//     required this.summaryIcon,
//     required this.summaryName,
//     required this.onTap,
//   });
// }
