import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReportStopPage extends StatefulWidget {
  const ReportStopPage({super.key});

  @override
  State<StatefulWidget> createState() => _ReportStopPageState();
}

class _ReportStopPageState extends State<ReportStopPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  late StreamController<int> _postsController;
  bool isLoading = true;
  late File file;

  @override
  void initState() {
    _postsController = StreamController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(StaticVarMethod.deviceName,
              style: const TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
        ),
        body: StreamBuilder<int>(
            stream: _postsController.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              if (snapshot.data == 1) {
                return SfPdfViewer.file(
                  file,
                  key: _pdfViewerKey,
                );
              } else if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data == 0) {
                return const Center(
                  child: Text('No Data'),
                );
              } else {
                return const Center(
                  child: Text('No Data'),
                );
              }
            }));
  }
}
