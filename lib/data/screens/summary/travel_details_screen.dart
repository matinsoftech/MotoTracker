import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/history.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';

class DailySummary extends StatefulWidget {
  const DailySummary({Key? key}) : super(key: key);

  @override
  State<DailySummary> createState() => _DailySummaryState();
}

class _DailySummaryState extends State<DailySummary> {
  late String _startDate, _endDate;
  List<TripsItems>? routes = [];
  List<DeviceItems> devices = [];
  String? currentDevice;
  int? currentDeviceId;
  String userName = "";
  GPSAPIS api = GPSAPIS();
  DateTime _fromDate = DateTime.now().subtract(const Duration(hours: 48));
  DateTime _toDate = DateTime.now().subtract(const Duration(hours: 24));
  bool disable = false;
  bool searchButtonClicked = false;

  int itemCount = 10;

  getUser() async {
    var prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("email") ?? "";
  }

  getDeviceList() async {
    devices = await StaticVarMethod.devicelist;
    currentDevice = devices[0].name;
    currentDeviceId = devices[0].id;
    setState(() {});
  }

  getCurrentDeviceId() {
    for (var element in devices) {
      if (element.name == currentDevice) {
        currentDeviceId = element.id;
      }
    }
  }

  search() async {
    routes = null;
    searchButtonClicked = true;
    getCurrentDeviceId();
    _startDate = _fromDate.toString().split(" ").first;
    _endDate = _toDate.toString().split(" ").first;
    routes = await GPSAPIS.getHistoryTripList(
      deviceId: currentDeviceId!,
      fromDate: StaticVarMethod.fromdate,
      toDate: StaticVarMethod.todate,
      fromTime: StaticVarMethod.fromtime,
      toTime: StaticVarMethod.totime,
    );
    routes ??= [];
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
    StaticVarMethod.fromtime = "00:00";
    StaticVarMethod.totime = "23:59";
    getDeviceList();
    getUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      appBar: AppBar(
        leading: const DrawerWidget(
          isHomeScreen: true,
        ),
        title: const Text('Travel Details'),
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
                  // fillColor: Colors.blue,
                  onPressed: disable ? null : handleClick,
                  child: const Text(
                    'Search',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
            ),
            const SizedBox(
              height: 30,
            ),
            routes != null
                ? routes!.isNotEmpty
                    ? LazyLoadScrollView(
                        onEndOfPage: loadMore,
                        scrollOffset: 100,
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: routes?.length != null
                                ? routes!.length > 10
                                    ? itemCount
                                    : routes?.length
                                : 0,
                            itemBuilder: (context, index) {
                              return dailySummaryCard(
                                  dailySummaryDetails: routes, index: index);
                            }),
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

  Future<String> getLocation(var lat, var lng) async {
    var currentLocation = await GPSAPIS.getGeocoder(lat, lng);
    return currentLocation.body;
  }

  dailySummaryCard({
    List<TripsItems>? dailySummaryDetails,
    required int index,
  }) {
    var lat = dailySummaryDetails![index]
        .items![dailySummaryDetails[index].items!.length - 1]
        .lat;
    var lng = dailySummaryDetails[index]
        .items![dailySummaryDetails[index].items!.length - 1]
        .lng;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
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
              width: 10,
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
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          userName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(
                        width: 110,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                              width: 40,
                              child: Icon(
                                Icons.vpn_key,
                                color: dailySummaryDetails[index]
                                        .items![dailySummaryDetails[index]
                                                .items!
                                                .length -
                                            1]
                                        .otherArr!
                                        .isNotEmpty
                                    ? dailySummaryDetails[index]
                                                .items![
                                                    dailySummaryDetails[index]
                                                            .items!
                                                            .length -
                                                        1]
                                                .otherArr![3]
                                                .toString()
                                                .split(" ")
                                                .last ==
                                            "false"
                                        ? Colors.red
                                        : Colors.green
                                    : Colors.grey,
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(DateTime.parse(dailySummaryDetails[index]
                              .items![
                                  dailySummaryDetails[index].items!.length - 1]
                              .rawTime)
                          .toString()),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder(
                      future: getLocation(lat, lng),
                      builder: (context, snapshot) {
                        return Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                width: 150,
                                child: Text(
                                    "${snapshot.hasData ? snapshot.data : ""}")),
                          ],
                        );
                      }),
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
                                "${dailySummaryDetails[index].averageSpeed ?? 0} km/h",
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
                              const Text(
                                "Distance",
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              Text(
                                dailySummaryDetails[index].distance.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
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
      {required List<TripsItems> dailySummaries,
      required int index,
      required String statusType,
      required String status,
      required Color statusColor}) {
    return Container(
      width: 70,
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

  loadMore() {
    setState(() {
      itemCount = itemCount + 10;
    });
  }
}
