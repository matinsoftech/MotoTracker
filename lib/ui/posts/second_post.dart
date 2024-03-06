import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../data/screens/home/home_screen.dart';

class SecondPost extends StatelessWidget {
  const SecondPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        // leading: const DrawerWidget(
        //   isHomeScreen: true,
        // ),
        centerTitle: true,
        title: const Text('The power of GPS tracking devices!'),
        backgroundColor: HomeScreen.primaryDark,
        //bottom: _reusableWidget.bottomAppBar(),
      ),
      body: SingleChildScrollView(
          child: Container(
              margin: const EdgeInsets.all(10),
              child: Html(
                data:
                    '<h2>Curbing Vehicle Theft in Nepal: The Power of GPS Tracking Devices!</h2>'
                    '<p style="text-align: justify;">'
                    'Attention all vehicle owners in Nepal! Are you tired of worrying about your precious vehicles falling into the wrong hands? Say goodbye to sleepless nights and constant anxiety, because GPS tracking devices are here to revolutionize vehicle security in Nepal!'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Here’s how GPS devices are putting a stop to vehicle theft across Nepal:'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Real-Time Tracking: GPS tracking devices provide real-time location updates of your vehicle, allowing you to monitor its movements remotely. In the unfortunate event of theft, you can immediately pinpoint the exact location of your vehicle, enabling law enforcement authorities to take swift action.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Geo-Fencing Alerts: Set up virtual boundaries or geo-fences around your vehicle\'s usual routes or designated areas. If your vehicle deviates from these predefined boundaries without authorization, you receive instant alerts on your mobile device, enabling you to act promptly and prevent theft.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Remote Immobilization: Many advanced GPS tracking devices offer the capability to remotely immobilize the vehicle\'s engine. In the event of theft, you can send a command to disable the engine, bringing the vehicle to a halt and thwarting the thief\'s escape.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Historical Data Logging: GPS devices not only track real-time movements but also store historical data of your vehicle\'s routes and locations. This valuable information aids law enforcement agencies in tracing the vehicle\'s movements and apprehending the culprits responsible for the theft.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Deterrent Effect: The mere presence of a visible GPS tracking device acts as a powerful deterrent to potential thieves. Knowing that the vehicle is equipped with GPS technology makes it less appealing for theft, as perpetrators are aware of the increased likelihood of swift detection and apprehension.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Insurance Benefits: Many insurance companies offer discounted premiums for vehicles equipped with GPS tracking devices. By investing in this technology, not only do you enhance the security of your vehicle, but you also enjoy financial benefits in the form of reduced insurance costs.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Don\'t wait until it\'s too late! Protect your vehicles from theft and safeguard your peace of mind with GPS tracking devices. Whether you own a car, motorcycle, or commercial vehicle, GPS technology offers a proactive and effective solution to combat vehicle theft in Nepal.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Take control of your vehicle\'s security today with GPS tracking technology – because when it comes to protecting what matters most, every second counts! 📞9704504790 🌐https://mototraccar.com/ 🚨🔒 #GPSTracking #VehicleSecurity #Nepal #StopVehicleTheft 🛡🌟'
                    '</p>',
              ))),
    );
  }
}
