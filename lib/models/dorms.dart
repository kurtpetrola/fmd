// models/dorms.dart

import 'dart:convert';

Dorms dormsFromJson(String str) => Dorms.fromJson(json.decode(str));

String dormsToJson(Dorms data) => json.encode(data.toJson());

class Dorms {
  final int? dormId;
  final String dormName;
  final String dormNumber;
  final String dormLocation;
  //final String dormImageUrl;
  //final String dormDescription;
  final String createdAt;

  Dorms({
    this.dormId,
    required this.dormName,
    required this.dormNumber,
    required this.dormLocation,
    //required this.dormImageUrl, // REQUIRED
    //required this.dormDescription, // REQUIRED
    required this.createdAt,
  });

  // =========================================================
  // 1. JSON Conversion (for API)
  // =========================================================

  factory Dorms.fromJson(Map<String, dynamic> json) => Dorms(
        dormId: json["dormId"] as int?,
        dormName: json["dormName"] as String,
        dormNumber: json["dormNumber"].toString(),
        dormLocation: json["dormLocation"] as String,
        //dormImageUrl: json["dormImageUrl"] as String,
        //dormDescription: json["dormDescription"] as String,
        createdAt: json["createdAt"] as String,
      );

  Map<String, dynamic> toJson() => {
        "dormId": dormId,
        "dormName": dormName,
        "dormNumber": dormNumber,
        "dormLocation": dormLocation,
        //"dormImageUrl": dormImageUrl,
        //"dormDescription": dormDescription,
        "createdAt": createdAt,
      };

  // =========================================================
  // 2. SQLite Conversion (for DatabaseHelper)
  // =========================================================

  factory Dorms.fromSqlite(Map<String, dynamic> map) => Dorms(
        dormId: map["dormId"] as int?,
        dormName: map["dormName"] as String,
        dormNumber: map["dormNumber"].toString(),
        dormLocation: map["dormLocation"] as String,
        //dormImageUrl: map["dormImageUrl"] as String,
        //dormDescription: map["dormDescription"] as String,
        createdAt: map["createdAt"] as String,
      );

  Map<String, dynamic> toSqlite() => {
        "dormId": dormId,
        "dormName": dormName,
        "dormNumber": dormNumber,
        "dormLocation": dormLocation,
        //"dormImageUrl": dormImageUrl,
        //"dormDescription": dormDescription,
        "createdAt": createdAt,
      };
}
