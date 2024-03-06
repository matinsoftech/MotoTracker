import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../data/screens/home/home_screen.dart';

class ThirdPost extends StatelessWidget {
  const ThirdPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        // leading: const DrawerWidget(
        //   isHomeScreen: true,
        // ),
        centerTitle: true,
        title: const Text('Introducing cutting edge GPS tracking'),
        backgroundColor: HomeScreen.primaryDark,
        //bottom: _reusableWidget.bottomAppBar(),
      ),
      body: SingleChildScrollView(
          child: Container(
              margin: const EdgeInsets.all(10),
              child: Html(
                data:
                    '<h2> Innovating Nepal: Introducing MotoTraccar\'s Cutting-Edge GPS Tracking   Devices!</h2>'
                    '<p style="text-align: justify;">'
                    'Exciting news for all forward-thinking Nepali businesses and individuals! Say hello to a new era of innovation with MotoTraccar\'s state-of-the-art GPS tracking devices. As Nepal embraces technological advancements, MotoTraccar is at the forefront, revolutionizing vehicle tracking and management like never before.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Here’s why MotoTraccar\'s GPS tracking devices are set to transform Nepal:'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Precision Tracking: MotoTraccar\'s GPS devices offer unparalleled accuracy in tracking vehicle movements. With advanced satellite technology, you can monitor your vehicles\' locations with pinpoint precision, even in the most remote areas of Nepa'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Comprehensive Fleet Management: Whether you own a single vehicle or manage a large fleet, MotoTraccar\'s tracking solutions provide comprehensive fleet management capabilities. From route optimization to fuel consumption monitoring, empower your business with data-driven insights for enhanced efficiency and profitability.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Customized Solutions: MotoTraccar understands that every business is unique. That\'s why they offer customizable tracking solutions tailored to your specific needs. Whether you\'re in transportation, logistics, or construction, MotoTraccar has the perfect GPS solution to streamline your operations'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Real-Time Alerts: Stay informed and in control at all times with real-time alerts from MotoTraccar\'s GPS devices. Receive instant notifications for events such as unauthorized vehicle movements, speeding, or maintenance reminders, ensuring proactive management of your assets'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Seamless Integration: MotoTraccar\'s tracking platform seamlessly integrates with your existing systems and workflows, making adoption smooth and hassle-free. With user-friendly interfaces and robust backend support, managing your fleet has never been easier'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Reliability and Support: MotoTraccar is committed to providing unmatched reliability and support to its customers in Nepal. With dedicated customer service and technical assistance, you can trust MotoTraccar to keep your vehicles safe and your operations running smoothly.'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Join the innovation revolution in Nepal with MotoTraccar\'s cutting-edge GPS tracking devices. Whether you\'re a business owner seeking to optimize fleet operations or an individual looking to enhance the security of your personal vehicle, MotoTraccar has the solution you need'
                    '</p>'
                    '<p style="text-align: justify;">'
                    'Don\'t wait any longer to embrace the future of vehicle tracking and management. Contact MotoTraccar today and take the first step towards a more efficient, secure, and innovative Nepal! 📞9704504790 🌐https://mototraccar.com/ 🚨🔒🚗🛰 #Innovation #GPSTracking #Nepal #MotoTraccar 🌟🚚'
                    '</p>',
              ))),
    );
  }
}
