import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/history.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../../config/static.dart';

class SingleTripSummary extends StatefulWidget {
  final String currentDeviceId;
  const SingleTripSummary({
    Key? key,
    required this.currentDeviceId,
  }) : super(key: key);

  @override
  State<SingleTripSummary> createState() => _SingleTripSummaryState();
}

class _SingleTripSummaryState extends State<SingleTripSummary> {
  bool disable = false;
  GPSAPIS api = GPSAPIS();
  History? routes;
  double averageSpeed = 0;
  double dis = 0;
  bool searchButtonClicked = false;
  late String _startDate, _endDate;
  DateTime _fromDate = DateTime.now().subtract(const Duration(hours: 48));
  DateTime _toDate = DateTime.now().subtract(const Duration(hours: 24));
  String _startTime = "00:00";
  String _endTime = "23:59";

  search() async {
    routes = null;
    searchButtonClicked = true;
    getCurrentTag();
    _startDate = _fromDate.toString().split(" ").first;
    _endDate = _toDate.toString().split(" ").first;
    routes = await GPSAPIS.getTripSummary(
        deviceId: int.parse(widget.currentDeviceId),
        fromDate: _startDate,
        toDate: _endDate,
        fromTime: _startTime,
        toTime: _endTime);

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
  void initState() {
    search();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Travel Summary'),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          routes == null && searchButtonClicked
              ? LinearProgressIndicator(
                  backgroundColor: HomeScreen.primaryLight,
                  valueColor: AlwaysStoppedAnimation(HomeScreen.primaryDark),
                  minHeight: 6,
                )
              : const SizedBox(),
          const SizedBox(
            height: 20,
          ),

          //Same as above but according to this page requirement
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                    hour: int.parse(_startTime.split(":")[0]),
                                    minute:
                                        int.parse(_startTime.split(":")[1])))
                            .then((value) {
                          if (value != null) {
                            setState(() {
                              if (value.minute < 10 && value.hour < 10) {
                                _startTime = "0${value.hour}:0${value.minute}";
                              } else if (value.minute < 10) {
                                _startTime = "${value.hour}:0${value.minute}";
                              } else if (value.hour < 10) {
                                _startTime = "0${value.hour}:${value.minute}";
                              } else {
                                _startTime = "${value.hour}:${value.minute}";
                              }
                            });
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
                              _startTime,
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
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                    hour: int.parse(_endTime.split(":")[0]),
                                    minute: int.parse(_endTime.split(":")[1])))
                            .then((value) {
                          if (value != null) {
                            setState(() {
                              if (value.minute < 10 && value.hour < 10) {
                                _endTime = "0${value.hour}:0${value.minute}";
                              } else if (value.minute < 10) {
                                _endTime = "${value.hour}:0${value.minute}";
                              } else if (value.hour < 10) {
                                _endTime = "0${value.hour}:${value.minute}";
                              } else {
                                _endTime = "${value.hour}:${value.minute}";
                              }
                            });
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
                              _endTime,
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
                ]),
          ),

          //  For Start and End Date
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showDatePicker(
                              context: context,
                              initialDate: _fromDate,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 90)),
                              lastDate: DateTime.now())
                          .then((value) {
                        if (value != null) {
                          setState(() {
                            _fromDate = value;
                          });
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
                            _fromDate.toString().split(" ").first,
                            style: const TextStyle(
                              fontSize: 16,
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
                  width: 20,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showDatePicker(
                              context: context,
                              initialDate: _fromDate,
                              firstDate: _fromDate,
                              lastDate:
                                  //1 weeek from start date
                                  DateTime.parse(
                                          _fromDate.toString().split(" ").first)
                                      .add(const Duration(days: 7)))
                          .then((value) {
                        if (value != null) {
                          setState(() {
                            _toDate = value;
                          });
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
                            _toDate.toString().split(" ").first,
                            style: const TextStyle(
                              fontSize: 16,
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
          //     customDateRangePicker();
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
          //         Text(
          //             "${StaticVarMethod.fromdate}:${StaticVarMethod.fromtime} - ${StaticVarMethod.todate}:${StaticVarMethod.totime}"),
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
            height: 30,
          ),
          Center(
            child: Container(
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
          ),
          routes == null && searchButtonClicked
              ? SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Center(
                      child: CircularProgressIndicator(
                    color: HomeScreen.primaryDark,
                  )),
                )
              : SizedBox.shrink(),
          const SizedBox(
            height: 30,
          ),
          routes != null
              ? routes!.items!.isNotEmpty
                  ? tripSummaryCard(
                      tripSummaryDetails: routes!,
                    )
                  : const Center(child: Text("No data to be shown"))
              : const SizedBox(),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  tripSummaryCard({
    required History tripSummaryDetails,
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
