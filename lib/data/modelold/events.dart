class Events {
  Events({
    this.status,
    this.items,
  });

  Events.fromJson(dynamic json) {
    status = json['status'];
    items = json['items'] != null ? Items.fromJson(json['items']) : null;
  }
  num? status;
  Items? items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    if (items != null) {
      map['items'] = items?.toJson();
    }
    return map;
  }
}

class Items {
  Items({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
    this.from,
    this.to,
    this.data,
  });

  Items.fromJson(dynamic json) {
    total = json['total'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    nextPageUrl = json['next_page_url'];
    prevPageUrl = json['prev_page_url'];
    from = json['from'];
    to = json['to'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(EventsData.fromJson(v));
      });
    }
  }
  num? total;
  num? perPage;
  num? currentPage;
  num? lastPage;
  String? nextPageUrl;
  dynamic prevPageUrl;
  num? from;
  num? to;
  List<EventsData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total'] = total;
    map['per_page'] = perPage;
    map['current_page'] = currentPage;
    map['last_page'] = lastPage;
    map['next_page_url'] = nextPageUrl;
    map['prev_page_url'] = prevPageUrl;
    map['from'] = from;
    map['to'] = to;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class EventsData {
  EventsData({
    this.id,
    this.userId,
    this.deviceId,
    this.geofenceId,
    this.positionId,
    this.alertId,
    this.type,
    this.message,
    this.address,
    this.altitude,
    this.course,
    this.latitude,
    this.longitude,
    this.power,
    this.speed,
    this.time,
    this.deleted,
    this.createdAt,
    this.updatedAt,
    this.deviceName,
  });

  EventsData.fromJson(dynamic json) {
    id = json['id'].toString();
    userId = json['user_id'].toString();
    deviceId = json['device_id'].toString();
    geofenceId = json['geofence_id'].toString();
    positionId = json['position_id'].toString();
    alertId = json['alert_id'].toString();
    type = json['type'];
    message = json['message'];
    address = json['address'];
    altitude = json['altitude'].toString();
    course = json['course'].toString();
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    power = json['power'];
    speed = json['speed'].toString();
    time = json['time'];
    deleted = json['deleted'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deviceName = json['device_name'];
  }
  String? id;
  String? userId;
  String? deviceId;
  dynamic geofenceId;
  String? positionId;
  String? alertId;
  String? type;
  String? message;
  dynamic address;
  String? altitude;
  String? course;
  String? latitude;
  String? longitude;
  dynamic power;
  String? speed;
  String? time;
  String? deleted;
  String? createdAt;
  String? updatedAt;
  String? deviceName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['device_id'] = deviceId;
    map['geofence_id'] = geofenceId;
    map['position_id'] = positionId;
    map['alert_id'] = alertId;
    map['type'] = type;
    map['message'] = message;
    map['address'] = address;
    map['altitude'] = altitude;
    map['course'] = course;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['power'] = power;
    map['speed'] = speed;
    map['time'] = time;
    map['deleted'] = deleted;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['device_name'] = deviceName;
    return map;
  }
}
