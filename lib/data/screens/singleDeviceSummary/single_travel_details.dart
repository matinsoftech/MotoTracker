import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/history.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';

import '../../../config/static.dart';

class SingleTravelDetail extends StatefulWidget {
  final int? currentDeviceId;
  const SingleTravelDetail({
    Key? key,
    required this.currentDeviceId,
  }) : super(key: key);

  @override
  State<SingleTravelDetail> createState() => _SingleTravelDetailState();
}

class _SingleTravelDetailState extends State<SingleTravelDetail> {
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

  search() async {
    routes = null;
    searchButtonClicked = true;

    _startDate = _fromDate.toString().split(" ").first;
    _endDate = _toDate.toString().split(" ").first;
    routes = await GPSAPIS.getHistoryTripList(
        deviceId: widget.currentDeviceId!,
        fromDate: _startDate,
        toDate: _endDate,
        fromTime: "00:00",
        toTime: "00:00");
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
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
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
                              return singleTravelDetailCard(
                                  singleTravelDetails: routes, index: index);
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

  singleTravelDetailCard({
    final List<TripsItems>? singleTravelDetails,
    required int index,
  }) {
    var lat = singleTravelDetails![index]
        .items![singleTravelDetails[index].items!.length - 1]
        .lat;
    var lng = singleTravelDetails[index]
        .items![singleTravelDetails[index].items!.length - 1]
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
                                color: singleTravelDetails[index]
                                        .items![singleTravelDetails[index]
                                                .items!
                                                .length -
                                            1]
                                        .otherArr!
                                        .isNotEmpty
                                    ? singleTravelDetails[index]
                                                .items![
                                                    singleTravelDetails[index]
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
                              )
                              // Text(
                              //   SingleTravelDetailDetails[index].stopTime ?? "",
                              //   style: const TextStyle(
                              //       fontSize: 13,
                              //       fontWeight: FontWeight.w500,
                              //       color: Colors.red,
                              //   ),
                              // ),
                              ),
                          const SizedBox(
                            height: 10,
                          ),
                          // const SizedBox(
                          //   width: 30,
                          //   child: Text(
                          //     "Stop",
                          //     style: const TextStyle(color: Colors.black87),
                          //   ),
                          // )
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
                      Text(DateTime.parse(singleTravelDetails[index]
                              .items![
                                  singleTravelDetails[index].items!.length - 1]
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
                                "${singleTravelDetails[index].averageSpeed ?? 0} km/h",
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
                                singleTravelDetails[index].distance.toString(),
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
      if (_toDate.difference(_fromDate).isNegative) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("From date cannot be more than to date"),
          ),
        );
      } else {
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
}
