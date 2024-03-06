import 'dart:async';
import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';
import 'package:myvtsproject/data/screens/reports/report_event.dart';
import 'package:myvtsproject/data/screens/singleDeviceSummary/fuel_report.dart';
import 'package:myvtsproject/data/screens/singleDeviceSummary/new_fuel_report.dart';
import 'package:myvtsproject/data/screens/singleDeviceSummary/single_fuel_summary.dart';
import 'package:myvtsproject/mapconfig/common_method.dart';

import '../home/home_screen.dart';

class ReportSelection extends StatefulWidget {
  final bool showDropDown;
  const ReportSelection({
    super.key,
    this.showDropDown = true,
  });

  @override
  ReportSelectionState createState() => ReportSelectionState();
}

class ReportSelectionState extends State<ReportSelection> {
  int _selectedperiod = 0;

  final List<String> _reportliststr = [
    "General information",
    "Drives and stops",
    // "Travel Sheet",
    "Fuel Report",
  ];

  final List<String> _devicesListstr = [];
  String _selectedReport = "";

  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();

  var selectedToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var fromTime = DateFormat("HH:mm").format(DateTime.now());
  var fromTripInfoTime = DateFormat("HH:mm").format(DateTime.now());
  var toTime = DateFormat("HH:mm").format(DateTime.now());
  var toTripInfoTime = DateFormat("HH:mm").format(DateTime.now());
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
        // leading: widget.showDropDown
        //     ? const DrawerWidget(
        //         isHomeScreen: true,
        //       )
        //     : null,
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
            color: Colors.grey.withOpacity(0.5),
          )
        ],
      ),
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
          // Container(
          //   margin: const EdgeInsets.only(top: 20),
          //   child: Row(
          //     children: [
          //       Expanded(
          //           child: OutlinedButton(
          //               onPressed: () {
          //                 setState(() {
          //                   _selectedperiod = 1;
          //                   showReport();
          //                 });
          //               },
          //               style: ButtonStyle(
          //                   minimumSize:
          //                       MaterialStateProperty.all(const Size(0, 30)),
          //                   overlayColor:
          //                       MaterialStateProperty.all(Colors.transparent),
          //                   shape: MaterialStateProperty.all(
          //                       RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(5.0),
          //                   )),
          //                   side: MaterialStateProperty.all(
          //                     const BorderSide(color: Colors.blue, width: 1.0),
          //                   )),
          //               child: const Text(
          //                 'Today',
          //                 style: TextStyle(
          //                     color: Colors.blue,
          //                     //fontWeight: FontWeight.bold,
          //                     fontSize: 11),
          //                 textAlign: TextAlign.center,
          //               ))),
          //       const SizedBox(
          //         width: 3,
          //       ),
          //       Expanded(
          //           child: OutlinedButton(
          //               onPressed: () {
          //                 setState(() {
          //                   _selectedperiod = 2;
          //                   showReport();
          //                 });
          //               },
          //               style: ButtonStyle(
          //                   minimumSize:
          //                       MaterialStateProperty.all(const Size(0, 30)),
          //                   overlayColor:
          //                       MaterialStateProperty.all(Colors.transparent),
          //                   shape: MaterialStateProperty.all(
          //                       RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(5.0),
          //                   )),
          //                   side: MaterialStateProperty.all(
          //                     const BorderSide(color: Colors.blue, width: 1),
          //                   )),
          //               child: const Text(
          //                 'Yesterday',
          //                 style: TextStyle(
          //                     color: Colors.blue,
          //                     //fontWeight: FontWeight.bold,
          //                     fontSize: 11),
          //                 textAlign: TextAlign.center,
          //               ))),
          //       const SizedBox(
          //         width: 3,
          //       ),
          //       Expanded(
          //         child: OutlinedButton(
          //           onPressed: () {
          //             setState(
          //               () {
          //                 _selectedperiod = 4;
          //                 showReport();
          //               },
          //             );
          //           },
          //           style: ButtonStyle(
          //             minimumSize: MaterialStateProperty.all(const Size(0, 30)),
          //             overlayColor:
          //                 MaterialStateProperty.all(Colors.transparent),
          //             shape: MaterialStateProperty.all(RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(5.0),
          //             )),
          //             side: MaterialStateProperty.all(
          //               const BorderSide(color: Colors.blue, width: 1.0),
          //             ),
          //           ),
          //           child: const Text(
          //             'Last 7 days',
          //             style: TextStyle(
          //                 color: Colors.blue,
          //                 //fontWeight: FontWeight.bold,
          //                 fontSize: 11),
          //             textAlign: TextAlign.center,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          const SizedBox(
            height: 20,
          ),

          //In Row Time Select Start and End
          Row(
            children: [
              Expanded(
                  child: InkWell(
                onTap: () {
                  //Set time
                  _fromTime(context);
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
                        formatReportTime(selectedFromTime),
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
              )),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  child: InkWell(
                onTap: () {
                  //Set time
                  _toTime(context);
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
                        formatReportTime(selectedToTime),
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
              )),
            ],
          ),

          SizedBox(
            height: 20,
          ),

          //For Date Select Start and End

          Row(
            children: [
              Expanded(
                  child: InkWell(
                onTap: () {
                  //Set time
                  _selectFromDate(context, setState);
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
                        formatReportDate(_selectedFromDate),
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
              )),
              SizedBox(
                width: 20,
              ),
              Expanded(
                  child: InkWell(
                onTap: () {
                  //Set time
                  _selectToDate(context, setState);
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
                        formatReportDate(_selectedToDate),
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
              )),
            ],
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

          // Row(
          //   children: [
          //     Expanded(
          //       child: OutlinedButton(
          //         onPressed: () {
          //           setState(
          //             () {
          //               _selectedperiod = 5;
          //             },
          //           );
          //         },
          //         style: ButtonStyle(
          //           minimumSize: MaterialStateProperty.all(const Size(0, 30)),
          //           overlayColor: MaterialStateProperty.all(Colors.transparent),
          //           shape: MaterialStateProperty.all(
          //             RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(5.0),
          //             ),
          //           ),
          //           side: MaterialStateProperty.all(
          //             const BorderSide(color: Colors.blueGrey, width: 2.5),
          //           ),
          //         ),
          //         child: const Text(
          //           'Select Custom Date & Time',
          //           style: TextStyle(
          //               color: Colors.blueGrey,
          //               fontWeight: FontWeight.bold,
          //               fontSize: 11),
          //           textAlign: TextAlign.center,
          //         ),
          //       ),
          //     ),
          //     const SizedBox(
          //       width: 3,
          //     ),
          //   ],
          // ),
          // _selectedperiod == 5
          //     ? Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: <Widget>[
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.start,
          //             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: <Widget>[
          //               const Text(
          //                 "From Date :",
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 14,
          //                 ),
          //               ),
          //               const SizedBox(
          //                 width: 10,
          //               ),
          //               ElevatedButton(
          //                 //color: CustomColor.primaryColor,
          //                 onPressed: () => _selectFromDate(context, setState),
          //                 child: Text(formatReportDate(_selectedFromDate),
          //                     style: const TextStyle(color: Colors.white)),
          //               ),
          //               const SizedBox(
          //                 width: 12,
          //               ),
          //               const Text(
          //                 " From Time :",
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 14,
          //                 ),
          //               ),
          //               const SizedBox(
          //                 width: 10,
          //               ),
          //               ElevatedButton(
          //                 onPressed: () {
          //                   setState(() {
          //                     _fromTime(context);
          //                   });
          //                 },
          //                 child: Text(formatReportTime(selectedFromTime),
          //                     style: const TextStyle(
          //                         backgroundColor: Colors.blue,
          //                         color: Colors.white)),
          //               ),
          //             ],
          //           ),
          //           Row(
          //             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: <Widget>[
          //               const SizedBox(
          //                 width: 18,
          //               ),
          //               const Text(
          //                 "To Date :",
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 14,
          //                 ),
          //               ),
          //               const SizedBox(
          //                 width: 11,
          //               ),
          //               ElevatedButton(
          //                 onPressed: () => _selectToDate(context, setState),
          //                 child: Text(formatReportDate(_selectedToDate),
          //                     style: const TextStyle(color: Colors.white)),
          //               ),
          //               const SizedBox(
          //                 width: 26,
          //               ),
          //               const Text(
          //                 " To Time :",
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 15,
          //                 ),
          //               ),
          //               const SizedBox(
          //                 width: 10,
          //               ),
          //               ElevatedButton(
          //                 onPressed: () {
          //                   setState(() {
          //                     _toTime(context);
          //                   });
          //                 },
          //                 child: Text(formatReportTime(selectedToTime),
          //                     style: const TextStyle(color: Colors.white)),
          //               ),
          //             ],
          //           )
          //         ],
          //       )
          //     : Container(),

          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              showReport();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: HomeScreen.primaryDark, width: 1),
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
                    "Show Report",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: HomeScreen.primaryDark,
                  )
                ],
              ),
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
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now());
    if (picked != null && picked != _selectedFromDate) {
      setState(() {
        _selectedFromDate = picked;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedFromDate,
        firstDate: _selectedFromDate,
        lastDate: _selectedFromDate.add(Duration(days: 7)

            // DateTime.now().add(Duration(days: countDaysFromStart)),
            ));
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
    StaticVarMethod.fromdate =
        DateFormat("yyyy-MM-dd").format(_selectedFromDate);
    StaticVarMethod.todate = DateFormat("yyyy-MM-dd").format(_selectedToDate);
    StaticVarMethod.fromtime = fromTime;
    StaticVarMethod.totime = toTime;
    log("fromdate: ${StaticVarMethod.fromdate}");
    log("todate: ${StaticVarMethod.todate}");
    log("fromtime: ${StaticVarMethod.fromtime}");
    log("totime: ${StaticVarMethod.totime}");

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
    } else if (_selectedReport.contains("Travel Sheet")) {
      StaticVarMethod.reportType = 4;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportEventPage()),
      );
    } else if (_selectedReport.contains("Fuel Report")) {
      StaticVarMethod.reportType = 5;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewFuelReport()),
      );
    }
  }
}
