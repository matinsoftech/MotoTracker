// To parse this JSON data, do
//
//     final event = eventFromJson(jsonString);

import 'dart:convert';

List<AlertEvent> eventFromJson(String str) =>
    List<AlertEvent>.from(json.decode(str).map((x) => AlertEvent.fromJson(x)));

String eventToJson(List<AlertEvent> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AlertEvent {
  int? id;
  int? userId;
  String? protocol;

  String? message;
  int? always;

  AlertEvent({
    this.id,
    this.userId,
    this.protocol,
    this.message,
    this.always,
  });

  factory AlertEvent.fromJson(Map<String, dynamic> json) => AlertEvent(
        id: json["id"],
        userId: json["user_id"],
        protocol: json["protocol"],
        message: json["message"],
        always: json["always"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "protocol": protocol,
        "always": always,
      };
}

class Condition {
  String? tag;
  String? type;
  String? tagValue;

  Condition({
    this.tag,
    this.type,
    this.tagValue,
  });

  factory Condition.fromJson(Map<String, dynamic> json) => Condition(
        tag: json["tag"],
        type: json["type"],
        tagValue: json["tag_value"],
      );

  Map<String, dynamic> toJson() => {
        "tag": tag,
        "type": type,
        "tag_value": tagValue,
      };
}

class Tag {
  String? eventCustomId;
  String? tag;

  Tag({
    this.eventCustomId,
    this.tag,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        eventCustomId: json["event_custom_id"],
        tag: json["tag"],
      );

  Map<String, dynamic> toJson() => {
        "event_custom_id": eventCustomId,
        "tag": tag,
      };
}
