import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:myvtsproject/data/screens/listscreen.dart';

import 'home/home_screen.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  PrivacyPolicyState createState() => PrivacyPolicyState();
}

class PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: customFloatingSupportButton(context),
      appBar: AppBar(
        // leading: const DrawerWidget(
        //   isHomeScreen: true,
        // ),
        centerTitle: true,
        title: const Text('Privacy Policy'),
        backgroundColor: HomeScreen.primaryDark,
        //bottom: _reusableWidget.bottomAppBar(),
      ),
      body: SingleChildScrollView(
          child: Container(
              margin: const EdgeInsets.all(10),
              child: Html(
                data:
                    '<h2>Mero Gadi Tracker Privacy Policy:</h2><p style="text-align: justify;">Mero Gadi Tracker ("Mero Gadi Tracker") operates <a href="https://merogaditracker.com">https://merogaditracker.com</a>  and may operate other websites. It is Mero Gadi Tracker policy to respect your privacy regarding any information we may collect while operating our websites.</p><h2>Website Visitors</h2><p style="text-align: justify;">Like most website operators, Mero Gadi Tracker collects non-personally-identifying information of the sort that web browsers and servers typically make available, such as the browser type, language preference, referring site, and the date and time of each visitor request. Mero Gadi Tracker purpose in collecting non-personally identifying information is to better understand how Mero Gadi Tracker visitors use its website. From time to time, Mero Gadi Tracker may release non-personally-identifying information in the aggregate, e.g., by publishing a report on trends in the usage of its website.</p><p style="text-align: justify;">Mero Gadi Tracker also collects potentially personally-identifying information like Internet Protocol (IP) addresses for logged in users and for users leaving comments on https://merogaditracker.com/ blogs/sites. Mero Gadi Tracker only discloses logged in user and commenter IP addresses under the same circumstances that it uses and discloses personally-identifying information as described below, except that commenter IP addresses and email addresses are visible and disclosed to the administrators of the blog/site where the comment was left.</p><h2>Gathering of Personally-Identifying Information</h2><p style="text-align: justify;">Certain visitors to Mero Gadi Tracker websites choose to interact with Mero Gadi Tracker in ways that require Mero Gadi Tracker to gather personally-identifying information. The amount and type of information that Mero Gadi Tracker gathers depends on the nature of the interaction. For example, we ask visitors who sign up at <a href="https://merogaditracker.com">https://merogaditracker.com</a> to provide a username and email address. Those who engage in transactions with Mero Gadi Tracker are asked to provide additional information, including as necessary the personal and financial information required to process those transactions. In each case, Mero Gadi Tracker collects such information only insofar as is necessary or appropriate to fulfill the purpose of the visitor interaction with Mero Gadi Tracker. Mero Gadi Tracker does not disclose personally-identifying information other than as described below. And visitors can always refuse to supply personally-identifying information, with the caveat that it may prevent them from engaging in certain website-related activities.</p><h2>Aggregated Statistics</h2><p style="text-align: justify;">Mero Gadi Tracker may collect statistics about the behavior of visitors to its websites. Mero Gadi Tracker may display this information publicly or provide it to others. However, Mero Gadi Tracker does not disclose personally-identifying information other than as described below.</p><h2>Protection of Certain Personally-Identifying Information</h2><p style="text-align: justify;">Mero Gadi Tracker discloses potentially personally-identifying and personally-identifying information only to those of its employees, contractors and affiliated organizations that (i) need to know that information in order to process it on Mero Gadi Tracker behalf or to provide services available at Mero Gadi Tracker websites, and (ii) that have agreed not to disclose it to others. Some of those employees, contractors and affiliated organizations may be located outside of your home country; by using Mero Gadi Tracker websites, you consent to the transfer of such information to them. Mero Gadi Tracker will not rent or sell potentially personally-identifying and personally-identifying information to anyone. Other than to its employees, contractors and affiliated organizations, as described above, Mero Gadi Tracker discloses potentially personally-identifying and personally-identifying information only in response to a subpoena, court order or other governmental request, or when Mero Gadi Tracker believes in good faith that disclosure is reasonably necessary to protect the property or rights of Mero Gadi Tracker, third parties or the public at large. If you are a registered user of an Mero Gadi Tracker website and have supplied your email address, Mero Gadi Tracker may occasionally send you an email to tell you about new features, solicit your feedback, or just keep you up to date with what going on with Mero Gadi Tracker and our products. If you send us a request (example via email or via one of our feedback mechanisms), we reserve the right to publish it in order to help us clarify or respond to your request or to help us support other users. Mero Gadi Tracker takes all measures reasonably necessary to protect against the unauthorized access, use, alteration or destruction of potentially personally-identifying and personally-identifying information</p><h2>Cookies</h2><p style="text-align: justify;">A cookie is a string of information that a website stores on a visitor computer, and that the visitor browser provides to the website each time the visitor returns. Mero Gadi Tracker uses cookies to help Mero Gadi Tracker identify and track visitors, their usage of Mero Gadi Tracker website, and their website access preferences. Mero Gadi Tracker visitors who do not wish to have cookies placed on their computers should set their browsers to refuse cookies before using Mero Gadi Tracker websites, with the drawback that certain features of Mero Gadi Tracker websites may not function properly without the aid of cookies.</p><h2>Business Transfers</h2><p style="text-align: justify;">If Mero Gadi Tracker, or substantially all of its assets, were acquired, or in the unlikely event that Mero Gadi Tracker goes out of business or enters bankruptcy, user information would be one of the assets that is transferred or acquired by a third party. You acknowledge that such transfers may occur, and that any acquirer of Mero Gadi Tracker may continue to use your personal information as set forth in this policy.</p><h2>Ads</h2><p style="text-align: justify;">Ads appearing on any of our websites may be delivered to users by advertising partners, who may set cookies. These cookies allow the ad server to recognize your computer each time they send you an online advertisement to compile information about you or others who use your computer. This information allows ad networks to, among other things, deliver targeted advertisements that they believe will be of most interest to you. This Privacy Policy covers the use of cookies by Mero Gadi Tracker and does not cover the use of cookies by any advertisers.</p><h2>Mero Gadi Tracker Privacy Policy Changes</h2><p style="text-align: justify;">Although most changes are likely to be minor, Mero Gadi Tracker may change its Mero Gadi Tracker Privacy Policy from time to time, and in Mero Gadi Tracker sole discretion. Mero Gadi Tracker encourages visitors to frequently check this page for any changes to its Mero Gadi Tracker Privacy Policy. If you have a <a href="https://merogaditracker.com/">https://merogaditracker.com/</a>  account, you might also receive an alert informing you of these changes. Your continued use of this site after any change in this Mero Gadi Tracker Privacy Policy will constitute your acceptance of such change.</p>',
              ))),
    );
  }
}
