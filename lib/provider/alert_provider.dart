import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myvtsproject/data/model/event.dart';

import '../data/data_sources.dart';
import '../data/model/add_alert_request.dart';
import '../data/model/alert_type.dart';

class AlertProfivider with ChangeNotifier {
  bool isLoadingEvent = false;
  bool isLoadingAlert = false;

  List<AlertEvent> _alertEvent = [];
  List<AlertType> _alertType = [];
  List<AlertType> get alertType => _alertType;

  List<AlertEvent> get alertEvent => _alertEvent;

  Future<void> getAlertEvent() async {
    log("getAlertEvent");
    isLoadingEvent = true;

    var response = await GPSAPIS.getAlertEvent();

    log("getAlertEvent length ${response.length}");

    if (response.isNotEmpty) {
      _alertEvent = response;

      _alertEvent.add(AlertEvent(
        id: 0,
        userId: 0,
        protocol: "",
        message: "Over Speed",
        always: 1,
      ));

      log("getAlertEvent length ${_alertEvent.length}");
      isLoadingEvent = false;
      notifyListeners();
    } else {
      isLoadingEvent = false;
      notifyListeners();
    }
  }

  Future<void> getAlertType() async {
    log("getAlertType");
    isLoadingAlert = true;
    notifyListeners();

    var response = await GPSAPIS.getAlertTypes();

    log("getAlertType length ${response.length}");

    if (response.isNotEmpty) {
      _alertType = response;
      isLoadingAlert = false;
      notifyListeners();
    } else {
      isLoadingAlert = false;
      notifyListeners();
    }
  }

  Future<void> addAlert(
      {required AddAlertRequest addAlertRequest, BuildContext? context}) async {
    showDialog(
        context: context!,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    var response = await GPSAPIS.addAlert(addAlertRequest: addAlertRequest);
    if (response) {
      getAlertType();
      Navigator.pop(context);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Alert Added Successfully");
    } else {
      Fluttertoast.showToast(msg: "Alert Not Added");
      Navigator.pop(context);
    }
  }
}
