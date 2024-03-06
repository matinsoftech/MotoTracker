class PlayBackRoute extends Object {
  String? deviceId;
  String? latitude;
  String? longitude;
  String? course;
  String? rawTime;
  String? time;
  List<String>? otherArr;
  dynamic speed;

  PlayBackRoute({
    this.deviceId,
    this.latitude,
    this.longitude,
    this.course,
    this.rawTime,
    this.time,
    this.otherArr,
    this.speed,
  });

  PlayBackRoute.fromJson(Map<String, dynamic> json) {
    deviceId = json["device_id"];
    latitude = json["latitude"];
    longitude = json["longitude"];
    course = json["course"];
    rawTime = json["raw_time"];
    otherArr = json["other_arr"] == null
        ? null
        : List<String>.from(
        json["other_arr"].map((x) => x.toString()));
    time = json["time"];

    speed = json["speed"];
  }

  Map<String, dynamic> toJson() => {
    'device_id': deviceId,
    'latitude': latitude,
    'longitude': longitude,
    'course': course,
    'raw_time': rawTime,
    'time': time,
    'speed': speed
  };
}
