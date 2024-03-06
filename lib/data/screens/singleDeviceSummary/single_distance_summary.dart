// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/history.dart';

import '../home/home_screen.dart';

class SingleDistanceSummary extends StatefulWidget {
  final String currentDeviceId;
  const SingleDistanceSummary({
    Key? key,
    required this.currentDeviceId,
  }) : super(key: key);

  @override
  State<SingleDistanceSummary> createState() => _SingleDistanceSummaryState();
}

class _SingleDistanceSummaryState extends State<SingleDistanceSummary> {
  List<TripsItems>? routes = [];
  int? currentDeviceId;
  String? currentDevice;
  GPSAPIS api = GPSAPIS();
  String? todaydata;
  String? todayDis;
  String? yestrdDis;
  String? weekDis;
  String? monthDis;

  final DateTime today = DateTime.now();

  final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));

  final DateTime weekday = DateTime.now().subtract(const Duration(days: 7));
  String weekdayString = DateFormat("yyyy-MM-dd")
      .format(DateTime.now().subtract(const Duration(days: 7)))
      .toString();
  final DateTime month = DateTime.now().subtract(const Duration(days: 30));
  String monthString = DateFormat("yyyy-MM-dd")
      .format(DateTime.now().subtract(const Duration(days: 30)))
      .toString();
  final String _todaySort =
      DateFormat("yyyy-MM-dd").format(DateTime.now()).toString();
  final String _yesterdaySort = DateFormat("yyyy-MM-dd")
      .format(DateTime.now().subtract(const Duration(days: 1)))
      .toString();
  final String _weekSort = DateFormat("yyyy-MM-dd")
      .format(DateTime.now().subtract(const Duration(days: 7)))
      .toString();
  final String _monthSort = DateFormat("yyyy-MM-dd")
      .format(DateTime.now().subtract(const Duration(days: 30)))
      .toString();
  bool yesterdayLoaded = false;
  bool weekLoaded = false;
  bool monthLoaded = false;

  getDeviceList() async {
    currentDevice = StaticVarMethod.deviceName;
    currentDeviceId = int.tryParse(StaticVarMethod.deviceId);
    StaticVarMethod.deviceId = currentDeviceId.toString();
    getDaily(_todaySort, _todaySort);
    // getYestrd(_yesterdaySort, _todaySort);
    // getWeekly(_weekSort, _todaySort);
    // getMonthly(_monthSort, _todaySort);
    setState(() {});
  }

  getDaily(String a, String b) async {
    print(a);
    // datetime to string

    StaticVarMethod.fromdate = a;
    StaticVarMethod.todate = b;
    StaticVarMethod.fromtime = "00:00:00";
    StaticVarMethod.totime = "23:59:00";
    todaydata = await GPSAPIS.getFuelRefills();

    todayDis = todaydata!;

    print(todaydata);
    setState(() {});
  }

  getYestrd(String a, String b) async {
    StaticVarMethod.fromdate = a;
    StaticVarMethod.fromtime = "00:00:00";
    StaticVarMethod.todate = b;
    StaticVarMethod.totime = "23:59:00";
    yestrdDis = await GPSAPIS.getFuelRefills();

    yestrdDis = yestrdDis!;

    setState(() {});
  }

  getWeekly(String a, String b) async {
    StaticVarMethod.fromdate = a;
    StaticVarMethod.fromtime = "00:00:00";
    StaticVarMethod.todate = b;
    StaticVarMethod.totime = "23:59:00";
    weekDis = await GPSAPIS.getFuelRefills();
    setState(() {});
  }

  getMonthly(String a, String b) async {
    StaticVarMethod.fromdate = a;
    StaticVarMethod.fromtime = "00:00:00";
    StaticVarMethod.todate = b;
    StaticVarMethod.totime = "23:59:00";
    monthDis = await GPSAPIS.getFuelRefills();
    setState(() {});
  }

  @override
  void initState() {
    getDeviceList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButton: customFloatingSupportButton(context),
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Distance Summary'),
          centerTitle: true,
          backgroundColor: HomeScreen.primaryDark,
        ),
        body: todayDis != null
            ? Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  TabBar(
                    // isScrollable: true,
                    indicator: const BoxDecoration(
                      color: HomeScreen.primaryDark,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color.fromARGB(255, 7, 97, 97),
                    onTap: (index) {
                      if (index == 1 && yesterdayLoaded == false) {
                        yestrdDis = null;
                        getYestrd(_yesterdaySort, _todaySort);
                        yesterdayLoaded = true;
                      }
                      if (index == 2 && weekLoaded == false) {
                        weekDis = null;
                        getWeekly(_weekSort, _todaySort);
                        weekLoaded = true;
                      }
                      if (index == 3 && monthLoaded == false) {
                        monthDis = null;
                        getMonthly(_monthSort, _todaySort);
                        monthLoaded = true;
                      }
                    },
                    tabs: const [
                      Tab(
                          child: Text('Today',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                      Tab(
                          child: Text('Yestrd.',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                      Tab(
                          child: Text('Weekly',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                      Tab(
                          child: Text('Monthly',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 60.0,
                              width: 60.0,
                              decoration: const BoxDecoration(
                                color: HomeScreen.primaryDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.directions_car,
                                    color: Colors.white, size: 30.0),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Text(currentDevice ?? ""),
                            ),
                            const SizedBox(width: 100.0),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Text(
                                "${todayDis ?? "0.0"} KM",
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        yestrdDis != null
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 60.0,
                                    width: 60.0,
                                    decoration: const BoxDecoration(
                                      color: HomeScreen.primaryDark,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.directions_car,
                                        color: Colors.white, size: 30.0),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(currentDevice ?? ""),
                                  ),
                                  const SizedBox(width: 70.0),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(
                                      "${yestrdDis ?? "0.0"} KM",
                                      style:
                                          const TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator()),
                        weekDis != null
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 60.0,
                                    width: 60.0,
                                    decoration: const BoxDecoration(
                                      color: HomeScreen.primaryDark,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.directions_car,
                                        color: Colors.white, size: 30.0),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(currentDevice ?? ""),
                                  ),
                                  const SizedBox(width: 70.0),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(
                                      "${weekDis ?? "0.0"} KM",
                                      style:
                                          const TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator()),
                        monthDis != null
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 60.0,
                                    width: 60.0,
                                    decoration: const BoxDecoration(
                                      color: HomeScreen.primaryDark,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.directions_car,
                                        color: Colors.white, size: 30.0),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(currentDevice ?? ""),
                                  ),
                                  const SizedBox(width: 70.0),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(
                                      "${monthDis ?? "0.0"} KM",
                                      style:
                                          const TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  )
                ],
              )
            : Center(
                child: CircularProgressIndicator(
                  backgroundColor: HomeScreen.primaryLight,
                  valueColor: AlwaysStoppedAnimation(HomeScreen.primaryDark),
                ),
              ),
      ),
    );
  }
}
