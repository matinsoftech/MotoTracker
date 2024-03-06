import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'global_widget.dart';

class IosPage extends StatefulWidget {
  const IosPage({super.key});

  @override
  IosPageState createState() => IosPageState();
}

class IosPageState extends State<IosPage> {
  final _globalWidget = GlobalWidget();

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
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: GestureDetector(
            child: const Icon(CupertinoIcons.back),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          middle: const Text('IOS Page'),
        ),
        child: Center(
          child: _globalWidget.createButton(
              buttonName: 'Go To New Page',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const IosPage()));
              }),
        ),
      ),
    );
  }
}
