import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';

class ParkingScreen extends StatefulWidget {
  final List<DeviceItems>? currentDevice;
  const ParkingScreen({super.key, this.currentDevice});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DeviceItems> devices = [];
  GPSAPIS api = GPSAPIS();
  Timer? timerDummy;
  bool isLoading = false;
  SharedPreferences? prefs;
  getDeviceList(bool shouldReload) async {
    if (widget.currentDevice != null) {
      if (shouldReload) {
        List<DeviceItems> allDevices =
            await api.getDevicesList(StaticVarMethod.userAPiHash);
        for (var element in allDevices) {
          if (element.id == widget.currentDevice!.first.id) {
            devices = [element];
            break;
          }
        }
      } else {
        devices = await widget.currentDevice!;
      }
    } else {
      devices = await api.getDevicesList(StaticVarMethod.userAPiHash);
    }
    setState(() {});
  }

  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    getSharedPreferences();
    getDeviceList(false);
    super.initState();
    timerDummy = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => getDeviceList(false));
  }

  @override
  void dispose() {
    timerDummy?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Anti theft - parking mode'),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
        elevation: 0,
      ),
      body: prefs == null
          ? const Center(
              child: CircularProgressIndicator(
                color: HomeScreen.primaryDark,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enable Anti theft - parking mode: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 20,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        String parkingMode =
                            devices[index].deviceData?.parkingMode.toString() ??
                                "0";
                        bool isParked = parkingMode == "1"
                            ? true
                            : parkingMode == "0"
                                ? false
                                : prefs!.getBool(devices[index].id.toString() +
                                        devices[index].name) ??
                                    false;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(devices[index].name ?? ""),
                              const SizedBox(
                                width: 15,
                              ),
                              CupertinoSwitch(
                                // focusColor: Colors.white,
                                // hoverColor: Colors.white,
                                // thumbColor: MaterialStateProperty.resolveWith(
                                //   (states) => Color.fromARGB(255, 7, 97, 97),
                                // ),
                                activeColor:
                                    const Color.fromARGB(255, 7, 97, 97),
                                value: isParked,
                                onChanged: (value) async {
                                  if (devices[index]
                                              .online
                                              .toString()
                                              .toLowerCase() ==
                                          "online" &&
                                      isParked == false) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Anti theft - parking mode for ${devices[index].name} cannot be enabled as the vehicle in currently running")));
                                  } else {
                                    showLoader(context);
                                    isParked = !isParked;
                                    String mode;
                                    if (isParked == true) {
                                      mode = "1";
                                    } else {
                                      mode = "0";
                                    }
                                    var res = await GPSAPIS.updateParkingMode(
                                        deviceId: devices[index].id.toString(),
                                        mode: mode.toString(),
                                        userAPiHash: StaticVarMethod.userAPiHash
                                            .toString());
                                    await prefs!.setBool(
                                        devices[index].id.toString() +
                                            devices[index].name,
                                        isParked);

                                    if (res) {
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text('Permission Denied'),
                                      ));
                                    }
                                  }
                                  if (widget.currentDevice != null) {
                                    await getDeviceList(true);
                                  } else {
                                    await getDeviceList(false);
                                  }
                                  if (devices[index]
                                          .online
                                          .toString()
                                          .toLowerCase() ==
                                      "offline") {
                                    Navigator.pop(context);
                                  }
                                  // });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

showLoader(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
            ],
          ),
        );
      });
}
