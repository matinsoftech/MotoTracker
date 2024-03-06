// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:myvtsproject/data/model/history.dart' show History;
// import 'package:myvtsproject/data/screens/home/home_screen.dart';
// import 'package:myvtsproject/data/screens/fuel%20screen/fuel_refill_screen.dart';
//
// import '../../../config/static.dart';
// import '../../../mapconfig/CommonMethod.dart';
// import '../../datasources.dart';
// import '../../modelold/devices.dart';
// import '../../modelold/report_model.dart';
// import '../listscreen.dart';
// import '../reports/ReportEvent.dart';
// import 'fuel_drain_screen.dart';
// import 'package:http/http.dart' as http;
//
// class FuelSummary extends StatefulWidget {
//   const FuelSummary({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<FuelSummary> createState() => _FuelSummaryState();
// }
//
// class _FuelSummaryState extends State<FuelSummary> {
//   List<DeviceItems> devices = [];
//   String? currentDevice;
//   double dis = 0;
//   double averageSpeed = 0;
//   late String _startDate, _endDate;
//   int? currentDeviceId;
//   GPSAPIS api = GPSAPIS();
//   DateTime _fromDate = DateTime.now().subtract(const Duration(hours: 48));
//   DateTime _toDate = DateTime.now().subtract(const Duration(hours: 24));
//   bool disable = false;
//   bool searchButtonClicked = false;
//
//   getDeviceList() async {
//     devices = await StaticVarMethod.devicelist;
//     currentDevice = devices.first.name;
//     currentDeviceId = devices.first.id;
//     StaticVarMethod.deviceId = currentDeviceId!.toString();
//
//     setState(() {});
//   }
//
//   getCurrentDeviceId() {
//     for (var element in devices) {
//       if (element.name == currentDevice) {
//         currentDeviceId = element.id;
//       }
//     }
//   }
//
//   Future<void> _selectFromDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: _fromDate,
//         firstDate: DateTime(2015, 8),
//         lastDate: DateTime(2101));
//     if (picked != null && picked != _fromDate) {
//       setState(() {
//         _fromDate = picked;
//       });
//     }
//   }
//
//   Future<void> _selectToDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: _toDate,
//         firstDate: _fromDate,
//         lastDate: DateTime(2101));
//     if (picked != null && picked != _toDate) {
//       setState(() {
//         _toDate = picked;
//       });
//     }
//   }
//
//   search() async {
//     fuelRefills = null;
//     searchButtonClicked = true;
//
//     _startDate = _fromDate.toString().split(" ").first;
//     _endDate = _toDate.toString().split(" ").first;
//     getFuelRefills();
//     // try {
//     setState(() {});
//   }
//
//   void handleClick() async {
//     setState(() {
//       searchButtonClicked = true;
//       disable = true;
//     });
//     search();
//
//     await Future.delayed(const Duration(seconds: 5));
//     setState(() {
//       disable = false;
//     });
//   }
//
//   List<Items>? fuelRefills;
//   List<Items>? fuelDrains;
//   String? totalFuelRefillsLtr;
//   String? totalFuelTheftsLtr;
//   String? totalFuelRefills;
//   String? totalFuelThefts;
//
//   getFuelRefills() async {
//     fuelRefills = null;
//     totalFuelRefillsLtr = null;
//     totalFuelTheftsLtr = null;
//     totalFuelRefills = null;
//     totalFuelThefts = null;
//
//     http.Response response = await http.post(Uri.parse("http://app.merogaditracker.com/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=11&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad"), body: {
//       "user_api_hash": StaticVarMethod.userAPiHash,
//     });
//     fuelRefills = ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
//     if (fuelRefills != null) {
//       if(fuelRefills!.isNotEmpty) {
//         if(fuelRefills![0].fuelTankFillings != null) {
//           totalFuelRefillsLtr = fuelRefills![0].fuelTankFillings!.sensor6!.last.current;
//           totalFuelRefills = "${fuelRefills![0].fuelTankFillings!.sensor6!.length}";
//         }
//         if(fuelRefills![0].fuelTankThefts != null) {
//           totalFuelTheftsLtr = fuelRefills![0].fuelTankThefts!.sensor6!.last.current;
//           totalFuelThefts = "${fuelRefills![0].fuelTankThefts!.sensor6!.length}";
//         }
//       }
//       totalFuelTheftsLtr ??= "0";
//       totalFuelRefillsLtr ??= "0";
//       totalFuelThefts ??= "0";
//       totalFuelRefills ??= "0";
//     }
//     setState(() {
//     });
//   }
//
//
//   getFuelThefts() async {
//     getFuelRefills();
//     http.Response response = await http.post(Uri.parse("http://app.merogaditracker.com/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=12&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad"), body: {
//       "user_api_hash": StaticVarMethod.userAPiHash,
//     });
//     fuelDrains = ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
//     print(fuelDrains);
//     setState(() {
//     });
//   }
//
//   @override
//   void initState() {
//     getDeviceList();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: const DrawerWidget(
//           isHomeScreen: true,
//         ),
//         title: const Text("Fuel Summary"),
//         centerTitle: true,
//         backgroundColor: HomeScreen.primaryDark,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 fuelRefills == null && searchButtonClicked
//                     ? LinearProgressIndicator(
//                         backgroundColor: HomeScreen.primaryLight,
//                         valueColor:
//                             AlwaysStoppedAnimation(HomeScreen.primaryDark),
//                         minHeight: 6,
//                       )
//                     : const SizedBox(),
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 Container(
//                   padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Center(
//                         child: Text(
//                           'Choose the Vehicle: ',
//                           style: TextStyle(
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                       Center(
//                         child: DropdownButton<String>(
//                           hint: const Text("       Select a vehicle       "),
//                           // focusColor: Color(Colors.black),
//                           items: devices
//                               .map((e) => DropdownMenuItem<String>(
//                                     value: e.name.toString(),
//                                     child: Text(
//                                       e.name.toString(),
//                                       style: TextStyle(
//                                         color: HomeScreen.primaryDark,
//                                       ),
//                                     ),
//                                   ))
//                               .toList(),
//                           focusColor: HomeScreen.primaryDark,
//                           iconDisabledColor: HomeScreen.primaryDark,
//                           dropdownColor: Colors.white,
//                           iconEnabledColor: HomeScreen.primaryDark,
//                           value: currentDevice,
//                           onChanged: (Object? value) async {
//                             currentDevice = value.toString();
//                             getCurrentDeviceId();
//                             StaticVarMethod.deviceId = currentDeviceId.toString();
//                             setState(() {});
//                           },
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 15,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           const Text(
//                             'From',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                           OutlinedButton(
//                             onPressed: () => _selectFromDate(context),
//                             child: Text(
//                               '${_fromDate.toLocal()}'.split(' ')[0],
//                               style: TextStyle(
//                                   fontSize: 18, color: HomeScreen.primaryDark),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       const Text(
//                         'To',
//                         style: TextStyle(fontSize: 18),
//                       ),
//                       OutlinedButton(
//                         onPressed: () => _selectToDate(context),
//                         child: Text(
//                           '${_toDate.toLocal()}'.split(' ')[0],
//                           style: TextStyle(
//                               fontSize: 18, color: HomeScreen.primaryDark),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Container(
//               width: 150,
//               decoration: BoxDecoration(
//                 color: HomeScreen.primaryDark,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: TextButton(
//                 onPressed: disable ? null : handleClick,
//                 child: const Text(
//                   'Search',
//                   style: TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 30,
//             ),
//             fuelRefills != null
//                 ? fuelSummaryCard()
//                 : const SizedBox(),
//             const SizedBox(
//               height: 30,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   fuelSummaryCard() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Container(
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               BoxShadow(
//                   blurRadius: 10,
//                   offset: const Offset(3, 3),
//                   color: Colors.grey.shade300)
//             ]),
//         padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//              StaticVarMethod.deviceName ?? "",
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const Divider(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.green,
//                       ),
//                       padding: const EdgeInsets.all(8.0),
//                       child: const Icon(
//                         Icons.local_gas_station_rounded,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 8,
//                     ),
//                     const Text(
//                       "Total Fuel Level",
//                       style: TextStyle(color: Colors.black54, fontSize: 15),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: const [],
//                     ),
//                     IconButton(
//                         onPressed: () {
//                           StaticVarMethod.deviceId = currentDeviceId.toString();
//                           StaticVarMethod.fromdate =
//                               formatDateReport(_fromDate.toString());
//                           StaticVarMethod.todate =
//                               formatDateReport(_toDate.toString());
//                           StaticVarMethod.reportType = 10;
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const ReportEventPage()),
//                           );
//                           // Navigator.of(context).push(MaterialPageRoute(
//                           //     builder: (_) => const FuelRefillScreen()));
//                         },
//                         icon: const Icon(
//                           Icons.arrow_forward_ios_outlined,
//                           size: 23,
//                           color: Colors.black54,
//                         ))
//                   ],
//                 ),
//               ],
//             ),
//             const Padding(
//               padding: EdgeInsets.only(left: 50.0),
//               child: Divider(),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.red,
//                       ),
//                       padding: const EdgeInsets.all(8.0),
//                       child: const Icon(
//                         Icons.gas_meter_rounded,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 8,
//                     ),
//                     const Text(
//                       "Total Fuel thefts",
//                       style: TextStyle(color: Colors.black54, fontSize: 15),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                             "$totalFuelTheftsLtr ltr",
//                             style: const TextStyle(fontWeight: FontWeight.bold)
//                         ),
//                         Text(
//                             "($totalFuelThefts times)"
//                         )
//                       ],
//                     ),
//                     IconButton(
//                         onPressed: () {
//                           StaticVarMethod.deviceId = currentDeviceId.toString();
//                           StaticVarMethod.fromdate =
//                               formatDateReport(_fromDate.toString());
//                           StaticVarMethod.todate =
//                               formatDateReport(_toDate.toString());
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => FuelDrainScreen(
//                                   fuelDrains: fuelRefills,
//                                 )),
//                           );
//                         },
//                         icon: const Icon(
//                           Icons.arrow_forward_ios_outlined,
//                           size: 23,
//                           color: Colors.black54,
//                         ))
//                   ],
//                 ),
//               ],
//             ),
//               const Padding(
//               padding: EdgeInsets.only(left: 50.0),
//               child: Divider(),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.blue,
//                       ),
//                       padding: const EdgeInsets.all(8.0),
//                       child: const Icon(
//                         Icons.gas_meter_outlined,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 8,
//                     ),
//                     const Text(
//                       "Total Fuel fillings",
//                       style: TextStyle(color: Colors.black54, fontSize: 15),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                             "$totalFuelRefillsLtr ltr",
//                             style: const TextStyle(fontWeight: FontWeight.bold)
//                         ),
//                         Text(
//                             "($totalFuelRefills times)"
//                         )
//                       ],
//                     ),
//                     IconButton(
//                         onPressed: () {
//                           StaticVarMethod.deviceId = currentDeviceId.toString();
//                           StaticVarMethod.fromdate =
//                               formatDateReport(_fromDate.toString());
//                           StaticVarMethod.todate =
//                               formatDateReport(_toDate.toString());
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => FuelRefillScreen(
//                                   fuelRefills: fuelRefills,
//                                 )),
//                           );
//                         },
//                         icon: const Icon(
//                           Icons.arrow_forward_ios_outlined,
//                           size: 23,
//                           color: Colors.black54,
//                         ),
//                     )
//                   ],
//                 ),
//               ],
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
