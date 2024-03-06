import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'consts.dart';

var cj = CookieJar();

class Session {
  static HttpClient client = HttpClient();

  static Future<String> apiGet(String url) async {
    HttpClientRequest request = await client.getUrl(Uri.parse(url));
    log(url);
    HttpClientResponse response = await request.close();
    return await response.transform(utf8.decoder).join();
  }

  static Future<String> apiPost(String url, dynamic data) async {
    HttpClientRequest request = await client.postUrl(Uri.parse(url));

    _setHeadersCookies(request, url);

    request.add(utf8.encode(json.encode(data)));
    HttpClientResponse response = await request.close();

    _updateCookies(response, url);

    return await response.transform(utf8.decoder).join();
  }

  static Future<void> _setHeadersCookies(
      HttpClientRequest request, String url) async {
    request.headers.set('content-type', 'application/json');
    request.headers.set('Accept', 'application/json');
    request.headers.set('Authorization', 'Bearer ${Consts.token}');
    request.headers.set('UserID', Consts.userId);
    request.cookies.addAll(await cj.loadForRequest(Uri.parse(url)));
  }

  static void _updateCookies(HttpClientResponse response, String url) {
    cj.saveFromResponse(Uri.parse(url), response.cookies);
  }
}
