// users.dart

import 'dart:convert';

Users userFromJson(String str) => Users.fromJson(json.decode(str));
String userToJson(Users data) => json.encode(data.toJson());

class Users {
  final int? usrId;
  final String usrName;
  final String usrEmail;
  final String usrPassword;

  Users({
    this.usrId,
    required this.usrName,
    required this.usrEmail,
    required this.usrPassword,
  });

  // Use this for converting a JSON string from an API response
  factory Users.fromJson(Map<String, dynamic> json) => Users(
        usrId: json["usrId"] as int?,
        usrName: json["usrName"] as String,
        usrEmail: json["usrEmail"] as String,
        usrPassword: json["usrPassword"] as String,
      );

  // Use this for converting a Map (row) retrieved directly from the SQLite database
  // Note: Your existing fromJson works perfectly here, so we can just use that,
  // or you can explicitly define a factory with a more conventional name:
  factory Users.fromMap(Map<String, dynamic> map) => Users.fromJson(map);

  Map<String, dynamic> toJson() => {
        "usrId": usrId,
        "usrName": usrName,
        "usrEmail": usrEmail,
        "usrPassword": usrPassword,
      };
}
