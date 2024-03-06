import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myvtsproject/config/apps/ecommerce/constant.dart';
import 'package:myvtsproject/config/apps/food_delivery/global_style.dart';

import 'package:permission_handler/permission_handler.dart';

import 'home/home_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  PermissionScreenState createState() => PermissionScreenState();
}

class PermissionScreenState extends State<PermissionScreen> {
  // initialize reusable widget
  late bool _locPermission = false;
  late bool _storPermission = false;
  // final _reusableWidget = ReusableWidget();
  @override
  void initState() {
    permissionStatus();
    // AppSettings.openAppSettings();
    super.initState();
  }

  permissionStatus() async {
    PermissionStatus locationStatus = await Permission.location.status;
    PermissionStatus storageStatus = await Permission.storage.status;
    setState(() {
      if (locationStatus == PermissionStatus.granted) {
        _locPermission = true;
      } else {
        _locPermission = false;
      }
      if (storageStatus == PermissionStatus.granted) {
        _storPermission = true;
      } else {
        _storPermission = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: customFloatingSupportButton(context),
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: GlobalStyle.appBarIconThemeColor,
          ),
          systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,
          centerTitle: true,
          title: const Text('Permission', style: GlobalStyle.appBarTitle),
          backgroundColor: GlobalStyle.appBarBackgroundColor,
          //bottom: _reusableWidget.bottomAppBar(),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(CupertinoIcons.location,
                            size: 30, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        const Text('location',
                            style: TextStyle(
                                color: charcoal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Switch(
                      value: _locPermission,
                      onChanged: (value) {
                        setState(() {
                          _locPermission = !_locPermission;
                          AppSettings.openAppSettings();
                          permissionStatus();
                        });
                      },
                    ),
                  ],
                )),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage,
                            size: 30, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        const Text('Storage',
                            style: TextStyle(
                                color: charcoal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Switch(
                      value: _storPermission,
                      onChanged: (value) {
                        setState(() {
                          _storPermission = !_storPermission;
                          AppSettings.openAppSettings();
                          permissionStatus();
                        });
                      },
                    ),
                  ],
                )),
          ],
        ));
  }
}
