import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/screens/reports/report_event.dart';
import 'package:myvtsproject/mapconfig/common_method.dart';

import '../home/home_screen.dart';

class InsideReport extends StatefulWidget {
  final bool showDropDown;
  const InsideReport({
    super.key,
    this.showDropDown = true,
  });

  @override
  InsideReportState createState() => InsideReportState();
}

class InsideReportState extends State<InsideReport> {
  int _selectedperiod = 0;

  final List<String> _reportliststr = [
    "General information",
    "Drives and stops",
    "Events",
    "Travel Sheet",
  ];

  final List<String> _devicesListstr = [];
  String _selectedReport = "";

  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();

  var selectedToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var fromTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var fromTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
  @override
  void initState() {
    super.initState();
    getdeviesList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getdeviesList() async {
    _devicesListstr.clear();
    for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
      _devicesListstr.add(StaticVarMethod.devicelist.elementAt(i).name!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      backgroundColor: Colors.white,
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Text("Report"),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ), //_globalWidget.globalAppBar(),
      body: Stack(
        children: [
          selectReport(),
          playBackControls(),
        ],
      ),
    );
  }

  Widget selectReport() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 15, right: 15),
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.white,
      ),
      child: DropdownSearch(
        mode: Mode.MENU,
        showSelectedItems: true,
        items: _reportliststr,
        dropdownSearchDecoration: const InputDecoration(
          //labelText: "Location",
          hintText: "Select location",
        ),
        onChanged: (dynamic value) {
          for (int i = 0; i < _reportliststr.length; i++) {
            if (value != null) {
              if (value == "") {
                break;
              }
            }
          }
          setState(() {
            _selectedReport = value;
          });
        },
        showSearchBox: true,
        searchFieldProps: const TextFieldProps(
          cursorColor: Colors.red,
        ),
      ),
    );
  }

  Widget playBackControls() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 30),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                blurRadius: 20,
                offset: Offset.zero,
                color: Colors.grey.withOpacity(0.5))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 10, left: 15, right: 15),
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.white,
            ),
            child: DropdownSearch(
              mode: Mode.MENU,
              showSelectedItems: true,
              items: _reportliststr,
              dropdownSearchDecoration: const InputDecoration(
                //labelText: "Location",
                hintText: "Select Report",
              ),
              onChanged: (dynamic value) {
                setState(() {
                  _selectedReport = value;
                });
              },
              showSearchBox: true,
              searchFieldProps: const TextFieldProps(
                cursorColor: Colors.red,
              ),
            ),
          ),
          widget.showDropDown == true
              ? Container(
                  margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white,
                  ),
                  child: DropdownSearch(
                    mode: Mode.MENU,
                    showSelectedItems: true,
                    items: _devicesListstr,
                    dropdownSearchDecoration: const InputDecoration(
                      //labelText: "Location",
                      hintText: "Select Vehicle",
                    ),
                    onChanged: (dynamic value) {
                      for (int i = 0;
                          i < StaticVarMethod.devicelist.length;
                          i++) {
                        if (value != null) {
                          if (StaticVarMethod.devicelist
                              .elementAt(i)
                              .name!
                              .contains(value)) {
                            StaticVarMethod.deviceId = StaticVarMethod
                                .devicelist
                                .elementAt(i)
                                .id
                                .toString();
                            break;
                          }
                        }
                      }
                      setState(() {});
                    },
                    showSearchBox: true,
                    searchFieldProps: const TextFieldProps(
                      cursorColor: Colors.red,
                    ),
                  ),
                )
              : const SizedBox(),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedperiod = 1;
                            showReport();
                          });
                        },
                        style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(const Size(0, 30)),
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                            side: MaterialStateProperty.all(
                              const BorderSide(color: Colors.blue, width: 1.0),
                            )),
                        child: const Text(
                          'Today',
                          style: TextStyle(
                              color: Colors.blue,
                              //fontWeight: FontWeight.bold,
                              fontSize: 11),
                          textAlign: TextAlign.center,
                        ))),
                const SizedBox(
                  width: 3,
                ),
                Expanded(
                    child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedperiod = 2;
                            showReport();
                          });
                        },
                        style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(const Size(0, 30)),
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                            side: MaterialStateProperty.all(
                              const BorderSide(color: Colors.blue, width: 1),
                            )),
                        child: const Text(
                          'Yesterday',
                          style: TextStyle(
                              color: Colors.blue,
                              //fontWeight: FontWeight.bold,
                              fontSize: 11),
                          textAlign: TextAlign.center,
                        ))),
                const SizedBox(
                  width: 3,
                ),
                Expanded(
                    child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedperiod = 4;
                          });
                        },
                        style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(const Size(0, 30)),
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                            side: MaterialStateProperty.all(
                              const BorderSide(color: Colors.blue, width: 1.0),
                            )),
                        child: const Text(
                          'Last 7 days',
                          style: TextStyle(
                              color: Colors.blue,
                              //fontWeight: FontWeight.bold,
                              fontSize: 11),
                          textAlign: TextAlign.center,
                        ))),
              ],
            ),
          ),
          // Row(
          //   children: [
          //     Expanded(
          //         child: OutlinedButton(
          //             onPressed: () {
          //               setState(() {
          //                 _selectedperiod = 3;
          //                 showReport();
          //               });
          //             },
          //             style: ButtonStyle(
          //                 minimumSize:
          //                     MaterialStateProperty.all(const Size(0, 30)),
          //                 overlayColor:
          //                     MaterialStateProperty.all(Colors.transparent),
          //                 shape:
          //                     MaterialStateProperty.all(RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(5.0),
          //                 )),
          //                 side: MaterialStateProperty.all(
          //                   const BorderSide(color: Colors.blue, width: 1.0),
          //                 )),
          //             child: const Text(
          //               'Before 2 days',
          //               style: TextStyle(
          //                   color: Colors.blue,
          //                   //fontWeight: FontWeight.bold,
          //                   fontSize: 11),
          //               textAlign: TextAlign.center,
          //             ))),
          //     const SizedBox(
          //       width: 3,
          //     ),
          //     Expanded(
          //         child: OutlinedButton(
          //             onPressed: () {
          //               setState(() {
          //                 _selectedperiod = 4;
          //               });
          //             },
          //             style: ButtonStyle(
          //                 minimumSize:
          //                     MaterialStateProperty.all(const Size(0, 30)),
          //                 overlayColor:
          //                     MaterialStateProperty.all(Colors.transparent),
          //                 shape:
          //                     MaterialStateProperty.all(RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(5.0),
          //                 )),
          //                 side: MaterialStateProperty.all(
          //                   const BorderSide(color: Colors.blue, width: 1.0),
          //                 )),
          //             child: const Text(
          //               'Last 7 days',
          //               style: TextStyle(
          //                   color: Colors.blue,
          //                   //fontWeight: FontWeight.bold,
          //                   fontSize: 11),
          //               textAlign: TextAlign.center,
          //             ))),
          //     const SizedBox(
          //       width: 3,
          //     ),
          //     Expanded(
          //         child: OutlinedButton(
          //             onPressed: () {
          //               /* Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                     builder: (context) => mainmapscreen()),
          //               );*/
          //               //Fluttertoast.showToast(msg: 'Item has been added to Shopping Cart');
          //             },
          //             style: ButtonStyle(
          //                 minimumSize:
          //                     MaterialStateProperty.all(const Size(0, 30)),
          //                 overlayColor:
          //                     MaterialStateProperty.all(Colors.transparent),
          //                 shape:
          //                     MaterialStateProperty.all(RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(5.0),
          //                 )),
          //                 side: MaterialStateProperty.all(
          //                   const BorderSide(color: Colors.blue, width: 0.5),
          //                 )),
          //             child: const Text(
          //               'Last Week',
          //               style: TextStyle(
          //                   color: Colors.blue,
          //                   //fontWeight: FontWeight.bold,
          //                   fontSize: 11),
          //               textAlign: TextAlign.center,
          //             ))),
          //     const SizedBox(
          //       width: 3,
          //     ),
          //   ],
          // ),

          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedperiod = 5;
                        });
                      },
                      style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(0, 30)),
                          overlayColor:
                              MaterialStateProperty.all(Colors.transparent),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          )),
                          side: MaterialStateProperty.all(
                            const BorderSide(
                                color: Colors.blueGrey, width: 2.5),
                          )),
                      child: const Text(
                        'Select Custom Date & Time',
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                        textAlign: TextAlign.center,
                      ))),
              const SizedBox(
                width: 3,
              ),
            ],
          ),
          _selectedperiod == 5
              ? Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () => _selectFromDate(context, setState),
                          child: Text(formatReportDate(_selectedFromDate),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _fromTime(context);
                            });
                          },
                          child: Text(formatReportTime(selectedFromTime),
                              style: const TextStyle(
                                  backgroundColor: Colors.blue,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () => _selectToDate(context, setState),
                          child: Text(formatReportDate(_selectedToDate),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _toTime(context);
                            });
                          },
                          child: Text(formatReportTime(selectedToTime),
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                )
              : Container(),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: OutlinedButton.icon(
              onPressed: () {
                showReport();
              },
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.blue),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  )),
                  side: MaterialStateProperty.all(
                    const BorderSide(color: Colors.blue, width: 1.0),
                  )),
              icon: const Icon(
                Icons.file_copy_outlined,
                size: 24.0,
              ),
              label: const Text('View Report       '),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFromDate(
      BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedFromDate) {
      setState(() {
        _selectedFromDate = picked;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedToDate) {
      setState(() {
        _selectedToDate = picked;
      });
    }
  }

  Future<void> _fromTime(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: selectedFromTime,
    );
    if (picked != null && picked != selectedFromTime) {
      setState(() {
        selectedFromTime = picked;
        var hour = selectedFromTime.hour;
        var minute = selectedFromTime.minute;
        fromTime = "$hour:$minute:00";
      });
    }
  }

  Future<void> _toTime(BuildContext context) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: selectedToTime,
    );
    if (picked != null && picked != selectedToTime) {
      setState(() {
        selectedToTime = picked;
        var hour = selectedToTime.hour;
        var minute = selectedToTime.minute;
        toTime = "$hour:$minute:00";
        //  TimeOfDayFormat.H_colon_mm.toString();
        //var formattedDate = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  void showReport() {
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

    if (_selectedperiod == 0) {
      String today;

      int dayCon = current.day;
      if (dayCon < 10) {
        today = "0$dayCon";
      } else {
        today = dayCon.toString();
      }
      int currentTime = DateTime.now().hour;
      int lastHour = DateTime.now().subtract(const Duration(hours: 1)).hour;
      int currentMinute = DateTime.now().minute;
      int lastMinute =
          DateTime.now().subtract(const Duration(minutes: 60)).minute;
      String? lastHourStr;
      String? lastMinStr;
      if (lastHour < 10) {
        lastHourStr = "0$lastHour";
      } else {
        lastHourStr = "$lastHour";
      }
      if (lastMinute < 10) {
        lastMinStr = "0$lastMinute";
      } else {
        lastMinStr = "$lastMinute";
      }
      fromTime = "$lastHourStr:$lastMinStr";
      toTime = "$currentTime:$currentMinute";
      var date = DateTime.parse("${current.year}-"
          "$month-"
          "$today "
          "$lastHourStr:$lastMinStr");

      StaticVarMethod.fromdate = formatDateReport(date.toString());
      StaticVarMethod.todate = formatDateReport(DateTime.now().toString());
      StaticVarMethod.fromtime = fromTime;
      StaticVarMethod.totime = toTime;
    } else if (_selectedperiod == 1) {
      String today;

      int dayCon = current.day + 1;
      if (dayCon < 10) {
        today = "0$dayCon";
      } else {
        today = dayCon.toString();
      }

      var date = DateTime.parse("${current.year}-"
          "$month-"
          "$today "
          "00:00:00");
      fromTime = "00:00:00";
      toTime = "00:00:00";

      StaticVarMethod.fromdate = formatDateReport(DateTime.now().toString());
      StaticVarMethod.todate = formatDateReport(date.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (_selectedperiod == 2) {
      String yesterday;

      int dayCon = current.day - 1;
      if (current.day <= 10) {
        yesterday = "0$dayCon";
      } else {
        yesterday = dayCon.toString();
      }

      var start = DateTime.parse("${current.year}-"
          "$month-"
          "$yesterday "
          "00:00:00");

      var end = DateTime.parse("${current.year}-"
          "$month-"
          "$yesterday "
          "24:00:00");

      fromTime = "00:00:00";
      toTime = "00:00:00";
      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (_selectedperiod == 3) {
      String sevenDay, currentDayString;
      int dayCon = current.day - current.weekday;
      int currentDay = current.day;
      if (dayCon < 10) {
        sevenDay = "0${dayCon.abs()}";
      } else {
        sevenDay = dayCon.toString();
      }
      if (currentDay < 10) {
        currentDayString = "0$currentDay";
      } else {
        currentDayString = currentDay.toString();
      }

      var start = DateTime.parse("${current.year}-"
          "$month-"
          "$sevenDay "
          "00:00:00");

      var end = DateTime.parse("${current.year}-"
          "$month-"
          "$currentDayString "
          "24:00:00");

      fromTime = "00:00:00";
      toTime = "00:00:00";
      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else {
      String startMonth, endMoth;
      if (_selectedFromDate.month < 10) {
        startMonth = "0${_selectedFromDate.month}";
      } else {
        startMonth = _selectedFromDate.month.toString();
      }

      if (_selectedToDate.month < 10) {
        endMoth = "0${_selectedToDate.month}";
      } else {
        endMoth = _selectedToDate.month.toString();
      }

      String startHour, endHour;
      if (selectedFromTime.hour < 10) {
        startHour = "0${selectedFromTime.hour}";
      } else {
        startHour = selectedFromTime.hour.toString();
      }

      String startMin, endMin;
      if (selectedFromTime.minute < 10) {
        startMin = "0${selectedFromTime.minute}";
      } else {
        startMin = selectedFromTime.minute.toString();
      }

      if (selectedToTime.minute < 10) {
        endMin = "0${selectedToTime.minute}";
      } else {
        endMin = selectedToTime.minute.toString();
      }

      if (selectedToTime.hour < 10) {
        endHour = "0${selectedToTime.hour}";
      } else {
        endHour = selectedToTime.hour.toString();
      }

      String startDay, endDay;
      if (_selectedFromDate.day <= 10) {
        if (_selectedFromDate.day == 10) {
          startDay = _selectedFromDate.day.toString();
        } else {
          startDay = "0${_selectedFromDate.day}";
        }
      } else {
        startDay = _selectedFromDate.day.toString();
      }

      if (_selectedToDate.day <= 10) {
        if (_selectedToDate.day == 10) {
          endDay = _selectedToDate.day.toString();
        } else {
          endDay = "0${_selectedToDate.day}";
        }
      } else {
        endDay = _selectedToDate.day.toString();
      }

      var start = DateTime.parse("${_selectedFromDate.year}-"
          "$startMonth-"
          "$startDay "
          "$startHour:"
          "$startMin:"
          "00");

      var end = DateTime.parse("${_selectedToDate.year}-"
          "$endMoth-"
          "$endDay "
          "$endHour:"
          "$endMin:"
          "00");

      fromTime = formatTimeReport(start.toString());
      toTime = formatTimeReport(end.toString());

      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = formatTimeReport(start.toString());
      StaticVarMethod.totime = formatTimeReport(end.toString());
    }

    if (_selectedReport.contains("General information")) {
      StaticVarMethod.reportType = 16;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportEventPage()),
      );
    } else if (_selectedReport.contains("Drives and stops")) {
      StaticVarMethod.reportType = 3;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportEventPage()),
      );
    } else if (_selectedReport.contains("Events")) {
      StaticVarMethod.reportType = 8;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportEventPage()),
      );
    } else if (_selectedReport.contains("Travel Sheet")) {
      StaticVarMethod.reportType = 4;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportEventPage()),
      );
    }
  }
}
