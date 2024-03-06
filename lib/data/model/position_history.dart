class PositionHistory extends Object {
  List<dynamic>? items;
  String? distanceSum;
  String? topSpeed;
  String? moveDuration;
  String? stopDuration;
  String? fuelConsumption;

  PositionHistory({this.items, this.distanceSum});

  PositionHistory.fromJson(Map<String, dynamic> json) {
    items = json["items"];
    distanceSum = json["distance_sum"];
    topSpeed = json['top_speed'];
    moveDuration = json['move_duration'];
    stopDuration = json['stop_duration'];
    fuelConsumption = json['fuel_consumption'];
  }
}
