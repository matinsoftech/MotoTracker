import 'dart:async';
import 'dart:convert';

import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myvtsproject/data/screens/vehicle_expiry.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myvtsproject/config/constant.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/livetrack.dart';
import 'package:myvtsproject/data/screens/options_screen/all_options.dart';
import 'package:myvtsproject/data/screens/playback_selection.dart';
import 'package:myvtsproject/data/screens/reports/report_selection.dart';
import 'package:myvtsproject/data/screens/signin.dart';
import 'package:myvtsproject/ui/reusable/shimmer_loading.dart';
import 'package:http/http.dart' as http;

import '../../bottom_navigation/bottom_navigation.dart';
import '../../mapconfig/common_method.dart';
import '../model/position_history.dart';
import '../model/user.dart';
import 'document screen/document_screen.dart';

class Home extends StatefulWidget {
  final Widget currentPage;
  const Home({
    Key? key,
    required this.currentPage,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      style: DrawerStyle.style1,
      disableDragGesture: true,
      menuScreen: DrawerScreen(
        setIndex: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      mainScreen: widget.currentPage,
      mainScreenTapClose: true,
      borderRadius: 30,
      showShadow: true,
      angle: 0.0,
      slideWidth: 250,

      menuBackgroundColor: HomeScreen.primaryDark,
      // menuBackgroundColor: const Color(0XFF2F697E),
    );
  }
}

class ListScreen extends StatefulWidget {
  final int? currentTab;
  static String? currentFilter;

  const ListScreen({
    Key? key,
    this.currentTab,
  }) : super(key: key);

  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen>
    with SingleTickerProviderStateMixin {
  List mahesh = [];
  final _shimmerLoading = ShimmerLoading();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  String filtertext = ListScreen.currentFilter ?? "All";
  bool _loading = true;
  Timer? _timerDummy;
  Set<Marker> markers = {};

  final Color _color1 = const Color(0xff777777);
  final Color _color2 = const Color(0xFF515151);
  List<DeviceItems> _vehiclesData = [];
  final List<DeviceItems> _vehiclesDataSorted = [];
  final List<DeviceItems> _vehiclesDataDuplicate = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  TextEditingController _etSearch = TextEditingController();

  int _tabIndex = 0;
  late TabController _tabController;

  final List<Tab> _tabBarList = const [
    Tab(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Text('All',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    )),
    Tab(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Text('Running',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    )),
    Tab(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Text('Stop',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    )),
    Tab(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Text('Idle',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    )),
    Tab(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Text('No Data',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    )),
    Tab(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Text('Inactive',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    )),
  ];

  GoogleMapController? _controller;

  var startdate;
  var enddate;
  var topSpeed = '';
  var moveDuration = '';
  var stopDuration = '';
  var fuelConsumption = '';
  var distanceSum = '';

  late BitmapDescriptor _markerDirection;
  void _setSourceAndDestinationIcons() async {
    _markerDirection = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/default_icon.jpeg');
  }

  @override
  void initState() {
    _setSourceAndDestinationIcons();

    _getData();
    _tabController = TabController(
        vsync: this,
        length: _tabBarList.length,
        initialIndex: widget.currentTab ?? _tabIndex);
    _timerDummy =
        Timer.periodic(const Duration(seconds: 10), (Timer t) => _getData());
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timerDummy?.cancel();
    _etSearch.dispose();
    super.dispose();
  }

  //added for testing purpose
  void showReport1(int selectedperiod, String currentday, String deviceid) {
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
    if (selectedperiod == 0) {
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
      toDate = formatDateReport(DateTime.now().toString());
      fromTime = "00:00";
      toTime = "23:59";

      StaticVarMethod.fromdate = fromDate;
      StaticVarMethod.todate = toDate;
      StaticVarMethod.fromtime = fromTime;
      StaticVarMethod.totime = toTime;
    }

    // Navigator.pop(context);

    getReport1(deviceid, StaticVarMethod.fromdate, StaticVarMethod.fromtime,
        StaticVarMethod.todate, StaticVarMethod.totime, currentday);
    /* Navigator.pushNamed(context, "/reportList",
        arguments: ReportArguments(device['id'], fromDate, fromTime,
            toDate, toTime, device["name"], 0));*/
  }

  Future<PositionHistory?> getReport1(String deviceID, String fromDate,
      String fromTime, String toDate, String toTime, String currentday) async {
    final response = await http.get(Uri.parse(
        "${StaticVarMethod.baseurlall}/api/get_history?lang=en&user_api_hash=${StaticVarMethod.userAPiHash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&snap_to_road=false&device_id=$deviceID"));

    if (response.statusCode == 200) {
      var value = PositionHistory.fromJson(json.decode(response.body));
      if (value.items!.isNotEmpty) {
        startdate = value.items!.first;
        enddate = value.items!.last;

        startdate = startdate['show'];
        enddate = enddate['show'];

        setState(() {
          topSpeed = value.topSpeed.toString();
          moveDuration = value.moveDuration.toString();
          stopDuration = value.stopDuration.toString();
          fuelConsumption = value.fuelConsumption.toString();
          distanceSum = value.distanceSum.toString();
        });
      }
    } else {
      return null;
    }
    return null;
  }

  //end of code added for testing purpose

  SharedPreferences? prefs;
  Future<void> _getData() async {
    prefs = await SharedPreferences.getInstance();
    GPSAPIS api = GPSAPIS();
    var hash = StaticVarMethod.userAPiHash;
    _vehiclesData = await api.getDevicesList(hash);

    if (_vehiclesData.isNotEmpty) {
      _vehiclesDataDuplicate.clear();
      _vehiclesDataSorted.clear();
      _vehiclesDataSorted.addAll(_vehiclesData);

      if (filtertext != "All") {
        for (int i = 0; i < _vehiclesDataSorted.length; i++) {
          DeviceItems model = _vehiclesDataSorted.elementAt(i);

          if (filtertext == "online") {
            if (model.online
                .toString()
                .toLowerCase()
                .contains(filtertext.toLowerCase())) {
              _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
            }
          } else if (filtertext == "offline") {
            if ((model.online.toString().toLowerCase().contains("offline") ||
                    model.online
                        .toString()
                        .toLowerCase()
                        .contains(filtertext.toLowerCase())) &&
                model.time.toString().toLowerCase().contains("not connected")) {
              _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
            }
          } else if (filtertext == "idle") {
            if ((model.online.toString().toLowerCase().contains("ack") ||
                    model.online
                        .toString()
                        .toLowerCase()
                        .contains(filtertext.toLowerCase())) &&
                double.parse(model.speed.toString()) < 1.0) {
              _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
            }
          } else if (filtertext == "stop") {
            if ((model.online.toString().toLowerCase().contains("offline") ||
                    model.online
                        .toString()
                        .toLowerCase()
                        .contains(filtertext.toLowerCase())) &&
                model.time.toString().toLowerCase() != "not connected") {
              _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
            }
          } else {
            if (model.name
                .toString()
                .toLowerCase()
                .contains(filtertext.toLowerCase())) {
              _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
            }
          }
        }
      } else {
        _vehiclesDataDuplicate.addAll(_vehiclesData);
      }

      StaticVarMethod.devicelist = _vehiclesData;
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } else {
      _loading = false;
      _vehiclesDataDuplicate.clear();
      _vehiclesDataSorted.clear();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double boxImageSize = (MediaQuery.of(context).size.width / 12);

    Widget? child;
    if (_loading == true) {
      child = const Center(child: CircularProgressIndicator());
    } else if (_vehiclesDataDuplicate.isNotEmpty) {
      child = RefreshIndicator(
        onRefresh: refreshData,
        child: (_loading == true)
            ? _shimmerLoading.buildShimmerContent()
            : devicesListwidget(boxImageSize),
      );
    } else if (_vehiclesDataDuplicate.isEmpty) {
      child = RefreshIndicator(
        onRefresh: refreshData,
        child: (_loading == true)
            ? _shimmerLoading.buildShimmerContent()
            : Container(),
      );
    }

    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      appBar: AppBar(
        // leading: const DrawerWidget(),
        leading: const Text(''),
        title: Container(
          margin: const EdgeInsets.fromLTRB(0, 15, 30, 12),
          height: kToolbarHeight - 24,
          child: TextFormField(
            controller: _etSearch,
            textAlignVertical: TextAlignVertical.bottom,
            maxLines: 1,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            onChanged: (value) {
              setState(() {
                if (value.isNotEmpty) {
                  filterSearchResults(value);
                } else {
                  _vehiclesData.clear();
                  filtertext = "All";
                  _getData();
                }
              });
            },
            decoration: InputDecoration(
              fillColor: Colors.grey[100],
              filled: true,
              hintText: 'Search Vehicles',
              prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 18),
              suffixIcon: (_etSearch.text == '')
                  ? null
                  : GestureDetector(
                      onTap: () {
                        filtertext = "All";
                        //setState(() {
                        _getData();
                        _etSearch = TextEditingController(text: '');
                        //  });
                      },
                      child:
                          Icon(Icons.close, color: Colors.grey[500], size: 16)),
              focusedBorder: UnderlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: UnderlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        bottom: TabBar(
          isScrollable: true,
          indicator: const BoxDecoration(
            color: HomeScreen.primaryDark,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xff000000),
          controller: _tabController,
          onTap: (position) {
            setState(() {
              _tabIndex = position;
              if (position == 0) {
                filterSearchResults("All");
              } else if (position == 1) {
                filterSearchResults("online");
              } else if (position == 2) {
                filterSearchResults("stop");
              } else if (position == 3) {
                filterSearchResults("idle");
              } else if (position == 4) {
                filterSearchResults("no data");
              } else if (position == 5) {
                filterSearchResults("offline");
              }
            });
            // Fluttertoast.showToast(
            //     msg: 'Click TabBar', toastLength: Toast.LENGTH_SHORT);
          },
          tabs: _tabBarList,
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh_sharp, color: _color1),
              onPressed: () {
                _getData();
              }),
        ],
      ),
      body: child,
    );
  }

  Widget devicesListwidget(double boxImageSize) {
    return ScrollablePositionedList.builder(
      key: _listKey,
      itemCount: _vehiclesDataDuplicate.length,
      itemBuilder: (context, index) =>
          _buildItem(_vehiclesDataDuplicate[index], boxImageSize, index),
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
    );
  }

  filterSearchResults(String query) {
    filtertext = query;
    _vehiclesDataDuplicate.clear();

    if (query.isNotEmpty && query != "All") {
      for (int i = 0; i < _vehiclesDataSorted.length; i++) {
        DeviceItems model = _vehiclesDataSorted.elementAt(i);

        if (query == "online") {
          if (model.online
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())) {
            _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
            _vehiclesDataDuplicate[0].id;
            print(_vehiclesDataDuplicate[0].id);
          }
        } else if (filtertext == "offline") {
          if ((model.online.toString().toLowerCase().contains("offline") ||
                  model.online
                      .toString()
                      .toLowerCase()
                      .contains(filtertext.toLowerCase())) &&
              model.time.toString().toLowerCase().contains("not connected")) {
            _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
          }
        } else if (query == "idle") {
          if ((model.online.toString().toLowerCase().contains("online") ||
                  model.online
                      .toString()
                      .toLowerCase()
                      .contains(filtertext.toLowerCase())) &&
              double.parse(model.speed.toString()) < 1.0) {
            _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
          }
        } else if (query == "stop") {
          if ((model.online.toString().toLowerCase().contains("offline") ||
                  model.online
                      .toString()
                      .toLowerCase()
                      .contains(filtertext.toLowerCase())) &&
              model.time.toString().toLowerCase() != "not connected") {
            _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
          }
        } else {
          if (model.name.toString().toLowerCase().contains(query
                  .toLowerCase()) /*||
                  model.devicedata!.first.imei!.contains(query.toLowerCase())*/
              ) {
            _vehiclesDataDuplicate.add(_vehiclesDataSorted.elementAt(i));
          }
        }
      }

      setState(() {});
    } else {
      if (query == "All") {
        _vehiclesDataDuplicate.addAll(_vehiclesDataSorted);
      }
    }
  }

  Widget _buildItem(DeviceItems productData, boxImageSize, index) {
    double lat = productData.lat!.toDouble();
    double lng = productData.lng!.toDouble();
    // double course = productData!.course as double;
    int speed = productData.speed!.toInt();
    String imei = productData.deviceData!.imei.toString();
    String carstatus = productData.online!.toString();
    String carSpeed = productData.speed!.toString();

    return GestureDetector(
      onTap: () {
        _timerDummy?.cancel();
        StaticVarMethod.deviceName = productData.name.toString();
        StaticVarMethod.deviceId = productData.id.toString();
        StaticVarMethod.imei = imei;
        StaticVarMethod.simno = productData.deviceData!.simNumber.toString();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AllOptionsPage(
                      productData: productData,
                      expiredate:
                          productData.deviceData!.expirationDate.toString(),
                    )));
        //showPopupDeleteFavorite(index, boxImageSize);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          color: Colors.white,
          child: Container(
            margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: carstatus.contains("online")
                        ? Colors.green.withOpacity(0.5)
                        : carstatus.contains("ack") &&
                                int.parse(carSpeed.toString()) < 1
                            ? Colors.yellow.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 70.0,
                      height: 70.0,
                      child: ClipOval(
                        // child: _loadImagePath(productData.name.toString()),
                        child: Image.asset(
                          '${prefs!.getString(productData.name.toString())}' !=
                                  "null"
                              ? '${prefs!.getString(productData.name.toString())}'
                              : carstatus.contains("online")
                                  ? 'assets/nepalicon/car_green.png'
                                  : carstatus.contains("ack") &&
                                          int.parse(carSpeed.toString()) < 1
                                      ? 'assets/nepalicon/car_orange.png'
                                      : 'assets/nepalicon/car_red.png',
                          fit: BoxFit.contain,
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productData.name.toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: _color2,
                              fontWeight: FontWeight.bold),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: (productData.speed! > 0)
                              ? BlinkText(
                                  '${productData.speed} KM/H',
                                  style: const TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.greenAccent,
                                      fontFamily: 'digital_font'),
                                  endColor: Colors.orange,
                                )
                              : Text('${productData.speed} KM/H',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    //fontWeight: FontWeight.bold,
                                  )),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.history_toggle_off,
                                color: softGrey,
                                size: 12,
                              ),
                              Text(
                                (speed > 0)
                                    ? ' Moving since:\n${productData.time!}'
                                    : ' Stop since:\n${productData.time!} ',
                                style: const TextStyle(
                                    fontSize: 11, color: softGrey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Container(
                //   margin: const EdgeInsets.only(top: 12),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: OutlinedButton(
                //           onPressed: () {
                //             StaticVarMethod.deviceName =
                //                 productData.name.toString();
                //             StaticVarMethod.deviceId =
                //                 productData.id.toString();
                //             StaticVarMethod.lat = productData.lat!.toDouble();
                //             StaticVarMethod.lng = productData.lng!.toDouble();
                //             StaticVarMethod.imei =
                //                 productData.deviceData!.imei.toString();
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) => const LiveTrack()),
                //             );
                //             //Fluttertoast.showToast(msg: 'Item has been added to Shopping Cart');
                //           },
                //           style: ButtonStyle(
                //             minimumSize:
                //                 MaterialStateProperty.all(const Size(0, 30)),
                //             overlayColor:
                //                 MaterialStateProperty.all(Colors.transparent),
                //             shape: MaterialStateProperty.all(
                //               RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(5.0),
                //               ),
                //             ),
                //             side: MaterialStateProperty.all(
                //               const BorderSide(
                //                   color: Color.fromARGB(255, 7, 97, 97),
                //                   width: 1.0),
                //             ),
                //           ),
                //           child: const Text(
                //             'Live Track',
                //             style: TextStyle(
                //                 color: Colors.black,
                //                 //fontWeight: FontWeight.bold,
                //                 fontSize: 11),
                //             textAlign: TextAlign.center,
                //           ),
                //         ),
                //       ),
                //       const SizedBox(
                //         width: 8,
                //       ),
                //       Expanded(
                //         child: OutlinedButton(
                //           onPressed: () {
                //             _timerDummy?.cancel();
                //
                //             StaticVarMethod.deviceName =
                //                 productData.name.toString();
                //             StaticVarMethod.deviceId =
                //                 productData.id.toString();
                //             StaticVarMethod.imei =
                //                 productData.deviceData!.imei.toString();
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) =>
                //                       const PlayBackSelection()),
                //             );
                //             //Fluttertoast.showToast(msg: 'Item has been added to Shopping Cart');
                //           },
                //           style: ButtonStyle(
                //             minimumSize:
                //                 MaterialStateProperty.all(const Size(0, 30)),
                //             overlayColor:
                //                 MaterialStateProperty.all(Colors.transparent),
                //             shape: MaterialStateProperty.all(
                //                 RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(5.0),
                //             )),
                //             side: MaterialStateProperty.all(
                //               const BorderSide(
                //                   color: Color.fromARGB(255, 7, 97, 97),
                //                   width: 1.0),
                //             ),
                //           ),
                //           child: const Text(
                //             'Playback',
                //             style: TextStyle(
                //                 color: Colors.black,
                //                 //fontWeight: FontWeight.bold,
                //                 fontSize: 11),
                //             textAlign: TextAlign.center,
                //           ),
                //         ),
                //       ),
                //       const SizedBox(
                //         width: 3,
                //       ),
                //       // Expanded(
                //       //   child: OutlinedButton(
                //       //     onPressed: () {
                //       //       _timerDummy?.cancel();
                //       //       StaticVarMethod.deviceName =
                //       //           productData.name.toString();
                //       //       StaticVarMethod.deviceId =
                //       //           productData.id.toString();
                //       //       StaticVarMethod.imei =
                //       //           productData.deviceData!.imei.toString();
                //       //       StaticVarMethod.simno =
                //       //           productData.deviceData!.simNumber.toString();
                //       //       Navigator.push(
                //       //         context,
                //       //         MaterialPageRoute(
                //       //           builder: (context) => AllOptionsPage(
                //       //             productData: productData,
                //       //             expiredate: productData
                //       //                 .deviceData!.expirationDate
                //       //                 .toString(),
                //       //           ),
                //       //         ),
                //       //       );
                //       //       //showPopupDeleteFavorite(index, boxImageSize);
                //       //     },
                //       //     style: ButtonStyle(
                //       //       minimumSize:
                //       //           MaterialStateProperty.all(const Size(0, 30)),
                //       //       overlayColor:
                //       //           MaterialStateProperty.all(Colors.transparent),
                //       //       shape: MaterialStateProperty.all(
                //       //         RoundedRectangleBorder(
                //       //           borderRadius: BorderRadius.circular(5.0),
                //       //         ),
                //       //       ),
                //       //       side: MaterialStateProperty.all(
                //       //         const BorderSide(
                //       //             color: Color.fromARGB(255, 7, 97, 97),
                //       //             width: 1.0),
                //       //       ),
                //       //     ),
                //       //     child: const Text(
                //       //       'Dashboard',
                //       //       style: TextStyle(
                //       //           color: Colors.black,
                //       //           //fontWeight: FontWeight.bold,
                //       //           fontSize: 11),
                //       //       textAlign: TextAlign.center,
                //       //     ),
                //       //   ),
                //       // ),
                //     ],
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // add marker
  Set<Marker> getmarkers(double lat, double lng, double course, String imei) {
    // void _addMarker(double lat, double lng,int index) {
    LatLng position = LatLng(lat, lng);

    // set initial marker
    markers.add(Marker(
      markerId: MarkerId(imei),
      anchor: const Offset(0.5, 0.5),
      position: position,
      rotation: course,
      /*  infoWindow: InfoWindow(title: 'This is marker 1'),
      onTap: () {
        Fluttertoast.showToast(msg: 'Click marker', toastLength: Toast.LENGTH_SHORT);
      },*/
      icon: _markerDirection,
    ));

    if (_controller != null) {
      _controller!
          .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
    }

    return markers;
  }

  void showPopupDeleteFavorite(index, boxImageSize) {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('No', style: TextStyle(color: softBlue)));
    Widget continueButton = TextButton(
      onPressed: () {
        int removeIndex = index;
        var removedItem = _vehiclesData.removeAt(removeIndex);
        builder(context, animation) {
          return _buildItem(removedItem, boxImageSize, removeIndex);
        }

        _listKey.currentState!.removeItem(removeIndex, builder);

        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: 'Item has been deleted from your favorite',
            toastLength: Toast.LENGTH_SHORT);
      },
      child: const Text('Yes', style: TextStyle(color: softBlue)),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text(
        'Delete Favorite',
        style: TextStyle(fontSize: 18),
      ),
      content: Text('Are you sure to delete this item from your Favorite ?',
          style: TextStyle(fontSize: 13, color: _color1)),
      actions: [
        cancelButton,
        continueButton,
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

  Future refreshData() async {
    setState(() {
      _vehiclesData.clear();
      _loading = true;
      _getData();
    });
  }
}

class DrawerScreen extends StatefulWidget {
  final ValueSetter setIndex;
  const DrawerScreen({Key? key, required this.setIndex}) : super(key: key);

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

String selectedTab = "dashboard";

class _DrawerScreenState extends State<DrawerScreen> {
  late User user;
  late SharedPreferences prefs;
  bool isLoading = true;
  String email = "";
  String username = "";
  String expirationDate = "";

  // added code
  var startdate;
  var enddate;

  //end of added code
  @override
  void initState() {
    getUser();
    checkPreference();

    super.initState();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  getUser() async {
    GPSAPIS.getUserData().then((value) => {
          isLoading = false,
          user = value!,
          email = value.email.toString(),
          username = "${value.firstName} ${value.lastName}",
          expirationDate = value.subscriptionExpiration.toString(),
        });
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: SizedBox(
        height: 710, //jenish
        width: MediaQuery.of(context).size.width,
        child: Drawer(
          elevation: 0,
          backgroundColor: HomeScreen.primaryDark,
          // width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              // UserAccountsDrawerHeader(
              //   accountName: Text(
              //     username,
              //     style: const TextStyle(color: Colors.white),
              //   ),
              //   accountEmail:
              //       Text(email, style: const TextStyle(color: Colors.white)),
              //   currentAccountPicture: Container(
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(50),
              //       border: Border.all(width: 2, color: Colors.white),
              //     ),
              //     child: CircleAvatar(
              //       backgroundColor: HomeScreen.primaryDark,
              //       radius: screenWidth / 10,
              //       child: SizedBox(
              //         height: screenWidth / 8,
              //         width: screenWidth / 8,
              //         // child: Image.asset("assets/images/mg_logo.png"),
              //         child: Image.asset("assets/images/moto_traccar.png"),
              //       ),
              //     ),
              //   ),
              //   decoration: BoxDecoration(
              //     color: HomeScreen.primaryDark,
              //     // color: Colors.red
              //   ),
              // ),
              // Text('username'),
              Ink(
                color: selectedTab == "dashboard"
                    ? HomeScreen.primaryLight.withOpacity(0.3)
                    : HomeScreen.primaryDark,
                child: ListTile(
                  leading: const Icon(
                    Icons.home_outlined,
                    color: Colors.orange,
                  ),
                  title: const Text('Dashboard',
                      style: TextStyle(color: Colors.black, fontSize: 12)),
                  onTap: () {
                    selectedTab = "dashboard";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BottomNavigation(
                          selectedPage: 0,
                        ),
                      ),
                    ); // navigate to home screen
                  },
                ),
              ),
              Ink(
                color: selectedTab == "live"
                    ? HomeScreen.primaryLight.withOpacity(0.3)
                    : HomeScreen.primaryDark,
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.white),
                  title: const Text('Live Tracking',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  onTap: () {
                    selectedTab = "live";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BottomNavigation(
                          selectedPage: 2,
                        ),
                      ),
                    );
                    // navigate to calendar screen
                  },
                ),
              ),
              Ink(
                color: selectedTab == "vehicle"
                    ? HomeScreen.primaryLight.withOpacity(0.3)
                    : HomeScreen.primaryDark,
                child: ListTile(
                  leading:
                      const Icon(Icons.car_rental_rounded, color: Colors.white),
                  title: const Text('Vehicle Status',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  onTap: () {
                    selectedTab = "vehicle";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BottomNavigation(
                          selectedPage: 1,
                        ),
                      ),
                    );
                    // navigate to calendar screen
                  },
                ),
              ),
              Ink(
                color: selectedTab == "alert"
                    ? HomeScreen.primaryLight.withOpacity(0.3)
                    : HomeScreen.primaryDark,
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.white),
                  title: const Text('Alert',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  onTap: () {
                    selectedTab = "alert";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BottomNavigation(
                          selectedPage: 3,
                        ),
                      ),
                    );
                    // navigate to loved screen
                  },
                ),
              ),
              Ink(
                color: selectedTab == "report"
                    ? HomeScreen.primaryLight.withOpacity(0.3)
                    : HomeScreen.primaryDark,
                child: ListTile(
                  leading: const Icon(Icons.menu, color: Colors.white),
                  title: const Text('Report',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  onTap: () {
                    selectedTab = "report";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Home(
                          currentPage: ReportSelection(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Ink(
                color: selectedTab == "expiry"
                    ? HomeScreen.primaryLight.withOpacity(0.3)
                    : HomeScreen.primaryDark,
                child: ListTile(
                  leading: const Icon(Icons.car_repair_outlined,
                      color: Colors.white),
                  title: const Text('Subscription Expiry',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  onTap: () {
                    selectedTab = "expiry";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Home(
                          currentPage: VehicleExpiry(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Ink(
                color: selectedTab == "document"
                    ? HomeScreen.primaryLight.withOpacity(0.3)
                    : HomeScreen.primaryDark,
                child: ListTile(
                  leading:
                      const Icon(Icons.document_scanner, color: Colors.white),
                  title: const Text('Documents',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  onTap: () {
                    selectedTab = "document";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Home(
                          currentPage: DocumentScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Ink(
                color: selectedTab == "settings"
                    ? HomeScreen.primaryLight.withOpacity(0.3)
                    : HomeScreen.primaryDark,
                child: ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text('Settings',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  onTap: () {
                    selectedTab = "settings";
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BottomNavigation(
                          selectedPage: 4,
                        ),
                      ),
                    );

                    // navigate to settings screen
                  },
                ),
              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: ListTile(
                    tileColor: HomeScreen.primaryDark,
                    leading: const Icon(Icons.exit_to_app, color: Colors.white),
                    title: const Text('Logout',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    onTap: () {
                      prefs.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignIn()),
                      );
                      // logout
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget drawerList(IconData icon, String text, int index) {
  //   return GestureDetector(
  //     onTap: () {
  //       widget.setIndex(index);
  //     },
  //     child: Container(
  //       margin: const EdgeInsets.only(left: 20, bottom: 12),
  //       child: Row(
  //         children: [
  //           Icon(
  //             icon,
  //             color: Colors.white,
  //           ),
  //           const SizedBox(
  //             width: 12,
  //           ),
  //           Text(
  //             text,
  //             style: const TextStyle(
  //                 color: Colors.white, fontWeight: FontWeight.bold),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class DrawerWidget extends StatelessWidget {
  final bool isHomeScreen;
  const DrawerWidget({Key? key, this.isHomeScreen = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        ZoomDrawer.of(context)!.toggle();
      },
      icon: Icon(
        Icons.menu,
        color: isHomeScreen ? Colors.white : HomeScreen.primaryDark,
      ),
    );
  }
}

//added by mahesh kattel for testing purpose
class NewDrawer extends StatelessWidget {
  const NewDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,

      backgroundColor: HomeScreen.primaryDark,
      // width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          // UserAccountsDrawerHeader(
          //   accountName: Text(
          //     username,
          //     style: const TextStyle(color: Colors.white),
          //   ),
          //   accountEmail:
          //       Text(email, style: const TextStyle(color: Colors.white)),
          //   currentAccountPicture: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(50),
          //       border: Border.all(width: 2, color: Colors.white),
          //     ),
          //     child: CircleAvatar(
          //       backgroundColor: HomeScreen.primaryDark,
          //       radius: screenWidth / 10,
          //       child: SizedBox(
          //         height: screenWidth / 8,
          //         width: screenWidth / 8,
          //         // child: Image.asset("assets/images/mg_logo.png"),
          //         child: Image.asset("assets/images/moto_traccar.png"),
          //       ),
          //     ),
          //   ),
          //   decoration: BoxDecoration(
          //     color: HomeScreen.primaryDark,
          //     // color: Colors.red
          //   ),
          // ),
          Text('username'),
          Ink(
            color: selectedTab == "dashboard"
                ? HomeScreen.primaryLight.withOpacity(0.3)
                : HomeScreen.primaryDark,
            child: ListTile(
              leading: const Icon(
                Icons.home_outlined,
                color: Colors.orange,
              ),
              title: const Text('Dashboard',
                  style: TextStyle(color: Colors.black, fontSize: 12)),
              onTap: () {
                selectedTab = "dashboard";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BottomNavigation(
                      selectedPage: 0,
                    ),
                  ),
                ); // navigate to home screen
              },
            ),
          ),
          Ink(
            color: selectedTab == "live"
                ? HomeScreen.primaryLight.withOpacity(0.3)
                : HomeScreen.primaryDark,
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.white),
              title: const Text('Live Tracking',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              onTap: () {
                selectedTab = "live";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BottomNavigation(
                      selectedPage: 2,
                    ),
                  ),
                );
                // navigate to calendar screen
              },
            ),
          ),
          Ink(
            color: selectedTab == "vehicle"
                ? HomeScreen.primaryLight.withOpacity(0.3)
                : HomeScreen.primaryDark,
            child: ListTile(
              leading:
                  const Icon(Icons.car_rental_rounded, color: Colors.white),
              title: const Text('Vehicle Status',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              onTap: () {
                selectedTab = "vehicle";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BottomNavigation(
                      selectedPage: 1,
                    ),
                  ),
                );
                // navigate to calendar screen
              },
            ),
          ),
          Ink(
            color: selectedTab == "alert"
                ? HomeScreen.primaryLight.withOpacity(0.3)
                : HomeScreen.primaryDark,
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.white),
              title: const Text('Alert',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              onTap: () {
                selectedTab = "alert";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BottomNavigation(
                      selectedPage: 3,
                    ),
                  ),
                );
                // navigate to loved screen
              },
            ),
          ),
          Ink(
            color: selectedTab == "report"
                ? HomeScreen.primaryLight.withOpacity(0.3)
                : HomeScreen.primaryDark,
            child: ListTile(
              leading: const Icon(Icons.menu, color: Colors.white),
              title: const Text('Report',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              onTap: () {
                selectedTab = "report";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Home(
                      currentPage: ReportSelection(),
                    ),
                  ),
                );
              },
            ),
          ),
          Ink(
            color: selectedTab == "expiry"
                ? HomeScreen.primaryLight.withOpacity(0.3)
                : HomeScreen.primaryDark,
            child: ListTile(
              leading:
                  const Icon(Icons.car_repair_outlined, color: Colors.white),
              title: const Text('Subscription Expiry',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              onTap: () {
                selectedTab = "expiry";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Home(
                      currentPage: VehicleExpiry(),
                    ),
                  ),
                );
              },
            ),
          ),
          Ink(
            color: selectedTab == "document"
                ? HomeScreen.primaryLight.withOpacity(0.3)
                : HomeScreen.primaryDark,
            child: ListTile(
              leading: const Icon(Icons.document_scanner, color: Colors.white),
              title: const Text('Documents',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              onTap: () {
                selectedTab = "document";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Home(
                      currentPage: DocumentScreen(),
                    ),
                  ),
                );
              },
            ),
          ),
          Ink(
            color: selectedTab == "settings"
                ? HomeScreen.primaryLight.withOpacity(0.3)
                : HomeScreen.primaryDark,
            child: ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Settings',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              onTap: () {
                selectedTab = "settings";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BottomNavigation(
                      selectedPage: 4,
                    ),
                  ),
                );

                // navigate to settings screen
              },
            ),
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: ListTile(
                tileColor: HomeScreen.primaryDark,
                leading: const Icon(Icons.exit_to_app, color: Colors.white),
                title: const Text('Logout',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                onTap: () {
                  // prefs.clear();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignIn()),
                  );
                  // logout
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
