import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/modelold/devices.dart';

import '../home/home_screen.dart';
import '../listscreen.dart';

class DailySlider extends StatefulWidget {
  const DailySlider({super.key});

  @override
  State<DailySlider> createState() => _DailySliderState();
}

class _DailySliderState extends State<DailySlider> {
  // List<TripsItems>? routes = [];
  List<DeviceItems> devices = [];
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
  final DateTime month = DateTime.now().subtract(const Duration(days: 30));
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

  getDeviceList() async {
    devices = await StaticVarMethod.devicelist;
    currentDevice = devices.first.name;
    currentDeviceId = devices.first.id;
    StaticVarMethod.deviceId = currentDeviceId.toString();
    getDaily(_todaySort, _todaySort);
    getYestrd(_yesterdaySort, _todaySort);
    getWeekly(_weekSort, _todaySort);
    getMonthly(_monthSort, _todaySort);
    setState(() {});
  }

  getCurrentDevice() {
    for (var element in devices) {
      if (element.name == currentDevice) {
        currentDeviceId = element.id;
        StaticVarMethod.deviceId = currentDeviceId.toString();
      }
    }
    setState(() {});
  }

  getDaily(String a, String b) async {
    StaticVarMethod.fromdate = a;
    StaticVarMethod.fromtime = "00:00";
    StaticVarMethod.todate = b;
    StaticVarMethod.totime = "23:59";
    todaydata = await GPSAPIS.getFuelRefills();

    todayDis = todaydata!;
    setState(() {});
  }

  getYestrd(String a, String b) async {
    StaticVarMethod.fromdate = a;
    StaticVarMethod.fromtime = "00:00";
    StaticVarMethod.todate = b;
    StaticVarMethod.totime = "00:00";
    yestrdDis = await GPSAPIS.getFuelRefills();

    yestrdDis = yestrdDis!;

    setState(() {});
  }

  getWeekly(String a, String b) async {
    StaticVarMethod.fromdate = a;
    StaticVarMethod.fromtime = "00:00";
    StaticVarMethod.todate = b;
    StaticVarMethod.totime = "00:00";
    weekDis = await GPSAPIS.getFuelRefills();
    setState(() {});
  }

  getMonthly(String a, String b) async {
    StaticVarMethod.fromdate = a;
    StaticVarMethod.fromtime = "00:00";
    StaticVarMethod.todate = b;
    StaticVarMethod.totime = "00:00";
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
            leading: const DrawerWidget(
              isHomeScreen: true,
            ),
            title: DropdownButton<String>(
              hint: const Text(
                "       Select a vehicle       ",
                style: TextStyle(color: Colors.white),
              ),
              items: devices
                  .map((e) => DropdownMenuItem<String>(
                        value: e.name.toString(),
                        child: Text(
                          e.name.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ))
                  .toList(),
              dropdownColor: HomeScreen.primaryDark,
              iconEnabledColor: Colors.white,
              value: currentDevice,
              onChanged: (Object? value) async {
                currentDevice = value.toString();
                await getCurrentDevice();
                todayDis = null;
                yestrdDis = null;
                weekDis = null;
                monthDis = null;
                getDaily(_todaySort, _todaySort);
                getYestrd(_yesterdaySort, _todaySort);
                getWeekly(_weekSort, _todaySort);
                getMonthly(_monthSort, _todaySort);
                setState(() {});
              },
            ),
            centerTitle: true,
            backgroundColor: HomeScreen.primaryDark,
          ),
          body: todayDis != null &&
                  yestrdDis != null &&
                  weekDis != null &&
                  monthDis != null
              ? Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    TabBar(
                        // isScrollable: true,
                        indicator: const BoxDecoration(
                          color: Color.fromARGB(255, 7, 97, 97),
                        ),
                        labelColor: Colors.white,
                        onTap: (_) {
                          setState(() {});
                        },
                        unselectedLabelColor:
                            const Color.fromARGB(255, 7, 97, 97),
                        tabs: const [
                          Tab(
                              child: Text('Today',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center)),
                          Tab(
                              child: Text('Yestrd.',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center)),
                          Tab(
                              child: Text('Weekly',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center)),
                          Tab(
                              child: Text('Monthly',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center)),
                        ]),
                    const SizedBox(
                      height: 50,
                    ),
                    Expanded(
                      child: TabBarView(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 60.0,
                                width: 60.0,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 7, 97, 97),
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
                            ]),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 60.0,
                                width: 60.0,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 7, 97, 97),
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
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                            ]),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 60.0,
                                width: 60.0,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 7, 97, 97),
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
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                            ]),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 60.0,
                                width: 60.0,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 7, 97, 97),
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
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                            ]),
                      ]),
                    )
                  ],
                )
              : LinearProgressIndicator(
                  backgroundColor: HomeScreen.primaryLight,
                  valueColor: AlwaysStoppedAnimation(HomeScreen.primaryDark),
                  minHeight: 6,
                )),
    );
  }
}
