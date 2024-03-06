import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:myvtsproject/config/static.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/consts.dart';
import '../data_sources.dart';

import 'home/home_screen.dart';
import 'options_screen/all_options.dart';

class LiveTrack extends StatefulWidget {
  const LiveTrack({super.key});

  @override
  LiveTrackState createState() => LiveTrackState();
}

class LiveTrackState extends State<LiveTrack> {
  late GoogleMapController _controller;
  bool _mapLoading = true;
  bool _statusbarLoading = true;

  Timer? _timerDummy;

  double _currentZoom = 15;

  final LatLng _initialPosition =
      LatLng(StaticVarMethod.lat, StaticVarMethod.lng);

  final Map<MarkerId, Marker> _allMarker = {};
  final List<LatLng> _latlng = [];
  bool _isBound = false;
  final bool _doneListing = false;
  MapType _currentMapType = MapType.normal;
  bool _trafficEnabled = false;
  var _trafficButtonColor = Colors.grey[700];
  Location currentLocation = Location();
  LocationData? location;
  String? imageFilePath;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  @override
  void initState() {
    super.initState();
    _timerDummy =
        Timer.periodic(const Duration(seconds: 2), (Timer t) => _getData());
  }

  Future<void> _getData() async {
    StaticVarMethod.devicelist = StaticVarMethod.devicelist;
    updateMarker();
  }

  @override
  void dispose() {
    _timerDummy?.cancel();

    //dispose timer

    super.dispose();
  }

  Future<BitmapDescriptor> _createImageLabel(
      {String label = 'label',
      double course = 0,
      Color color = Colors.red,
      String? iconPath}) async {
    var prefs = await SharedPreferences.getInstance();
    imageFilePath = prefs.getString(StaticVarMethod.deviceName);
    if (imageFilePath != null) {
      return getMarkerIcon(imageFilePath!, label, color, course, false);
    } else {
      return getMarkerIcon(iconPath!, label, color, course, false);
    }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(StaticVarMethod.deviceName,
            style: const TextStyle(color: Colors.black, fontSize: 15)),
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
      ), //_globalWidget.globalAppBar(),
      body: Stack(
        children: [
          _buildGoogleMap(),
          Positioned(
            bottom: 340,
            left: 16,
            child: GestureDetector(
              onTap: () {
                _onMapTypeButtonPressed();
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.map,
                  color: Colors.grey[700],
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 300,
            left: 16,
            child: GestureDetector(
              onTap: () {
                _trafficEnabledPressed();
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.traffic_outlined,
                  color: _trafficButtonColor,
                  size: 25,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 260,
            left: 16,
            child: GestureDetector(
              onTap: () async {
                var currentZoomLevel = await _controller.getZoomLevel();

                currentZoomLevel = currentZoomLevel + 2;
                _controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _initialPosition,
                      zoom: currentZoomLevel,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.zoom_in,
                  color: Colors.grey[700],
                  size: 30,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 220,
            left: 16,
            child: GestureDetector(
              onTap: () async {
                var currentZoomLevel = await _controller.getZoomLevel();
                currentZoomLevel = currentZoomLevel - 2;
                if (currentZoomLevel < 0) currentZoomLevel = 0;
                _controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _initialPosition,
                      zoom: currentZoomLevel,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.zoom_out,
                  color: Colors.grey[700],
                  size: 30,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 260,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                getLocation();
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 220,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                _recenterall();
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          ),
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
          (_statusbarLoading) ? _showStatusPopup() : Container()
        ],
      ),
    );
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
      _trafficButtonColor =
          _trafficEnabled == false ? Colors.grey[700] : Colors.blue;
    });
  }

  void _recenterall() {
    CameraUpdate u2 =
        CameraUpdate.newLatLngBounds(_boundsFromLatLngList(_latlng), 50);
    _controller.moveCamera(u2).then((void v) {
      _check(u2, _controller);
    });
  }

  void getLocation() async {
    location = await currentLocation.getLocation();

    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(location?.latitude ?? 0.0, location?.longitude ?? 0.0),
      zoom: 12.0,
    )));
  }

  // build google maps to used inside widget
  Widget _buildGoogleMap() {
    return GoogleMap(
      mapType: _currentMapType,
      trafficEnabled: _trafficEnabled,
      compassEnabled: false,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      mapToolbarEnabled: false,
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
      polylines: Set<Polyline>.of(polylines.values),
    );
  }

  late double lati;
  late double lngi;
  String fUpdateTime = 'Not Found';
  String fspeed = 'Not Found';
  String ftotalDistance = 'Not Found';
  String fstopDuration = 'Not Found';

  void updateMarker() {
    var devicelist = StaticVarMethod.devicelist
        .where((i) => i.deviceData!.imei!.contains(StaticVarMethod.imei))
        .single;

    MaterialColor color;
    String label;

    // print lat and log
    print('lat: ${devicelist.lat} lng: ${devicelist.lng}');
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
      color = Colors.orange;
      label = devicelist.name.toString();
    } else {
      iconpath = 'assets/nepalicon/car_red.png';
      color = Colors.red;
      label = devicelist.name.toString();
    }
    lati = devicelist.lat!.toDouble();
    lngi = devicelist.lng!.toDouble();
    double? angle = 0.0;
    if (devicelist.course.toString().contains("-") ||
        devicelist.course.toString().contains("null")) {
      angle = 0.0;
    }
    LatLng position = LatLng(lati, lngi);
    _latlng.add(position);

    _createImageLabel(
            label: label, course: angle, color: color, iconPath: iconpath)
        .then((BitmapDescriptor customIcon) {
      if (mounted) {
        setState(() {
          _mapLoading = false;
          fUpdateTime = devicelist.time.toString();
          fspeed = devicelist.speed.toString();
          ftotalDistance = devicelist.driver.toString();
          fstopDuration = devicelist.time.toString();

          // Update the marker as before
          _allMarker[MarkerId(devicelist.id.toString())] = Marker(
            infoWindow: InfoWindow(title: label),
            rotation: double.parse(devicelist.course.toString()),
            visible: true,
            markerId: MarkerId(devicelist.id.toString()),
            position: LatLng(
              lati,
              lngi,
            ),
            onTap: () {
              StaticVarMethod.deviceId = devicelist.id.toString();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AllOptionsPage(
                    expiredate: devicelist.deviceData!.expirationDate
                        .toString()
                        .split(" ")
                        .first,
                    productData: devicelist,
                  ),
                ),
              );
              setState(() {
                _statusbarLoading = (_statusbarLoading) ? false : true;
              });
            },
            anchor: const Offset(0.5, 0.8),
            icon: customIcon,
          );
          getAddress(lati, lngi);

          // Update the camera as before
          _controller.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(lati, lngi), 17));

          // Create the polyline
          PolylineId polylineId = PolylineId(devicelist.id.toString());
          Polyline polyline = Polyline(
            polylineId: polylineId,
            color: color,
            width: 4,
            points: _latlng,
          );

          // Add the polyline to the polylines map
          polylines[polylineId] = polyline;

          // Update the UI with the polyline
          drawPolyline();
        });
      }
    });
  }

  Widget _showStatusPopup() {
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
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(children: [
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
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    child: Image.asset(
                                        "assets/images/icons8-location-100.png",
                                        height: 30,
                                        width: 30)),
                                const SizedBox(
                                  width: 4,
                                ),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(6, 6, 6, 6),
                                    child: GestureDetector(
                                        onTap: () {
                                          address = "Loading....";
                                          setState(() {});
                                          getAddress(lati, lngi);
                                        },
                                        child: Text(address,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.blue),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis)))
                              ],
                            ))))
              ]),
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
                              margin: const EdgeInsets.fromLTRB(6, 6, 1, 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4)),
                                      child: Image.asset(
                                          "assets/images/speedometer1.png",
                                          height: 25,
                                          width: 25)),
                                  const SizedBox(
                                    width: 40,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          child: Text(' $fspeed KM/H',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                // fontFamily: 'digital_font'
                                              )),
                                        ),
                                        Row(
                                          children: const [
                                            Text(' Speed',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  height: 1.5,
                                                  //color: Colors.blue
                                                  fontWeight: FontWeight.bold,
                                                ))
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )))),
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
                                  Text(fstopDuration,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        //height: 0.8,
                                        // fontFamily: 'arial_font',
                                        // fontWeight: FontWeight.bold
                                      )),
                                  Row(
                                    children: const [
                                      /*Icon(Icons.location_on,
                                                  color: Colors.blue, size: 12),*/
                                      Text('Last Update',
                                          style: TextStyle(
                                            fontSize: 10,
                                            //color: Colors.blue
                                            fontWeight: FontWeight.bold,
                                          ))
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
            ],
          ),
        ),
      ),
    );
  }

  void drawPolyline() async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        width: 3,
        polylineId: id,
        color: Colors.redAccent,
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
    if (mounted) {
      setState(() {});
    }
  }

  String address = "Address!";
  String getAddress(lat, lng) {
    if (lat != null) {
      GPSAPIS.getGeocoder(lat, lng).then((value) {
        try {
          if (value.body.contains(", ")) {
            address =
                "${value.body.split(", ")[1]}, ${value.body.split(", ")[2]}";
            setState(() {});

            return address;
          } else {
            address = value.body;
            setState(() {});

            return address;
          }
        } catch (_) {
          address = value.body;
          setState(() {});

          return address;
        }
      });
    } else {
      address = "Address not found";
    }
    return address;
  }
}

Future<BitmapDescriptor> getMarkerIcon(String imagePath, String infoText,
    Color color, double rotateDegree, bool _showTitle) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  //size
  Size canvasSize = Size(700.0, 220.0);
  Size markerSize = Size(130.0, 130.0);
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

Future<ui.Image> getImageFromPath(String imagePath) async {
  var bd = await rootBundle.load(imagePath);
  Uint8List imageBytes = Uint8List.view(bd.buffer);

  final Completer<ui.Image> completer = Completer();

  ui.decodeImageFromList(imageBytes, (ui.Image img) {
    return completer.complete(img);
  });

  return completer.future;
}

Future<ui.Image> getImageFromPathUrl(String imagePath) async {
  final response = await http.Client().get(Uri.parse(imagePath));
  final bytes = response.bodyBytes;

  final Completer<ui.Image> completer = Completer();

  ui.decodeImageFromList(bytes, (ui.Image img) {
    return completer.complete(img);
  });

  return completer.future;
}
