class User extends Object {
  String? email;
  String? subscriptionExpiration;
  dynamic daysLeft;
  String? plan;
  int? devicesLimit;
  int? groupId;
  String? firstName;
  String? lastName;

  User(
      {this.email,
      this.subscriptionExpiration,
      this.daysLeft,
      this.plan,
      this.devicesLimit,
      this.groupId,
      this.firstName,
      this.lastName});

  User.fromJson(Map<String, dynamic> json) {
    email = json["email"];
    subscriptionExpiration = json["subscription_expiration"];
    daysLeft = json["days_left"];
    plan = json["plan"];
    devicesLimit = json["devices_limit"];
    groupId = json["group_id"];
    firstName = json["first_name"];
    lastName = json["last_name"];
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'subscription_expiration': subscriptionExpiration,
        'days_left': daysLeft,
        'plan': plan,
        'devices_limit': devicesLimit,
        'group_id': groupId,
        'first_name': firstName,
        'last_name': lastName
      };
}
