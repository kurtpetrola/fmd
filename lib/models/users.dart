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

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        usrName: json["usrName"],
        usrEmail: json["usrEmail"],
        usrPassword: json["usrPassword"],
      );

  Map<String, dynamic> toJson() => {
        "usrId": usrId,
        "usrName": usrName,
        "usrEmail": usrEmail,
        "usrPassword": usrPassword,
      };
}
