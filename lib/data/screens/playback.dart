import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/model/playback_route.dart';
import 'package:myvtsproject/data/model/position_history.dart';
import 'package:myvtsproject/mapconfig/common_method.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home/home_screen.dart';

class PlaybackPage extends StatefulWidget {
  const PlaybackPage({super.key});

  @override
  State<StatefulWidget> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  MapType _currentMapType = MapType.normal;
  bool _isPlaying = false;
  var _isPlayingIcon = Icons.pause_circle_outline;
  bool _trafficEnabled = false;
  Set<Marker> _markers = <Marker>{};
  double currentZoom = 14.0;
  late StreamController<dynamic> _postsController;
  late Timer timerPlayBack;
  late List<PlayBackRoute> routeList = [];
  late bool isLoading;
  double pinPillPosition = 0;

  int _sliderValue = 0;
  int _sliderValueMax = 0;
  int playbackTime = 200;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  List<Choice> choices = [];
  SharedPreferences? prefs;

  late Choice _selectedChoice; // The app's "state".

  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });

    if (_selectedChoice.title == 'slow') {
      playbackTime = 600;
      timerPlayBack.cancel();
      playRoute();
    } else if (_selectedChoice.title == 'medium') {
      playbackTime = 400;
      timerPlayBack.cancel();
      playRoute();
    } else if (_selectedChoice.title == 'fast') {
      playbackTime = 100;
      timerPlayBack.cancel();
      playRoute();
    }
  }

  final int _selectedperiod = 0;
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
  String distanceSum = "0 KM";
  String topSpeed = "0 KM";
  String moveDuration = "0s";
  String stopDuration = "0s";
  String fuelConsumption = "0 ltr";
  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  initState() {
    initPrefs();
    _postsController = StreamController();
    getReport(
        StaticVarMethod.deviceId,
        StaticVarMethod.fromdate,
        StaticVarMethod.fromtime,
        StaticVarMethod.todate,
        StaticVarMethod.totime);
    super.initState();
  }

  Timer interval(Duration duration, func) {
    Timer function() {
      Timer timer = Timer(duration, function);
      func(timer);
      return timer;
    }

    return Timer(duration, function);
  }

  void playRoute() {
    var iconPath = prefs!.getString(StaticVarMethod.deviceName);
    iconPath ??= "assets/nepalicon/car_green.png";
    interval(Duration(milliseconds: playbackTime), (timer) async {
      Uint8List? icon;

      if (routeList.length != _sliderValue) {
        _sliderValue++;
      }
      // for (var arr in routeList[_sliderValue.toInt()].otherArr!) {
      //   if(routeList[_sliderValue.toInt()].otherArr![3].split(":").first.contains("ignition")) {
      if (routeList.isNotEmpty) {
        // if (DateTime.parse(routeList[_sliderValue.toInt()].rawTime!)
        // .isBefore(DateTime.parse(element['raw_time']))) {
        polylineCoordinates.add(LatLng(
          double.parse(routeList[_sliderValue.toInt()].latitude.toString()),
          double.parse(routeList[_sliderValue.toInt()].longitude.toString()),
        ));
        // }
        if (routeList[_sliderValue.toInt()]
                .otherArr![3]
                .contains("ignition: true") &&
            routeList[_sliderValue.toInt()].speed.toString() == "0") {
          icon = await getBytesFromAsset(iconPath!, 120,
              red: 200, green: 200, blue: 0);
          // }
        } else if (routeList[_sliderValue.toInt()].speed.toString() == "0") {
          icon = await getBytesFromAsset(iconPath!, 120,
              red: 150, green: 1, blue: 32);
        } else if (routeList[_sliderValue.toInt()]
            .time
            .toString()
            .toLowerCase()
            .contains("not")) {
          icon = await getBytesFromAsset(iconPath!, 120,
              red: 0, green: 0, blue: 150);
        } else {
          icon = await getBytesFromAsset(iconPath!, 120,
              red: 1, green: 2, blue: 32);
        }
      }

      // }

      timerPlayBack = timer;
      _markers = <Marker>{};
      if (routeList.length - 1 == _sliderValue.toInt()) {
        timerPlayBack.cancel();
      } else if (routeList.length != _sliderValue.toInt()) {
        moveCamera(routeList[_sliderValue.toInt()]);
        _markers.add(
          Marker(
            markerId:
                MarkerId(routeList[_sliderValue.toInt()].deviceId.toString()),
            position: LatLng(
              double.parse(routeList[_sliderValue.toInt()].latitude.toString()),
              double.parse(
                  routeList[_sliderValue.toInt()].longitude.toString()),
            ),
            rotation: double.parse(routeList[_sliderValue.toInt()].course!),
            icon: BitmapDescriptor.fromBytes(icon!),
          ),
        );
        if (mounted) {
          setState(() {});
        }
      } else {
        timerPlayBack.cancel();
      }
    });
  }

  void playUsingSlider(int pos) async {
    var iconPath = prefs!.getString(StaticVarMethod.deviceName);
    iconPath ??= "assets/nepalicon/car_green.png";
    Uint8List? icon;

    if (routeList.isNotEmpty) {
      if (routeList[_sliderValue.toInt()]
              .otherArr![3]
              .contains("ignition: true") &&
          routeList[_sliderValue.toInt()].speed.toString() == "0") {
        icon = await getBytesFromAsset(iconPath, 90,
            red: 200, green: 200, blue: 0);
        // }
      } else if (routeList[_sliderValue.toInt()].speed.toString() == "0") {
        icon =
            await getBytesFromAsset(iconPath, 90, red: 150, green: 1, blue: 32);
      } else if (routeList[_sliderValue.toInt()]
          .time
          .toString()
          .toLowerCase()
          .contains("not")) {
        icon =
            await getBytesFromAsset(iconPath, 90, red: 0, green: 0, blue: 150);
      } else {
        icon =
            await getBytesFromAsset(iconPath, 90, red: 1, green: 150, blue: 32);
      }
    }
    _markers = <Marker>{};
    if (routeList.length != _sliderValue.toInt()) {
      moveCamera(routeList[_sliderValue.toInt()]);
      _markers.add(
        Marker(
          markerId:
              MarkerId(routeList[_sliderValue.toInt()].deviceId.toString()),
          position: LatLng(
            double.parse(routeList[_sliderValue.toInt()].latitude.toString()),
            double.parse(routeList[_sliderValue.toInt()].longitude.toString()),
          ), // updated position
          rotation: double.parse(routeList[_sliderValue.toInt()].course!),
          icon: BitmapDescriptor.fromBytes(icon!),
        ),
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  void moveCamera(PlayBackRoute pos) async {
    CameraPosition cPosition = CameraPosition(
      target: LatLng(
        double.parse(routeList[_sliderValue.toInt()].latitude.toString()),
        double.parse(routeList[_sliderValue.toInt()].longitude.toString()),
      ),
      zoom: currentZoom,
    );

    if (isLoading) {
      _showProgress(false);
    }
    isLoading = false;
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  Future<PositionHistory?> getReport(String deviceID, String fromDate,
      String fromTime, String toDate, String toTime) async {
    final response = await http.get(Uri.parse(
        "${StaticVarMethod.baseurlall}/api/get_history?lang=en&user_api_hash=${StaticVarMethod.userAPiHash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&snap_to_road=false&device_id=$deviceID"));
    if (response.statusCode == 200) {
      var value = PositionHistory.fromJson(json.decode(response.body));

      if (value.items!.isNotEmpty) {
        value.items?.forEach((element) {
          _postsController.add(element);
          element['items'].forEach((element) {
            if (element['latitude'] != null) {
              PlayBackRoute blackRoute = PlayBackRoute();
              blackRoute.deviceId = element['device_id'].toString();
              blackRoute.longitude = element['longitude'].toString();
              blackRoute.latitude = element['latitude'].toString();
              blackRoute.speed = element['speed'];
              blackRoute.course = element['course'].toString();
              blackRoute.rawTime = element['raw_time'].toString();
              blackRoute.time = element["time"].toString();
              blackRoute.otherArr =
                  List<String>.from(element["other_arr"].map((x) => x));

              routeList.add(blackRoute);
            }
          });
          _sliderValueMax = routeList.length;
        });
        playRoute();

        if (mounted) {
          setState(() {
            topSpeed = value.topSpeed.toString();
            moveDuration = value.moveDuration.toString();
            stopDuration = value.stopDuration.toString();
            fuelConsumption = value.fuelConsumption.toString();
            distanceSum = value.distanceSum.toString();
          });
        }
        drawPolyline();
      } else {
        if (isLoading) {
          _showProgress(false);
          isLoading = false;
        }
        // _timer.cancel(),
        AlertDialogCustom().showAlertDialog(context, 'NoData', 'Failed', 'Ok');
      }
    } else {
      return null;
    }
    return null;
  }

  void drawPolyline() async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        width: 3,
        polylineId: id,
        color: Colors.green,
        points: polylineCoordinates);
    polylines[id] = polyline;
    if (mounted) {
      setState(() {});
    }
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _trafficEnabledPressed() {
    setState(() {
      _trafficEnabled = _trafficEnabled == false ? true : false;
    });
  }

  void _playPausePressed() {
    setState(() {
      _isPlaying = _isPlaying == false ? true : false;
      if (_isPlaying) {
        timerPlayBack.cancel();
      } else {
        playRoute();
      }
      _isPlayingIcon = _isPlaying == false
          ? Icons.pause_circle_outline
          : Icons.play_circle_outline;
    });
  }

  currentMapStatus(CameraPosition position) {
    currentZoom = position.zoom;
  }

  @override
  void dispose() {
    if (timerPlayBack.isActive) {
      timerPlayBack.cancel();
    }
    super.dispose();
  }

  static const CameraPosition _initialRegion = CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    choices = <Choice>[
      const Choice(title: 'slow', icon: Icons.directions_car),
      const Choice(title: 'medium', icon: Icons.directions_bike),
      const Choice(title: 'fast', icon: Icons.directions_boat),
    ];
    _selectedChoice = choices[0];
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      appBar: AppBar(
        title: Text(StaticVarMethod.deviceName,
            style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        actions: <Widget>[
          // action button
          PopupMenuButton<Choice>(
            onSelected: _select,
            icon: const Icon(Icons.timer),
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title!),
                );
              }).toList();
            },
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: _initialRegion,
            onCameraMove: currentMapStatus,
            trafficEnabled: _trafficEnabled,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              CustomProgressIndicatorWidget()
                  .showProgressDialog(context, 'Loading ..');
              isLoading = true;
            },
            markers: _markers,
            polylines: Set<Polyline>.of(polylines.values),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: _onMapTypeButtonPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.white,
                    mini: true,
                    child:
                        const Icon(Icons.map, size: 20.0, color: Colors.black),
                  ),
                  FloatingActionButton(
                    heroTag: "traffic",
                    onPressed: _trafficEnabledPressed,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.white,
                    mini: true,
                    child: const Icon(Icons.traffic,
                        size: 20.0, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          playBackControls(),
        ],
      ),
    );
  }

  Widget playBackControls() {
    String fUpdateTime = 'Loading ..';
    String speed = 'Loading ..';
    if (routeList.length > _sliderValue.toInt()) {
      fUpdateTime = formatTime(routeList[_sliderValue.toInt()].rawTime!);
      speed = convertSpeed(routeList[_sliderValue.toInt()].speed);
    }

    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  blurRadius: 20,
                  offset: Offset.zero,
                  color: Colors.grey.withOpacity(0.5))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                      child: InkWell(
                        child: Icon(_isPlayingIcon,
                            color: Colors.black, size: 40.0),
                        onTap: () {
                          _playPausePressed();
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 5.0, left: 0.0),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Slider(
                        value: _sliderValue.toDouble(),
                        onChanged: (newSliderValue) {
                          setState(() => _sliderValue = newSliderValue.toInt());
                          if (!timerPlayBack.isActive) {
                            playUsingSlider(newSliderValue.toInt());
                          }
                        },
                        min: 0,
                        max: _sliderValueMax.toDouble(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(80, 1, 80, 1),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        color: Colors.white,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                child: Image.asset(
                                  "assets/images/speedometer.png",
                                  height: 25,
                                  width: 25,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        speed,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          // fontFamily: 'digital_font'
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: Image.asset(
                                "assets/images/movingdurationicon.png",
                                height: 25,
                                width: 25,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      moveDuration,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: const [
                                      Text(
                                        'Move Time',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: Image.asset(
                                "assets/images/stopdurationicon.png",
                                height: 25,
                                width: 25,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stopDuration,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: const [
                                      Text(
                                        'Stop Time',
                                        style: TextStyle(
                                          fontSize: 10,
                                          //color: Colors.blue
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                child: Image.asset(
                                    "assets/images/icons8-clock-100.png",
                                    height: 25,
                                    width: 25)),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fUpdateTime,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        height: 1.8,
                                      )),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                child: Image.asset(
                                    "assets/images/routeicon.png",
                                    height: 25,
                                    width: 25)),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: Text(distanceSum,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          // fontFamily: 'digital_font'
                                        )),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(6, 6, 1, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: Image.asset(
                                "assets/images/speedometer1.png",
                                height: 25,
                                width: 25,
                              ),
                            ),
                            const SizedBox(
                              width: 1,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      topSpeed,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        // fontFamily: 'digital_font'
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: const [
                                      Text(
                                        'Top Speed',
                                        style: TextStyle(
                                          fontSize: 10,
                                          //color: Colors.blue
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showProgress(bool status) {
    if (status) {
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                Container(
                    margin: const EdgeInsets.only(left: 5),
                    child: const Text('Loading ...')),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.pop(context);
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

      int dayCon = current.day + 1;
      if (dayCon <= 10) {
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
      fromTime = "00:00";
      toTime = "00:00";

      StaticVarMethod.fromdate = fromDate;
      StaticVarMethod.todate = toDate;
      StaticVarMethod.fromtime = fromTime;
      StaticVarMethod.totime = toTime;
    } else if (_selectedperiod == 1) {
      String yesterday;

      int dayCon = current.day - 1;
      if (current.day <= 10) {
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
    } else if (_selectedperiod == 2) {
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

    Navigator.pop(context);

    getReport(
        StaticVarMethod.deviceId,
        StaticVarMethod.fromdate,
        StaticVarMethod.fromtime,
        StaticVarMethod.todate,
        StaticVarMethod.totime);
    /* Navigator.pushNamed(context, "/reportList",
        arguments: ReportArguments(device['id'], fromDate, fromTime,
            toDate, toTime, device["name"], 0));*/
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String? title;
  final IconData? icon;
}

class AlertDialogCustom {
  showAlertDialog(BuildContext context, String message, String heading,
      String buttonAcceptTitle) {
    // set up the buttons
    Widget okButton = TextButton(
      child: Text(buttonAcceptTitle),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(heading),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class CustomProgressIndicatorWidget {
  showProgressDialog(BuildContext context, String message) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 5), child: Text(message)),
        ],
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
