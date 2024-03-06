import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/history.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../../mapconfig/common_method.dart';

class TripSummaryScreen extends StatefulWidget {
  const TripSummaryScreen({Key? key}) : super(key: key);

  @override
  State<TripSummaryScreen> createState() => _TripSummaryScreenState();
}

class _TripSummaryScreenState extends State<TripSummaryScreen> {
  List<DeviceItems> devices = [];
  String? currentDevice;
  bool disable = false;

  GPSAPIS api = GPSAPIS();

  double dis = 0;
  double averageSpeed = 0;
  String apiHash =
      "\$2y\$10\$yUmXjzCeKUZ1fb8SHRZJTe7AWBmVhDAMrSmoi6DVxkicvS3rtmW6G";
  late String _startDate, _endDate;
  DateTime _fromDate = DateTime.now().subtract(const Duration(hours: 48));
  DateTime _toDate = DateTime.now().subtract(const Duration(hours: 24));
  TimePickerSpinnerController fromTimeController =
      TimePickerSpinnerController();
  TimePickerSpinnerController toTimeController = TimePickerSpinnerController();

  History? routes;
  List<DeviceItems> deviceList = [];
  int? currentDeviceId;

  bool searchButtonClicked = false;

  String formatTime(String input) {
    List<String> parts = input.split(' ');

    String formatted = "";

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].contains('h')) {
        formatted += "${parts[i]} ";
        continue;
      }

      if (parts[i].contains('mins')) {
        formatted += "${parts[i].replaceAll('mins', '')} mins";
        continue;
      }
    }

    return formatted.trim();
  }

  getDeviceList() async {
    devices = await StaticVarMethod.devicelist;
    currentDevice = devices.first.name;
    currentDeviceId = devices.first.id;
    setState(() {});
  }

  getCurrentDeviceId() {
    for (var element in devices) {
      if (element.name == currentDevice) {
        currentDeviceId = element.id;
      }
    }
  }

  List months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec'
  ];

  List days = [
    'sun',
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
  ];
  var currentDate = DateTime.now();

  search() async {
    routes = null;
    searchButtonClicked = true;
    getCurrentTag();
    _startDate = _fromDate.toString().split(" ").first;
    _endDate = _toDate.toString().split(" ").first;
    routes = await GPSAPIS.getTripSummary(
      deviceId: currentDeviceId!,
      fromDate: StaticVarMethod.fromdate,
      toDate: StaticVarMethod.todate,
      fromTime: StaticVarMethod.fromtime,
      toTime: StaticVarMethod.totime,
    );

    // try {
    dis = double.parse(routes!.distanceSum?.split(" ").first ?? "0.0");
    List<String> timeParts = routes!.moveDuration!.split(" ");
    double hours = 0.0;
    double minutes = 0.0;
    double seconds = 0.0;

    try {
      hours = double.parse(timeParts[0].split("h")[0]);
      minutes = double.parse(timeParts[1].split("min")[0]);
      seconds = double.parse(timeParts[2].split("s")[0]);
    } catch (e) {
      try {
        hours = 0.0;
        minutes = double.parse(timeParts[0].split("min")[0]);
        seconds = double.parse(timeParts[1].split("s")[0]);
      } catch (e) {
        try {
          hours = 0.0;
          minutes = 0.0;
          seconds = double.parse(timeParts[1].split("s")[0]);
        } catch (e) {
          hours = 0.0;
          minutes = 0.0;
          seconds = 0.0;
        }
      }
    }

    double totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

    averageSpeed = dis / (totalSeconds / 3600);

    setState(() {});
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  @override
  void initState() {
    StaticVarMethod.fromtime = "00:00";
    StaticVarMethod.totime = "23:59";
    getDeviceList();
    fromTimeController.showMenu();
    toTimeController.showMenu();
    super.initState();
  }

  void handleClick() async {
    setState(() {
      searchButtonClicked = true;
      disable = true;
    });
    search();

    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      disable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      appBar: AppBar(
        leading: const DrawerWidget(
          isHomeScreen: true,
        ),
        title: const Text('Travel Summary'),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            routes == null && searchButtonClicked
                ? LinearProgressIndicator(
                    backgroundColor: HomeScreen.linearColor,
                    valueColor: AlwaysStoppedAnimation(HomeScreen.primaryDark),
                    minHeight: 6,
                  )
                : const SizedBox(),
            const SizedBox(
              height: 20,
            ),
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
                      onTap: () {
                        StaticVarMethod.fromdate =
                            formatDateReport(DateTime.now().toString());
                        StaticVarMethod.todate =
                            formatDateReport(DateTime.now().toString());
                        StaticVarMethod.fromtime = "00:00";
                        StaticVarMethod.totime =
                            "${DateTime.now().hour}:${DateTime.now().minute}";
                        setState(() {});
                        handleClick();
                      }),
                  _buildCustomDateWidget(
                      label: "Yesterday",
                      onTap: () {
                        StaticVarMethod.fromdate = formatDateReport(
                            DateTime.now()
                                .subtract(const Duration(hours: 24))
                                .toString());
                        StaticVarMethod.todate = formatDateReport(DateTime.now()
                            .subtract(const Duration(hours: 24))
                            .toString());

                        StaticVarMethod.fromtime = "00:00";
                        StaticVarMethod.totime = "23:59";

                        setState(() {});
                        handleClick();
                      }),
                  _buildCustomDateWidget(
                      label: "This Week",
                      onTap: () {
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
                      }),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                customDateRangePicker();
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
                        "${StaticVarMethod.fromdate}:${' ' + StaticVarMethod.fromtime} - ${StaticVarMethod.todate}:${' ' + StaticVarMethod.totime}"),
                    const SizedBox(
                      width: 20,
                    ),
                    Icon(
                      Icons.calendar_month_outlined,
                      color: HomeScreen.primaryDark,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Choose the Vehicle: ',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Center(
                    child: DropdownButton<String>(
                      hint: const Text("       Select a vehicle       "),
                      // focusColor: Color(Colors.black),
                      items: devices
                          .map((e) => DropdownMenuItem<String>(
                                value: e.name.toString(),
                                child: Text(
                                  e.name.toString(),
                                  style: TextStyle(
                                    color: HomeScreen.primaryDark,
                                  ),
                                ),
                              ))
                          .toList(),
                      focusColor: HomeScreen.primaryDark,
                      iconDisabledColor: HomeScreen.primaryDark,
                      dropdownColor: Colors.white,
                      iconEnabledColor: HomeScreen.primaryDark,
                      value: currentDevice,
                      onChanged: (Object? value) async {
                        currentDevice = value.toString();
                        getCurrentDeviceId();
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 150,
              decoration: BoxDecoration(
                color: HomeScreen.primaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: disable ? null : handleClick,
                child: const Text(
                  'Search',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            routes != null
                ? routes!.items!.isNotEmpty
                    ? tripSummaryCard(
                        tripSummaryDetails: routes!,
                      )
                    : const Text("No data to be shown")
                : const SizedBox(),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  tripSummaryCard({
    required History tripSummaryDetails,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
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
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 1,
              decoration: const BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  )),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(
                            width: 130,
                            child: Text(
                              'Travel Summary',
                              // TripSummaryDetails[index].vehicleName?.toUpperCase() ?? "",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 75,
                            child: Text(
                              "Mero gadi",
                              style: TextStyle(color: Colors.black87),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        width: 110,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                              width: 40,
                              child: Text(
                                tripSummaryDetails.distanceSum ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            width: 30,
                            // child: Text(
                            //   "Stop",
                            //   style: const TextStyle(color: Colors.black87),
                            // ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      customVehicleStatusCard(
                          tripSummaries: tripSummaryDetails,
                          // index: index,
                          statusType: "Running",
                          status: tripSummaryDetails.moveDuration ?? "",
                          statusColor: Colors.green),
                      const SizedBox(
                        width: 40,
                      ),
                      customVehicleStatusCard(
                          tripSummaries: tripSummaryDetails,
                          // index: index,
                          statusType: "Stop",
                          status: tripSummaryDetails.stopDuration ?? "",
                          statusColor: Colors.red),
                      const SizedBox(
                        width: 6,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 70,
                                child: Text(
                                  "Avg Speed",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              Text(
                                averageSpeed.toStringAsFixed(2) == "Infinity"
                                    ? "0"
                                    : " ${averageSpeed.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 70,
                                child: Text(
                                  "Max Speed",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              Text(
                                tripSummaryDetails.topSpeed ?? "",
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        height: 50,
                        width: 2,
                        decoration: BoxDecoration(color: Colors.grey.shade400),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: const [],
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
    );
  }

  customVehicleStatusCard(
      {required History tripSummaries,
      // required int index,
      required String statusType,
      required String status,
      required Color statusColor}) {
    return Container(
      width: 115,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              blurRadius: 10,
              color: Colors.grey.shade200,
              offset: const Offset(3, 3)),
        ],
        color: Colors.white,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 10,
              decoration: const BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    statusType,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          ],
        ),
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
    List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
      context: context,
      startInitialDate: DateTime(_fromDate.year, _fromDate.month, _fromDate.day,
          _fromDate.hour, _fromDate.minute, _fromDate.second),
      startFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      startLastDate: _fromDate.add(
        const Duration(days: 3652),
      ),
      endInitialDate: DateTime(_toDate.year, _toDate.month, _toDate.day,
          _toDate.hour, _toDate.minute, _toDate.second),
      endFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      endLastDate: _toDate.add(
        const Duration(days: 3652),
      ),
      is24HourMode: true,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      barrierDismissible: true,
      type: OmniDateTimePickerType.dateAndTime,
    );
    if (dateTimeList != null && dateTimeList.isNotEmpty) {
      _fromDate = dateTimeList.first;
      _toDate = dateTimeList.last;
      StaticVarMethod.fromdate = _fromDate.toString().split(" ").first;
      StaticVarMethod.todate = _toDate.toString().split(" ").first;
      String? fromDateHour;
      String? fromDateMin;
      if (_fromDate.hour < 10) {
        fromDateHour = "0${_fromDate.hour}";
      } else {
        fromDateHour = "${_fromDate.hour}";
      }
      if (_fromDate.minute < 10) {
        fromDateMin = "0${_fromDate.minute}";
      } else {
        fromDateMin = "${_fromDate.minute}";
      }
      String? toDateHour;
      String? toDateMin;
      if (_toDate.hour < 10) {
        toDateHour = "0${_toDate.hour}";
      } else {
        toDateHour = "${_toDate.hour}";
      }
      if (_toDate.minute < 10) {
        toDateMin = "0${_toDate.minute}";
      } else {
        toDateMin = "${_toDate.minute}";
      }
      StaticVarMethod.fromtime = "$fromDateHour:$fromDateMin";
      StaticVarMethod.totime = "$toDateHour:$toDateMin";
      setState(() {});
      handleClick();
    }
  }
}
