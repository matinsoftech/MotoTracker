import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/model/history.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class TodaySummary extends StatefulWidget {
  const TodaySummary({Key? key}) : super(key: key);

  @override
  State<TodaySummary> createState() => _TodaySummaryState();
}

class _TodaySummaryState extends State<TodaySummary> {
  List<TripsItems>? routes;
  List<DeviceItems> devices = [];
  String? currentDevice;
  int? currentDeviceId;
  String userName = "";
  GPSAPIS api = GPSAPIS();
  bool showProgress = false;

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

  search() async {
    showProgress = true;
    routes = null;
    // searchButtonClicked = true;
    getCurrentDeviceId();

    routes = await GPSAPIS.getHistoryTripList(
        deviceId: currentDeviceId!,
        fromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
        toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
        fromTime: "00:00",
        toTime: "23:59");
    routes ??= [];
    showProgress = false;
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
    getDeviceList();
    getUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: customFloatingSupportButton(context),
      appBar: AppBar(
        leading: const DrawerWidget(
          isHomeScreen: true,
        ),
        title: const Text('Daily Travel Details'),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            routes == null && showProgress
                ? LinearProgressIndicator(
                    backgroundColor: HomeScreen.linearColor,
                    valueColor: AlwaysStoppedAnimation(HomeScreen.primaryDark),
                    minHeight: 6,
                  )
                : const SizedBox(),
            const SizedBox(
              height: 30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                            showProgress = true;
                            currentDevice = value.toString();
                            getCurrentDeviceId();
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 15,
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
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: LazyLoadScrollView(
                          onEndOfPage: loadMore,
                          scrollOffset: 100,
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: routes!.isNotEmpty
                                  ? routes!.length > 10
                                      ? itemCount
                                      : routes?.length
                                  : 0,
                              itemBuilder: (context, index) {
                                return dailySummaryCard(
                                    dailySummaryDetails: routes, index: index);
                              }),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20.0, left: 20.0, right: 20.0),
                        child: Column(
                          children: [
                            Container(
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 25.0, horizontal: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 150,
                                              child: Text(
                                                userName,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 110,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: const [
                                                SizedBox(
                                                    width: 40,
                                                    child: Icon(
                                                      Icons.vpn_key,
                                                      color: Colors.grey,
                                                    )),
                                                SizedBox(
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
                                            Text(
                                                "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}"),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: const [
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                                width: 150,
                                                child:
                                                    Text("Location not found")),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: const [
                                                Text(
                                                  "Avg Speed:   ",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87),
                                                ),
                                                Text(
                                                  "0.00 km/h",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Row(
                                              children: const [
                                                Text(
                                                  "Distance:    ",
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                                Text(
                                                  "0.00 Km",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
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
                            const SizedBox(
                              height: 20,
                            ),
                            const Text('No Data Found')
                          ],
                        ),
                      )
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

  loadMore() {
    setState(() {
      itemCount = itemCount + 10;
    });
  }
}
