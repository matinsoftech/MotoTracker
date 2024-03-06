import 'package:flutter/material.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebsiteWebView extends StatelessWidget {
  WebsiteWebView({super.key});

  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HomeScreen.primaryDark,
        title: const Text('About MatinSoftech'),
      ),
      body: SafeArea(
          child: WebView(
        initialUrl: 'https://www.matinsoftech.com',
        onWebViewCreated: (WebViewController controller) {
          _controller = controller;
        },
      )),
    );
  }
}
