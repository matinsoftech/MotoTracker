import 'dart:async';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/history.dart';
import 'package:myvtsproject/ui/reusable/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'home/home_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  final _globalWidget = GlobalWidget();

  late GoogleMapController _controller;
  bool _mapLoading = true;
  Timer? _timerDummy;

  final List<LatLng> _latlng = [];

  final Map<PolylineId, Polyline> _mapPolylines = {};

  double _currentZoom = 14;

  final LatLng _initialPosition = const LatLng(-6.168033, 106.900467);

  List<AllItems> _allItemsData = [];
  final List<AllItems> _allItemsSorted = [];
  final List<AllItems> _allItemsDuplicate = [];

  @override
  void initState() {
    _getData();
    super.initState();
  }

  Future<void> _getData() async {
    GPSAPIS api = GPSAPIS();
    var hash = StaticVarMethod.userAPiHash;
    _allItemsData = await api.getHistoryAllList(hash);
    if (_allItemsData.isNotEmpty) {
      _allItemsDuplicate.clear();
      _allItemsSorted.clear();
      _allItemsSorted.addAll(_allItemsData);
      _allItemsDuplicate.addAll(_allItemsData);
      for (int i = 0; i < _allItemsData.length; i++) {
        if (_allItemsData[i].lat != 0) {
          double lat = _allItemsData[i].lat as double;
          double lng = _allItemsData[i].lng as double;
          _latlng.add(LatLng(lat, lng));
        }
      }
      if (mounted) {
        setState(() {
          _mapLoading = false;
        });
      }
    } else {
      _mapLoading = false;
      _allItemsDuplicate.clear();
      _allItemsSorted.clear();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _timerDummy?.cancel();
    super.dispose();
  }

  // add marker
  void _drawPolylines() {
    const PolylineId polylineId = PolylineId('1');
    final Polyline polyline = Polyline(
      polylineId: polylineId,
      visible: true,
      width: 2,
      points: _latlng,
      color: Colors.pinkAccent,
    );
    _mapPolylines[polylineId] = polyline;

    CameraUpdate u2 = CameraUpdate.newCameraPosition(
        CameraPosition(target: _initialPosition, zoom: 15));

    _controller.moveCamera(u2).then((void v) {
      _check(u2, _controller);
    });
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

  // when the Google Maps Camera is change, get the current position
  void _onGeoChanged(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      backgroundColor: Colors.white,
      appBar: _globalWidget.globalAppBar(),
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
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  // build google maps to used inside widget
  Widget _buildGoogleMap() {
    return GoogleMap(
      mapType: MapType.normal,
      trafficEnabled: false,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      mapToolbarEnabled: true,
      polylines: Set<Polyline>.of(_mapPolylines.values),
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: _currentZoom,
      ),
      onCameraMove: _onGeoChanged,
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
        _timerDummy = Timer(const Duration(milliseconds: 300), () {
          setState(() {
            _mapLoading = false;
            _drawPolylines();
          });
        });
      },
    );
  }
}
