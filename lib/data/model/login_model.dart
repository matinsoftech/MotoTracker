/// status : 1
/// user_api_hash : "$2y$10$8MV3tJb7PlW2O/mIBoT.tuFd0ZJoanvlQzlymF8Ls6YcrD4EBE0ji"

class LoginModel {
  num? status;
  String? userApiHash;
  Data? data;

  LoginModel({
    this.status,
    this.userApiHash,
    this.data,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json["status"],
      userApiHash: json["user_api_hash"],
      data: Data.fromJson(json["user"]),
    );
  }
}

class Data {
  int? id;

  Data({this.id});
  Data.fromJson(dynamic json) {
    id = json['id'];
  }

// Map<String, dynamic> toJson() {
//   final map = <String, dynamic>{};
//   map['id'] = id;
//   return map;
// }
}
