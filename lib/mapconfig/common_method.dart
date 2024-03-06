import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

String formatTime(String time) {
  DateTime lastUpdate = DateTime.parse(time);
  return DateFormat('dd-MM-yyyy hh:mm:ss aa').format(lastUpdate.toLocal());
}

String formatDateReport(String date) {
  DateTime lastUpdate = DateTime.parse(date);
  return DateFormat('yyyy-MM-dd').format(lastUpdate.toLocal());
}

String formatTimeReport(String date) {
  DateTime lastUpdate = DateTime.parse(date);
  return DateFormat('hh:mm:ss').format(lastUpdate.toLocal());
}

String convertSpeed(var speed) {
  return "${speed.toInt()} Km/h";
}

String convertDistance(double distance) {
  double calcDistance = distance / 1000;
  return "${calcDistance.toStringAsFixed(2)} Km";
}

String convertDuration(int duration) {
  double hours = duration / 3600000;
  double minutes = duration % 3600000 / 60000;
  return "${hours.toInt()} hr ${minutes.toInt()} min";
}

Future<Uint8List?> getBytesFromAsset(String path, int width,
    {int? red, int? blue, int? green}) async {
  if (path.isNotEmpty) {

    ByteData data = await rootBundle.load(path);
    Uint8List imageU8 = data.buffer.asUint8List(
      data.offsetInBytes, data.lengthInBytes
    );
    List<int> dataListInt = imageU8.cast<int>();

    img.Image iconImage = img.decodePng(dataListInt)!;

    img.colorOffset(
      iconImage,
      red: red ?? 128,
      blue: blue ?? 128,
      green: green ?? 128,
    );

    iconImage = img.copyResize(iconImage, width: width);

    final Uint8List iconImageColorful = Uint8List.fromList(img.encodePng(iconImage));
    // BitmapDescriptor newIcon = BitmapDescriptor.fromBytes(iconImageColorful);
    // ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
    //     targetWidth: width);
    // ui.FrameInfo fi = await codec.getNextFrame();
    return (iconImageColorful)
        .buffer
        .asUint8List();
  } else {
    return null;
  }
}

Future<Uint8List?> getBytesFromBytes(var data, int width) async {
  if (data != null) {
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  } else {
    return null;
  }
}

LatLngBounds boundsFromLatLngList(List<dynamic> list) {
  assert(list.isNotEmpty);
  double? x0, x1, y0, y1;
  for (var value in list) {
    if (x0 == null) {
      x0 = x1 = double.parse(value['lat'].toString());
      y0 = y1 = double.parse(value['lng'].toString());
    } else {
      if (double.parse(value['lat'].toString()) > x1!) {
        x1 = double.parse(value['lat'].toString());
      }
      if (double.parse(value['lat'].toString()) < x0) {
        x0 = double.parse(value['lat'].toString());
      }
      if (double.parse(value['lng'].toString()) > y1!) {
        y1 = double.parse(value['lng'].toString());
      }
      if (double.parse(value['lng'].toString()) < y0!) {
        y0 = double.parse(value['lng'].toString());
      }
    }
  }
  return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
}

LatLngBounds boundsFromLatLngGeofenceList(Set<Marker> list) {
  assert(list.isNotEmpty);
  double? x0, x1, y0, y1;
  for (var value in list) {
    if (x0! == null) {
      x0 = x1 = value.position.latitude;
      y0 = y1 = value.position.longitude;
    } else {
      if (value.position.latitude > x1!) x1 = value.position.latitude;
      if (value.position.latitude < x0) x0 = value.position.latitude;
      if (value.position.longitude > y1!) y1 = value.position.longitude;
      if (value.position.longitude < y0!) y0 = value.position.longitude;
    }
  }
  return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
}

Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(
    String color, String path, int width) async {
  if (path == null) {
    if (color == "yellow") {
      path = "images/marker_arrow_static.png";
    } else if (color == "green") {
      path = "images/marker_arrow_online.png";
    } else if (color == "red") {
      path = "images/marker_arrow_offline.png";
    }
    final Uint8List? imageData = await getBytesFromAsset(path, width);
    return BitmapDescriptor.fromBytes(imageData!);
  } else {
    final Uint8List? imageData = await getBytesFromAsset(path, width);
    return BitmapDescriptor.fromBytes(imageData!);
  }
}

Future<BitmapDescriptor> getBitmapDescriptorFromBytes(
    var path, int width) async {
  final Uint8List? imageData = await getBytesFromBytes(path, width);
  return BitmapDescriptor.fromBytes(imageData!);
}

String formatReportDate(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date.toLocal());
}

String formatReportTime(TimeOfDay timeOfDay) {
  return "${timeOfDay.hour}:${timeOfDay.minute}";
}

String convertCourse(double course) {
  if ((course >= 15) && (course < 75)) {
    return "NE";
  } else if ((course >= 75) && (course < 105)) {
    return "E";
  } else if ((course >= 105) && (course < 165)) {
    return "SE";
  } else if ((course >= 165) && (course < 195)) {
    return "S";
  } else if ((course >= 195) && (course < 255)) {
    return "SW";
  } else if ((course >= 255) && (course < 285)) {
    return "W";
  } else if ((course >= 285) && (course < 345)) {
    return "NW";
  } else {
    return "N";
  }
}
