class NewReport {
  List<NewModelItem>? items;

  NewReport({this.items});
  factory NewReport.fromJson(Map<String, dynamic> json) {
    return NewReport(
      items: json['items'] != null
          ? List<NewModelItem>.from(
              json['items'].map((x) => NewModelItem.fromJson(x)))
          : null,
    );
  }
}

class NewModelItem {
  List<FuelReport>? fuelReport;

  NewModelItem({this.fuelReport});

  factory NewModelItem.fromJson(Map<String, dynamic> json) {
    var sensorKey = json['fuel_tank_sensors']?.isNotEmpty == true
        ? json['fuel_tank_sensors'][0]
        : null;
    print(sensorKey);
    print(json['current_fuel'].toString());

    return NewModelItem(
      fuelReport: json['current_fuel']?.isNotEmpty == true && sensorKey != null
          ? List<FuelReport>.from((json['current_fuel'][sensorKey] as Map)
                  .map((k, v) => MapEntry(k, FuelReport.fromJson(v)))
                  .values)
              .toList()
          : null,
    );
  }
}

class FuelReport {
  DateTime? startDate;
  double? startValue;
  DateTime? stopDate;
  double? endValue;
  double? totalConsumption;
  double? totalDistanceTravelled;
  double? totalRefill;
  double? totalTheft;

  FuelReport({
    this.startDate,
    this.startValue,
    this.stopDate,
    this.endValue,
    this.totalConsumption,
    this.totalDistanceTravelled,
    this.totalRefill,
    this.totalTheft,
  });

  factory FuelReport.fromJson(Map<String, dynamic> json) => FuelReport(
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        startValue: double.tryParse(json["start_value"].toString()),
        stopDate: json["stop_date"] == null
            ? null
            : DateTime.parse(json["stop_date"]),
        endValue: json["end_value"] == null
            ? 0.0
            : double.tryParse(json["end_value"].toString()),
        totalConsumption: json["total_consumption"] == null
            ? 0.0
            : double.tryParse(json["total_consumption"].toString()),
        totalDistanceTravelled: json["total_distance_travelled"] == null
            ? 0.0
            : double.tryParse(json["total_distance_travelled"].toString()),
        totalRefill: json["total_refill"] == null
            ? 0.0
            : double.tryParse(json["total_refill"].toString()),
        totalTheft: json["total_theft"] == null
            ? 0.0
            : double.tryParse(json["total_theft"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "start_date": startDate?.toIso8601String(),
        "start_value": startValue,
        "stop_date": stopDate?.toIso8601String(),
        "end_value": endValue,
        "total_consumption": totalConsumption,
        "total_distance_travelled": totalDistanceTravelled,
        "total_refill": totalRefill,
        "total_theft": totalTheft,
      };
}
