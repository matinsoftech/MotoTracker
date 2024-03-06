import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkUtil {
  static final NetworkUtil _instance = NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = const JsonDecoder();

  Future<dynamic> get(String url){
    return http.get(Uri.parse(url)).then((http.Response response){
      final String res = response.body;
      final int statusCode = response.statusCode;

      if(statusCode<200 || statusCode>400){
        throw Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }
  static Map<String, String> headers = {};
  Future<dynamic> post(String url, {headers, body, encoding}){
    return http
        .post(Uri.parse(url), body: body, headers: headers, encoding: encoding)
        .then((http.Response response){

          final String res = response.body;
          final int statusCode = response.statusCode;
          if(statusCode<200 || statusCode>400){
            throw Exception("Error while fetching data");
          }
          return _decoder.convert(res);
    });
  }
}