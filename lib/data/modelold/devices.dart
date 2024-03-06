class Devices {
  Devices({
    this.title,
    this.items,
  });

  Devices.fromJson(dynamic json) {
    title = json['title'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(DeviceItems.fromJson(v));
      });
    }
  }
  String? title;
  List<DeviceItems>? items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    if (items != null) {
      map['items'] = items?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class DeviceItems {
  DeviceItems({
    this.id,
    this.name,
    this.online,
    this.time,
    this.speed,
    this.lat,
    this.lng,
    this.course,
    this.power,
    this.altitude,
    this.address,
    this.protocol,
    this.driver,
    this.sensors,
    this.services,
    this.iconColor,
    this.deviceData,
  });

  DeviceItems.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    online = json['online'];
    time = json['time'];
    speed = json['speed'];
    lat = json['lat'];
    lng = json['lng'];
    course = json['course'];
    power = json['power'];
    altitude = json['altitude'];
    address = json['address'];
    protocol = json['protocol'];
    driver = json['driver'];
    if (json['sensors'] != null) {
      sensors = [];
      json['sensors'].forEach((v) {
        //sensors?.add(Dynamic.fromJson(v));
      });
    }
    if (json['services'] != null) {
      services = [];
      json['services'].forEach((v) {
        // services?.add(Dynamic.fromJson(v));
      });
    }
    iconColor = json['icon_color'];
    deviceData = json['device_data'] != null
        ? DeviceData.fromJson(json['device_data'])
        : null;
  }
  dynamic id;
  dynamic name;
  dynamic online;
  dynamic time;
  dynamic speed;
  dynamic lat;
  dynamic lng;
  dynamic course;
  dynamic power;
  dynamic altitude;
  dynamic address;
  dynamic protocol;
  dynamic driver;
  List<dynamic>? sensors;
  List<dynamic>? services;
  dynamic iconColor;
  DeviceData? deviceData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['online'] = online;
    map['time'] = time;
    map['speed'] = speed;
    map['lat'] = lat;
    map['lng'] = lng;
    map['course'] = course;
    map['power'] = power;
    map['altitude'] = altitude;
    map['address'] = address;
    map['protocol'] = protocol;
    map['driver'] = driver;
    if (sensors != null) {
      map['sensors'] = sensors?.map((v) => v.toJson()).toList();
    }
    if (services != null) {
      map['services'] = services?.map((v) => v.toJson()).toList();
    }
    map['icon_color'] = iconColor;
    if (deviceData != null) {
      map['device_data'] = deviceData?.toJson();
    }
    return map;
  }
}

class DeviceData {
  DeviceData({
    this.active,
    this.deleted,
    this.imei,
    this.fuelMeasurementId,
    this.fuelQuantity,
    this.fuelPrice,
    this.fuelPerKm,
    this.expirationDate,
    this.simNumber,
    this.createdAt,
    this.updatedAt,
    this.parkingMode,
    this.protocol,
  });

  DeviceData.fromJson(dynamic json) {
    active = json['active'];
    deleted = json['deleted'];
    imei = json['imei'];
    fuelMeasurementId = json['fuel_measurement_id'];
    fuelQuantity = json['fuel_quantity'];
    fuelPrice = json['fuel_price'];
    fuelPerKm = json['fuel_per_km'];
    expirationDate = json['expiration_date'];
    simNumber = json['sim_number'];
    parkingMode = int.parse(json['parking_mode'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    protocol = json['protocol'];
  }
  dynamic active;
  dynamic deleted;
  dynamic imei;
  dynamic fuelMeasurementId;
  dynamic fuelQuantity;
  dynamic fuelPrice;
  dynamic fuelPerKm;
  dynamic expirationDate;
  dynamic simNumber;
  int? parkingMode;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic protocol;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['active'] = active;
    map['deleted'] = deleted;
    map['imei'] = imei;
    map['fuel_measurement_id'] = fuelMeasurementId;
    map['fuel_quantity'] = fuelQuantity;
    map['fuel_price'] = fuelPrice;
    map['fuel_per_km'] = fuelPerKm;
    map['expiration_date'] = expirationDate;
    map['sim_number'] = simNumber;
    map['parking_mode'] = parkingMode;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['protocol'] = protocol;
    return map;
  }
}
