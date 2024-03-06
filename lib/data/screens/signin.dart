import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:myvtsproject/bottom_navigation/bottom_navigation.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/model/login_model.dart';
import 'package:myvtsproject/data/screens/contact%20screen/contact_screen.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  bool _obscureText = true;
  IconData _iconVisible = Icons.visibility_off;
  final Color _mainColor = const Color.fromARGB(255, 7, 97, 97);
  final Color _underlineColor = const Color(0xFFCCCCCC);
  late LoginModel loginModel;

  //text controlller//
  final TextEditingController _usernameFieldController =
      TextEditingController();
  final TextEditingController _passwordFieldController =
      TextEditingController();

  late SharedPreferences prefs;
  bool isBusy = true;
  bool isLoggedIn = false;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      if (_obscureText == true) {
        _iconVisible = Icons.visibility_off;
      } else {
        _iconVisible = Icons.visibility;
      }
    });
  }

  void pushNotificationsInitialization(String email) async {
    await FirebaseMessaging.instance.subscribeToTopic(email);
  }

  @override
  void initState() {
    checkPreference();
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    _usernameFieldController.text =
        prefs.getString('email') ?? StaticVarMethod.defaultUserName;
    _passwordFieldController.text =
        prefs.getString('password') ?? StaticVarMethod.defaultPassword;

    if (prefs.get('email') != null) {
      login();
    } else {
      isBusy = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Platform.isIOS
            ? SystemUiOverlayStyle.light
            : const SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.light),
        child: Stack(
          children: <Widget>[
            Container(
                margin: EdgeInsets.fromLTRB(
                    0, MediaQuery.of(context).size.height / 10, 0, 0),
                alignment: Alignment.topCenter,
                child:
                    Image.asset('assets/images/moto_traccar.png', height: 100)),
            ListView(
              children: <Widget>[
                // create form login
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.fromLTRB(
                      32, MediaQuery.of(context).size.height / 3.0 - 72, 32, 0),
                  color: Colors.white,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 40,
                        ),
                        const Center(
                          child: Text(
                            'SIGN IN',
                            style: TextStyle(
                                color: HomeScreen.primaryDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: _usernameFieldController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (String value) {},
                          decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[600]!)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: _underlineColor),
                              ),
                              labelText: 'Email or phone',
                              labelStyle: TextStyle(color: Colors.grey[700])),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: _passwordFieldController,
                          obscureText: _obscureText,
                          onChanged: (String value) {},
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[600]!)),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _underlineColor),
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.grey[700]),
                            suffixIcon: IconButton(
                                icon: Icon(_iconVisible,
                                    color: Colors.grey[700], size: 20),
                                onPressed: () {
                                  _toggleObscureText();
                                }),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) =>
                                    HomeScreen.primaryDark,
                              ),
                              overlayColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            onPressed: () {
                              EasyLoading.show(status: 'loading...');
                              //_globalFunction.showProgressDialog(context);
                              if (_usernameFieldController.text.isEmpty) {
                                Fluttertoast.showToast(
                                    msg:
                                        '_username == null || _username.isEmpty',
                                    toastLength: Toast.LENGTH_SHORT);
                              } else if (_passwordFieldController
                                  .text.isEmpty) {
                                Fluttertoast.showToast(
                                    msg:
                                        '_password == null || _password.isEmpty',
                                    toastLength: Toast.LENGTH_SHORT);
                              } else {
                                login();
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Forgot password? ",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const ContactScreen()));
                      },
                      child: const Text(
                        "Contact us",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xff776605),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    GPSAPIS api = GPSAPIS();
    print('Login button pressed');

    api
        .getlogin(_usernameFieldController.text, _passwordFieldController.text)
        .then((response) {
      if (response != null) {
        print(response.body);
        if (response.statusCode == 200) {
          pushNotificationsInitialization(
              LoginModel.fromJson(jsonDecode(response.body))
                  .data!
                  .id
                  .toString());
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
            MaterialPageRoute(
                // builder: (context) => BottomNavigation( loginModel: response)),
                builder: (context) => const BottomNavigation()),
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
      } else {
        isLoggedIn = false;
        isBusy = false;
        setState(() {});
        EasyLoading.dismiss();
        Fluttertoast.showToast(
            msg: "Error Msg",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.lightGreen.shade50,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }
}
