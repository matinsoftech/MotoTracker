import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myvtsproject/bottom_navigation/bottom_navigation.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/login.dart';
import 'package:myvtsproject/data/screens/check.dart';
import 'package:myvtsproject/data/screens/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 4),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => const CheckIn(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // child: ListView(shrinkWrap: true, children: [
        //   Container(
        //     margin: const EdgeInsets.only(bottom: 20),
        //     width: MediaQuery.of(context).size.width / 3,
        //     height: MediaQuery.of(context).size.height / 8,
        //     child: Image.asset('assets/images/mototraccar_splash.jpg'),
        //   ),
        //   Container(
        //       alignment: Alignment.center,
        //       // margin: EdgeInsets.only(top: 10),
        //       child: const Text(
        //         "Moto Traccar",
        //         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        //       ))
        // ]),
        child: Image.asset('assets/images/mototraccar_splash.jpg'),
      ),
    );
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs!.get('email') != null) {
      if (prefs!.get("popup_notify") == null) {
        prefs!.setBool("popup_notify", true);
      }
      checkLogin();
    } else {
      prefs!.setBool("popup_notify", true);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
      );
    }
  }

  void checkLogin() {
    Future.delayed(const Duration(milliseconds: 5000), () {
      GPSAPIS
          .login(prefs!.get('email'), prefs!.get('password'))
          .then((response) {
        if (response != null) {
          if (response.statusCode == 200) {
            prefs!.setString("user", response.body);
            final user = Login.fromJson(jsonDecode(response.body));
            prefs!.setString('user_api_hash', user.userApiHash!);
            // updateToken();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BottomNavigation()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignIn()),
            );
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignIn()),
          );
        }
      });
    });
  }
}
