import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/playback_selection.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../config/functions.dart';
import '../../../config/static.dart';
import '../../../mapconfig/common_method.dart';
import '../../modelold/devices.dart';
import '../../modelold/report_model.dart';
import '../fuel screen/fuel_drain_screen.dart';
import '../fuel screen/fuel_refill_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SingleFuelSummary extends StatefulWidget {
  final String currentDeviceId;
  List<Items>? fuelRefills;
  List<Items>? fuelLevel;
  List<Items>? fuelDrains;
  bool firstLoadingDone = false;

  SingleFuelSummary({
    Key? key,
    required this.currentDeviceId,
    this.fuelRefills,
    this.fuelLevel,
    this.fuelDrains,
  }) : super(key: key);

  @override
  State<SingleFuelSummary> createState() => _SingleFuelSummaryState();
}

class _SingleFuelSummaryState extends State<SingleFuelSummary> {
  List<DeviceItems> devices = [];
  String? currentDevice;
  int? currentDeviceId;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  bool disable = false;
  bool searchButtonClicked = false;
  bool showCustomDatePicker = false;
  bool isTodaySelected = true;

  // double getFuelConsuption() =>
  //  {((double.tryParse(startFuelLevel ?? "0")! + double.tryParse(totalFuelRefills ?? "0")!) - (double.tryParse(currentFuelLevel ?? "0")! + double.tryParse(totalFuelTheftsLtr ?? "0")!)).toStringAsFixed(2)};

  double calculateFuelConsumption() {
    double startFuel = double.tryParse(startFuelLevel ?? "0") ?? 0;
    double totalRefills = double.tryParse(totalFuelRefillsLtr ?? "0") ?? 0;
    double currentFuel = double.tryParse(currentFuelLevel ?? "0") ?? 0;
    double totalThefts = double.tryParse(totalFuelTheftsLtr ?? "0") ?? 0;

    //print all upper values
    print("startFuel $startFuel");
    print("totalRefills $totalRefills");
    print("currentFuel $currentFuel");
    print("totalThefts $totalThefts");

    // print total fuel consumption in ltr
    print((startFuel + totalRefills) - (currentFuel - totalThefts));
    log("fuel refill response ${(startFuel + totalRefills)}");
    log("fuel cut response ${(currentFuel + totalThefts)}");

    double fuelConsumption =
        (startFuel + totalRefills) - (currentFuel + totalThefts);
    return double.parse(fuelConsumption.toStringAsFixed(2));
  }

  search() async {
    fuelRefills = null;
    searchButtonClicked = true;

    getFuelRefills();
    setState(() {});
  }

  handleClick() async {
    setState(() {
      searchButtonClicked = true;
      disable = true;
    });
    await search();

    setState(() {
      disable = false;
    });
    ReportDataItem data = ReportDataItem(
      currentFuel: currentFuelLevel,
      startFuel: startFuelLevel,
      fuelConsumed: calculateFuelConsumption() < 0
          ? "0.0"
          : calculateFuelConsumption().toString(),
      fuelThefts: totalFuelTheftsLtr,
      fuelRefills: totalFuelRefillsLtr,
      distanceTravelled: distanceSum,
      endFuel: currentFuelLevel,
      from: StaticVarMethod.fromdate,
      to: StaticVarMethod.todate,
      mileage: calculateMileage(),
      moveDuration: movingDuration,
    );
    repotData.add(data);
  }

  List<Items>? fuelRefills;
  List<Items>? fuelLevel;
  List<Items>? fuelDrains;
  List<FuelFillings> newFuelRefills = [];
  List<FuelFillings> newFuelDrains = [];

  String? totalFuelRefillsLtr;
  String? totalFuelTheftsLtr;
  String? totalFuelRefills;
  String? totalFuelThefts;
  String? distanceSum;
  String? movingDuration;
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

  List<ReportDataItem> repotData = [];

  //fuelThefts
  String? totalFuelTheftsLtrOld;
  String? totalFuelTheftsOld;

  var selectedToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedFromTime = TimeOfDay.fromDateTime(DateTime.now());
  // var fromTime = DateFormat("HH:mm:ss").format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00, 00));
  // var toTime = DateFormat("HH:mm:ss").format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00, 00));

  bool isTimeWithinOneHour(String previousTime, String currentTime) {
    // Parse the time strings into DateTime objects
    DateFormat format = DateFormat("dd-MM-yyyy hh:mm:ss a");
    DateTime previousDateTime = format.parse(previousTime);
    DateTime currentDateTime = format.parse(currentTime);

    // Adjust the currentDateTime if it is in AM and previousDateTime is in PM
    if (currentDateTime.isBefore(previousDateTime) &&
        currentDateTime.hour < 12 &&
        previousDateTime.hour >= 12) {
      currentDateTime = currentDateTime.add(Duration(days: 1));
    }

    // Calculate the difference in hours
    Duration difference = currentDateTime.difference(previousDateTime);
    int differenceInHours = difference.inHours.abs();

    // Check if the difference is within 1 hour
    return differenceInHours <= 1;
  }

  getFuelRefills() async {
    fuelRefills = null;
    totalFuelRefillsLtr = null;
    newFuelRefills = [];
    double fuelRefillsInLtr = 0.0;

    totalFuelRefills = null;

    if (widget.fuelRefills == null || widget.fuelRefills == []) {
      http.Response response = await http.post(
        Uri.parse(
            "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=11&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
        body: {
          "user_api_hash": StaticVarMethod.userAPiHash,
        },
      );
      log("fuel refill response ${response.request}");
      log("fuel refill response ${response.body}");
      fuelRefills =
          ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
    } else {
      fuelRefills = widget.fuelRefills;
      widget.fuelRefills = null;
    }

    if (fuelRefills != null) {
      if (fuelRefills!.isNotEmpty) {
        distanceSum = fuelRefills![0].distanceSum;
        movingDuration = fuelRefills![0].moveDuration;
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
          }

          totalFuelRefillsLtr = totalRefills.toStringAsFixed(2) ?? "0.0";
          totalFuelRefills = newFuelRefills.length.toString() ?? "0";
        }

        // if (fuelRefills![0].fuelTankFillings != null) {
        //   int dataCount =
        //       fuelRefills![0].fuelTankFillings!.sensor6?.length ?? 0;
        //   int refillCount = 0;
        //   double refills = 0.0;
        //   double totalRefills = 0.0;
        //   double? lastFuelCurrent;

        //   for (int i = 0; i < dataCount; i++) {
        //     log("fuel refill response ${fuelRefills![0].fuelTankFillings!.sensor6![i].last}");
        //     log("fuel refill response ${fuelRefills![0].fuelTankFillings!.sensor6![i].diff}");
        //     Sensor6 currentRefill =
        //         fuelRefills![0].fuelTankFillings!.sensor6![i];

        //     if (currentRefill.current == lastFuelCurrent.toString()) {
        //       continue; // Skip duplicate fuel tank filling
        //     }

        //     if (lastFuelCurrent != null) {
        //       refillCount++;
        //       totalRefills += refills;
        //       FuelFillings fuel = FuelFillings(
        //         date: currentRefill.time,
        //         lat: currentRefill.lat,
        //         lng: currentRefill.lng,
        //         diff: refills.toStringAsFixed(3),
        //       );
        //       newFuelRefills.add(fuel);
        //       refills = 0.0;
        //     }

        //     refills += currentRefill.diff!;
        //     lastFuelCurrent = double.tryParse(currentRefill.current!);
        //   }

        //   // Add the last refill if it's not a duplicate
        //   if (lastFuelCurrent != null) {
        //     refillCount++;
        //     totalRefills += refills;
        //     FuelFillings fuel = FuelFillings(
        //       date: fuelRefills![0].fuelTankFillings!.sensor6!.last.time,
        //       lat: fuelRefills![0].fuelTankFillings!.sensor6!.last.lat,
        //       lng: fuelRefills![0].fuelTankFillings!.sensor6!.last.lng,
        //       diff: refills.toStringAsFixed(3),
        //     );
        //     newFuelRefills.add(fuel);
        //   }

        //   totalFuelRefillsLtr = totalRefills.toStringAsFixed(2);
        //   totalFuelRefills = "$refillCount";
        // }

        // if (fuelRefills![0].fuelTankFillings != null) {
        //   int dataCount = 0;
        //   dataCount = fuelRefills![0].fuelTankFillings!.sensor6?.length ?? 0;
        //   int refillCount = 0;
        //   double refills = 0.0;
        //   double totalRefills = 0.0;
        //   int count = 0;
        //   for (int i = 0; i < dataCount; i++) {
        //     fuelRefillsInLtr = fuelRefillsInLtr +
        //         fuelRefills![0].fuelTankFillings!.sensor6![i].diff!.toDouble();
        //     String? lastFuelRefillLocation;
        //     String? lastFuelTime;
        //     if (i > 0) {
        //       lastFuelRefillLocation =
        //           "${double.parse(fuelRefills![0].fuelTankFillings!.sensor6![i - 1].lat!).toStringAsFixed(3)}, ${double.parse(fuelRefills![0].fuelTankFillings!.sensor6![i - 1].lng!).toStringAsFixed(3)}";
        //       print(
        //           "Here${fuelRefills![0].fuelTankFillings!.sensor6![i - 1].time}");

        //       lastFuelTime =
        //           (fuelRefills![0].fuelTankFillings!.sensor6![i - 1].time!);
        //     } else {
        //       lastFuelRefillLocation =
        //           "${double.parse(fuelRefills![0].fuelTankFillings!.sensor6![i].lat!).toStringAsFixed(3)}, ${double.parse(fuelRefills![0].fuelTankFillings!.sensor6![i].lng!).toStringAsFixed(3)}";
        //       print(
        //           "Here${fuelRefills![0].fuelTankFillings!.sensor6![i].time}");
        //       lastFuelTime =
        //           (fuelRefills![0].fuelTankFillings!.sensor6![i].time!);
        //     }

        //     String currentFuelTime =
        //         (fuelRefills![0].fuelTankFillings!.sensor6![i].time!);
        //     String currentFuelRefillLocation =
        //         "${double.parse(fuelRefills![0].fuelTankFillings!.sensor6![i].lat!).toStringAsFixed(3)}, ${double.parse(fuelRefills![0].fuelTankFillings!.sensor6![i].lng!).toStringAsFixed(3)}";

        //     bool isWithinOneHour =
        //         isTimeWithinOneHour(lastFuelTime, currentFuelTime);
        //     print('Is within one hour: $isWithinOneHour');
        //     //changed here
        //     // if (currentFuelRefillLocation != lastFuelRefillLocation ) {
        //     if (isWithinOneHour == false) {
        //       refillCount++;
        //       if (count <= 1) {
        //         refills += fuelRefills![0].fuelTankFillings!.sensor6![i].diff!;
        //       }
        //       totalRefills += refills;
        //       FuelFillings fuel = FuelFillings(
        //         date: fuelRefills![0].fuelTankFillings!.sensor6![i].time,
        //         lat: fuelRefills![0].fuelTankFillings!.sensor6![i].lat,
        //         lng: fuelRefills![0].fuelTankFillings!.sensor6![i].lng,
        //         diff: refills.toStringAsFixed(3),
        //       );
        //       newFuelRefills.add(fuel);
        //       refills = 0.0;
        //       count = 0;
        //     } else {
        //       refills += fuelRefills![0].fuelTankFillings!.sensor6![i].diff!;
        //       count++;
        //       if (i == dataCount - 1) {
        //         refillCount++;
        //         totalRefills += refills;
        //         FuelFillings fuel = FuelFillings(
        //           date: fuelRefills![0].fuelTankFillings!.sensor6![i].time,
        //           lat: fuelRefills![0].fuelTankFillings!.sensor6![i].lat,
        //           lng: fuelRefills![0].fuelTankFillings!.sensor6![i].lng,
        //           diff: refills.toStringAsFixed(3),
        //         );
        //         newFuelRefills.add(fuel);
        //       }
        //     }

        //     // String formattedDateTime = fuelRefills![0].fuelTankFillings!.sensor6![i].time!.substring(0, 19);
        //     // String formattedDate = formattedDateTime.split(" ").first;
        //     // String formattedTime = formattedDateTime.split(" ").last;
        //     // String year = formattedDate.split("-").last;
        //     // String month = formattedDate.split("-")[1];
        //     // String day = formattedDate.split("-").first;
        //     // String finalDateTime = "$year-$month-$day $formattedTime";
        //     // DateTime refillDate = DateTime.parse(finalDateTime);
        //     // print(refillDate);
        //   }
        //   totalFuelRefillsLtr = totalRefills.toStringAsFixed(2);
        //   totalFuelRefills = "$refillCount";
        // }
      }
      totalFuelRefillsLtr ??= "0";
      totalFuelRefills ??= "0";
      distanceSum ??= "0";
      fuelConsumptionFuel ??= "0";
    }
    getFuelThefts();
  }

  getFuelThefts() async {
    fuelDrains = [];
    totalFuelTheftsLtrOld = null;
    newFuelDrains = [];

    double fuelTheftsInLtr = 0.0;
    totalFuelTheftsOld = '0';
    totalFuelTheftsLtr = '0';
    totalFuelThefts = '0';

    if (widget.fuelDrains == null || widget.fuelDrains == []) {
      http.Response response = await http.post(
        Uri.parse(
            "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=12&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
        body: {
          "user_api_hash": StaticVarMethod.userAPiHash,
        },
      );
      fuelDrains =
          ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
    } else {
      fuelDrains = widget.fuelDrains;
      widget.fuelDrains = null;
    }

    /// [New Logic] ////

    /// [Old Logic] ////

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
    if (widget.fuelLevel == null || widget.fuelLevel == []) {
      fuelLevel = null;
      http.Response response = await http.post(
        Uri.parse(
            "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=10&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
        body: {
          "user_api_hash": StaticVarMethod.userAPiHash,
        },
      );
      fuelLevel = ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
    } else {
      fuelLevel = widget.fuelLevel;
      widget.fuelLevel = null;
    }
    if (fuelLevel != null) {
      if (fuelLevel!.isNotEmpty) {
        currentFuelLevel = fuelLevel![0].sensorValues != null &&
                fuelLevel![0].sensorValues!.sensor6 != null &&
                fuelLevel![0].sensorValues!.sensor6!.isNotEmpty
            ? fuelLevel![0].sensorValues!.sensor6![0].currentFuel
            : "0.0";
        startFuelLevel = fuelLevel![0].sensorValues != null &&
                fuelLevel![0].sensorValues!.sensor6 != null &&
                fuelLevel![0].sensorValues!.sensor6!.isNotEmpty
            ? fuelLevel![0].sensorValues!.sensor6![1].currentFuel
            : "0.0";
      }
    }
    // double startFuel = double.tryParse(startFuelLevel ?? "0.0") ?? 0.0;
    // double fuelConsumption =
    //     double.tryParse(fuelConsumptionFuel ?? "0.0") ?? 0.0;
    // double endFuel = double.tryParse(currentFuelLevel ?? "0.0") ?? 0.0;
    // double fuelFillings = double.tryParse(totalFuelRefillsLtr ?? "0.0") ?? 0.0;
    setState(() {});
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

  String calculateMileage() {
    mileage = null;
    if (double.parse(distanceSum!) != 0.0 &&
        calculateFuelConsumption() >= 0.0) {
      mileage = (double.parse(distanceSum!) / calculateFuelConsumption())
          .toStringAsFixed(3);

      return mileage!;
    } else {
      return mileage = "0.0";
    }
  }

  @override
  void initState() {
    super.initState();
    _fromDate =
        DateTime(_fromDate.year, _fromDate.month, _fromDate.day, 00, 00, 00);
    _toDate = DateTime(_toDate.year, _toDate.month, _toDate.day, 00, 00, 00);

    showCustomDatePicker = false;
    StaticVarMethod.fromdate = formatDateReport(DateTime.now().toString());
    StaticVarMethod.todate = formatDateReport(DateTime.now().toString());
    // StaticVarMethod.fromtime = fromTime;
    // StaticVarMethod.totime = toTime;
    if (widget.firstLoadingDone == false) {
      widget.firstLoadingDone = true;
      handleClick();
    }
  }

  List<List<String>> data = [
    ['Name', 'Age', 'Country'],
    ['John Doe', '30', 'USA'],
    ['Jane Doe', '25', 'Canada'],
  ];

  Future<Uint8List?> generatePdfFile(List<List<String>> data) async {
    try {
      final pw.Document pdf = pw.Document();

      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            context: context,
            data: data,
          );
        },
      ));

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      final String fileName =
          // date for name
          '${StaticVarMethod.fromdate} - ${StaticVarMethod.todate} - ${StaticVarMethod.deviceName}.pdf';
      final String filePath = '$appDocPath/$fileName';

      final Uint8List bytes = await pdf.save();

      await File(filePath).writeAsBytes(bytes);

      print('PDF file saved at: $filePath');

      return bytes;
    } catch (error) {
      print('Error generating PDF file: $error');
      return null;
    }
  }

  Future<void> downloadPdfFile(Uint8List pdfBytes) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      final String fileName =
          // date for name
          '${StaticVarMethod.fromdate} - ${StaticVarMethod.todate} - ${StaticVarMethod.deviceName}.pdf';
      final String filePath = '$appDocPath/$fileName';

      await File(filePath).writeAsBytes(pdfBytes);

      // Download the PDF
      print('PDF saved at: $filePath');
      await OpenFile.open(filePath);
    } catch (error) {
      print('Error downloading PDF: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fuel Summary"),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Column(
          children: [
            (fuelRefills == null || fuelLevel == null || fuelDrains == null) &&
                    searchButtonClicked
                ? LinearProgressIndicator(
                    backgroundColor: HomeScreen.linearColor,
                    valueColor: AlwaysStoppedAnimation(HomeScreen.primaryDark),
                    minHeight: 6,
                  )
                : const SizedBox(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
              child: GridView(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3,
                  crossAxisSpacing: 15,
                ),
                children: [
                  _buildCustomDateWidget(
                    label: "Today",
                    onTap: fuelRefills == null && searchButtonClicked
                        ? () {}
                        : () {
                            showCustomDatePicker = false;
                            isTodaySelected = true;
                            StaticVarMethod.fromdate =
                                formatDateReport(DateTime.now().toString());
                            StaticVarMethod.todate =
                                formatDateReport(DateTime.now().toString());
                            StaticVarMethod.fromtime = "00:00";
                            StaticVarMethod.totime =
                                "${DateTime.now().hour}:${DateTime.now().minute}";
                            setState(() {});
                            handleClick();
                          },
                  ),
                  _buildCustomDateWidget(
                    label: "Yesterday",
                    onTap: fuelRefills == null && searchButtonClicked
                        ? () {}
                        : () {
                            showCustomDatePicker = false;
                            isTodaySelected = false;
                            StaticVarMethod.fromdate = formatDateReport(
                                DateTime.now()
                                    .subtract(const Duration(hours: 24))
                                    .toString());
                            StaticVarMethod.todate = formatDateReport(
                                DateTime.now()
                                    .subtract(const Duration(hours: 24))
                                    .toString());

                            StaticVarMethod.fromtime = "00:00";
                            StaticVarMethod.totime = "23:59";

                            setState(() {});
                            handleClick();
                          },
                  ),
                  _buildCustomDateWidget(
                    label: "This Week",
                    onTap: fuelRefills == null && searchButtonClicked
                        ? () {}
                        : () {
                            showCustomDatePicker = false;
                            isTodaySelected = false;
                            StaticVarMethod.fromdate = formatDateReport(
                                DateTime.now()
                                    .subtract(const Duration(days: 7))
                                    .toString());
                            StaticVarMethod.todate =
                                formatDateReport(DateTime.now().toString());
                            StaticVarMethod.fromtime = "00:00";
                            StaticVarMethod.totime = "23:59";
                            setState(() {});
                            handleClick();
                          },
                  ),
                ],
              ),
            ),

            //In Row Time Select Start and End

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      isTodaySelected = false;
                      showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                  hour: int.parse(
                                      StaticVarMethod.fromtime.substring(0, 2)),
                                  minute: int.parse(StaticVarMethod.fromtime
                                      .substring(3, 5))))
                          .then((value) {
                        if (value != null) {
                          //  in 00:00 format
                          //if less than 10 then add 0 before
                          if (value.hour < 10 && value.minute < 10) {
                            StaticVarMethod.fromtime =
                                "0${value.hour}:0${value.minute}";
                          } else if (value.hour < 10) {
                            StaticVarMethod.fromtime =
                                "0${value.hour}:${value.minute}";
                          } else if (value.minute < 10) {
                            StaticVarMethod.fromtime =
                                "${value.hour}:0${value.minute}";
                          } else {
                            StaticVarMethod.fromtime =
                                "${value.hour}:${value.minute}";
                          }
                          setState(() {});
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(3, 3),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${StaticVarMethod.fromtime}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Icon(
                            Icons.timer,
                            color: HomeScreen.primaryDark,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      isTodaySelected = false;
                      //Select time
                      showTimePicker(
                              context: context,
                              //in 24 hour format

                              initialTime: TimeOfDay(
                                  hour: int.parse(
                                      StaticVarMethod.totime.substring(0, 2)),
                                  minute: int.parse(
                                      StaticVarMethod.totime.substring(3, 5))))
                          .then((value) {
                        if (value != null) {
                          // with 23 hour format
                          //  in 00:00 format
                          //if less than 10 then add 0 before
                          if (value.hour < 10 && value.minute < 10) {
                            StaticVarMethod.totime =
                                "0${value.hour}:0${value.minute}";
                          } else if (value.hour < 10) {
                            StaticVarMethod.totime =
                                "0${value.hour}:${value.minute}";
                          } else if (value.minute < 10) {
                            StaticVarMethod.totime =
                                "${value.hour}:0${value.minute}";
                          } else {
                            StaticVarMethod.totime =
                                "${value.hour}:${value.minute}";
                          }

                          setState(() {});
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(3, 3),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${StaticVarMethod.totime}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Icon(
                            Icons.timer,
                            color: HomeScreen.primaryDark,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 15,
            ),

            //In Row Date Select Start and End

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        isTodaySelected = false;
                        //Select Date
                        showDatePicker(
                                context: context,
                                initialDate:
                                    DateTime.parse(StaticVarMethod.fromdate),
                                firstDate: DateTime(2019),
                                lastDate: DateTime.now())
                            .then((value) {
                          if (value != null) {
                            StaticVarMethod.fromdate =
                                //Only date
                                value.toString().substring(0, 10);
                            setState(() {});
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(3, 3),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${StaticVarMethod.fromdate}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: HomeScreen.primaryDark,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        isTodaySelected = false;
                        //Select Date
                        showDatePicker(
                                context: context,
                                initialDate:
                                    DateTime.parse(StaticVarMethod.todate),
                                firstDate:
                                    DateTime.parse(StaticVarMethod.fromdate),
                                lastDate:
                                    // Only 7 days can be selected from first date and only today can be selected from last date not more than that
                                    DateTime.parse(StaticVarMethod.fromdate)
                                        .add(const Duration(days: 7)))
                            .then((value) {
                          if (value != null) {
                            StaticVarMethod.todate =
                                //Only date
                                value.toString().substring(0, 10);
                            setState(() {});
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(3, 3),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${StaticVarMethod.todate}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: HomeScreen.primaryDark,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // InkWell(
            //   onTap: () {
            //     isTodaySelected = false;

            //     // customDateRangePicker();
            //   },
            //   child: Container(
            //     margin: const EdgeInsets.symmetric(horizontal: 20.0),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(8),
            //       boxShadow: const [
            //         BoxShadow(
            //           color: Colors.black12,
            //           blurRadius: 10,
            //           offset: Offset(3, 3),
            //         )
            //       ],
            //     ),
            //     padding: const EdgeInsets.all(8),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         InkWell(
            //           onTap: () {
            //             showDatePicker(
            //                     context: context,
            //                     initialDate:
            //                         DateTime.parse(StaticVarMethod.fromdate),
            //                     firstDate: DateTime(2019),
            //                     lastDate: DateTime.now())
            //                 .then((value) {
            //               if (value != null) {
            //                 StaticVarMethod.fromdate =
            //                     formatDateReport(value.toString());
            //                 setState(() {});
            //               }
            //             });
            //           },
            //           child: Text(
            //             "${StaticVarMethod.fromdate}",
            //             style: const TextStyle(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.black54),
            //           ),
            //         ),
            //         Text(
            //           " - ",
            //           style: const TextStyle(
            //               fontSize: 16,
            //               fontWeight: FontWeight.bold,
            //               color: Colors.black54),
            //         ),
            //         InkWell(
            //           onTap: () {
            //             showDatePicker(
            //                     context: context,
            //                     initialDate:
            //                         DateTime.parse(StaticVarMethod.todate),
            //                     firstDate: DateTime(2019),
            //                     lastDate: DateTime.now())
            //                 .then((value) {
            //               if (value != null) {
            //                 StaticVarMethod.todate =
            //                     formatDateReport(value.toString());
            //                 setState(() {});
            //               }
            //             });
            //           },
            //           child: Text(
            //             "${StaticVarMethod.todate}",
            //             style: const TextStyle(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.black54),
            //           ),
            //         ),
            //         const SizedBox(
            //           width: 20,
            //         ),
            //         Icon(
            //           Icons.calendar_month_outlined,
            //           color: HomeScreen.primaryDark,
            //         )
            //       ],
            //     ),
            //   ),
            // ),

            const SizedBox(
              height: 15,
            ),
            //REfresh Button
            InkWell(
              onTap: () {
                isTodaySelected = false;
                handleClick();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(3, 3),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Load Data",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Icon(
                      Icons.refresh,
                      color: HomeScreen.primaryDark,
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            (fuelRefills != null && fuelLevel != null && fuelDrains != null)
                ? newFuelSummaryCard()
                : const SizedBox(),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  fuelSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                blurRadius: 10,
                offset: const Offset(3, 3),
                color: Colors.grey.shade300)
          ]),
      padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    padding: const EdgeInsets.all(5.0),
                    child: const Icon(
                      Icons.gas_meter_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const Text(
                    "Total Fuel thefts",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "$totalFuelTheftsLtr ltr",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("($totalFuelThefts times)")
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FuelDrainScreen(
                                    fuelDrains: totalFuelThefts == "0"
                                        ? []
                                        : newFuelDrains,
                                  )),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: 20,
                        color: Colors.black54,
                      ))
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 45.0),
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
                    padding: const EdgeInsets.all(5.0),
                    child: const Icon(
                      Icons.gas_meter_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const Text(
                    "Total Fuel fillings",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("$totalFuelRefillsLtr ltr",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("($totalFuelRefills times)")
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FuelRefillScreen(
                                  fuelRefills: newFuelRefills,
                                )),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                      color: Colors.black54,
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  newFuelSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: const [
        //   BoxShadow(
        //     blurRadius: 10,
        //     offset: Offset(3,3),
        //     color: Colors.black26
        //   )
        // ]
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: HomeScreen.primaryDark.withOpacity(0.2),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.local_gas_station_rounded,
                        color: HomeScreen.primaryDark,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      StaticVarMethod.deviceName.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                isTodaySelected
                    ? Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: const Color.fromRGBO(62, 187, 69, 1),
                          // border: Border.all(
                          //   color: const Color.fromRGBO(187, 221, 222, 1),
                          //   width: 5,
                          // )
                        ),
                        // padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Current Fuel Level",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                  text: currentFuelLevel ?? "0",
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: const <TextSpan>[
                                    TextSpan(
                                        text: "ltr",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18))
                                  ]),
                            )
                          ],
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Fuel Consumed",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                              text: calculateFuelConsumption() < 0
                                  ? "0.0"
                                  : calculateFuelConsumption().toString(),

                              // fuelConsumptionFuel ?? "0",
                              style: TextStyle(
                                fontSize: 23,
                                color: HomeScreen.primaryDark,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: " ltr",
                                    style: TextStyle(
                                        color: HomeScreen.primaryDark,
                                        fontSize: 20))
                              ]),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Distance",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        RichText(
                          text: TextSpan(
                              text: distanceSum,
                              style: TextStyle(
                                fontSize: 23,
                                color: HomeScreen.primaryDark,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: " KM",
                                    style: TextStyle(
                                        color: HomeScreen.primaryDark,
                                        fontSize: 20))
                              ]),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 2,
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0)
                .copyWith(bottom: 5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_gas_station_outlined,
                            color: HomeScreen.primaryDark,
                          ),
                          Text(
                            "Mileage: ",
                            style: TextStyle(
                              color: HomeScreen.primaryDark,
                              fontWeight: FontWeight.w400,
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            calculateMileage() ?? "0.0",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: [
                          Icon(
                            Icons.time_to_leave,
                            color: HomeScreen.primaryDark,
                          ),
                          Text(
                            "Move duration: ",
                            style: TextStyle(
                              color: HomeScreen.primaryDark,
                              fontWeight: FontWeight.w400,
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            movingDuration ?? "0",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Row(
                        children: [
                          Icon(
                            Icons.gas_meter_rounded,
                            color: HomeScreen.primaryDark,
                          ),
                          Text(
                            "Start Fuel: ",
                            style: TextStyle(
                              color: HomeScreen.primaryDark,
                              fontWeight: FontWeight.w400,
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            startFuelLevel ?? "0",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: [
                          Icon(
                            Icons.garage_sharp,
                            color: HomeScreen.primaryDark,
                          ),
                          Text(
                            "Ending Fuel: ",
                            style: TextStyle(
                              color: HomeScreen.primaryDark,
                              fontWeight: FontWeight.w400,
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            currentFuelLevel ?? "0",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          fuelSummaryCard(),
          const SizedBox(
            height: 20,
          ),

          // ReportDataItems in table

          // if (repotData.isNotEmpty)
          //   SingleChildScrollView(
          //     scrollDirection: Axis.horizontal,
          //     child: DataTable(
          //       columnSpacing: 10 ,
          //       columns: const [
          //         DataColumn(
          //           label: Text(
          //             "From",
          //             style:
          //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          //           ),
          //         ),
          //         DataColumn(
          //           label: Text(
          //             "To",
          //             style:
          //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          //           ),
          //         ),
          //         DataColumn(
          //           label: Text(
          //             "Start Fuel",
          //             style:
          //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          //           ),
          //         ),
          //         DataColumn(
          //           label: Text(
          //             "End Fuel",
          //             style:
          //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          //           ),
          //         ),
          //         DataColumn(
          //           label: Text(
          //             "Fuel Consumed",
          //             style:
          //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          //           ),
          //         ),
          //         DataColumn(
          //           label: Text(
          //             "Current Fuel",
          //             style:
          //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          //           ),
          //         ),
          //         DataColumn(
          //           label: Text(
          //             "Fuel Refills",
          //             style:
          //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          //           ),
          //         ),
          //         DataColumn(
          //           label: Text(
          //             "Fuel Thefts",
          //             style:
          //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          //           ),
          //         ),
          //         DataColumn(
          //           label: Text(
          //             "Distance Travelled",
          //             style:
          //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          //           ),
          //         ),
          //         DataColumn(
          //           label: Text(
          //             "Move Duration",
          //             style:
          //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          //           ),
          //         ),
          //         DataColumn(
          //           label: Text(
          //             "Mileage",
          //             style:
          //                 TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          //           ),
          //         ),
          //       ],
          //       rows: [
          //         for (var item in repotData)
          //           DataRow(
          //             cells: [
          //               DataCell(
          //                 Text(
          //                   item.from ?? "",
          //                   style: const TextStyle(
          //                       fontWeight: FontWeight.bold, fontSize: 10),
          //                 ),
          //               ),
          //               DataCell(
          //                 Text(
          //                   item.to ?? "",
          //                   style: const TextStyle(
          //                       fontWeight: FontWeight.bold, fontSize: 10),
          //                 ),
          //               ),
          //               DataCell(
          //                 Text(
          //                   item.startFuel ?? "",
          //                   style: const TextStyle(
          //                       fontWeight: FontWeight.bold, fontSize: 10),
          //                 ),
          //               ),
          //               DataCell(
          //                 Text(
          //                   item.endFuel ?? "",
          //                   style: const TextStyle(
          //                       fontWeight: FontWeight.bold, fontSize: 10),
          //                 ),
          //               ),
          //               DataCell(
          //                 Text(
          //                   item.fuelConsumed ?? "",
          //                   style: const TextStyle(
          //                       fontWeight: FontWeight.bold, fontSize: 10),
          //                 ),
          //               ),
          //               DataCell(
          //                 Text(
          //                   item.currentFuel ?? "",
          //                   style: const TextStyle(
          //                       fontWeight: FontWeight.bold, fontSize: 10),
          //                 ),
          //               ),
          //               DataCell(
          //                 Text(
          //                   item.fuelRefills ?? "",
          //                   style: const TextStyle(
          //                       fontWeight: FontWeight.bold, fontSize: 10),
          //                 ),
          //               ),
          //               DataCell(
          //                 Text(
          //                   item.fuelThefts ?? "",
          //                   style: const TextStyle(
          //                       fontWeight: FontWeight.bold, fontSize: 10),
          //                 ),
          //               ),
          //               DataCell(
          //                 Text(
          //                   item.distanceTravelled ?? "",
          //                   style: const TextStyle(
          //                       fontWeight: FontWeight.bold, fontSize: 10),
          //                 ),
          //               ),
          //               DataCell(
          //                 Text(
          //                   item.moveDuration ?? "",
          //                   style: const TextStyle(
          //                       fontWeight: FontWeight.bold, fontSize: 10),
          //                 ),
          //               ),
          //               DataCell(
          //                 Text(
          //                   item.mileage ?? "",
          //                   style: const TextStyle(
          //                       fontWeight: FontWeight.bold, fontSize: 10),
          //                 ),
          //               ),
          //             ],
          //           ),
          //       ],
          //     ),
          //   ),

          // Table(

          //   border: TableBorder.all(color: Colors.grey.shade300),
          //   children: [
          //     TableRow(
          //       decoration: BoxDecoration(
          //         color: Colors.grey.shade200,
          //       ),
          //       children: [
          //         const Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Text(
          //             "From",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Text(
          //             "To",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Text(
          //             "Start Fuel",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Text(
          //             "End Fuel",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Text(
          //             "Fuel Consumed",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Text(
          //             "Current Fuel",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Text(
          //             "Fuel Refills",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Text(
          //             "Fuel Thefts",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Text(
          //             "Distance Travelled",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Text(
          //             "Move Duration",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //         const Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: Text(
          //             "Mileage",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //     for (var item in repotData)
          //       TableRow(
          //         children: [
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Text(
          //               item.from ?? "",
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Text(
          //               item.to ?? "",
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Text(
          //               item.startFuel ?? "",
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Text(
          //               item.endFuel ?? "",
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Text(
          //               item.fuelConsumed ?? "",
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Text(
          //               item.currentFuel ?? "",
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Text(
          //               item.fuelRefills ?? "",
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Text(
          //               item.fuelThefts ?? "",
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Text(
          //               item.distanceTravelled ?? "",
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Text(
          //               item.moveDuration ?? "",
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Text(
          //               item.mileage ?? "",
          //               style: const TextStyle(fontWeight: FontWeight.bold),
          //             ),
          //           ),
          //         ],
          //       ),
          //   ],
          // ),

          // ListTile(
          //   onTap: () {
          //     var milege = calculateMileage();
          //     var fuelConsumption = calculateFuelConsumption() < 0
          //         ? "0.0"
          //         : calculateFuelConsumption().toString();

          //     List<List<String>> data = [
          //       [
          //         'From',
          //         'To',
          //         'Start Fuel',
          //         'End Fuel',
          //         'Fuel Consumed',
          //         'Current Fuel',
          //         'Fuel Refills',
          //         'Fuel Thefts',
          //         'Distance Travelled',
          //         'Move Duration',
          //         'Mileage'
          //       ],
          //       [
          //         '${StaticVarMethod.fromdate}',
          //         '${StaticVarMethod.todate}',
          //         '$startFuelLevel',
          //         '$currentFuelLevel',
          //         fuelConsumption,
          //         '$currentFuelLevel',
          //         '$totalFuelRefillsLtr',
          //         '$totalFuelTheftsLtr',
          //         '$distanceSum',
          //         '$movingDuration',
          //         '$milege'
          //       ],
          //     ];
          //     //generate and download pdf
          //     generatePdfFile(data).then((pdfBytes) {
          //       if (pdfBytes != null) {
          //         downloadPdfFile(pdfBytes);
          //       }
          //     });
          // },
          //   leading: Icon(
          //     Icons.report_outlined,
          //     color: HomeScreen.primaryDark,
          //   ),
          //   title: const Text("Download Report"),
          //   trailing: const Icon(Icons.download_outlined),
          // ),

          ListTile(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlayBackSelection())),
            leading: Icon(
              Icons.location_on,
              color: HomeScreen.primaryDark,
            ),
            title: const Text("View playback history"),
            trailing: const Icon(Icons.arrow_forward_ios_outlined),
          )

          // Row(
          //   children: [
          //     Icon(
          //       Icons.gas_meter_rounded,
          //       color: HomeScreen.primaryDark,
          //     ),
          //     Text(
          //       "Distance Travelled: ",
          //       style: TextStyle(
          //         color: HomeScreen.primaryDark,
          //         fontWeight: FontWeight.w400,
          //         fontSize: 9,
          //       ),
          //     ),
          //     const Text(
          //       "30 KM",
          //       style: TextStyle(
          //         fontWeight: FontWeight.bold,
          //         fontSize: 9,
          //       ),
          //     )
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildCustomDateWidget({
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(3, 5),
              color: Colors.black26,
            )
          ],
          color: HomeScreen.primaryDark,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  customDateRangePicker() async {
    // List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
    //   context: context,
    //   startInitialDate: DateTime(_fromDate.year, _fromDate.month, _fromDate.day,
    //       _fromDate.hour, _fromDate.minute, _fromDate.second),
    //   startFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
    //   startLastDate: _fromDate.add(
    //     const Duration(days: 3652),
    //   ),
    //   endInitialDate: DateTime(_toDate.year, _toDate.month, _toDate.day,
    //       _toDate.hour, _toDate.minute, _toDate.second),
    //   endFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
    //   endLastDate: _toDate.add(
    //     const Duration(days: 3652),
    //   ),
    //   is24HourMode: true,
    //   borderRadius: const BorderRadius.all(Radius.circular(16)),
    //   constraints: const BoxConstraints(
    //     maxWidth: 350,
    //     maxHeight: 650,
    //   ),
    //   barrierDismissible: true,
    //   type: OmniDateTimePickerType.dateAndTime,
    // );

    showCustomDateRangePicker(
      context,
      dismissible: true,
      minimumDate: DateTime.now().subtract(const Duration(days: 90)),
      maximumDate: DateTime.now().add(const Duration(days: 90)),
      endDate: _toDate,
      startDate: _fromDate,
      backgroundColor: Colors.white,
      primaryColor: Colors.green,
      onApplyClick: (start, end) {
        setState(() {
          _fromDate = start;
          _toDate = end;
          StaticVarMethod.fromdate = _fromDate.toString().split(" ").first;
          StaticVarMethod.todate = _toDate.toString().split(" ").first;
        });
        if (_toDate.difference(_fromDate).isNegative) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("From date cannot be more than to date"),
            ),
          );
        } else {
          // StaticVarMethod.fromdate = _fromDate.toString().split(" ").first;
          // StaticVarMethod.todate = _toDate.toString().split(" ").first;
          // String? fromDateHour;
          // String? fromDateMin;
          // if (_fromDate.hour < 10) {
          //   fromDateHour = "0${_fromDate.hour}";
          // } else {
          //   fromDateHour = "${_fromDate.hour}";
          // }
          // if (_fromDate.minute < 10) {
          //   fromDateMin = "0${_fromDate.minute}";
          // } else {
          //   fromDateMin = "${_fromDate.minute}";
          // }
          // String? toDateHour;
          // String? toDateMin;
          // if (_toDate.hour < 10) {
          //   toDateHour = "0${_toDate.hour}";
          // } else {
          //   toDateHour = "${_toDate.hour}";
          // }
          // if (_toDate.minute < 10) {
          //   toDateMin = "0${_toDate.minute}";
          // } else {
          //   toDateMin = "${_toDate.minute}";
          // }
          // StaticVarMethod.fromtime = "$fromDateHour:$fromDateMin";
          // StaticVarMethod.totime = "$toDateHour:$toDateMin";
          setState(() {});
          handleClick();
        }
      },
      onCancelClick: () {},
    );
  }
}

class FuelFillings {
  String? date;
  String? lat;
  String? lng;
  String? diff;

  FuelFillings({
    this.date,
    this.lat,
    this.lng,
    this.diff,
  });
}

class ReportDataItem {
  String? from;
  String? to;
  String? startFuel;
  String? endFuel;
  String? fuelConsumed;
  String? currentFuel;
  String? fuelRefills;
  String? fuelThefts;
  String? distanceTravelled;
  String? moveDuration;
  String? mileage;

  ReportDataItem({
    this.from,
    this.to,
    this.startFuel,
    this.endFuel,
    this.fuelConsumed,
    this.currentFuel,
    this.fuelRefills,
    this.fuelThefts,
    this.distanceTravelled,
    this.moveDuration,
    this.mileage,
  });
}
