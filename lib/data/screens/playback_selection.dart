import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/static.dart';
import '../data_sources.dart';
import 'playback.dart';
import '../../mapconfig/common_method.dart';

import 'home/home_screen.dart';

class PlayBackSelection extends StatefulWidget {
  const PlayBackSelection({super.key});

  @override
  PlayBackSelectionState createState() => PlayBackSelectionState();
}

class PlayBackSelectionState extends State<PlayBackSelection> {
  // initialize global widget
  late GoogleMapController _controller;
  bool _mapLoading = true;
  Timer? _timerDummy;
  double _currentZoom = 14;
  final LatLng _initialPosition =
      LatLng(StaticVarMethod.lat, StaticVarMethod.lng);

  final Map<MarkerId, Marker> _allMarker = {};
  final List<LatLng> _latlng = [];
  bool _isBound = false;
  final bool _doneListing = false;
  //date time hepers
  int _selectedperiod = 0;
  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now().add(const Duration(days: 1));
  String? imageFilePath;
  var selectedToTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoToTime = TimeOfDay.fromDateTime(DateTime.now());
  // 00:00 date

  var selectedFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var selectedTripInfoFromTime = TimeOfDay.fromDateTime(DateTime.now());
  var fromTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var fromTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTime = DateFormat("HH:mm:ss").format(DateTime.now());
  var toTripInfoTime = DateFormat("HH:mm:ss").format(DateTime.now());
  @override
  void initState() {
    super.initState();
    _timerDummy =
        Timer.periodic(const Duration(seconds: 20), (Timer t) => _getData());
  }

  Future<void> _getData() async {
    GPSAPIS api = GPSAPIS();
    var hash = StaticVarMethod.userAPiHash;
    StaticVarMethod.devicelist = await api.getDevicesList(hash);
    updateMarker();
    /*   setState(() {

      });*/
  }

  @override
  void dispose() {
    _timerDummy?.cancel();
    super.dispose();
  }

  Future<BitmapDescriptor> _createImageLabel(
      {String iconpath = '',
      String label = 'label',
      double fontSize = 20,
      double course = 0,
      Color color = Colors.red,
      bool showtitle = true}) async {
    return getMarkerIcon(iconpath, label, color, course, false);
  }

  void _check(CameraUpdate u, GoogleMapController c) async {
    c.moveCamera(u);
    _controller.moveCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      _check(u, c);
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  // when the Google Maps Camera is change, get the current position
  void _onGeoChanged(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(StaticVarMethod.deviceName,
            style: const TextStyle(color: Colors.black, fontSize: 15)),
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _buildGoogleMap(),
          (_mapLoading)
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.grey[100],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink(),
          playBackControls(),
        ],
      ),
    );
  }

  Widget playBackControls() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 1, bottom: 30),
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
                margin: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    // Expanded(
                    //     child: OutlinedButton(
                    //         onPressed: () {
                    //           setState(() {
                    //             _selectedperiod = 0;
                    //             showReport();
                    //           });
                    //         },
                    //         style: ButtonStyle(
                    //             minimumSize: MaterialStateProperty.all(
                    //                 const Size(0, 30)),
                    //             overlayColor: MaterialStateProperty.all(
                    //                 Colors.transparent),
                    //             shape: MaterialStateProperty.all(
                    //                 RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(5.0),
                    //             )),
                    //             side: MaterialStateProperty.all(
                    //               const BorderSide(
                    //                   color: Colors.blue, width: 1.0),
                    //             )),
                    //         child: const Text(
                    //           'Last Hours',
                    //           style: TextStyle(
                    //               color: Colors.blue,
                    //               //fontWeight: FontWeight.bold,
                    //               fontSize: 11),
                    //           textAlign: TextAlign.center,
                    //         ))),
                    // const SizedBox(
                    //   width: 3,
                    // ),
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              print("Today");
                              setState(() {
                                _selectedperiod = 1;
                                showReport();
                              });
                            },
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(
                                    const Size(0, 30)),
                                overlayColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                )),
                                side: MaterialStateProperty.all(
                                  const BorderSide(
                                      color: Colors.blue, width: 1.0),
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
                                minimumSize: MaterialStateProperty.all(
                                    const Size(0, 30)),
                                overlayColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                )),
                                side: MaterialStateProperty.all(
                                  const BorderSide(
                                      color: Colors.blue, width: 1),
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
                            ),
                          ),
                          side: MaterialStateProperty.all(
                            const BorderSide(color: Colors.blue, width: 1.0),
                          ),
                        ),
                        child: const Text(
                          'Last 7 days',
                          style: TextStyle(
                              color: Colors.blue,
                              //fontWeight: FontWeight.bold,
                              fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
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

              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (_selectedFromDate.isAfter(_selectedToDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('From date cannot be ahead of To date'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      // fromDate is ahead of toDate
                      // do something...
                    } else {
                      showReport();
                      // fromDate is not ahead of toDate
                      // do something else...
                    }

                    // Fluttertoast.showToast(msg: 'Press Outline Button', toastLength: Toast.LENGTH_SHORT);
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
                    Icons.play_arrow_outlined,
                    size: 24.0,
                  ),
                  label: const Text('View Playback History        '),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // build google maps to used inside widget
  Widget _buildGoogleMap() {
    return GoogleMap(
      mapType: MapType.normal,
      trafficEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      mapToolbarEnabled: false,
      padding: const EdgeInsets.only(bottom: 200),
      markers: Set<Marker>.of(_allMarker.values),
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: _currentZoom,
      ),
      onCameraMove: _onGeoChanged,
      onCameraIdle: () {
        if (_isBound == false && _doneListing == true) {
          _isBound = true;
          CameraUpdate u2 =
              CameraUpdate.newLatLngBounds(_boundsFromLatLngList(_latlng), 50);
          _controller.moveCamera(u2).then((void v) {
            _check(u2, _controller);
          });
        }
      },
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;

        _timerDummy = Timer(const Duration(seconds: 0), () {
          setState(() {
            _mapLoading = false;

            updateMarker();
            if (_isBound == false && _doneListing == true) {
              _isBound = true;
              CameraUpdate u2 = CameraUpdate.newLatLngBounds(
                  _boundsFromLatLngList(_latlng), 100);
              _controller.moveCamera(u2).then((void v) {
                _check(u2, _controller);
              });
            }
            _mapLoading = false;
          });
        });
      },
    );
  }

  updateMarker() {
    var devicelist = StaticVarMethod.devicelist
        .where((i) => i.deviceData!.imei!.contains(StaticVarMethod.imei))
        .single;
    MaterialColor color;
    String label;
    String iconpath = 'assets/nepalicon/car_red.png';
    if (devicelist.speed!.toInt() > 0) {
      iconpath = 'assets/nepalicon/car_green.png';
      color = Colors.green;
      label = '${devicelist.name}(${devicelist.speed!} km)';
    } else if (devicelist.online!.contains('online')) {
      iconpath = 'assets/nepalicon/car_green.png';
      color = Colors.green;
      label = devicelist.name.toString();
    } else if (devicelist.online!.contains('ack')) {
      iconpath = 'assets/nepalicon/car_red.png';
      color = Colors.yellow;
      label = devicelist.name.toString();
    } else {
      iconpath = 'assets/nepalicon/car_red.png';
      color = Colors.red;
      label = devicelist.name.toString();
    }
    double lat = devicelist.lat!.toDouble();
    double lng = devicelist.lng!.toDouble();
    double? course = 0.0;
    if (devicelist.course.toString().contains("-") ||
        devicelist.course.toString().contains("null")) {
      course = 0.0;
    } else {
      String course = devicelist.course.toString() + ".0";
    }
    //double angle =  devicelist.course as double;
    LatLng position = LatLng(lat, lng);
    _latlng.add(position);
    _createImageLabel(
            label: label, course: course, color: color, iconpath: iconpath)
        .then((BitmapDescriptor customIcon) {
      if (mounted) {
        setState(() {
          _mapLoading = false;
          _allMarker[MarkerId(devicelist.id.toString())] = Marker(
            markerId: MarkerId(devicelist.id.toString()),
            position: position,
            //rotation: 0.0,
            infoWindow: const InfoWindow(title: 'This is marker '),
            onTap: () {
              /*   Fluttertoast.showToast(
                  msg: 'Click marker ',
                  toastLength: Toast.LENGTH_SHORT);*/
            },
            anchor: const Offset(0.5, 0.5),
            icon: customIcon,
          );

          _controller
              .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17));
        });
      }
    });
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
    String fromDate;
    String toDate;
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

      var date = DateTime.parse("${current.year}-"
          "$month-"
          "$today "
          "00:00:00");
      fromDate = formatDateReport(DateTime.now().toString());
      toDate = formatDateReport(date.toString());
      DateTime now = DateTime.now();
      DateTime oneHourAgo = now.subtract(const Duration(hours: 1));
      String formattedTime = DateFormat('HH:mm').format(oneHourAgo);
      fromTime = "00:00";
      toTime = "23:59";

      StaticVarMethod.fromdate = fromDate;
      StaticVarMethod.todate = toDate;
      StaticVarMethod.fromtime = formattedTime;
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
      fromDate = formatDateReport(DateTime.now().toString());
      toDate = formatDateReport(date.toString());
      fromTime = "00:00:00";
      toTime = "00:00:00";

      StaticVarMethod.fromdate = formatDateReport(DateTime.now().toString());
      StaticVarMethod.todate = formatDateReport(date.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (_selectedperiod == 2) {
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

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
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

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
      fromTime = "00:00:00";
      toTime = "00:00:00";
      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (_selectedperiod == 4) {
      String sevenDay, currentDayString;
      int dayCon = current.day - 7;
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

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
      fromTime = "00:00:00";
      toTime = "00:00:00";
      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = "00:00";
      StaticVarMethod.totime = "00:00";
    } else if (_selectedperiod == 5) {
      // String sevenDay, currentDayString;
      // int dayCon = current.weekday + 7;
      // int currentDay = current.day;
      // if (dayCon < 10) {
      //   sevenDay = "0${dayCon.abs()}";
      // } else {
      //   sevenDay = dayCon.toString();
      // }
      // if (currentDay < 10) {
      //   currentDayString = "0$currentDay";
      // } else {
      //   currentDayString = currentDay.toString();
      // }
      //
      // var start = DateTime.parse("${current.year}-"
      //     "$month-"
      //     "$sevenDay "
      //     "00:00:00");
      //
      // var end = DateTime.parse("${current.year}-"
      //     "$month-"
      //     "$currentDayString "
      //     "24:00:00");

      fromDate = formatDateReport(_selectedFromDate.toString());
      toDate = formatDateReport(_selectedToDate.toString());
      fromTime = "${selectedFromTime.hour}:${selectedFromTime.minute}";
      toTime = "${selectedFromTime.hour}:${selectedFromTime.minute}";
      StaticVarMethod.fromdate = fromDate;
      StaticVarMethod.todate = toDate;
      StaticVarMethod.fromtime = fromTime;
      StaticVarMethod.totime = toTime;
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

      fromDate = formatDateReport(start.toString());
      toDate = formatDateReport(end.toString());
      fromTime = formatTimeReport(start.toString());
      toTime = formatTimeReport(end.toString());

      StaticVarMethod.fromdate = formatDateReport(start.toString());
      StaticVarMethod.todate = formatDateReport(end.toString());
      StaticVarMethod.fromtime = formatTimeReport(start.toString());
      StaticVarMethod.totime = formatTimeReport(end.toString());
    }

    //Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlaybackPage()),
    );
    // getReport(StaticVarMethod.deviceId,StaticVarMethod.fromdate,StaticVarMethod.fromtime,StaticVarMethod.todate,StaticVarMethod.totime);
    /* Navigator.pushNamed(context, "/reportList",
        arguments: ReportArguments(device['id'], fromDate, fromTime,
            toDate, toTime, device["name"], 0));*/
  }
}

Future<BitmapDescriptor> getMarkerIcon(String imagePath, String infoText,
    Color color, double rotateDegree, bool _showTitle) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  //size
  Size canvasSize = Size(700.0, 220.0);
  Size markerSize = Size(120.0, 120.0);
  late TextPainter textPainter;
  if (_showTitle) {
    // Add info text
    textPainter = TextPainter();
    textPainter.text = TextSpan(
      text: infoText,
      style:
          TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: color),
    );
    textPainter.layout();
  }

  final Paint infoPaint = Paint()..color = Colors.white;
  final Paint infoStrokePaint = Paint()..color = color;
  final double infoHeight = 70.0;
  final double strokeWidth = 2.0;

  //final Paint markerPaint = Paint()..color = color.withOpacity(0);
  final double shadowWidth = 30.0;

  final Paint borderPaint = Paint()
    ..color = color
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

  final double imageOffset = shadowWidth * .5;

  canvas.translate(
      canvasSize.width / 2, canvasSize.height / 2 + infoHeight / 2);

  // Add shadow circle
  // canvas.drawOval(
  //     Rect.fromLTWH(-markerSize.width / 2, -markerSize.height / 2,
  //         markerSize.width, markerSize.height),
  //     markerPaint);
  // // Add border circle
  // canvas.drawOval(
  //     Rect.fromLTWH(
  //         -markerSize.width / 2 + shadowWidth,
  //         -markerSize.height / 2 + shadowWidth,
  //         markerSize.width - 2 * shadowWidth,
  //         markerSize.height - 2 * shadowWidth),
  //     borderPaint);

  // Oval for the image
  Rect oval = Rect.fromLTWH(
      -markerSize.width / 2 + .5 * shadowWidth,
      -markerSize.height / 2 + .5 * shadowWidth,
      markerSize.width - shadowWidth,
      markerSize.height - shadowWidth);

  //save canvas before rotate
  canvas.save();

  double rotateRadian = (pi / 180.0) * rotateDegree;

  //Rotate Image
  canvas.rotate(rotateRadian);

  // Add path for oval image
  canvas.clipPath(Path()..addOval(oval));

  ui.Image image;
  // Add image
  // if(imagePath.contains("arrow-ack.png")){
  image = await getImageFromPath(imagePath);
  // image = await getImageFromPath("assets/images/direction.png");
  /* }else{
    image = await getImageFromPathUrl(imagePath);

  }*/

  paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitHeight);

  canvas.restore();
  if (_showTitle) {
    // Add info box stroke
    canvas.drawPath(
        Path()
          ..addRRect(RRect.fromLTRBR(
              -textPainter.width / 2 - infoHeight / 2,
              -canvasSize.height / 2 - infoHeight / 2 + 1,
              textPainter.width / 2 + infoHeight / 2,
              -canvasSize.height / 2 + infoHeight / 2 + 1,
              Radius.circular(35.0)))
          ..moveTo(-15, -canvasSize.height / 2 + infoHeight / 2 + 1)
          ..lineTo(0, -canvasSize.height / 2 + infoHeight / 2 + 25)
          ..lineTo(15, -canvasSize.height / 2 + infoHeight / 2 + 1),
        infoStrokePaint);

    //info info box
    canvas.drawPath(
        Path()
          ..addRRect(RRect.fromLTRBR(
              -textPainter.width / 2 - infoHeight / 2 + strokeWidth,
              -canvasSize.height / 2 - infoHeight / 2 + 1 + strokeWidth,
              textPainter.width / 2 + infoHeight / 2 - strokeWidth,
              -canvasSize.height / 2 + infoHeight / 2 + 1 - strokeWidth,
              Radius.circular(32.0)))
          ..moveTo(-15 + strokeWidth / 2,
              -canvasSize.height / 2 + infoHeight / 2 + 1 - strokeWidth)
          ..lineTo(
              0, -canvasSize.height / 2 + infoHeight / 2 + 25 - strokeWidth * 2)
          ..lineTo(15 - strokeWidth / 2,
              -canvasSize.height / 2 + infoHeight / 2 + 1 - strokeWidth),
        infoPaint);
    textPainter.paint(
        canvas,
        Offset(
            -textPainter.width / 2,
            -canvasSize.height / 2 -
                infoHeight / 2 +
                infoHeight / 2 -
                textPainter.height / 2));

    canvas.restore();
  }

  // Convert canvas to image
  final ui.Image markerAsImage = await pictureRecorder
      .endRecording()
      .toImage(canvasSize.width.toInt(), canvasSize.height.toInt());

  // Convert image to bytes
  final ByteData? byteData =
      await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List? uint8List = byteData?.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(uint8List!);
}

Future<ui.Image> getImageFromPath(String? imagePath) async {
  if (imagePath!.contains("asset") == false) {
    File imageFile = File(imagePath);
    final data = await imageFile.readAsBytes();
    var imageUint = data.buffer.asUint8List();
    // var bd = await rootBundle.load(imagePath);
    Uint8List imageBytes = Uint8List.view(imageUint.buffer);

    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  } else {
    var bd = await rootBundle.load(imagePath);
    Uint8List imageBytes = Uint8List.view(bd.buffer);
    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  }
}
