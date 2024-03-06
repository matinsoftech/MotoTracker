import 'dart:developer';

class ReportModel {
  List<Items>? items;

  ReportModel({this.items});

  ReportModel.fromJson(Map<String, dynamic> json) {
    items = json["items"] == null
        ? null
        : List<Items>.from(json["items"].map((x) => Items.fromJson(x)));
  }
}

class Items {
  int? api;
  String? dateFrom;
  String? dateTo;
  int? history;
  int? topSpeed;
  String? distanceSum;
  String? moveDuration;
  String? stopDuration;
  int? averageSpeed;
  int? overspeedCount;
  String? routeStart;
  String? routeEnd;
  bool? showAddresses;
  int? stopSpeed;
  double? stopKm;
  int? speedLimit;
  bool? getOverspeeds;
  bool? getUnderspeeds;
  int? overspeedsCount;
  int? underspeedsCount;
  String? unitOfDistance;
  String? distanceUnitHour;
  String? unitOfAltitude;
  String? odometer;
  String? odometerSensorId;
  String? engineHours;
  String? engineWork;
  String? engineIdle;
  FuelTankThefts? fuelTankThefts;
  FuelTankFillings? fuelTankFillings;
  FuelConsumption? fuelConsumption;
  String? engineSensor;
  int? engineStatus;
  String? reportType;
  SensorsArr? sensorsArr;
  SensorValues? sensorValues;

  Items({
    this.api,
    this.dateFrom,
    this.dateTo,
    this.history,
    this.topSpeed,
    this.distanceSum,
    this.moveDuration,
    this.stopDuration,
    this.averageSpeed,
    this.overspeedCount,
    this.routeStart,
    this.routeEnd,
    this.showAddresses,
    this.stopSpeed,
    this.stopKm,
    this.speedLimit,
    this.getOverspeeds,
    this.getUnderspeeds,
    this.overspeedsCount,
    this.underspeedsCount,
    this.unitOfDistance,
    this.distanceUnitHour,
    this.unitOfAltitude,
    this.odometer,
    this.odometerSensorId,
    this.engineHours,
    this.engineWork,
    this.engineIdle,
    this.fuelTankThefts,
    this.fuelTankFillings,
    this.fuelConsumption,
    this.engineSensor,
    this.engineStatus,
    this.reportType,
    this.sensorsArr,
    this.sensorValues,
  });

  factory Items.fromJson(Map<String, dynamic> json) {
    var sensorKey = json['fuel_tank_sensors'].isNotEmpty
        ? json['fuel_tank_sensors'][0]
        : null;
    return Items(
      api: json["api"],
      dateFrom: json["date_from"],
      dateTo: json["date_to"],
      history: json["history"],
      topSpeed: json["top_speed"],
      distanceSum: json["distance_sum"],
      moveDuration: json["move_duration"],
      stopDuration: json["stop_duration"],
      averageSpeed: json["average_speed"],
      overspeedCount: json["overspeed_count"],
      routeStart: json["route_start"],
      routeEnd: json["route_end"],
      showAddresses: json["show_addresses"],
      stopSpeed: int.tryParse(json["stop_speed"].toString()),
      stopKm: json["stop_km"],
      speedLimit: json["speed_limit"],
      getOverspeeds: json["getOverspeeds"],
      getUnderspeeds: json["getUnderspeeds"],
      overspeedsCount: json["overspeeds_count"],
      underspeedsCount: json["underspeeds_count"],
      unitOfDistance: json["unit_of_distance"],
      distanceUnitHour: json["distance_unit_hour"],
      unitOfAltitude: json["unit_of_altitude"],
      odometer: json["odometer"],
      odometerSensorId: json["odometer_sensor_id"],
      engineHours: json["engine_hours"],
      engineWork: json["engine_work"],
      engineIdle: json["engine_idle"],
      fuelTankFillings: json['fuel_tank_fillings'].isNotEmpty
          ? FuelTankFillings.fromJson(json["fuel_tank_fillings"], sensorKey)
          : null,
      fuelTankThefts: json['fuel_tank_thefts'].isNotEmpty
          ? FuelTankThefts.fromJson(json["fuel_tank_thefts"], sensorKey)
          : null,
      fuelConsumption: json['fuel_consumption'].isNotEmpty
          ? FuelConsumption.fromJson(json['fuel_consumption'], sensorKey)
          : null,
      engineSensor: json["engine_sensor"],
      engineStatus: json["engine_status"],
      reportType: json["report_type"],
      sensorsArr: json['sensors_arr'].isNotEmpty
          ? SensorsArr.fromJson(json['sensors_arr'], sensorKey)
          : null,
      sensorValues: json['sensor_values'] != null
          ? SensorValues.fromJson(json['sensor_values'], sensorKey)
          : null,
    );
  }
}

class FuelTankThefts {
  List<Sensor6>? sensor6;

  FuelTankThefts({this.sensor6});

  factory FuelTankThefts.fromJson(Map<String, dynamic> json, String key) {
    return FuelTankThefts(
        sensor6: json[key] != null
            ? List<Sensor6>.from(
                json[key].map(
                  (x) => Sensor6.fromJson(x),
                ),
              )
            : json[key] != null
                ? List<Sensor6>.from(
                    json[key].map(
                      (x) => Sensor6.fromJson(x),
                    ),
                  )
                : null);
  }
}

class FuelTankFillings {
  List<Sensor6>? sensor6;

  FuelTankFillings({this.sensor6});

  factory FuelTankFillings.fromJson(Map<String, dynamic> json, String key) {
    return FuelTankFillings(
        sensor6: json[key] != null
            ? List<Sensor6>.from(
                json[key].map(
                  (x) => Sensor6.fromJson(x),
                ),
              )
            : json[key] != null
                ? List<Sensor6>.from(
                    json[key].map(
                      (x) => Sensor6.fromJson(x),
                    ),
                  )
                : null);
  }
}

class Sensor6 {
  String? time;
  String? last;
  double? diff;
  double? speed;
  String? current;
  String? lat;
  String? lng;
  String? address;

  Sensor6(
      {this.time,
      this.last,
      this.diff,
      this.speed,
      this.current,
      this.lat,
      this.lng,
      this.address});

  Sensor6.fromJson(Map<String, dynamic> json) {
    time = json['time'].toString();
    last = json['last'].toString();
    diff = double.tryParse(json['diff'].toString());
    speed = double.tryParse(json['speed'].toString());

    current = json['current'];
    lat = json['lat'].toString();
    lng = json['lng'].toString();
    address = json['address'];
  }
}

class FuelConsumption {
  double? sensor6;

  FuelConsumption({this.sensor6});

  FuelConsumption.fromJson(Map<String, dynamic> json, String key) {
    sensor6 = json[key] != null
        ? double.tryParse(json[key].toString())
        : json[key] != null
            ? double.tryParse(json[key].toString())
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sensor_12'] = sensor6;
    return data;
  }
}

class SensorsArr {
  Sensor6? sensor6;

  SensorsArr({this.sensor6});

  SensorsArr.fromJson(Map<String, dynamic> json, String key) {
    sensor6 = json[key] != null ? Sensor6.fromJson(json[key]) : null;
  }
}

class SensorValues {
  List<FuelLevel>? sensor6;

  SensorValues({this.sensor6});

  SensorValues.fromJson(Map<String, dynamic> json, String key) {
    sensor6 = json[key] != null
        ? List<FuelLevel>.from(
            json[key].map(
              (x) => FuelLevel.fromJson(x),
            ),
          )
        : json[key] != null
            ? List<FuelLevel>.from(
                json[key].map(
                  (x) => FuelLevel.fromJson(x),
                ),
              )
            : null;
  }
}

class FuelLevel {
  String? t;
  String? currentFuel;
  String? i;

  FuelLevel({
    this.t,
    this.currentFuel,
    this.i,
  });

  factory FuelLevel.fromJson(Map<String, dynamic> json) {
    return FuelLevel(
      t: json["t"],
      currentFuel: json["v"].toString(),
      i: json["i"].toString(),
    );
  }
}
