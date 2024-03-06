// To parse this JSON data, do
//
//     final alertType = alertTypeFromJson(jsonString);

import 'dart:convert';

AlertType alertTypeFromJson(String str) => AlertType.fromJson(json.decode(str));

String alertTypeToJson(AlertType data) => json.encode(data.toJson());

class AlertType {
  int? id;
  int? userId;
  int? active;
  String? name;
  String? email;
  String? mobilePhone;
  int? overspeedSpeed;
  int? overspeedDistance;
  int? acAlarm;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<int>? devices;

  AlertType({
    this.id,
    this.userId,
    this.active,
    this.name,
    this.email,
    this.mobilePhone,
    this.overspeedSpeed,
    this.overspeedDistance,
    this.acAlarm,
    this.createdAt,
    this.updatedAt,
    this.devices,
  });

  factory AlertType.fromJson(Map<String, dynamic> json) => AlertType(
        id: json["id"],
        userId: json["user_id"],
        active: json["active"],
        name: json["name"],
        email: json["email"],
        mobilePhone: json["mobile_phone"],
        overspeedSpeed: json["overspeed_speed"],
        overspeedDistance: json["overspeed_distance"],
        acAlarm: json["ac_alarm"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        devices: json["devices"] == null
            ? []
            : List<int>.from(json["devices"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "active": active,
        "name": name,
        "email": email,
        "mobile_phone": mobilePhone,
        "overspeed_speed": overspeedSpeed,
        "overspeed_distance": overspeedDistance,
        "ac_alarm": acAlarm,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "devices":
            devices == null ? [] : List<dynamic>.from(devices!.map((x) => x)),
      };
}
