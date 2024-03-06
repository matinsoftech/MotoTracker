import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/model/history.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:myvtsproject/data/data_sources.dart';

class StoppageSummary extends StatefulWidget {
  const StoppageSummary({Key? key}) : super(key: key);

  @override
  State<StoppageSummary> createState() => _StoppageSummaryState();
}

class _StoppageSummaryState extends State<StoppageSummary> {
  List<DeviceItems> devices = [];
  String? currentDevice;
  double dis = 0;
  double averageSpeed = 0;
  late String _startDate, _endDate;
  int? currentDeviceId;
  GPSAPIS api = GPSAPIS();
  DateTime _fromDate = DateTime.now().subtract(const Duration(hours: 48));
  DateTime _toDate = DateTime.now().subtract(const Duration(hours: 24));
  bool disable = false;
  bool searchButtonClicked = false;

  History? routes;
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

  @override
  void initState() {
    getDeviceList();
    super.initState();
  }

  Future<void> selectionChanged(
      DateRangePickerSelectionChangedArgs args) async {
    _startDate =
        DateFormat('yyyy-MM-dd').format(args.value.startDate).toString();
    _endDate = DateFormat('yyyy-MM-dd')
        .format(args.value.endDate ?? args.value.startDate)
        .toString();
    routes = await GPSAPIS.getStoppage(
        deviceId: currentDeviceId!,
        fromDate: _startDate,
        toDate: _endDate,
        fromTime: "00:00",
        toTime: "00:00");
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
      hours = 0.0;
      minutes = double.parse(timeParts[0].split("min")[0]);
      seconds = double.parse(timeParts[1].split("s")[0]);
    }
    setState(() {});
  }

  search() async {
    routes = null;
    searchButtonClicked = true;
    getCurrentDeviceId();
    _startDate = _fromDate.toString().split(" ").first;
    _endDate = _toDate.toString().split(" ").first;
    routes = await GPSAPIS.getTripSummary(
        deviceId: currentDeviceId!,
        fromDate: _startDate,
        toDate: _endDate,
        fromTime: "00:00",
        toTime: "00:00");
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
      hours = 0.0;
      minutes = double.parse(timeParts[0].split("min")[0]);
      seconds = double.parse(timeParts[1].split("s")[0]);
    }

    double totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

    averageSpeed = dis / (totalSeconds / 3600);
    setState(() {});
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
        title: const Text('Stop Summary'),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                routes == null && searchButtonClicked
                    ? LinearProgressIndicator(
                        backgroundColor: HomeScreen.primaryLight,
                        valueColor:
                            AlwaysStoppedAnimation(HomeScreen.primaryDark),
                        minHeight: 6,
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 20,
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
                            "${StaticVarMethod.fromdate}:${StaticVarMethod.fromtime} - ${StaticVarMethod.todate}:${StaticVarMethod.totime}"),
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
                          style: TextStyle(
                            fontSize: 18,
                          ),
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
              ],
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
                    ? stopSummaryCard(
                        stopSummaryDetails: routes!,
                      )
                    : const Text("No data to be shown")
                : const SizedBox(),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  stopSummaryCard({
    required History stopSummaryDetails,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, right: 20.0, left: 20.0),
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
                              'Stoppage',
                              // stopSummaryDetails[index].vehicleName?.toUpperCase() ?? "",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
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
                              stopSummaryDetails.stopDuration ?? "",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            width: 30,
                            child: Text(
                              "Stop",
                              style: TextStyle(color: Colors.black87),
                            ),
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
                          stopSummaries: stopSummaryDetails,
                          // index: index,
                          statusType: "Running",
                          status: stopSummaryDetails.moveDuration ?? "",
                          statusColor: Colors.green),
                      const SizedBox(
                        width: 40,
                      ),
                      customVehicleStatusCard(
                          stopSummaries: stopSummaryDetails,
                          // index: index,
                          statusType: "Stop",
                          status: stopSummaryDetails.stopDuration ?? "",
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
                              Text(averageSpeed.toStringAsFixed(2) == "Infinity"? "0":
                                "${averageSpeed.toStringAsFixed(2)} km/hr",
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
                                stopSummaryDetails.topSpeed ?? "",
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
                          Row(
                            children: [
                              const SizedBox(
                                child: Text(
                                  "Distance",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                stopSummaryDetails.distanceSum ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 10),
                              )
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
    );
  }

  customVehicleStatusCard(
      {required History stopSummaries,
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

  customDateRangePicker() async {
    List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
      context: context,
      startInitialDate: _fromDate,
      startFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      startLastDate: _fromDate.add(
        const Duration(days: 3652),
      ),
      endInitialDate: _toDate,
      endFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      endLastDate: _toDate.add(
        const Duration(days: 3652),
      ),
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      selectableDayPredicate: (dateTime) {
        // Disable 25th Feb 2023
        if (dateTime == DateTime(2023, 2, 25)) {
          return false;
        } else {
          return true;
        }
      },
    );
    if (dateTimeList != null && dateTimeList.isNotEmpty) {
      _fromDate = dateTimeList.first;
      _toDate = dateTimeList.last;
      StaticVarMethod.fromdate = _fromDate.toString();
      StaticVarMethod.todate = _toDate.toString();
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
    }
  }
}
