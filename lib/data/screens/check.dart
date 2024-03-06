import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:myvtsproject/bottom_navigation/bottom_navigation.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/login_model.dart';
import 'package:myvtsproject/data/screens/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({super.key});

  @override
  CheckInState createState() => CheckInState();
}

class CheckInState extends State<CheckIn> {
  late LoginModel loginModel;
  String _username = "client@test,in", _password = "87654321";

  //text controlller//
  final TextEditingController _usernameFieldController =
      TextEditingController();
  final TextEditingController _passwordFieldController =
      TextEditingController();

  late SharedPreferences prefs;
  bool isBusy = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    _usernameFieldController.addListener(_emailListen);
    _passwordFieldController.addListener(_passwordListen);

    checkPreference();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();

    _usernameFieldController.text = prefs.getString('email') ?? "";
    _passwordFieldController.text = prefs.getString('password') ?? "";

    if (prefs.get('email') != null) {
      login();
    } else {
      isBusy = false;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
      );
      setState(() {});
    }
  }

  void _emailListen() {
    if (_usernameFieldController.text.isEmpty) {
      _username = "";
    } else {
      _username = _usernameFieldController.text;
    }
  }

  void _passwordListen() {
    if (_passwordFieldController.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFieldController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/mototraccar_splash.jpg'),
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
      ),
    );
  }

  Future<void> login() async {
    GPSAPIS api = GPSAPIS();

    api.getlogin(_username, _password).then((response) {
      // if (response != null) {
      if (response.statusCode == 200) {
        prefs.setBool("popup_notify", true);
        prefs.setString("user", response.body);
        isBusy = false;
        isLoggedIn = true;
        final res = LoginModel.fromJson(json.decode(response.body));
        StaticVarMethod.userAPiHash = res.userApiHash;
        EasyLoading.dismiss();
        prefs.setString('user_api_hash', res.userApiHash!);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavigation()),
        );
      } else if (response.statusCode == 401) {
        isBusy = false;
        isLoggedIn = false;
        EasyLoading.dismiss();
        Fluttertoast.showToast(
            msg: "Login Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
        setState(() {});
      } else if (response.statusCode == 400) {
        isBusy = false;
        isLoggedIn = false;
        if (response.body ==
            "Account has expired - SecurityException (PermissionsManager:259 < *:441 < SessionResource:104 < ...)") {
          setState(() {});
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Failed"),
              content: const Text("Login Failed"),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    EasyLoading.dismiss();
                    Navigator.of(context, rootNavigator: true)
                        .pop(); // dismisses only the dialog and returns nothing
                  },
                  child: const Text("ok"),
                ),
              ],
            ),
          );
        }
      } else {
        isBusy = false;
        isLoggedIn = false;
        EasyLoading.dismiss();
        Fluttertoast.showToast(
            msg: response.body,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {});
      }
      // } else {
      //   isLoggedIn = false;
      //   isBusy = false;
      //   setState(() {});
      //   EasyLoading.dismiss();
      //   Fluttertoast.showToast(
      //       msg: "Error Msg",
      //       toastLength: Toast.LENGTH_SHORT,
      //       gravity: ToastGravity.CENTER,
      //       timeInSecForIosWeb: 1,
      //       backgroundColor: Colors.lightGreen.shade50,
      //       textColor: Colors.white,
      //       fontSize: 16.0);
      // }
    });
  }
}
