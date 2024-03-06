import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart'
    show LazyLoadScrollView;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/history.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';

class SingleDailyTravelSummary extends StatefulWidget {
  final String currentDeviceId;
  const SingleDailyTravelSummary({
    Key? key,
    required this.currentDeviceId,
  }) : super(key: key);

  @override
  State<SingleDailyTravelSummary> createState() =>
      _SingleDailyTravelSummaryState();
}

class _SingleDailyTravelSummaryState extends State<SingleDailyTravelSummary> {
  List<TripsItems>? routes;
  String userName = "";
  GPSAPIS api = GPSAPIS();
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

    routes = await GPSAPIS.getHistoryTripList(
        deviceId: int.parse(widget.currentDeviceId),
        fromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
        toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
        fromTime: "00:00",
        toTime: "23:59");
    routes ??= [];
    setState(() {});
  }

  @override
  void initState() {
    getUser();
    search();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          onPressed: ((() => Navigator.pop(context))),
        ),
        title: const Text('Daily Travel Details'),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            routes == null && searchButtonClicked
                ? LinearProgressIndicator(
                    backgroundColor: HomeScreen.linearColor,
                    valueColor: AlwaysStoppedAnimation(HomeScreen.primaryDark),
                    minHeight: 6,
                  )
                : const SizedBox(),
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
                            itemCount: routes!.isNotEmpty
                                ? routes!.length > 10
                                    ? itemCount
                                    : routes?.length
                                : 0,
                            itemBuilder: (context, index) {
                              return dailySummaryCard(
                                  dailySummaryDetails: routes, index: index);
                            }),
                      )
                    : const Center(child: Text("No data to be shown"))
                : const SizedBox(),
            // : const Text(" No data to be shown"),
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
