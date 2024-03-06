import 'dart:async';
import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:myvtsproject/config/apps/ecommerce/global_style.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/model/position_history.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/mapconfig/common_method.dart';

class KmDetail extends StatefulWidget {
  const KmDetail({super.key});

  @override
  KmDetailState createState() => KmDetailState();
}

class KmDetailState extends State<KmDetail> {
  final List<Sales> _smartphoneData = [];

  final DateTime _selectedFromDate = DateTime.now();
  final DateTime _selectedToDate = DateTime.now();

  var selectedToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var fromTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var fromTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
  String distanceSum = "O KM";
  String topSpeed = "O KM";
  String moveDuration = "Os";
  String stopDuration = "Os";
  String fuelConsumption = "O ltr";

  dynamic _series = [];

  @override
  void initState() {
    super.initState();

    showReport1(0, "Today");
    showReport1(1, "yesterday");
    showReport1(2, "2 day ago");
    showReport1(3, "3 day ago");
  }

  Future<PositionHistory?> getReport1(String deviceID, String fromDate,
      String fromTime, String toDate, String toTime, String currentday) async {
    final response = await http.get(Uri.parse(
        "${StaticVarMethod.baseurlall}/api/get_history?lang=en&user_api_hash=${StaticVarMethod.userAPiHash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&snap_to_road=false&device_id=$deviceID"));
    if (response.statusCode == 200) {
      var value = PositionHistory.fromJson(json.decode(response.body));
      if (value.items!.isNotEmpty) {
        setState(() {
          topSpeed = value.topSpeed.toString();
          topSpeed = value.topSpeed.toString();
          moveDuration = value.moveDuration.toString();
          stopDuration = value.stopDuration.toString();
          fuelConsumption = value.fuelConsumption.toString();
          distanceSum = value.distanceSum.toString();

          var text =
              double.parse(distanceSum.replaceAll(RegExp("[a-zA-Z:s]"), ""));

          _smartphoneData.add(Sales(currentday, text));

          _series = [
            charts.Series(
                id: "Km detail",
                domainFn: (Sales sales, _) => sales.year,
                measureFn: (Sales sales, _) => sales.sale,
                labelAccessorFn: (Sales sales, _) => '${sales.sale} Km',
                data: _smartphoneData),
          ];
        });
      }
    } else {
      return null;
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: customFloatingSupportButton(context),
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,
          centerTitle: true,
          title:
              Text(StaticVarMethod.deviceName, style: GlobalStyle.appBarTitle),
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          //bottom: _reusableWidget.bottomAppBar(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 300,
                  child: (_series.length! > 0)
                      ? charts.BarChart(
                          _series,
                          vertical: false,
                          barGroupingType: charts.BarGroupingType.grouped,
                          behaviors: [charts.SeriesLegend()],
                          barRendererDecorator: charts.BarLabelDecorator<
                                  String>(
                              labelPosition: charts.BarLabelPosition
                                  .auto), // write text inside bar, must add labelAccessorFn at charts.Series
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ));
  }

  void showReport1(int selectedperiod, String currentday) {
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

      StaticVarMethod.fromdate = formatDateReport(DateTime.now().toString());
      StaticVarMethod.todate = formatDateReport(date.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (selectedperiod == 1) {
      String yesterday;

      int dayCon = current.day - 1;
      if (current.day < 10) {
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

      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (selectedperiod == 2) {
      String yesterday;

      int dayCon = current.day - 2;
      if (current.day < 10) {
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

      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (selectedperiod == 3) {
      String yesterday;

      int dayCon = current.day - 3;
      if (current.day < 10) {
        yesterday = "0$dayCon";
      } else {
        yesterday = dayCon.toString();
      }

      var start = DateTime(
        current.year,
        current.month,
        int.parse(yesterday),
        00,
        00,
      );

      var end = DateTime(
        current.year,
        current.month,
        int.parse(yesterday),
        23,
        59,
      );

      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (selectedperiod == 2) {
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

      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = formatTimeReport(start.toString());
      StaticVarMethod.totime = formatTimeReport(end.toString());
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
}

class Sales {
  String year;
  double sale;

  Sales(this.year, this.sale);
}
