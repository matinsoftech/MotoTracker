import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../data/screens/home/home_screen.dart';

class FirstPost extends StatelessWidget {
  const FirstPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        // leading: const DrawerWidget(
        //   isHomeScreen: true,
        // ),
        centerTitle: true,
        title: const Text('Why we need gps device?'),
        backgroundColor: HomeScreen.primaryDark,
        //bottom: _reusableWidget.bottomAppBar(),
      ),
      body: SingleChildScrollView(
          child: Container(
              margin: const EdgeInsets.all(10),
              child: Html(
                data: '<h2>why we need gps device?</h2>'
                    '<p style="text-align: justify;">'
                    '🚗📍 Attention Vehicle Owners in Nepal! 🇳🇵 Are you looking for peace of mind while your vehicles are on the road? Introducing MOTO TRACCAR | Your Ultimate GPS Tracking Solution! 🛰'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'In a country like Nepal where diverse terrains and challenging roads are part of everyday travel, ensuring the safety and security of your vehicles is paramount. With GPS tracking devices, you can now monitor and manage your vehicles with ease and confidence.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Here’s why you need a GPS tracking device for your vehicle in Nepal:'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Enhanced Security: Keep your vehicles safe from theft and unauthorized use. GPS tracking allows you to pinpoint the exact location of your vehicle in real-time, enabling swift recovery in case of theft.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Fleet Management: For businesses operating fleets of vehicles, GPS tracking devices provide invaluable insights into vehicle usage, route optimization, and driver behavior. Increase efficiency and reduce operational costs with better fleet management.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Peace of Mind: Whether it’s your personal car or a commercial vehicle, knowing its whereabouts at all times brings peace of mind. With GPS tracking, you can monitor vehicle movement remotely, even in the most remote areas of Nepal.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Emergency Assistance: In case of accidents or emergencies, GPS tracking devices can be lifesaving. They allow for quick response and dispatch of assistance to the exact location of the vehicle, potentially saving lives.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Compliance: With regulations evolving, certain industries and vehicle types might require GPS tracking for compliance purposes. Stay ahead of regulatory requirements by installing a GPS tracking device today.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Don’t wait until it’s too late! Invest in the safety and security of your vehicles with GPS tracking technology. Whether you own a private car, a commercial truck, or a fleet of vehicles, GPS tracking devices offer unparalleled benefits that are essential for modern vehicle ownership.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Contact us today to learn more about how GPS tracking devices can benefit you and your vehicles in Nepal! 📞9704504790 🌐https://mototraccar.com/  #GPSTracking #VehicleSecurity #Nepal #SafetyFirst 🚦🔒'
                    '</p>',
              ))),
    );
  }
}
