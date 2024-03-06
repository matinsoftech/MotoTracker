import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/modelold/devices.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';

class ChangeNavigationIconScreen extends StatefulWidget {
  const ChangeNavigationIconScreen({super.key});

  @override
  ChangeNavigationIconScreenState createState() =>
      ChangeNavigationIconScreenState();
}

class ChangeNavigationIconScreenState
    extends State<ChangeNavigationIconScreen> {
  String? _imagePath;
  ImagePicker imagePicker = ImagePicker();
  String? currentDevice;
  List<DeviceItems> devices = [];
  String? chosenIcon;
  String? firstICon;
  // bool selected = false;
  List<String> defaultIcon = [
    "assets/images/default_icon.jpeg",
  ];

  List<String> assetList = [
    "assets/rotatingicon/icon1.png",
    "assets/rotatingicon/798.png",
    "assets/rotatingicon/799.png",
    "assets/rotatingicon/800.png",
    "assets/rotatingicon/801.png",
    "assets/rotatingicon/5.png",
    "assets/rotatingicon/6.png",
    "assets/rotatingicon/7.png",
    "assets/rotatingicon/8.png",
    "assets/rotatingicon/9.png",
    "assets/rotatingicon/91.png",
    "assets/rotatingicon/92.png",
    "assets/rotatingicon/93.png",
    "assets/rotatingicon/94.png",
    "assets/rotatingicon/100.png",
    "assets/rotatingicon/101.png",
    "assets/rotatingicon/102.png",
  ];

  List<String> deviceicon = [
    "assets/icons/2.png",
    "assets/icons/13.png",
    "assets/icons/14.png",
    "assets/icons/15.png",
    "assets/icons/16.png",
    "assets/icons/17.png",
    "assets/icons/18.png",
    "assets/icons/20.png",
    "assets/icons/22.png",
    "assets/icons/28.png",
    "assets/icons/29.png",
    "assets/icons/31.png",
    "assets/icons/35.png",
    "assets/icons/36.png",
    "assets/icons/37.png",
    "assets/icons/38.png",
    "assets/icons/39.png",
    "assets/icons/41.png",
    "assets/icons/44.png",
  ];

  GPSAPIS api = GPSAPIS();

  getDeviceList() async {
    devices = await StaticVarMethod.devicelist;
    currentDevice = devices[0].name;
    _loadImagePath(currentDevice!);
  }

  @override
  void initState() {
    getDeviceList();

    setState(() {});

    super.initState();
  }

  // Load the saved image path from Shared Preferences
  _loadImagePath(String currentDevice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePath = prefs.getString(currentDevice);
    });
  }

  // Save the selected image path to Shared Preferences
  _saveImagePath(String deviceName, String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(deviceName, imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      appBar: AppBar(
        title: const Text("Change Icon"),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Device: ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              DropdownButton<String>(
                items: devices
                    .map((e) => DropdownMenuItem<String>(
                          value: e.name.toString(),
                          child: Text(
                            e.name.toString(),
                            style: TextStyle(
                              color: HomeScreen.primaryDark,
                            ),
                          ),
                        ))
                    .toList(),
                focusColor: HomeScreen.primaryDark,
                iconDisabledColor: HomeScreen.primaryDark,
                dropdownColor: Colors.white,
                iconEnabledColor: HomeScreen.primaryDark,
                value: currentDevice,
                // _loadImagePath(currentDevice);
                onChanged: (Object? value) async {
                  currentDevice = value.toString();
                  chosenIcon = _loadImagePath(currentDevice!);
                  setState(() {});
                },
              ),
              const SizedBox(
                height: 15,
              ),
              ExpandablePanel(
                header: const Text('Default Icons: ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                collapsed: const Text(''),
                expanded: GridView.count(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  children: defaultIcon.map((asset) {
                    return GestureDetector(
                      onTap: () {
                        // Do something with the asset, such as print its path
                        chosenIcon = asset;
                        _imagePath = null;
                        chosenIcon != null
                            ? _saveImagePath(currentDevice!, chosenIcon!)
                            : _saveImagePath(currentDevice!,
                                'assets/images/default_icon.jpeg');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("$currentDevice icon changed")),
                        );
                        setState(() {});
                      },
                      child: Image.asset(asset),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ExpandablePanel(
                header: const Text('Rotating Icons: ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                collapsed: const SizedBox(),
                expanded: GridView.count(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  children: assetList.map((asset) {
                    return GestureDetector(
                      onTap: () {
                        _imagePath = null;
                        chosenIcon = asset;
                        chosenIcon != null
                            ? _saveImagePath(currentDevice!, chosenIcon!)
                            : _saveImagePath(currentDevice!,
                                'assets/images/default_icon.jpeg');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("$currentDevice icon changed")),
                        );
                        setState(() {});
                      },
                      child: Image.asset(asset),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ExpandablePanel(
                header: const Text('Icons: ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                collapsed: const SizedBox(),
                expanded: GridView.count(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  children: deviceicon.map((asset) {
                    return GestureDetector(
                      onTap: () {
                        _imagePath = null;
                        chosenIcon = asset;
                        chosenIcon != null
                            ? _saveImagePath(currentDevice!, chosenIcon!)
                            : _saveImagePath(currentDevice!,
                                'assets/images/default_icon.jpeg');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("$currentDevice icon changed")),
                        );
                        setState(() {});
                      },
                      child: Image.asset(asset),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text('Selected Icon: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 100,
                width: 100,
                child: _imagePath != null
                    ? Image.asset("$_imagePath")
                    : chosenIcon != null
                        ? Image.asset('$chosenIcon')
                        : Image.asset("assets/images/default_icon.jpeg"),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
