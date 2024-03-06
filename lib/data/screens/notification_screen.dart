import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/modelold/events.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';

import '../data_sources.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  List<EventsData> eventList = [];

  @override
  initState() {
    getnotiList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      backgroundColor: const Color(0XFFeaeaeb),
      appBar: appBar(),
      body: eventList.isNotEmpty
          ? listView()
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      // leading: const DrawerWidget(
      //   isHomeScreen: true,
      // ),
      title: const Text(
        'Alert',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: HomeScreen.primaryDark,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget listView1() {
    return ListView(
        children: ListTile.divideTiles(
            color: Colors.white,
            tiles: eventList.map((item) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber,
                    child: CachedNetworkImage(
                      imageUrl:
                          'http://116.58.56.123:8008/Content/EmpImg/${item.id}.jpg',
                      imageBuilder: (context, imageProvider) => Container(
                        width: 80.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image),
                    ),
                  ),
                  title: Text(item.deviceName.toString()),
                  subtitle: Text(item.message.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {},
                  ),
                ))).toList());
  }

  Widget listView() {
    return ListView.builder(
      itemCount: eventList.length,
      itemBuilder: (BuildContext context, int index) {
        DateTime eventDate = DateTime.parse(eventList[index].createdAt!);
        DateTime currentDate = DateTime.now();
        Duration diff = currentDate.difference(eventDate);
        if (diff.inHours > 24) {
          return const SizedBox();
        } else {
          return GestureDetector(
              child: listViewItems(index), onTap: () => onTapped());
        }
      },
    );
  }

  onTapped() {}

  Widget listViewItems(int index) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            prefixIcon(index),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                    left: 8, right: 30, top: 15, bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(
                    //   height: 40,
                    // ),
                    message(index),
                    const SizedBox(
                      height: 20,
                    ),
                    timeAndDate(index),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget prefixIcon(int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.white,
        ),
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 13),
        child: Center(
          child: Image.asset(
            "assets/images/alarmnotification96by96.png",
            height: 50,
            width: 50,
          ),
        ),
      ),
    );
  }

  Widget message(int index) {
    double textsize = 16;

    return RichText(
      maxLines: 5,
      textAlign: TextAlign.left,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        text: ' ${eventList[index].deviceName}',
        style: TextStyle(
          fontSize: textsize,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget timeAndDate(int index) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eventList[index].message.toString(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 7, 97, 97),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              eventList[index].time.toString(),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getnotiList() async {
    GPSAPIS api = GPSAPIS();
    try {
      eventList = await api.getEventsList(StaticVarMethod.userAPiHash);
      if (eventList.isNotEmpty) {
        StaticVarMethod.eventList = eventList;
        setState(() {});
      } else {}
    } catch (_) {}
  }

  Widget noNotificationScreen() {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    const pageTitle = Padding(
      padding: EdgeInsets.only(top: 1.0, bottom: 30.0),
      child: Text(
        "Notifications",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 40.0,
        ),
      ),
    );

    final image = Image.asset("assets/images/empty.png");

    final notificationHeader = Container(
      padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
      child: const Text(
        "No New Notification",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
      ),
    );
    final notificationText = Text(
      "You currently do not have any unread notifications.",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
        color: Colors.grey.withOpacity(0.6),
      ),
      textAlign: TextAlign.center,
    );

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(
          top: 70.0,
          left: 30.0,
          right: 30.0,
          bottom: 30.0,
        ),
        height: deviceHeight,
        width: deviceWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            pageTitle,
            SizedBox(
              height: deviceHeight * 0.1,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[image, notificationHeader, notificationText],
            ),
          ],
        ),
      ),
    );
  }
}
