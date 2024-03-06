import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TravelSummaryDetail {
  String? vehicleName;
  String? ownerName;
  String? runningTime;
  String? idleTime;
  String? stopTime;
  String? inactiveTime;
  double? totalDistance;
  String? startKm;
  String? endKm;
  String? startLocation;
  String? endLocation;
  double? avgSpeed;
  double? maxSpeed;
  int? alertCount;

  TravelSummaryDetail(
      {this.vehicleName,
      this.ownerName,
      this.runningTime,
      this.idleTime,
      this.stopTime,
      this.inactiveTime,
      this.totalDistance,
      this.startKm,
      this.endKm,
      this.startLocation,
      this.endLocation,
      this.avgSpeed,
      this.maxSpeed,
      this.alertCount});
}

class TravelSummaryScreen extends StatefulWidget {
  const TravelSummaryScreen({Key? key}) : super(key: key);

  @override
  State<TravelSummaryScreen> createState() => _TravelSummaryScreenState();
}

class _TravelSummaryScreenState extends State<TravelSummaryScreen> {
  late String _startDate, _endDate;
  final DateRangePickerController _controller = DateRangePickerController();
  List<TravelSummaryDetail> travelSummaries = [
    TravelSummaryDetail(
        vehicleName: "BAPRA 01025CHA",
        ownerName: "Acuman",
        totalDistance: 1.62,
        runningTime: "00:04",
        idleTime: "00:03",
        stopTime: "05:02",
        inactiveTime: "07:26",
        startKm: "0000226",
        endKm: "0000228",
        startLocation: "BiratnagarN.P.14",
        endLocation: "BiratnagarN.P.3",
        avgSpeed: 22.0,
        maxSpeed: 42.0,
        alertCount: 6),
    TravelSummaryDetail(
        vehicleName: "BAPRA03 0045",
        ownerName: "Matin Softech",
        totalDistance: 3,
        runningTime: "01:10",
        idleTime: "03:20",
        stopTime: "07:02",
        inactiveTime: "03:26",
        startKm: "0021226",
        endKm: "0021228",
        startLocation: "BiratnagarN.P.14",
        endLocation: "BiratnagarN.P.3",
        avgSpeed: 30.0,
        maxSpeed: 60.0,
        alertCount: 15)
  ];

  @override
  void initState() {
    final DateTime today = DateTime.now();
    _startDate = DateFormat("MM-dd-yyyy HH:mm").format(today).toString();
    _endDate = DateFormat("MM-dd-yyyy HH:mm")
        .format(today.add(const Duration(days: 7)))
        .toString();
    _controller.selectedRange =
        PickerDateRange(today, today.add(const Duration(days: 3)));
    super.initState();
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _startDate = DateFormat('MM-dd-yyyy HH:mm')
          .format(args.value.startDate)
          .toString();
      _endDate = DateFormat('MM-dd-yyyy HH:mm')
          .format(args.value.endDate ?? args.value.startDate)
          .toString();
    });
  }

  String _startTime = "00:00";
  String _endTime = "23:59";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerWidget(
          isHomeScreen: true,
        ),
        title: const Text("Travel Summary"),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.search)
        //   ),
        //   IconButton(
        //       onPressed: () {},
        //       icon: const Icon(Icons.filter_alt_outlined)
        //   )
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

              //in  row time selection start date and end Time
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                  hour: int.parse(_startTime.split(":")[0]),
                                  minute: int.parse(_startTime.split(":")[1])))
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

              // Container(
              //   padding: const EdgeInsets.all(10),
              //   decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(12),
              //       boxShadow: [
              //         BoxShadow(
              //             color: Colors.grey.shade300,
              //             blurRadius: 10,
              //             offset: const Offset(3, 3))
              //       ]),
              //   child: ListTile(
              //     title: Text(
              //       "$_startDate - $_endDate",
              //       style: const TextStyle(fontSize: 13),
              //     ),
              //     trailing: IconButton(
              //       onPressed: () {
              //         customDateRangePicker();
              //       },
              //       icon: Icon(
              //         Icons.calendar_month_outlined,
              //         color: HomeScreen.primaryDark,
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   height: 30,
              // ),
              ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: travelSummaries.length,
                  itemBuilder: (context, index) {
                    return travelSummaryCard(
                        travelSummaryDetails: travelSummaries, index: index);
                  }),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  travelSummaryCard({
    required List<TravelSummaryDetail> travelSummaryDetails,
    required int index,
  }) {
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 150,
                            child: Text(
                              travelSummaryDetails[index]
                                      .vehicleName
                                      ?.toUpperCase() ??
                                  "",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 75,
                            child: Text(
                              travelSummaryDetails[index].ownerName ?? "",
                              style: const TextStyle(color: Colors.black87),
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
                              travelSummaryDetails[index]
                                      .totalDistance
                                      ?.toString() ??
                                  "",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            width: 30,
                            child: Text(
                              "km",
                              style: TextStyle(color: Colors.black87),
                            ),
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
                          travelSummaries: travelSummaries,
                          index: index,
                          statusType: "Running",
                          status: travelSummaries[index].runningTime ?? "",
                          statusColor: Colors.green),
                      const SizedBox(
                        width: 6,
                      ),
                      customVehicleStatusCard(
                          travelSummaries: travelSummaries,
                          index: index,
                          statusType: "Idle",
                          status: travelSummaries[index].idleTime ?? "",
                          statusColor: Colors.amber),
                      const SizedBox(
                        width: 6,
                      ),
                      customVehicleStatusCard(
                          travelSummaries: travelSummaries,
                          index: index,
                          statusType: "Stop",
                          status: travelSummaries[index].stopTime ?? "",
                          statusColor: Colors.red),
                      const SizedBox(
                        width: 6,
                      ),
                      customVehicleStatusCard(
                          travelSummaries: travelSummaries,
                          index: index,
                          statusType: "Inactive",
                          status: travelSummaries[index].inactiveTime ?? "",
                          statusColor: Colors.blue)
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 10,
                                      color: Colors.grey.shade200,
                                      offset: const Offset(3, 3))
                                ]),
                            padding: const EdgeInsets.all(12),
                            child: Center(
                              child: Text(
                                travelSummaries[index].startKm ?? "0000000",
                                style: const TextStyle(
                                    letterSpacing: 5,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 10,
                                      color: Colors.grey.shade200,
                                      offset: const Offset(3, 3))
                                ]),
                            padding: const EdgeInsets.all(12),
                            child: Center(
                              child: Text(
                                travelSummaries[index].endKm ?? "0000000",
                                style: const TextStyle(
                                    letterSpacing: 5,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          Container(
                            height: 30,
                            width: 2,
                            decoration:
                                BoxDecoration(color: Colors.grey.shade400),
                          ),
                          Icon(
                            Icons.circle_outlined,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          Text(
                            travelSummaries[index].startLocation ?? "",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            travelSummaries[index].endLocation ?? "",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
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
                                "${travelSummaries[index].avgSpeed} km/h",
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
                                "${travelSummaries[index].maxSpeed} km/h",
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
                        width: 20,
                      ),
                      Container(
                        height: 50,
                        width: 2,
                        decoration: BoxDecoration(color: Colors.grey.shade400),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Alerts",
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          Text(
                            travelSummaries[index].alertCount.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      )
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
      {required List<TravelSummaryDetail> travelSummaries,
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

  customDateRangePicker() {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SizedBox(
            height: 280,
            width: 100,
            child: SfDateRangePicker(
              controller: _controller,
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: selectionChanged,
              allowViewNavigation: false,
            ),
          ),
        );
      },
      context: context,
    );
  }
}
