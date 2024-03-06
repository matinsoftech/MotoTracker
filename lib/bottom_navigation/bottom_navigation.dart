import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';
import 'package:myvtsproject/data/screens/mainmapscreen.dart';
import 'package:myvtsproject/data/screens/notification_screen.dart';
import 'package:myvtsproject/data/screens/settings_screen.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:flutter/material.dart';
import 'package:myvtsproject/data/screens/vechile_screen.dart';
import 'package:upgrader/upgrader.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/model/User.dart';
import '../data/screens/document screen/document_screen.dart';
import '../data/screens/reports/report_selection.dart';
import '../data/screens/signin.dart';
import '../data/screens/vehicle_expiry.dart';

class BottomNavigation extends StatefulWidget {
  final int? selectedPage;
  final int? currentTab;
  final String? currentFilter;

  const BottomNavigation(
      {super.key, this.selectedPage, this.currentTab, this.currentFilter});
  @override
  BottomNavigationState createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation> {
  final Color _color1 = Colors.white;
  final Color _color2 = const Color(0xFFA1A1A1);

  Color blackColor = const Color(0xff000000);

  late PageController _pageController;
  int _currentIndex = 0;
//added by mahesh kattel to get user and make drawer
  late User user;
  bool isLoading = true;
  String email = "";
  String username = "";
  String expirationDate = "";
  late SharedPreferences prefs;
  //added code ends here

  // Pages if you click bottom navigation
  List<Widget> _contentPages = [];

  @override
  void didChangeDependencies() {
    ListScreen.currentFilter = widget.currentFilter ?? "All";
    _contentPages = <Widget>[
      //listscreen(loginModel : ""),
      const Home(
        currentPage: HomeScreen(),
      ),
      // Home(
      //   currentPage: ListScreen(currentTab: widget.currentTab ?? 0),
      //   // currentPage: VechileScreen(),
      // ),
      const Home(
        currentPage: MainMapScreen(),
      ),
      const Home(
        currentPage: MainMapScreen(),
      ),

      // const Home(
      //   currentPage: SettingScreen(),
      // ),
      Home(
        currentPage: ListScreen(currentTab: widget.currentTab ?? 0),
        // currentPage: VechileScreen(),
      ),
    ];
    super.didChangeDependencies();
  }

  @override
  void initState() {
    getUser();
    checkPreference();
    // set initial pages for navigation to home page
    _pageController = PageController(initialPage: widget.selectedPage ?? 0);
    _pageController.addListener(_handleTabSelection);
    if (widget.selectedPage != null && widget.selectedPage == 4) {
      _currentIndex = (widget.selectedPage! - 1);
    } else if (widget.selectedPage != null) {
      _currentIndex = widget.selectedPage!;
    }

    super.initState();
    updateToken();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {});
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();
  }

  getUser() async {
    GPSAPIS.getUserData().then((value) => {
          isLoading = false,
          email = value!.email.toString(),
          username = "${value.firstName} ${value.lastName}",
          expirationDate = value.subscriptionExpiration.toString(),
        });
    setState(() {
      print(email);
    });
  }

  Future<void> updateToken() async {
    GPSAPIS.getUserData().then(
        (value) => {GPSAPIS.activateFCM(StaticVarMethod.notificationToken)});
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(minutes: 5),
      ),
      child: Scaffold(
          backgroundColor: Colors.white,
          /*appBar: _globalWidget.globalAppBar(),*/
          appBar: AppBar(
            toolbarHeight: 70,
            // leading: const DrawerWidget(
            //   isHomeScreen: true,
            // ),
            leading: Builder(builder: (context) {
              return InkWell(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: const Icon(
                    Icons.menu,
                    size: 35,
                  ));
            }),

            title: SizedBox(
              height: 70,
              // width: 50,
              child: Image.asset(
                // "assets/images/homeAppBar.png",
                "assets/images/logo_mototraccar.png",
                fit: BoxFit.contain,
                height: 170,
              ),
            ),
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
                        child: const Icon(Icons.notifications, size: 35)),
                    const SizedBox(width: 10),
                    InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const SettingScreen();
                            },
                          ));
                        },
                        child: const Icon(Icons.person, size: 35)),
                  ],
                ),
              )
            ],
            centerTitle: false,
            backgroundColor: HomeScreen.primaryDark.withOpacity(0.8),
            // elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          drawer: Drawer(
              backgroundColor: HomeScreen.primaryDark,
              child: Padding(
                padding: const EdgeInsets.only(left: 35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        SharedTextWidget(
                            text: username,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        SharedTextWidget(
                            text: email,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                        const SizedBox(height: 30),
                        Ink(
                          color: selectedTab == "dashboard"
                              ? HomeScreen.primaryLight.withOpacity(0.3)
                              : HomeScreen.primaryDark,
                          child: ListTile(
                            leading: Icon(
                              Icons.home_outlined,
                              color: blackColor,
                              size: 30,
                            ),
                            title: Text('Dashboard',
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            onTap: () {
                              selectedTab = "dashboard";
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BottomNavigation(
                                    selectedPage: 0,
                                  ),
                                ),
                              ); // navigate to home screen
                            },
                          ),
                        ),
                        Ink(
                          color: selectedTab == "live"
                              ? HomeScreen.primaryLight.withOpacity(0.3)
                              : HomeScreen.primaryDark,
                          child: ListTile(
                            leading: Icon(Icons.location_on,
                                color: blackColor, size: 30),
                            title: Text('Live Tracking',
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            onTap: () {
                              selectedTab = "live";
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BottomNavigation(
                                    selectedPage: 2,
                                  ),
                                ),
                              );
                              // navigate to calendar screen
                            },
                          ),
                        ),
                        Ink(
                          color: selectedTab == "vehicle"
                              ? HomeScreen.primaryLight.withOpacity(0.3)
                              : HomeScreen.primaryDark,
                          child: ListTile(
                            leading: Icon(Icons.car_rental_rounded,
                                size: 30, color: blackColor),
                            title: Text('Vehicle Status',
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            onTap: () {
                              selectedTab = "vehicle";
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BottomNavigation(
                                    selectedPage: 1,
                                  ),
                                ),
                              );
                              // navigate to calendar screen
                            },
                          ),
                        ),
                        Ink(
                          color: selectedTab == "alert"
                              ? HomeScreen.primaryLight.withOpacity(0.3)
                              : HomeScreen.primaryDark,
                          child: ListTile(
                            leading: Icon(Icons.warning,
                                size: 30, color: blackColor),
                            title: Text('Alert',
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            onTap: () {
                              selectedTab = "alert";
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const Home(
                                        currentPage: NotificationsPage())),
                              );
                              // navigate to loved screen
                            },
                          ),
                        ),
                        Ink(
                          color: selectedTab == "report"
                              ? HomeScreen.primaryLight.withOpacity(0.3)
                              : HomeScreen.primaryDark,
                          child: ListTile(
                            leading:
                                Icon(Icons.menu, size: 30, color: blackColor),
                            title: Text('Report',
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            onTap: () {
                              selectedTab = "report";
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Home(
                                    currentPage: ReportSelection(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Ink(
                          color: selectedTab == "expiry"
                              ? HomeScreen.primaryLight.withOpacity(0.3)
                              : HomeScreen.primaryDark,
                          child: ListTile(
                            leading: Icon(Icons.car_repair_outlined,
                                size: 30, color: blackColor),
                            title: Text('Subscription Expiry',
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            onTap: () {
                              selectedTab = "expiry";
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Home(
                                    currentPage: VehicleExpiry(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Ink(
                          color: selectedTab == "document"
                              ? HomeScreen.primaryLight.withOpacity(0.3)
                              : HomeScreen.primaryDark,
                          child: ListTile(
                            leading: Icon(Icons.document_scanner,
                                size: 30, color: blackColor),
                            title: Text('Documents',
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            onTap: () {
                              selectedTab = "document";
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Home(
                                    currentPage: DocumentScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Ink(
                          color: selectedTab == "settings"
                              ? HomeScreen.primaryLight.withOpacity(0.3)
                              : HomeScreen.primaryDark,
                          child: ListTile(
                            leading: Icon(Icons.settings,
                                size: 30, color: blackColor),
                            title: Text('Settings',
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            onTap: () {
                              selectedTab = "settings";
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const Home(
                                          currentPage: SettingScreen(),
                                        )),
                              );

                              // navigate to settings screen
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Divider(height: 10, thickness: 2, color: whiteColor),
                        Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: ListTile(
                            tileColor: HomeScreen.primaryDark,
                            leading: Icon(Icons.exit_to_app,
                                size: 30, color: blackColor),
                            title: Text('Logout',
                                style:
                                    TextStyle(color: blackColor, fontSize: 15)),
                            onTap: () {
                              prefs.clear();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignIn()),
                              );
                              // logout
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _contentPages.map((Widget content) {
              return content;
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _currentIndex = 2;
              _pageController.jumpToPage(2);

              FocusScope.of(context).unfocus();
            },
            backgroundColor: Colors.white,
            child: const Icon(
              CupertinoIcons.location_solid,
              color: HomeScreen.primaryDark,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (value) {
              print(value);
              if (value == 3) {
                _currentIndex = 3;
                _pageController.jumpToPage(3);
              } else if (value == 4) {
                _currentIndex = 4;
                _pageController.jumpToPage(4);
              } else {
                _currentIndex = value;
                _pageController.jumpToPage(value);
              }
              setState(() {});

              FocusScope.of(context).unfocus();
            },
            selectedFontSize: 8,
            unselectedFontSize: 8,
            iconSize: 28,
            backgroundColor: blackColor,
            // backgroundColor: const Color(0xff000000),
            selectedItemColor:
                _currentIndex == 2 ? Colors.transparent : Colors.white,
            items: [
              BottomNavigationBarItem(
                  backgroundColor: blackColor,
                  label: '',
                  icon: Icon(Icons.home,
                      color: _currentIndex == 0 ? _color1 : _color2)),

              const BottomNavigationBarItem(
                  label: '',
                  icon:
                      Icon(Icons.location_on_sharp, color: Colors.transparent)),
              const BottomNavigationBarItem(
                  label: '',
                  icon:
                      Icon(Icons.location_on_sharp, color: Colors.transparent)),
              BottomNavigationBarItem(
                  backgroundColor: blackColor,
                  label: '',
                  icon: Icon(Icons.list,
                      color: _currentIndex == 1 ? _color1 : _color2)),
              // BottomNavigationBarItem(
              //     label: 'Alert',
              //     icon: Icon(Icons.warning,
              //         color: _currentIndex == 3 ? _color1 : _color2)),
              // BottomNavigationBarItem(
              //     // ignore: deprecated_member_use
              //     label: 'Settings',
              //     icon: Icon(Icons.person_outline,
              //         color: _currentIndex == 4 ? _color1 : _color2)),
              // BottomNavigationBarItem(
              //     label: '',
              //     icon: Icon(Icons.list,
              //         color: _currentIndex == 2 ? _color1 : _color2)),
            ],
          )),
    );
  }
}
