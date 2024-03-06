bool isWithinTimeWindow(
    String? lastTime, String? currentTime, int windowMinutes) {
  if (lastTime == null || currentTime == null) {
    return false;
  }

  DateTime lastDateTime = _parseCustomDateTime(lastTime);
  DateTime currentDateTime = _parseCustomDateTime(currentTime);
  Duration difference = currentDateTime.difference(lastDateTime);
  int differenceMinutes = difference.inMinutes;

  return differenceMinutes <= windowMinutes;
}

DateTime _parseCustomDateTime(String dateTimeString) {
  List<String> parts = dateTimeString.split(" ");
  String datePart = parts[0];
  String timePart = parts[1];

  List<String> dateParts = datePart.split("-");
  int day = int.parse(dateParts[0]);
  int month = int.parse(dateParts[1]);
  int year = int.parse(dateParts[2]);

  String period = parts[2];
  List<String> timeParts = timePart.split(":");
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);
  if (period == "PM") {
    hour += 12;
  }

  return DateTime(year, month, day, hour, minute);
}
