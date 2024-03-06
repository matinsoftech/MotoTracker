import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeCustomizationScreen extends StatefulWidget {
  const HomeCustomizationScreen({super.key});

  @override
  State<HomeCustomizationScreen> createState() =>
      _HomeCustomizationScreenState();
}

class _HomeCustomizationScreenState extends State<HomeCustomizationScreen> {
  final List<SummaryToggle> summaries = [
    SummaryToggle(
        imagePath: "assets/images/thief.jpeg",
        label: "Anti theft - parking mode"),
    SummaryToggle(imagePath: "assets/images/trip.jpg", label: "Travel Summary"),
    SummaryToggle(imagePath: "assets/images/report.png", label: "Report"),
    SummaryToggle(
        imagePath: "assets/images/icons8-location-100.png",
        label: "Daily Travel Details"),
    SummaryToggle(
        imagePath: "assets/images/movingdurationicon.png",
        label: "Travel Details"),
    SummaryToggle(
        imagePath: "assets/images/stopdurationicon.png",
        label: "Stoppage Summary"),
    SummaryToggle(
        imagePath: "assets/images/distance.png", label: "Distance Summary"),
    SummaryToggle(
        imagePath: "assets/images/markersicon.png", label: "Live Tracking"),
    SummaryToggle(
        imagePath: "assets/images/icons8-info-popup-100.png",
        label: "Vehicle Status"),
    SummaryToggle(
        imagePath: "assets/images/alarmnotification96by96.png",
        label: "Alerts"),
    SummaryToggle(
        imagePath: "assets/images/icons8-clock-100.png",
        label: "Subscription Expiry"),
    SummaryToggle(imagePath: "assets/images/documents.jpg", label: "Documents"),
    SummaryToggle(
        imagePath: "assets/images/termsandconditions.png",
        label: "Terms and Conditions"),
    SummaryToggle(imagePath: "assets/images/privacy.png", label: "Privacy"),
    SummaryToggle(
      imagePath: "assets/images/vehicle_stop.jpg",
      label: "Vehicle Immobilize",
    ),
  ];

  SharedPreferences? _prefs;

  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width / 10;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
        title: const Text("Home Customisation Screen"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: _prefs != null
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: summaries.length,
                  itemBuilder: (context, index) {
                    bool isOn =
                        _prefs!.getBool(summaries[index].label) ?? false;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Image.asset(summaries[index].imagePath,
                                  height: imageSize, width: imageSize),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                summaries[index].label,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          CupertinoSwitch(
                            activeColor: HomeScreen.primaryDark,
                            value: isOn,
                            onChanged: (value) {
                              isOn = !isOn;
                              _prefs!.setBool(summaries[index].label, isOn);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}

class SummaryToggle {
  String imagePath;
  String label;

  SummaryToggle({
    required this.imagePath,
    required this.label,
  });
}
