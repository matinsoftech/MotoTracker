/*
this is constant pages
 */

import 'package:flutter/material.dart';

const String appName = 'DevKit';

// color for apps
const Color primaryColor = Color(0xFF0181cc);
const Color accentColor = Color(0xFFe75f3f);

const Color black21 = Color(0xFF212121);
const Color blackColor = Color(0xff000000);
const Color black55 = Color(0xFF555555);
const Color black77 = Color(0xFF777777);
const Color softGrey = Color(0xFFaaaaaa);
const Color softBlue = Color(0xff01aed6);

const int statusOk = 200;
const int statusBadRequest = 400;
const int statusNotAuthorized = 403;
const int statusNotFound = 404;
const int statusInternalError = 500;

const String errorOccured = 'Error occured, please try again later';

const int limitPage = 8;

const String globalUrl = 'https://devkit.ijteknologi.com';
//const String GLOBAL_URL = 'http://192.168.0.4/devkit';

const String serverUrl = 'https://devkit.ijteknologi.com/api';
//const String SERVER_URL = 'http://192.168.0.4/devkit/api';

const String loginApi = "$serverUrl/authentication/login";
const String productApi = "$serverUrl/example/getProduct";
