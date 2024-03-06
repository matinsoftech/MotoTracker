import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myvtsproject/config/apps/ecommerce/constant.dart';
import 'package:myvtsproject/data/model/user.dart';
import 'package:myvtsproject/data/screens/change_navigation_icon_screen.dart';
import 'package:myvtsproject/data/screens/contact%20screen/contact_screen.dart';
import 'package:myvtsproject/data/screens/customize_notification.dart';
import 'package:myvtsproject/data/screens/geofences/GeofenceList.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';
import 'package:myvtsproject/data/screens/parking_screen.dart';
import 'package:myvtsproject/data/screens/playback.dart';
import 'package:myvtsproject/data/screens/privacy_policy.dart';
import 'package:myvtsproject/data/screens/reports/inside_report.dart';
import 'package:myvtsproject/data/screens/signin.dart';
import 'package:myvtsproject/data/screens/terms_and_conditions.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myvtsproject/data/data_sources.dart';

import 'customize home/home_customisation_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  // initialize reusable widget
  // final _reusableWidget = ReusableWidget();
  late User user;
  late SharedPreferences prefs;
  bool isLoading = true;
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _retypePassword = TextEditingController();
  bool showFuelSummary = false;
  String email = "";
  String subscriptionExpiration = "";
  @override
  void initState() {
    getUser();
    checkPreference();
    super.initState();
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
    showFuelSummary = prefs.getBool("showFuelSummary") ?? false;
  }

  getUser() async {
    GPSAPIS.getUserData().then((value) => {
          isLoading = false,
          user = value!,
          email = value.email.toString(),
          subscriptionExpiration = value.subscriptionExpiration.toString(),
          setState(() {})
        });
    setState(() {});
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
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,

        /* iconTheme: IconThemeData(
          color: GlobalStyle.appBarIconThemeColor,
        ),*/
        //systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,
        // Noteeee
        // centerTitle: true,
        // title: Text('Settings', style: TextStyle(
        //   color: Colors.black,
        //   fontWeight: FontWeight.bold
        // ),
        // ),
        // backgroundColor: GlobalStyle.appBarBackgroundColor, ///Jenish comment
        //bottom: _reusableWidget.bottomAppBar(),
      ),
      body: ListView(
        children: [
          _createAccountInformation(),
          _buildTotalSummary(),
        ],
      ),
    );
  }

  Widget _createAccountInformation() {
    final double profilePictureSize = MediaQuery.of(context).size.width / 4;
    return Container(
        margin: const EdgeInsets.all(5),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          //elevation: 2,
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: profilePictureSize,
                height: profilePictureSize,
                padding: const EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () {
                    Fluttertoast.showToast(
                        msg: 'Click picture', toastLength: Toast.LENGTH_SHORT);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: profilePictureSize,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xffdfdedf),
                      radius: profilePictureSize - 4,
                      child: Hero(
                        tag: 'profilePicture',
                        child: ClipOval(
                          child: Image.asset("assets/images/moto_traccar.png",
                              height: profilePictureSize - 4,
                              width: profilePictureSize - 4),

                          //child: buildCacheNetworkImage(width: profilePictureSize-4, height: profilePictureSize-4, url: GLOBAL_URL+'/assets/images/user/avatar.png')
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              (email.isNotEmpty)
                  ? Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 8,
                          ),
                          GestureDetector(
                            onTap: () {
                              Fluttertoast.showToast(
                                  msg:
                                      'Click account information / user profile',
                                  toastLength: Toast.LENGTH_SHORT);
                            },
                            child: Row(
                              children: const [
                                /*  Text(''+expiration_date, style: TextStyle(
                          fontSize: 14, color: Colors.grey
                      )),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(Icons.chevron_right, size: 20, color: SOFT_GREY)*/
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),
            ],
          ),
        ));
  }

  Widget _buildTotalSummary() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TermsAndConditions()),
              );
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
                //margin: EdgeInsets.only(bottom: 16),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    /* border: Border.all(
                        width: 1,
                        color: Colors.grey[300]!
                    ),*/
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.file_copy_rounded,
                            size: 30, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Terms & Conditions',
                            style: TextStyle(
                                color: charcoal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Icon(Icons.chevron_right, size: 30, color: softGrey),
                  ],
                )),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicy()),
              );
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.grey[100]!),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.privacy_tip, size: 30, color: Colors.yellow),
                        SizedBox(width: 12),
                        Text('Privacy',
                            style: TextStyle(
                                color: charcoal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Icon(Icons.chevron_right, size: 30, color: softGrey),
                  ],
                )),
          ),
          // GestureDetector(
          //   behavior: HitTestBehavior.translucent,
          //   onTap: () {
          //     changePasswordDialog();
          //   },
          //   child: Container(
          //       alignment: Alignment.center,
          //       padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
          //       //margin: EdgeInsets.only(bottom: 16),
          //       decoration: const BoxDecoration(
          //           color: Colors.white,
          //           /* border: Border.all(
          //               width: 1,
          //               color: Colors.grey[300]!
          //           ),*/
          //           borderRadius: BorderRadius.only(
          //               topLeft: Radius.circular(10),
          //               topRight: Radius.circular(10))),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Row(
          //             children: const [
          //               Icon(Icons.change_circle, size: 30, color: Colors.red),
          //               SizedBox(width: 12),
          //               Text('Change Password',
          //                   style: TextStyle(
          //                       color: charcoal, fontWeight: FontWeight.bold)),
          //             ],
          //           ),
          //           const Icon(Icons.chevron_right, size: 30, color: softGrey),
          //         ],
          //       )),
          // ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InsideReport()),
              );
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.grey[100]!),
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.stacked_bar_chart,
                            size: 30, color: Colors.blueGrey),
                        SizedBox(width: 12),
                        Text('Reports',
                            style: TextStyle(
                                color: charcoal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Icon(Icons.chevron_right, size: 30, color: softGrey),
                  ],
                )),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChangeNavigationIconScreen()),
              );
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.grey[100]!),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.invert_colors_on_outlined,
                            size: 30, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Change Icons',
                            style: TextStyle(
                                color: charcoal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Icon(Icons.chevron_right, size: 30, color: softGrey),
                  ],
                )),
          ),

          const SizedBox(height: 4),

          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
              //margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1, color: Colors.grey[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_gas_station,
                          size: 30, color: Colors.amber.shade700),
                      const SizedBox(width: 12),
                      const Text('Show Fuel Summary',
                          style: TextStyle(
                              color: charcoal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Switch(
                    value: showFuelSummary,
                    onChanged: (value) {
                      setState(() {
                        showFuelSummary = !showFuelSummary;
                        prefs.setBool("showFuelSummary", showFuelSummary);
                      });
                    },
                  ),
                ],
              )),

          // Customization Notification
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CustomizeNotification()),
              );
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
                //margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.grey[100]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications,
                            size: 30, color: Colors.amber.shade700),
                        const SizedBox(width: 12),
                        const Text('Add Alert',
                            style: TextStyle(
                                color: charcoal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                )),
          ),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GeofenceListPage()),
              );
            },
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
                //margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.grey[100]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications,
                            size: 30, color: Colors.amber.shade700),
                        const SizedBox(width: 12),
                        const Text('GeoFence',
                            style: TextStyle(
                                color: charcoal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                )),
          ),

          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomeCustomizationScreen()),
                );
              },
              child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.grey[100]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.dashboard_customize,
                              size: 30, color: Colors.pinkAccent),
                          SizedBox(width: 12),
                          Text('Home Customization Settings',
                              style: TextStyle(
                                  color: charcoal,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Icon(Icons.chevron_right,
                          size: 30, color: softGrey),
                    ],
                  ))),

          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParkingScreen()),
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1, color: Colors.grey[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/thief.jpeg",
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Anti theft - parking mode',
                        style: TextStyle(
                          color: charcoal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 30,
                    color: softGrey,
                  ),
                ],
              ),
            ),
          ),
          // GestureDetector(
          //   behavior: HitTestBehavior.translucent,
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => const PermissionScreen()),
          //     );
          //   },
          //   child: Container(
          //     alignment: Alignment.center,
          //     padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
          //     decoration: BoxDecoration(
          //         color: Colors.white,
          //         border: Border.all(width: 1, color: Colors.grey[100]!)),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Row(
          //           children: const [
          //             Icon(Icons.security,
          //                 size: 30, color: Colors.deepOrangeAccent),
          //             SizedBox(width: 12),
          //             Text('Permissions',
          //                 style: TextStyle(
          //                     color: charcoal, fontWeight: FontWeight.bold)),
          //           ],
          //         ),
          //         const Icon(Icons.chevron_right, size: 30, color: softGrey),
          //       ],
          //     ),
          //   ),
          // ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Share.share(
                  'http://play.google.com/store/apps/details?id=ms.pioneer.merogadi');
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.grey[100]!)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.share, size: 30, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Share App',
                          style: TextStyle(
                              color: charcoal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Icon(Icons.chevron_right, size: 30, color: softGrey),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactScreen()),
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.grey[100]!),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.contact_support,
                          size: 30, color: Colors.yellow),
                      SizedBox(width: 12),
                      Text('Support',
                          style: TextStyle(
                              color: charcoal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Icon(Icons.chevron_right, size: 30, color: softGrey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              prefs.clear();
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignIn()),
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.grey[300]!),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(10) //         <--- border radius here
                      )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.logout, size: 30, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      const Text('Sign Out',
                          style: TextStyle(
                              color: charcoal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Icon(Icons.chevron_right, size: 30, color: softGrey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changePasswordDialog() {
    Dialog simpleDialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return SizedBox(
          height: 250.0,
          width: 400.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        TextField(
                          controller: _newPassword,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'New Password'),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _retypePassword,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Retype Password'),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            ElevatedButton(
                              //color: Colors.red,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              // color: CustomColor.primaryColor,
                              onPressed: () {
                                updatePassword();
                              },
                              child: const Text(
                                'Ok',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) => simpleDialog,
    );
  }

  void updatePassword() {
    if (_newPassword.text == _retypePassword.text) {
      // Map<String, String> requestBody = <String, String>{
      //   'password': _newPassword.text
      // };
      // gpsapis.changePassword(_newPassword.toString()).then((value) => {
      //   AlertDialogCustom().showAlertDialog(
      //       context,'Password Updated Successfully','Change Password','ok')
      // });
      var result = GPSAPIS.changePassword(_newPassword.text.toString());
      if (result != null) {
        AlertDialogCustom().showAlertDialog(
            context, 'Password Updated Successfully', 'Change Password', 'ok');
      }
    } else {
      AlertDialogCustom()
          .showAlertDialog(context, 'Password Not Same', 'Failed', 'ok');
    }
  }
}

//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:myvtsproject/config/static.dart';
// import 'package:myvtsproject/data/datasources.dart';
// import 'package:myvtsproject/data/model/events.dart';
// import 'package:settings_ui/settings_ui.dart';
//
//
//
// class settingscreen extends StatefulWidget {
//
//   @override
//   _settingscreenState createState() => _settingscreenState();
// }
//
// /*class _settingscreenState extends State<settingscreen> {
//   bool valNotify1 = true;
//   bool valNotify2 = false;
//   bool valNotify3 = false;
//   onChangeFunction1(bool newValue1) {
//     setState(() {
//       valNotify1 = newValue1;
//     });
//   }
//
//   onChangeFunction2(bool newValue2) {
//     setState(() {
//       valNotify2 = newValue2;
//     });
//   }
//
//   onChangeFunction3(bool newValue3) {
//     setState(() {
//       valNotify3 = newValue3;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Settings UI", style: TextStyle(fontSize: 22)),
//         leading: IconButton(
//           onPressed: () {},
//           icon: const Icon(
//             Icons.print,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(10),
//         child: ListView(
//           children: [
//             const SizedBox(height: 40),
//             Row(
//               children: const [
//                 Icon(
//                   Icons.person,
//                   color: Colors.blue,
//                 ),
//                 SizedBox(width: 10),
//                 Text(
//                   "Account",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 )
//               ],
//             ),
//             const Divider(height: 20, thickness: 1),
//             const SizedBox(height: 10),
//             buildAccountOption(context, "Change Password"),
//             buildAccountOption(context, "Context Setting"),
//             buildAccountOption(context, "Social"),
//             buildAccountOption(context, "Language"),
//             buildAccountOption(context, "Privacy and Security"),
//             const SizedBox(height: 40),
//             Row(
//               children: const [
//                 Icon(Icons.volume_up_outlined, color: Colors.blue),
//                 SizedBox(width: 10),
//                 Text("Notifications",
//                     style:
//                     TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//               ],
//             ),
//             const Divider(height: 20, thickness: 1),
//             buildNotificationOption(
//                 "Theme Dark", valNotify1, onChangeFunction1),
//             buildNotificationOption(
//                 "Account Active", valNotify2, onChangeFunction2),
//             buildNotificationOption(
//                 "Opportunity", valNotify3, onChangeFunction3),
//             const SizedBox(height: 50),
//             Center(
//               child: OutlinedButton(
//                 style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal:
//                         40) */
// /*
//                                 shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20)
//                         )*/
// /*
//                 ),
//                 onPressed: () {},
//                 child: const Text("SIGN OUT",
//                     style: TextStyle(
//                       fontSize: 16,
//                       letterSpacing: 2.2,
//                       color: Colors.black,
//                     )),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Padding buildNotificationOption(
//       String title, bool value, Function onChangeMethod) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title,
//               style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[600])),
//           Transform.scale(
//             scale: 0.7,
//             child: CupertinoSwitch(
//               activeColor: Colors.blue,
//               trackColor: Colors.grey,
//               value: value,
//               onChanged: (bool newValue) {
//                 onChangeMethod(newValue);
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   GestureDetector buildAccountOption(BuildContext context, String title) {
//     return GestureDetector(
//       onTap: () {
//         showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text(title),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: const [
//                     Text("Option1"),
//                     Text("Option2"),
//                   ],
//                 ),
//                 actions: [
//                   TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text("close"))
//                 ],
//               );
//             });
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(title,
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey[600])),
//             const Icon(
//               Icons.person,
//               color: Colors.blue,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }*/
//
// class _settingscreenState extends State<settingscreen> {
//
//   bool useCustomTheme = false;
//
//   final platformsMap = <DevicePlatform, String>{
//     DevicePlatform.device: 'Default',
//     DevicePlatform.android: 'Android',
//     DevicePlatform.iOS: 'iOS',
//     DevicePlatform.web: 'Web',
//     DevicePlatform.fuchsia: 'Fuchsia',
//     DevicePlatform.linux: 'Linux',
//     DevicePlatform.macOS: 'MacOS',
//     DevicePlatform.windows: 'Windows',
//   };
//   DevicePlatform selectedPlatform = DevicePlatform.device;
//
//   @override
//   initState() {
//     super.initState();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     //return noNotificationScreen();
//     return Scaffold(
//       appBar: appBar(),
//       body:  SettingsList(
//         platform: selectedPlatform,
//         lightTheme: !useCustomTheme
//             ? null
//             : SettingsThemeData(
//           dividerColor: Colors.red,
//           tileDescriptionTextColor: Colors.yellow,
//           leadingIconsColor: Colors.pink,
//           settingsListBackground: Colors.white,
//           settingsSectionBackground: Colors.green,
//           settingsTileTextColor: Colors.tealAccent,
//           tileHighlightColor: Colors.blue,
//           titleTextColor: Colors.cyan,
//           trailingTextColor: Colors.deepOrangeAccent,
//         ),
//         darkTheme: !useCustomTheme
//             ? null
//             : SettingsThemeData(
//           dividerColor: Colors.pink,
//           tileDescriptionTextColor: Colors.blue,
//           leadingIconsColor: Colors.red,
//           settingsListBackground: Colors.grey,
//           settingsSectionBackground: Colors.tealAccent,
//           settingsTileTextColor: Colors.green,
//           tileHighlightColor: Colors.yellow,
//           titleTextColor: Colors.cyan,
//           trailingTextColor: Colors.orange,
//         ),
//         sections: [
//           SettingsSection(
//             title: Text('Common'),
//
//             tiles: <SettingsTile>[
//               SettingsTile.navigation(
//                 leading: Icon(Icons.language),
//                 title: Text('Language'),
//                 trailing:Icon(Icons.arrow_forward_ios_outlined),
//               ),
//               SettingsTile.navigation(
//                 leading: Icon(Icons.cloud_outlined),
//                 title: Text('Environment'),
//                 value: Text('Production'),
//               ),
//               SettingsTile.navigation(
//                 leading: Icon(Icons.devices_other),
//                 title: Text('Platform'),
//                 onPressed: (context) async {
//                 /*final platform = await Navigation.navigateTo<DevicePlatform>(
//                     context: context,
//                     style: NavigationRouteStyle.material,
//                     screen: PlatformPickerScreen(
//                       platform: selectedPlatform,
//                       platforms: platformsMap,
//                     ),
//                   );*/
//
//                /*   if (platform != null && platform is DevicePlatform) {
//                     setState(() {
//                       selectedPlatform = platform;
//                     });
//                   }*/
//                 },
//                 value: Text("platformsMap[selectedPlatform]"),
//               ),
//               SettingsTile.switchTile(
//                 onToggle: (value) {
//                   setState(() {
//                     useCustomTheme = value;
//                   });
//                 },
//                 initialValue: useCustomTheme,
//                 leading: Icon(Icons.format_paint),
//                 title: Text('Enable custom theme'),
//               ),
//             ],
//           ),
//           SettingsSection(
//             title: Text('Account'),
//             tiles: <SettingsTile>[
//               SettingsTile.navigation(
//                 leading: Icon(Icons.phone),
//                 title: Text('Phone number'),
//               ),
//               SettingsTile.navigation(
//                 leading: Icon(Icons.mail),
//                 title: Text('Email'),
//                 enabled: false,
//               ),
//               SettingsTile.navigation(
//                 leading: Icon(Icons.logout),
//                 title: Text('Sign out'),
//               ),
//             ],
//           ),
//           SettingsSection(
//             title: Text('Security'),
//             tiles: <SettingsTile>[
//               SettingsTile.switchTile(
//                 onToggle: (_) {},
//                 initialValue: true,
//                 leading: Icon(Icons.phonelink_lock),
//                 title: Text('Lock app in background'),
//               ),
//               SettingsTile.switchTile(
//                 onToggle: (_) {},
//                 initialValue: true,
//                 leading: Icon(Icons.fingerprint),
//                 title: Text('Use fingerprint'),
//                 description: Text(
//                   'Allow application to access stored fingerprint IDs',
//                 ),
//               ),
//               SettingsTile.switchTile(
//                 onToggle: (_) {},
//                 initialValue: true,
//                 leading: Icon(Icons.lock),
//                 title: Text('Change password'),
//               ),
//               SettingsTile.switchTile(
//                 onToggle: (_) {},
//                 initialValue: true,
//                 leading: Icon(Icons.notifications_active),
//                 title: Text('Enable notifications'),
//               ),
//             ],
//           ),
//           SettingsSection(
//             title: Text('Misc'),
//             tiles: <SettingsTile>[
//               SettingsTile.navigation(
//                 leading: Icon(Icons.description),
//                 title: Text('Terms of Service'),
//               ),
//               SettingsTile.navigation(
//                 leading: Icon(Icons.collections_bookmark),
//                 title: Text('Open source license'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//
//   }
//
//   PreferredSizeWidget  appBar(){
//     return AppBar(
//       leading: IconButton(
//         icon: Icon(Icons.arrow_back, color: Colors.white),
//         onPressed: () =>   Navigator.pop(context,true),
//         //Navigator.of(context,rootNavigator: true).pop(),
//       ),
//       title: Text("Notification"),
//       centerTitle: true,
//     );
//   }
//
//
//
// }
