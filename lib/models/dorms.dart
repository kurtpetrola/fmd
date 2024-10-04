import 'dart:convert';

Dorms userFromJson(String str) => Dorms.fromJson(json.decode(str));

String userToJson(Dorms data) => json.encode(data.toJson());

class Dorms {
  final int? dormId;
  final String dormName;
  final String dormNumber;
  final String dormLocation;
  final String createdAt;

  Dorms({
    this.dormId,
    required this.dormName,
    required this.dormNumber,
    required this.dormLocation,
    required this.createdAt,
  });

  factory Dorms.fromJson(Map<String, dynamic> json) => Dorms(
        dormId: json["dormId"],
        dormName: json["dormName"],
        dormNumber: json["dormNumber"],
        dormLocation: json["dormLocation"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toJson() => {
        "usrId": dormId,
        "usrName": dormName,
        "dormNumber": dormNumber,
        "dormLocation": dormLocation,
        "usrPassword": createdAt,
      };
}
