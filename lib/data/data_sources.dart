import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/model/position_history.dart';
import 'package:myvtsproject/data/modelold/events.dart';
import 'package:myvtsproject/data/model/history.dart';
import 'package:myvtsproject/data/modelold/report_model.dart' as report;
import 'package:myvtsproject/utils/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/GeofenceModel.dart';
import 'model/add_alert_request.dart';
import 'model/alert_type.dart';
import 'model/event.dart';
import 'model/user.dart';
import 'modelold/devices.dart';
import 'model/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';

class GPSAPIS {
  static final baseUrl = StaticVarMethod.baseurlall;

  static final loginUrl = "$baseUrl/api/login";
  static final devicesUrl = "$baseUrl/api/get_devices";
  static final historyUrl = "$baseUrl/api/get_history";
  static final eventsUrl = "$baseUrl/api/get_events";
  static final addressUrl = " $baseUrl/api/geoAddress_Mbl";
  // static final addressUrl = "$baseUrl/api/geo_address";
  static final skuListUrl = "$baseUrl/api/Mapi/SKUList";
  static final planPolicyListUrl = "$baseUrl/api/Mapi/PlanPolicyList";
  static final parkingModeUrl = "$baseUrl/api/update_parking_mode";

  static final instPriceBySkuAutoUrl = "$baseUrl/api/Mapi/InstPriceBySKUAuto";

  static final supplierListUrl = "$baseUrl/api/Mapi/GetSuppliers";
  static final getAllBrancesDailySaleUrl =
      "$baseUrl/api/Mapi/GetAllBranchesDailySale";

  static Map<String, String> headers = {};

  Future getDevicesList(String? userApiHash) async {
    return Session.apiGet("$devicesUrl?user_api_hash=$userApiHash")
        .then((dynamic res) {
      var jsonData = json.decode(res.toString());
      try {
        List<DeviceItems> list = [];
        for (var i = 0; i < jsonData.length; i++) {
          for (var p in Devices.fromJson(jsonData[i]).items ?? []) {
            list.add(p);
          }
        }
        return list;
      } catch (e) {
        log(e.toString());
      }
    });
  }

  static Future<bool> updateParkingMode(
      {required String userAPiHash,
      required String mode,
      required String deviceId}) async {
    final url = Uri.parse(parkingModeUrl);
    var response = await http.post(url, body: {
      'user_api_hash': userAPiHash,
      'mode': mode,
      'device_id': deviceId,
    });
    log(response.request!.url.toString());
    log(response.body);
    log(response.statusCode.toString());
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<List<DeviceItems>> getDevicesItems(String? userApiHash) async {
    final response =
        await http.get(Uri.parse("$devicesUrl?user_api_hash=$userApiHash"));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      try {
        List<DeviceItems> list = [];
        for (var i = 0; i < jsonData.length; i++) {
          for (var p in Devices.fromJson(jsonData[i]).items ?? []) {
            list.add(p);
          }
        }
        return list;
      } catch (_) {
        List<DeviceItems> list = [];
        return list;
      }
    } else {
      List<DeviceItems> list = [];
      return list;
    }
  }

  Future<http.Response> getlogin(String email, String password) async {
    print("$loginUrl?email=$email&password=$password");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceId = await PlatformDeviceId.getDeviceId;
    final http.Response response;
    if (email.contains("@")) {
      response = await http.post(
          Uri.parse(
            loginUrl,
          ),
          body: {
            'email': email,
            'password': password,
            'login_device_id': deviceId,
          });
    } else {
      response = await http
          .get(Uri.parse("$loginUrl?phone=$email&password=$password"));
    }
    print(response.statusCode);
    if (response.statusCode == 200) {
      var res = LoginModel.fromJson(json.decode(response.body));
      StaticVarMethod.userAPiHash = res.userApiHash;

      await prefs.setString('email', email);
      await prefs.setString('password', password);
      return response;
    } else {
      return response;
    }
  }

  getEventsList(String? userApiHash) async {
    return Session.apiGet("$eventsUrl?lang=en&user_api_hash=$userApiHash")
        .then((dynamic res) {
      var jsonData = json.decode(res.toString());
      try {
        List<EventsData> list = [];
        var events = Events.fromJson(jsonData);
        print(events);
        for (var i = 0; i < events.items!.data!.length; i++) {
          list.add(events.items!.data![i]);
        }
        return list;
      } catch (_) {}
    });
  }

  static Future<List<AlertEvent>> getAlertEvent() async {
    final response = await http.get(Uri.parse(
        "$baseUrl/api/get_custom_events?lang=en&user_api_hash=${StaticVarMethod.userAPiHash}"));

    log(response.request!.url.toString());
    log(response.body);

    if (response.statusCode == 200) {
      try {
        var jsonData = json.decode(response.body)["items"]['events']["data"];
        return List<AlertEvent>.from(
            jsonData.map((x) => AlertEvent.fromJson(x))).toList();
      } catch (e) {
        log(e.toString());
        List<AlertEvent> list = [];
        return list;
      }
    } else {
      List<AlertEvent> list = [];
      return list;
    }
  }

  //Get alertTypes
  static Future<List<AlertType>> getAlertTypes() async {
    final response = await http.get(Uri.parse(
        "$baseUrl/api/get_alerts?lang=en&user_api_hash=${StaticVarMethod.userAPiHash}"));

    log(response.request!.url.toString());

    if (response.statusCode == 200) {
      try {
        var jsonData = json.decode(response.body)["items"]['alerts'];
        return List<AlertType>.from(jsonData.map((x) => AlertType.fromJson(x)))
            .toList();
      } catch (_) {
        List<AlertType> list = [];
        return list;
      }
    } else {
      List<AlertType> list = [];
      return list;
    }
  }

  //Add Alert
  static Future<bool> addAlert({AddAlertRequest? addAlertRequest}) async {
    log(jsonEncode(addAlertRequest?.toJson()));
    final response = await http.post(Uri.parse("$baseUrl/api/add_alert"),
        body: addAlertRequest?.toJson(),
        headers: {
          "Accept": "application/json",
        });

    log(response.request!.url.toString());
    log(response.body);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<List<TripsItems>?> getHistoryTripList({
    String? userApiHash,
    required int deviceId,
    required String fromDate,
    required String toDate,
    required String fromTime,
    required String toTime,
  }) async {
    return Session.apiGet(
            "$historyUrl?lang=en&user_api_hash=${StaticVarMethod.userAPiHash}&device_id=$deviceId&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&snap_to_road=false")
        .then((dynamic res) {
      //print full url

      var jsonData = json.decode(res.toString());
      try {
        List<TripsItems> list = [];
        var history = History.fromJson(jsonData);
        for (var i = 0; i < history.items!.length; i++) {
          list.add(history.items![i]);
        }
        return list;
      } catch (e) {
        log(e.toString());
      }
      return null;
    });
  }

  getHistoryAllList(String? userApiHash) async {
    return Session.apiGet(
            "$historyUrl?lang=en&user_api_hash=$userApiHash&device_id=${StaticVarMethod.deviceId}&from_date=${StaticVarMethod.fromdate}&from_time=${StaticVarMethod.fromtime}&to_date=${StaticVarMethod.todate}&to_time=${StaticVarMethod.totime}")
        .then((dynamic res) {
      var jsonData = json.decode(res.toString());
      try {
        List<AllItems> list = [];

        var history = History.fromJson(jsonData);
        for (var i = 0; i < history.items!.length; i++) {
          for (var p in history.items![i].items ?? []) {
            list.add(p);
          }
        }
        return list;
      } catch (_) {}
    });
  }

  static Future<History> getTripSummary({
    String? userApiHash,
    required int deviceId,
    required String fromDate,
    required String toDate,
    required String fromTime,
    required String toTime,
  }) async {
    final response = await http.get(Uri.parse(
        "$historyUrl?lang=en&user_api_hash=${StaticVarMethod.userAPiHash}&device_id=$deviceId&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&snap_to_road=false"));
    if (response.statusCode == 200) {
      try {
        return History.fromJson(json.decode(response.body));
      } catch (_) {
        History model = History();
        return model;
      }
    } else {
      History model = History();
      return model;
    }
  }

  static Future<String> getDistanceSums({
    String? userApiHash,
    required int deviceId,
    required String fromDate,
    required String toDate,
    required String fromTime,
    required String toTime,
  }) async {
    headers['content-type'] = "application/json";
    final response = await http.get(
        Uri.parse(
            "$historyUrl?lang=en&user_api_hash=${StaticVarMethod.userAPiHash}&device_id=$deviceId&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&snap_to_road=false"),
        headers: headers);
    if (response.statusCode == 200) {
      try {
        return json.decode(response.body)["distance_sum"];
      } catch (_) {
        return "Error catch";
      }
    } else {
      return "Error";
    }
  }

  static Future<History> getStoppage({
    String? userApiHash,
    required int deviceId,
    required String fromDate,
    required String toDate,
    required String fromTime,
    required String toTime,
  }) async {
    final response = await http.get(Uri.parse(
        "$historyUrl?lang=en&user_api_hash=${StaticVarMethod.userAPiHash}&device_id=$deviceId&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&snap_to_road=false"));
    if (response.statusCode == 200) {
      try {
        return History.fromJson(json.decode(response.body));
      } catch (_) {
        History model = History();
        return model;
      }
    } else {
      History model = History();
      return model;
    }
  }

  Future<History> getHistory(String? userApiHash) async {
    final response = await http.get(Uri.parse(
        "$historyUrl?lang=en&user_api_hash=$userApiHash&device_id=369&from_date=2022-08-13&from_time=00:00&to_date=2022-08-13&to_time=11:45"));
    if (response.statusCode == 200) {
      try {
        return History.fromJson(json.decode(response.body));
      } catch (_) {
        History model = History();
        return model;
      }
    } else {
      History model = History();
      return model;
    }
  }

  Future<Events> getEvents(String? userApiHash) async {
    final response = await http
        .get(Uri.parse("$eventsUrl?lang=en&user_api_hash=$userApiHash"));
    if (response.statusCode == 200) {
      try {
        return Events.fromJson(json.decode(response.body));
      } catch (_) {
        Events model = Events();
        return model;
      }
    } else {
      Events model = Events();
      return model;
    }
  }

  static Future<PositionHistory?> getHistorynew(String deviceID,
      String fromDate, String fromTime, String toDate, String toTime) async {
    final response = await http.get(Uri.parse(
        "$historyUrl?lang=en&user_api_hash=${StaticVarMethod.userAPiHash}&from_date=$fromDate&from_time=$fromTime&to_date=$toDate&to_time=$toTime&device_id=$deviceID"));
    if (response.statusCode == 200) {
      return PositionHistory.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  static Future<http.Response> getGeocoder(lat, lng) async {
    // headers['content-type'] =
    //     "application/x-www-form-urlencoded; charset=UTF-8";

    log("http://app.merogaditracker.com/api/geo_address?lat=$lat&lon=$lng&user_api_hash=${StaticVarMethod.userAPiHash!}");

    final response = await http.get(
      Uri.parse(
          "http://app.merogaditracker.com/api/geo_address?lat=$lat&lon=$lng&user_api_hash=${StaticVarMethod.userAPiHash!}"),
    );

    log(response.body);
    log(response.request!.url.toString());
    return response;
  }

  //reports

  static Future<http.Response> getReport(
      String deviceID, String fromDate, String toDate, int type,
      {String? fromTime, String? toTime}) async {
    String url =
        "$baseUrl/api/generate_report?user_api_hash=${StaticVarMethod.userAPiHash}&date_from=${StaticVarMethod.fromdate}&date_to=${StaticVarMethod.todate}&lang=en&type=${StaticVarMethod.reportType}&time_from=${StaticVarMethod.fromtime}&time_to=${StaticVarMethod.totime}&format=html&devices[]=${StaticVarMethod.deviceId}&generate=1";

    final response = await http.post(Uri.parse(url));

    log(response.request!.url.toString());
    if (response.statusCode == 200) {
      return response;
    } else {
      return response;
    }
  }

  static Future<String?> getReportDownloadUrl(
      String deviceID, String fromDate, String toDate, int type,
      {String? fromTime, String? toTime}) async {
    String url =
        "$baseUrl/reports/update?format=html&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=${StaticVarMethod.reportType}&devices[]=${StaticVarMethod.deviceId}&title=dasdsad";

    final response = await http.post(Uri.parse(url), body: {
      "user_api_hash": StaticVarMethod.userAPiHash,
    });

    log(response.request!.url.toString());
    log(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["url"];
    } else {
      return null;
    }
  }

  static Future<RouteReport?> getKMReport(String deviceID, String fromDate,
      String toDate, int type, String toTime, String fromTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse(
        "${baseUrl}api/generate_report?user_api_hash=${prefs.getString('user_api_hash')}&date_from=$fromDate&devices[]=$deviceID&date_to=$toDate&format=pdf&type=2&from_time=$fromTime&to_time=$toTime"));
    if (response.statusCode == 200) {
      return RouteReport.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  static Future<User?> getUserData() async {
    final response = await http.get(Uri.parse(
        "$baseUrl/api/get_user_data?user_api_hash=${StaticVarMethod.userAPiHash!}"));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body)["user"]);
    } else {
      return null;
    }
  }

  static changePassword(String val) async {
    String url =
        "$baseUrl/api/change_password?user_api_hash=${StaticVarMethod.userAPiHash!}&lang=en&password=$val&password_confirmation=$val";

    return Session.apiPost(url, "").then((dynamic res) {
      var responseBool = res;
      return responseBool;
    });
  }

  static Future<http.Response> activateFCM(token) async {
    final response = await http.get(
        Uri.parse(
            "$baseUrl/api/fcm_token?user_api_hash=${StaticVarMethod.userAPiHash!}&token=$token"),
        headers: headers);

    log(StaticVarMethod.notificationToken);

    log(response.request!.url.toString());
    log(response.body);
    return response;
  }

  static Future<http.Response?> login(email, password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.post(
          Uri.parse("$baseUrl/api/login?email=$email&password=$password"));

      if (response.statusCode == 200) {
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        return response;
      } else {
        return response;
      }
    } catch (e) {
      return null;
    }
  }

  static getFuelRefills() async {
    List<report.Items>? fuelRefills;
    String? distanceSumFuel;
    print(StaticVarMethod.totime);
    http.Response response = await http.post(
        Uri.parse(
            "$baseUrl/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=11&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
        body: {
          "user_api_hash": StaticVarMethod.userAPiHash,
        });
    log(response.request.toString());
    fuelRefills =
        report.ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
    if (fuelRefills != null) {
      if (fuelRefills.isNotEmpty) {
        distanceSumFuel = fuelRefills[0].distanceSum;
      }
      distanceSumFuel ??= "0";
    }
    return distanceSumFuel;
  }

  static getFuelRefillsNow() async {
    List<report.Items>? fuelRefills;

    print(StaticVarMethod.totime);
    var response = await http.post(
      Uri.parse(
          "$baseUrl/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=11&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}"),
      body: {
        "user_api_hash": StaticVarMethod.userAPiHash,
      },
    );

    log(response.request.toString());

    log('Status code: ${response.statusCode}');

    log('Response body: ${response.body}');

    //if 302
    if (response.statusCode == 302) {
      log('Redirecting to ${response.headers["location"]}');
      var url = response.headers["location"];

      response = await http.get(Uri.parse(url!));
    }

    if (response.statusCode == 200) {
      fuelRefills =
          report.ReportModel.fromJson(jsonDecode(response.body)["data"]).items;
    }

    return fuelRefills;
  }

  ////////////////Geofences//////////////
  static Future<List<Geofence>?> getGeoFences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    headers['Accept'] = "application/json";
    final response = await http.get(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/get_geofences?user_api_hash=" +
            StaticVarMethod.userAPiHash!),
        headers: headers);
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body)['items']['geofences'];
      if (list.isNotEmpty) {
        return list.map((model) => Geofence.fromJson(model)).toList();
      } else {
        return null;
      }
    } else {
      print(response.statusCode);
      return null;
    }
  }

  static Future<http.Response> addGeofence(fence) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    headers['content-type'] =
        "application/x-www-form-urlencoded; charset=UTF-8";
    final response = await http.post(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/add_geofence?user_api_hash=" +
            StaticVarMethod.userAPiHash!),
        body: fence,
        headers: headers);
    return response;
  }

  static Future<http.Response> editGeoFence(fence) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    headers['content-type'] =
        "application/x-www-form-urlencoded; charset=UTF-8";
    final response = await http.post(
        Uri.parse(StaticVarMethod.baseurlall +
            "/api/edit_geofence?user_api_hash=" +
            StaticVarMethod.userAPiHash!),
        body: fence,
        headers: headers);
    return response;
  }

  static Future<http.Response> updateGeofence(String fence, String id) async {
    headers['content-type'] = "application/json; charset=utf-8";
    final response = await http.put(
        Uri.parse(StaticVarMethod.baseurlall + "/api/geofences/" + id),
        body: fence,
        headers: headers);
    return response;
  }
}

class RouteReport extends Object {
  int? status;
  String? url;
  RouteReport({this.status, this.url});

  RouteReport.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    url = json["url"];
  }
}
