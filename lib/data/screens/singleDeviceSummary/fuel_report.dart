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

class FuelReport extends StatefulWidget {
  final String currentDeviceId;
  // List<Items>? fuelRefills;
  // List<Items>? fuelLevel;
  // List<Items>? fuelDrains;
  bool firstLoadingDone = false;

  FuelReport({
    Key? key,
    required this.currentDeviceId,
  }) : super(key: key);

  @override
  State<FuelReport> createState() => _FuelReportState();
}

class _FuelReportState extends State<FuelReport> {
  List<DeviceItems> devices = [];
  String? currentDevice;
  int? currentDeviceId;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  bool disable = false;
  bool searchButtonClicked = false;
  bool showCustomDatePicker = false;
  bool isTodaySelected = true;
  bool isLoading = true;

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

    await getFuelRefills();
    setState(() {});
  }

  handleClick() async {
    log("handle click");
    var startDate = StaticVarMethod.fromdate;
    var endDate = StaticVarMethod.todate;
    var startTime = '00:00'; //StaticVarMethod.fromtime;
    var endTime = '23:59'; //StaticVarMethod.totime;
    StaticVarMethod.fromtime = startTime;
    StaticVarMethod.totime = endTime;

    int totalDays =
        DateTime.parse(endDate).difference(DateTime.parse(startDate)).inDays +
            1;

    log("total days $totalDays");
    log("start date $startDate");
    log("end date $endDate");

    for (int i = 0; i <= totalDays; i++) {
      //Each day not different day only time will be different
      DateTime fromDate = DateTime.parse(startDate).add(Duration(days: i));
      DateTime toDate = DateTime.parse(startDate).add(Duration(days: i));

      StaticVarMethod.fromdate = fromDate.toString().split(" ").first;
      StaticVarMethod.todate = toDate.toString().split(" ").first;

      await search();

      log("Report data");
      ReportDataItem data = ReportDataItem(
        currentFuel:
            //in one decimal digit
            double.parse(currentFuelLevel ?? "0").toStringAsFixed(1),
        startFuel:
            //in one decimal digit
            double.parse(startFuelLevel ?? "0").toStringAsFixed(1),
        fuelConsumed: calculateFuelConsumption() < 0
            ? "0.0"
            : calculateFuelConsumption().toStringAsFixed(1),
        fuelThefts:
            //in one decimal digit
            double.parse(totalFuelTheftsLtr ?? "0").toStringAsFixed(1),
        fuelRefills:
            //in one decimal digit
            double.parse(totalFuelRefillsLtr ?? "0").toStringAsFixed(1),
        distanceTravelled:
            //in on decimal digit
            double.parse(distanceSum ?? "0").toStringAsFixed(1),
        endFuel:
            //in one decimal digit
            double.parse(currentFuelLevel ?? "0").toStringAsFixed(1),
        from: StaticVarMethod.fromdate,
        to: StaticVarMethod.todate,
        mileage: calculateMileage(),
        moveDuration: movingDuration,
      );
      repotData.add(data);
      log("report data ${repotData.length}");

      //If last date then  loading false
      if (i == totalDays - 1) {
        isLoading = false;
        setState(() {});
      }
    }

    // await search();
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

    http.Response response = await http.post(
      Uri.parse(
          "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=11&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
      body: {
        "user_api_hash": StaticVarMethod.userAPiHash,
      },
    );
    log("fuel refill response ${response.request}");
    log("fuel refill response ${response.body}");
    fuelRefills = ReportModel.fromJson(jsonDecode(response.body)["data"]).items;

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
      }
      totalFuelRefillsLtr ??= "0";
      totalFuelRefills ??= "0";
      distanceSum ??= "0";
      fuelConsumptionFuel ??= "0";
    }
    await getFuelThefts();
  }

  getFuelThefts() async {
    fuelDrains = [];
    totalFuelTheftsLtrOld = null;
    newFuelDrains = [];

    double fuelTheftsInLtr = 0.0;
    totalFuelTheftsOld = '0';
    totalFuelTheftsLtr = '0';
    totalFuelThefts = '0';

    http.Response response = await http.post(
      Uri.parse(
          "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=12&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
      body: {
        "user_api_hash": StaticVarMethod.userAPiHash,
      },
    );
    fuelDrains = ReportModel.fromJson(jsonDecode(response.body)["data"]).items;

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

    await getCurrentFuel();
  }

  getCurrentFuel() async {
    fuelLevel = null;
    http.Response response = await http.post(
      Uri.parse(
          "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=10&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
      body: {
        "user_api_hash": StaticVarMethod.userAPiHash,
      },
    );
    fuelLevel = ReportModel.fromJson(jsonDecode(response.body)["data"]).items;

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
    if (double.parse(distanceSum ?? '0') != 0.0 &&
        calculateFuelConsumption() >= 0.0) {
      mileage = (double.parse(distanceSum!) / calculateFuelConsumption())
          .toStringAsFixed(1);

      return mileage!;
    } else {
      return mileage = "0.0";
    }
  }

  @override
  void initState() {
    super.initState();

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            newFuelSummaryCard(),
          ],
        ),
      ),
    );
  }

  newFuelSummaryCard() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
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
            ],
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        // ReportDataItems in table

        // if (repotData.isNotEmpty)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnSpacing: 10,
            columns: const [
              DataColumn(
                label: Text(
                  "Date",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  "Start Fuel",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  "Fuel Refills",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  "Fuel Thefts",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  "Fuel Consumed",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  "End Fuel",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  "Distance",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  "Mileage",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
            rows: [
              for (var item in repotData)
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        item.from ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item.startFuel ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item.fuelRefills ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item.fuelThefts ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item.fuelConsumed ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item.endFuel ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item.distanceTravelled ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        item.mileage ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListTile(
                onTap: () {
                  //Make list from ReportDataItem
                  List<List<String>> data = [
                    [
                      "Date",
                      "Start Fuel",
                      "Fuel Refills",
                      "Fuel Thefts",
                      "Fuel Consumed",
                      "End Fuel",
                      "Distance",
                      "Mileage",
                    ],
                    for (var item in repotData)
                      [
                        item.from ?? "",
                        item.startFuel ?? "",
                        item.fuelRefills ?? "",
                        item.fuelThefts ?? "",
                        item.fuelConsumed ?? "",
                        item.endFuel ?? "",
                        item.distanceTravelled ?? "",
                        item.mileage ?? "",
                      ],
                  ];

                  //generate and download pdf
                  generatePdfFile(data).then((pdfBytes) {
                    if (pdfBytes != null) {
                      downloadPdfFile(pdfBytes);
                    }
                  });
                },
                leading: Icon(
                  Icons.report_outlined,
                  color: HomeScreen.primaryDark,
                ),
                title: const Text("Download Report"),
                trailing: const Icon(Icons.download_outlined),
              ),

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
