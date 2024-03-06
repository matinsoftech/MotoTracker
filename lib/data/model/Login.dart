class Login extends Object {
  int? status;
  String? userApiHash;

  Login({this.status, this.userApiHash});

  Login.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    userApiHash = json["user_api_hash"];
  }

  Map<String, dynamic> toJson() =>
      {'status': status, 'user_api_hash': userApiHash};
}
