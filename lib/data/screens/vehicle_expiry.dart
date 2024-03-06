import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';

import '../modelold/devices.dart';
import 'home/home_screen.dart';

class VehicleExpiry extends StatefulWidget {
  const VehicleExpiry({super.key});

  @override
  State<VehicleExpiry> createState() => _VehicleExpiryState();
}

class _VehicleExpiryState extends State<VehicleExpiry> {
  late List<DeviceItems> devicelist;
  @override
  void initState() {
    devicelist = StaticVarMethod.devicelist;
    super.initState();
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
          // leading: const DrawerWidget(
          //   isHomeScreen: true,
          // ),
          title: const Text(
            'Subscription Expiry',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: HomeScreen.primaryDark,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: devicelist.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.car_crash_outlined,
                      color: Color(0xffd79626),
                      size: 40,
                    ),
                    title: Text(devicelist[index].name),
                    subtitle: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.clock,
                          color: Color(0xffd79626),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(devicelist[index]
                            .deviceData!
                            .expirationDate
                            .toString()),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }
}
