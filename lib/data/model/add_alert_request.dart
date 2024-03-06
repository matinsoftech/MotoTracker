import 'dart:convert';

import '../../config/static.dart';

class AddAlertRequest {
  String? name;

  List<int>? devices;

  int? speed;
  int? eventId;

  AddAlertRequest({this.name, this.devices, this.speed, this.eventId});

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": "",
      "event_id": eventId.toString(),
      "type": "1",
      "devices": jsonEncode(
          devices == null ? [] : List<dynamic>.from(devices!.map((x) => x))),
      if (speed != null) "speed": speed.toString(),
      "user_api_hash": StaticVarMethod.userAPiHash,
    };
  }
}
