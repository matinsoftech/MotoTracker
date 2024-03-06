import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myvtsproject/config/constant.dart';
import 'package:myvtsproject/data/screens/notification_screen.dart';
import 'package:myvtsproject/data/screens/settings_screen.dart';

import 'listscreen.dart';

Color yellowColor = const Color(0xffd79626);
Color whiteColor = const Color(0xffffffff);

class VechileScreen extends StatefulWidget {
  const VechileScreen({super.key});

  @override
  State<VechileScreen> createState() => _VechileScreenState();
}

class _VechileScreenState extends State<VechileScreen> {
  List icon = const [
    (Icons.gesture_sharp),
    (Icons.local_parking),
    (Icons.history_outlined),
    (Icons.electric_bike),
    (Icons.car_rental),
    (Icons.battery_charging_full_sharp),
    (Icons.turn_sharp_right_outlined),
    (Icons.social_distance),
    (Icons.play_circle_fill_sharp),
  ];
  List iconName = [
    'GeoFence',
    'Parking Mode',
    'Parking History',
    'Ride History',
    'Vehicle Info',
    'Battery Info',
    'Trip Summary',
    'Distance Summary',
    'Video PlayBack',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFeaeaeb),
      appBar: AppBar(
        // leading: const DrawerWidget(
        //   isHomeScreen: true,
        // ),
        title: const Text(
          'Vehicle Screen',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffeacb49),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const NotificationsPage();
                        },
                      ));
                    },
                    child: const Icon(Icons.notifications)),
                const SizedBox(width: 10),
                InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const SettingScreen();
                        },
                      ));
                    },
                    child: const Icon(Icons.person)),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 27),
                          SharedTextWidget(
                              text: 'Welcome',
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                          SizedBox(height: 5),
                          SharedTextWidget(text: 'to the world of MotoTracker'),
                          SizedBox(height: 7),
                          SharedTextWidget(
                              text:
                                  'An application to connect your bike and much more')
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        MaterialButton(
                          onPressed: () {},
                          color: const Color(0xff000000),
                          child: const SharedTextWidget(
                              text: 'Add Vehicle', color: Colors.white),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),
                const ContainerWithImage(
                    image: 'assets/images/moto_traccar.png'),
                const SizedBox(height: 30),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of columns
                    crossAxisSpacing: 5.0, // Spacing between columns
                    mainAxisSpacing: 8.0, // Spacing between rows
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 300,
                      child: SharedContainer(
                          iconData: icon[index], text: iconName[index]),
                    );
                  },
                ),
                const SizedBox(height: 30),
                const ContainerWithImage(
                    image: 'assets/images/moto_traccar.png', height: 70),
                const SizedBox(height: 30),
                SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: yellowColor),
                              height: 300,
                              width: 200,
                              child: Image.asset(
                                  'assets/images/moto_traccar.png',
                                  fit: BoxFit.fill)),
                        );
                      },
                    )),
                const SizedBox(height: 30),
                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: whiteColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/question.jpg')),
                      const SizedBox(height: 10),
                      const SharedTextWidget(
                          text: 'Do you have a Question?',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xff1e406d)),
                      const SizedBox(height: 10),
                      const SharedTextWidget(
                          text: 'Get 24*7 resolutions to your queries',
                          fontSize: 18,
                          color: Color(0xff1e406d)),
                      const SizedBox(height: 20),
                      MaterialButton(
                        color: blackColor,
                        onPressed: () {},
                        child: SharedTextWidget(
                            text: 'Start Chatting',
                            color: whiteColor,
                            fontSize: 16),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContainerWithImage extends StatelessWidget {
  const ContainerWithImage({
    super.key,
    this.height = 200,
    required this.image,
  });

  final double height;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: whiteColor),
          child: Image.asset(image)),
    );
  }
}

class SharedContainer extends StatelessWidget {
  const SharedContainer({
    super.key,
    required this.iconData,
    required this.text,
  });

  final IconData iconData;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: whiteColor),
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(iconData, color: yellowColor, size: 50),
              const SizedBox(height: 10),
              Text(text, textAlign: TextAlign.center)
            ]),
      ),
    );
  }
}

class SharedTextWidget extends StatelessWidget {
  const SharedTextWidget(
      {super.key,
      required this.text,
      this.fontSize = 14,
      this.fontWeight = FontWeight.normal,
      this.color = blackColor});
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color),
    );
  }
}
