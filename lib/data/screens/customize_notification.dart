import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myvtsproject/data/screens/alert/add_alert_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';

import '../../provider/alert_provider.dart';
import '../model/alert_type.dart';

class CustomizeNotification extends StatefulWidget {
  final List<DeviceItems>? currentDevice;
  const CustomizeNotification({super.key, this.currentDevice});

  @override
  State<CustomizeNotification> createState() => _CustomizeNotificationState();
}

class _CustomizeNotificationState extends State<CustomizeNotification>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;

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
    initAlertData();

    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    timerDummy = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => getDeviceList(false));
  }

  initAlertData() async {
    final provider = Provider.of<AlertProfivider>(context, listen: false);
    provider.getAlertEvent();
    await provider.getAlertType();

    setState(() {
      if (provider.alertType.isNotEmpty) {
        alertType = provider.alertType.first;
      }
    });
  }

  @override
  void dispose() {
    timerDummy?.cancel();
    super.dispose();
  }

  AlertType? alertType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notification Settings',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: HomeScreen.primaryDark,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => AddAlertScreen()));
          },
          child: Icon(Icons.add),
          backgroundColor: HomeScreen.primaryDark,
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return context.read<AlertProfivider>().getAlertType();
          },
          child: Consumer<AlertProfivider>(
            builder: (context, provider, child) {
              if (provider.isLoadingAlert) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (provider.alertType.isEmpty) {
                return Center(
                  child: Text(
                    'No events found.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                );
              } else {
                return ListView(
                  children: [
                    ...List.generate(
                        provider.alertType.length,
                        (index) => Card(
                              child: ListTile(
                                onTap: () {},
                                title:
                                    Text(provider.alertType[index].name ?? ""),
                              ),
                            ))
                  ],
                );
              }
            },
            child: Container(),
          ),
        ));
  }

  buildList(
    List<String> list,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        bool isEnable = list.contains(devices[index].id.toString());

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                  activeColor: const Color.fromARGB(255, 7, 97, 97),
                  value: isEnable,
                  onChanged: (value) async {}),
            ],
          ),
        );
      },
    );
  }
}

showLoader(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Timer(Duration(seconds: 5), () {
          Navigator.pop(context); // Close the dialog
        });
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
