import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/vechile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  bool isSupportEnabled = true;
  SharedPreferences? _prefs;

  initiateSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    isSupportEnabled = _prefs!.getBool("isSupportEnabled")!;
    StaticVarMethod.isSupportEnabled = isSupportEnabled;
    setState(() {});
  }

  @override
  void initState() {
    initiateSharedPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: customFloatingSupportButton(context),
      appBar: AppBar(
        title: const Text("Support"),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      backgroundColor: Colors.black.withOpacity(0.1),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    )),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/moto_traccar.png",
                      height: 100,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 20.0, right: 20.0, bottom: 50.0, top: 30.0),
                      child: Text(
                        "Have you forgotten your password or you want to change your password? please contact us",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customSupportWidget(
                              title: "Call Us",
                              iconData: Icons.phone_forwarded,
                              color: Colors.orange,
                              onTap: () async {
                                if (await canLaunchUrl(Uri(
                                    scheme: "tel",
                                    path: StaticVarMethod.appMobile))) {
                                  await launchUrl(Uri(
                                      scheme: "tel",
                                      path: StaticVarMethod.appMobile));
                                } else {
                                  throw 'Could not launch';
                                }
                              }),
                          customSupportWidget(
                              title: "Email Us",
                              iconData: Icons.email,
                              color: Colors.blue,
                              onTap: () {
                                sendEmail(context,
                                    emailTo: StaticVarMethod.appMail,
                                    subject: "Mero Gadi Support",
                                    body: "");
                              }),
                          customSupportWidget(
                              title: "WhatsApp",
                              iconData: Icons.message,
                              color: Colors.green,
                              onTap: () {
                                _launchWhatsapp();
                              })
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customSupportTile(
                        title: "Mobile", value: StaticVarMethod.appMobile),
                    customSupportTile(
                        title: "Mail", value: StaticVarMethod.appMail),
                    customSupportTile(
                        title: "WhatsApp",
                        value: StaticVarMethod.appWhatsAppNumber)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Show support button",
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CupertinoSwitch(
                        value: isSupportEnabled,
                        thumbColor: HomeScreen.primaryDark,
                        activeColor: HomeScreen.primaryDark.withOpacity(0.5),
                        onChanged: (value) {
                          isSupportEnabled = !isSupportEnabled;
                          _prefs!.setBool("isSupportEnabled", isSupportEnabled);
                          StaticVarMethod.isSupportEnabled = isSupportEnabled;
                          setState(() {});
                        })
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  customSupportWidget(
      {required String title,
      required IconData iconData,
      required Color color,
      required var onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(3, 3),
                  color: Colors.grey.shade300)
            ]),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100)),
              padding: const EdgeInsets.all(10),
              child: Icon(
                iconData,
                color: color,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }

  sendEmail(BuildContext context,
      {required String emailTo,
      required String subject,
      required String body}) async {
    Uri mail = Uri.parse("mailto:$emailTo?subject=$subject&body=$body");
    try {
      await launchUrl(mail);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  _launchWhatsapp() async {
    try {
      var whatsapp = StaticVarMethod.appWhatsAppNumber;
      var whatsappAndroid = Uri.parse("https://wa.me/$whatsapp?text=");
      await launchUrl(whatsappAndroid, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  customSupportTile({
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          value,
          style: TextStyle(color: yellowColor, fontSize: 17),
        ),
        const SizedBox(
          height: 10,
        ),
        Divider(
          color: HomeScreen.primaryDark,
        )
      ],
    );
  }
}
