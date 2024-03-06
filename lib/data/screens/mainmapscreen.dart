import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:image/image.dart' as img;
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:myvtsproject/data/screens/options_screen/all_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/consts.dart';
import 'home/home_screen.dart';

class MainMapScreen extends StatefulWidget {
  const MainMapScreen({super.key});

  @override
  MainMapScreenState createState() => MainMapScreenState();
}

class MainMapScreenState extends State<MainMapScreen> {
  late GoogleMapController _controller;
  bool _mapLoading = true;
  Timer? _timerDummy;
  String? imageFilePath;

  bool _showMarker = true;
  bool _showTitle = true;
  double _currentZoom = 14;

  LatLng _initialPosition = LatLng(StaticVarMethod.lat, StaticVarMethod.lng);
  Location currentLocation = Location();

  final Map<MarkerId, Marker> _allMarker = {};
  final List<LatLng> _latlng = [];
  bool _isBound = false;
  bool _doneListing = false;
  MapType _currentMapType = MapType.normal;
  bool _trafficEnabled = false;
  var _trafficButtonColor = Colors.grey[700];
  @override
  void initState() {
    super.initState();
    _timerDummy =
        Timer.periodic(const Duration(seconds: 20), (Timer t) => _getData());
  }

  Future<void> _getData() async {
    StaticVarMethod.devicelist = await StaticVarMethod.devicelist;
    updateMarker();
  }

  @override
  void dispose() {
    _timerDummy?.cancel();
    super.dispose();
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<BitmapDescriptor> _createImageLabel(
      {String iconpath = '',
      String label = 'label',
      double fontSize = 20,
      double course = 0,
      Color color = Colors.red,
      bool showtitle = true}) async {
    return getMarkerIcon(iconpath, label, color, course, showtitle);
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

  void _onGeoChanged(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   // leading: const DrawerWidget(
      //   //   isHomeScreen: true,
      //   // ),
      //   centerTitle: true,
      //   title: SizedBox(
      //     width: screenWidth / 2,
      //     child: SizedBox(
      //         height: 40, child: Image.asset('assets/images/moto_traccar.png')),
      //   ),
      //   backgroundColor: HomeScreen.primaryDark,
      // ),
      body: Stack(
        children: [
          _buildGoogleMap(),
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showMarker = (_showMarker) ? false : true;
                  for (int a = 0; a < _allMarker.length; a++) {
                    if (_allMarker[MarkerId(a.toString())] != null) {
                      _allMarker[MarkerId(a.toString())] =
                          _allMarker[MarkerId(a.toString())]!.copyWith(
                        visibleParam: _showMarker,
                      );
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: (_showMarker)
                    ? Image.asset("assets/images/movingdurationicon.png",
                        height: 20, width: 20)
                    : Image.asset("assets/images/movingdurationhide.png",
                        height: 20, width: 20),
              ),
            ),
          ),
          Positioned(
            top: 57,
            left: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showTitle = (_showTitle) ? false : true;
                  updateMarker();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ],
                ),
                // color: Colors.white,
                //color: Color(0x99FFFFFF),
                child: (_showTitle)
                    ? Image.asset("assets/images/textshow.png",
                        height: 25, width: 25)
                    : Image.asset("assets/images/texthideone.png",
                        height: 25, width: 25),
              ),
            ),
          ),
          Positioned(
            bottom: 140,
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
            bottom: 103,
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
            bottom: 57,
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
            bottom: 20,
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
            bottom: 57,
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
            bottom: 20,
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
              : const SizedBox.shrink()
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
    final Uint8List markIcons =
        await getImages("assets/images/direction.png", 100);
    var location = await currentLocation.getLocation();

    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0),
      zoom: 12.0,
    )));
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      mapType: _currentMapType,
      trafficEnabled: _trafficEnabled,
      compassEnabled: false,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      mapToolbarEnabled: false,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
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
        _timerDummy = Timer(const Duration(seconds: 0), () async {
          setState(() {
            _mapLoading = false;
          });
          updateMarker();
          if (_isBound == false) {
            _isBound = true;
            var currentZoomLevel = 20.0;
            currentZoomLevel = currentZoomLevel - 1.0;
            if (currentZoomLevel < 0) currentZoomLevel = 0;
            _controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    // target: _initialPosition,
                    target: LatLng(27.7172, 85.3240),
                    // zoom: currentZoomLevel,
                    zoom: 6.5),
              ),
            );
          }
          _mapLoading = false;
          setState(() {});
        });
      },
    );
  }

  updateMarker() {
    /* Fluttertoast.showToast(
        msg: 'Click marker ' + ( 1).toString(),
        toastLength: Toast.LENGTH_SHORT);*/

    // _initialPosition = LatLng(StaticVarMethod.devicelist[0].lat!.toDouble(),
    //     StaticVarMethod.devicelist[0].lng!.toDouble());
    //_allMarker.clear();
    for (int i = 0; i < StaticVarMethod.devicelist.length; i++) {
      if (StaticVarMethod.devicelist[i].lat != 0) {
        var color;
        var label;

        String iconpath = 'assets/nepalicon/car_red.png';
        if (StaticVarMethod.devicelist[i].speed!.toInt() > 0) {
          iconpath = 'assets/nepalicon/car_green.png';
          color = Colors.green;
          label = StaticVarMethod.devicelist[i].name.toString() +
              '(' +
              StaticVarMethod.devicelist[i].speed!.toString() +
              ' km)';
        } else if (StaticVarMethod.devicelist[i].online!.contains('online')) {
          iconpath = 'assets/nepalicon/car_green.png';
          color = Colors.green;
          label = StaticVarMethod.devicelist[i].name.toString();
        } else {
          iconpath = 'assets/nepalicon/car_red.png';
          color = Colors.red;
          label = StaticVarMethod.devicelist[i].name.toString();
        }
        double lat = StaticVarMethod.devicelist[i].lat as double;
        double lng = StaticVarMethod.devicelist[i].lng as double;
        // String iconpath = StaticVarMethod.devicelist[i].icon!.path.toString();
        //double angle =  StaticVarMethod.devicelist[i].course as double;
        LatLng position = LatLng(lat, lng);
        _latlng.add(position);
        _createImageLabel(
                iconpath: iconpath,
                label: label,
                course: 1,
                color: color,
                showtitle: _showTitle)
            .then((BitmapDescriptor customIcon) {
          if (mounted) {
            setState(() {
              _mapLoading = false;
              _allMarker[MarkerId(i.toString())] = Marker(
                  markerId: MarkerId(i.toString()),
                  position: position,
                  //rotation: 0.0,
                  // infoWindow: InfoWindow(
                  //    title: 'This is marker ' + (i + 1).toString()),
                  onTap: () {
                    _initialPosition =
                        LatLng(position.latitude, position.longitude);
                    StaticVarMethod.imei = StaticVarMethod
                        .devicelist[i].deviceData!.imei
                        .toString();
                    setState(() {
                      // isshowvehicledetail = true;
                    });
                    /*      Fluttertoast.showToast(
                        msg: 'Click marker ' + (i + 1).toString(),
                        toastLength: Toast.LENGTH_SHORT);*/
                  },
                  anchor: Offset(0.5, 0.5),
                  icon: customIcon);
            });
          }
        });
        if (i == StaticVarMethod.devicelist.length - 1) {
          _doneListing = true;
        }
      }
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
      textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: infoText,
        style: TextStyle(
            fontSize: 20.0, fontWeight: FontWeight.w600, color: color),
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
            ..lineTo(0,
                -canvasSize.height / 2 + infoHeight / 2 + 25 - strokeWidth * 2)
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
    //File imageFile = File(imagePath);
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
}
