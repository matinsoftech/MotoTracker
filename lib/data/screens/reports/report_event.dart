import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/data_sources.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';

class ReportEventPage extends StatefulWidget {
  const ReportEventPage({super.key});

  @override
  State<StatefulWidget> createState() => _ReportEventPageState();
}

class _ReportEventPageState extends State<ReportEventPage> {
  bool isLoading = true;
  late File file;

  late WebViewController _controller;
  @override
  void initState() {
    getReport();
    super.initState();
  }

  _loadHtmlFromAssets(String html) async {
    int idx = html.indexOf("</html>");
    String parts = html.substring(0, idx).trim();

    setState(() {
      _controller.loadUrl(Uri.dataFromString(parts,
              mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
          .toString());

      isLoading = false;
    });
  }

  getReport() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      timer.cancel();
      GPSAPIS
          .getReport(StaticVarMethod.deviceId, StaticVarMethod.fromdate,
              StaticVarMethod.todate, StaticVarMethod.reportType,
              fromTime: StaticVarMethod.fromtime,
              toTime: StaticVarMethod.totime)
          .then((value) => {_loadHtmlFromAssets(value.body.toString())});
    });
  }

  getReportDownloadUrl() async {
    String? url;
    url = await GPSAPIS.getReportDownloadUrl(
        StaticVarMethod.deviceId,
        StaticVarMethod.fromdate,
        StaticVarMethod.todate,
        StaticVarMethod.reportType,
        fromTime: StaticVarMethod.fromtime,
        toTime: StaticVarMethod.totime);
    if (url != null) {
      log(url.toString());
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    }
  }

  void _loadHtmlAndDownload(WebViewController controller) async {
    log("load html");
    // Inject JavaScript to get the HTML content
    final htmlContent = await controller
        .runJavascriptReturningResult('document.documentElement.outerHTML');

    // Save HTML content to a file
    final taskId = await FlutterDownloader.enqueue(
      url: 'data:text/html;charset=utf-8,' + Uri.encodeComponent(htmlContent),
      savedDir: '/path/to/save/directory',
      showNotification: true,
      openFileFromNotification: true,
    );
    print('Download task ID: $taskId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(StaticVarMethod.deviceName,
              style: const TextStyle(color: Colors.black, fontSize: 14)),
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
        ),
        body: Stack(
          children: [
            WebView(
              onProgress: (int progress) {
                log("This is progress $progress");
              },
              // onclick

              initialUrl: 'about:blank',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
              },
              navigationDelegate: (var request) {
                if (request.url.contains("http://maps.google.com/maps")) {
                  log("This is url ${request.url}");
                  launchUrl(Uri.parse(request.url),
                      mode: LaunchMode.externalApplication);
                }
                return NavigationDecision.navigate;
              },
            ),
            Positioned(
                bottom: 30,
                right: 20,
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: HomeScreen.primaryDark.withOpacity(0.2),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.download,
                      color: HomeScreen.primaryDark,
                    ),
                  ),
                  onTap: () {
                    getReportDownloadUrl();
                  },
                )),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox.shrink()
          ],
        ));
  }
}

class ReportEventArgument {
  final int eventId;
  final int positionId;
  final Map<String, dynamic> attributes;
  final String type;
  final String name;
  ReportEventArgument(
      this.eventId, this.positionId, this.attributes, this.type, this.name);
}
