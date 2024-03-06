class Devices {
  Devices({
    num? id,
    String? title,
    List<DeviceItems>? items,
  }) {
    _id = id;
    _title = title;
    _items = items;
  }

  Devices.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    if (json['items'] != null) {
      _items = [];
      json['items'].forEach((v) {
        _items?.add(DeviceItems.fromJson(v));
      });
    }
  }
  num? _id;
  String? _title;
  List<DeviceItems>? _items;

  num? get id => _id;
  String? get title => _title;
  List<DeviceItems>? get items => _items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    if (_items != null) {
      map['items'] = _items?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 369
/// alarm : 0
/// name : "PS BR22PA 1985"
/// online : "ack"
/// time : "18-10-2022 15:24:03"
/// timestamp : 1666089320
/// lat : 25.401708
/// lng : 86.339088
/// course : 186
/// speed : 0
/// altitude : 0
/// power : "-"
/// address : "-"
/// protocol : "gt06"
/// driver : "-"
/// sensors : [{"id":1520,"type":"acc","name":"Vehicle","show_in_popup":0,"value":"On","val":true,"scale_value":null}]
/// ignition_duration : "0s"
/// idle_duration : "0s"
/// stop_duration : "2h 35min 13s"
/// total_distance : 25108.03

class DeviceItems {
  items({
    num? id,
    num? alarm,
    String? name,
    String? online,
    String? time,
    num? timestamp,
    num? lat,
    num? lng,
    num? course,
    num? speed,
    num? altitude,
    String? power,
    String? address,
    String? protocol,
    String? driver,
    DeviceIcon? icon,
    List<Sensors>? sensors,
    String? ignitionDuration,
    String? idleDuration,
    String? stopDuration,
    num? totalDistance,
    DeviceData? deviceData,
  }) {
    _id = id;
    _alarm = alarm;
    _name = name;
    _online = online;
    _time = time;
    _timestamp = timestamp;
    _lat = lat;
    _lng = lng;
    _course = course;
    _speed = speed;
    _altitude = altitude;
    _power = power;
    _address = address;
    _protocol = protocol;
    _driver = driver;
    _icon = icon;
    _sensors = sensors;

    _ignitionDuration = ignitionDuration;
    _idleDuration = idleDuration;
    _stopDuration = stopDuration;
    _totalDistance = totalDistance;
    _deviceData = deviceData;
  }

  DeviceItems.fromJson(dynamic json) {
    _id = json['id'];
    _alarm = json['alarm'];
    _name = json['name'];
    _online = json['online'];
    _time = json['time'];
    _timestamp = json['timestamp'];
    _lat = json['lat'];
    _lng = json['lng'];
    _course = json['course'];
    _speed = json['speed'];
    _altitude = json['altitude'];
    _power = json['power'];
    _address = json['address'];
    _protocol = json['protocol'];
    _driver = json['driver'];
    _icon = json['icon'] != null ? DeviceIcon.fromJson(json['icon']) : null;
    if (json['sensors'] != null) {
      _sensors = [];
      json['sensors'].forEach((v) {
        _sensors?.add(Sensors.fromJson(v));
      });
    }
    _ignitionDuration = json['ignition_duration'];
    _idleDuration = json['idle_duration'];
    _stopDuration = json['stop_duration'];
    _totalDistance = json['total_distance'];
    _deviceData = json['device_data'] != null
        ? DeviceData.fromJson(json['device_data'])
        : null;
  }
  num? _id;
  num? _alarm;
  String? _name;
  String? _online;
  String? _time;
  num? _timestamp;
  num? _lat;
  num? _lng;
  num? _course;
  num? _speed;
  num? _altitude;
  String? _power;
  String? _address;
  String? _protocol;
  String? _driver;
  DeviceIcon? _icon;
  List<Sensors>? _sensors;
  String? _ignitionDuration;
  String? _idleDuration;
  String? _stopDuration;
  num? _totalDistance;
  DeviceData? _deviceData;

  num? get id => _id;
  num? get alarm => _alarm;
  String? get name => _name;
  String? get online => _online;
  String? get time => _time;
  num? get timestamp => _timestamp;
  num? get lat => _lat;
  num? get lng => _lng;
  dynamic get course => _course;
  num? get speed => _speed;
  num? get altitude => _altitude;
  String? get power => _power;
  String? get address => _address;
  String? get protocol => _protocol;
  String? get driver => _driver;
  DeviceIcon? get icon => _icon;
  List<Sensors>? get sensors => _sensors;
  String? get ignitionDuration => _ignitionDuration;
  String? get idleDuration => _idleDuration;
  String? get stopDuration => _stopDuration;
  num? get totalDistance => _totalDistance;
  DeviceData? get deviceData => _deviceData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['alarm'] = _alarm;
    map['name'] = _name;
    map['online'] = _online;
    map['time'] = _time;
    map['timestamp'] = _timestamp;
    map['lat'] = _lat;
    map['lng'] = _lng;
    map['course'] = _course;
    map['speed'] = _speed;
    map['altitude'] = _altitude;
    map['power'] = _power;
    map['address'] = _address;
    map['protocol'] = _protocol;
    map['driver'] = _driver;
    if (_icon != null) {
      map['icon'] = _icon?.toJson();
    }
    if (_sensors != null) {
      map['sensors'] = _sensors?.map((v) => v.toJson()).toList();
    }
    map['ignition_duration'] = _ignitionDuration;
    map['idle_duration'] = _idleDuration;
    map['stop_duration'] = _stopDuration;
    map['total_distance'] = _totalDistance;
    if (_deviceData != null) {
      map['device_data'] = _deviceData?.toJson();
    }
    return map;
  }
}

class DeviceData {
  DeviceData({
    num? id,
    num? userId,
    num? active,
    num? deleted,
    String? name,
    String? imei,
    String? fuelQuantity,
    String? fuelPrice,
    String? fuelPerKm,
    String? simNumber,
    String? deviceModel,
    dynamic expirationDate,
  }) {
    _id = id;
    _userId = userId;
    _active = active;
    _deleted = deleted;
    _name = name;
    _imei = imei;
    _fuelQuantity = fuelQuantity;
    _fuelPrice = fuelPrice;
    _fuelPerKm = fuelPerKm;
    _simNumber = simNumber;
    _deviceModel = deviceModel;
    _expirationDate = expirationDate;
  }

  DeviceData.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _active = json['active'];
    _deleted = json['deleted'];
    _name = json['name'];
    _imei = json['imei'];
    _fuelQuantity = json['fuel_quantity'];
    _fuelPrice = json['fuel_price'];
    _fuelPerKm = json['fuel_per_km'];
    _simNumber = json['sim_number'];
    _deviceModel = json['device_model'];
    _expirationDate = json['expiration_date'];
  }
  num? _id;
  num? _userId;
  num? _active;
  num? _deleted;
  String? _name;
  String? _imei;
  String? _fuelQuantity;
  String? _fuelPrice;
  String? _fuelPerKm;
  String? _simNumber;
  String? _deviceModel;
  dynamic _expirationDate;

  num? get id => _id;
  num? get userId => _userId;
  num? get active => _active;
  num? get deleted => _deleted;
  String? get name => _name;
  String? get imei => _imei;
  String? get fuelQuantity => _fuelQuantity;
  String? get fuelPrice => _fuelPrice;
  String? get fuelPerKm => _fuelPerKm;
  String? get simNumber => _simNumber;
  String? get deviceModel => _deviceModel;
  dynamic get expirationDate => _expirationDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['active'] = _active;
    map['deleted'] = _deleted;
    map['name'] = _name;
    map['imei'] = _imei;
    map['fuel_quantity'] = _fuelQuantity;
    map['fuel_price'] = _fuelPrice;
    map['fuel_per_km'] = _fuelPerKm;
    map['sim_number'] = _simNumber;
    map['device_model'] = _deviceModel;
    map['expiration_date'] = _expirationDate;
    return map;
  }
}

/// id : 1520
/// type : "acc"
/// name : "Vehicle"
/// show_in_popup : 0
/// value : "On"
/// val : true
/// scale_value : null

class Sensors {
  Sensors({
    num? id,
    String? type,
    String? name,
    num? showInPopup,
    String? value,
    dynamic val,
    dynamic scaleValue,
  }) {
    _id = id;
    _type = type;
    _name = name;
    _showInPopup = showInPopup;
    _value = value;
    _val = val;
    _scaleValue = scaleValue;
  }

  Sensors.fromJson(dynamic json) {
    _id = json['id'];
    _type = json['type'];
    _name = json['name'];
    _showInPopup = json['show_in_popup'];
    _value = json['value'];
    _val = json['val'];
    _scaleValue = json['scale_value'];
  }
  num? _id;
  String? _type;
  String? _name;
  num? _showInPopup;
  String? _value;
  dynamic _val;
  dynamic _scaleValue;

  num? get id => _id;
  String? get type => _type;
  String? get name => _name;
  num? get showInPopup => _showInPopup;
  String? get value => _value;
  dynamic get val => _val;
  dynamic get scaleValue => _scaleValue;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['type'] = _type;
    map['name'] = _name;
    map['show_in_popup'] = _showInPopup;
    map['value'] = _value;
    map['val'] = _val;
    map['scale_value'] = _scaleValue;
    return map;
  }
}

class DeviceIcon {
  DeviceIcon({
    num? id,
    dynamic userId,
    String? type,
    dynamic order,
    num? width,
    num? height,
    String? path,
    num? byStatus,
  }) {
    _id = id;
    _userId = userId;
    _type = type;
    _order = order;
    _width = width;
    _height = height;
    _path = path;
    _byStatus = byStatus;
  }

  DeviceIcon.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _type = json['type'];
    _order = json['order'];
    _width = json['width'];
    _height = json['height'];
    _path = json['path'];
    _byStatus = json['by_status'];
  }
  num? _id;
  dynamic _userId;
  String? _type;
  dynamic _order;
  num? _width;
  num? _height;
  String? _path;
  num? _byStatus;

  num? get id => _id;
  dynamic get userId => _userId;
  String? get type => _type;
  dynamic get order => _order;
  num? get width => _width;
  num? get height => _height;
  String? get path => _path;
  num? get byStatus => _byStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['type'] = _type;
    map['order'] = _order;
    map['width'] = _width;
    map['height'] = _height;
    map['path'] = _path;
    map['by_status'] = _byStatus;
    return map;
  }
}
