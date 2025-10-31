// models/dorms.dart

import 'dart:convert';

Dorms dormsFromJson(String str) => Dorms.fromJson(json.decode(str));

String dormsToJson(Dorms data) => json.encode(data.toJson());

class Dorms {
  final int? dormId;
  final String dormName;
  final String dormNumber;
  final String dormLocation;
  final String dormDescription;
  final String dormImageAsset;
  final String genderCategory;
  final String priceCategory;
  final double? latitude;
  final double? longitude;
  final String createdAt;

  Dorms({
    this.dormId,
    required this.dormName,
    required this.dormNumber,
    required this.dormLocation,
    this.dormDescription = '', // Default value for safety

    this.dormImageAsset = 'assets/images/dorm_default.jpeg', // Default image

    this.genderCategory = 'Mixed/General', // Default value
    this.priceCategory = 'Standard', // Default value

    // Default to null if not provided
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  // =========================================================
  // copyWith METHOD
  // This method allows creating a new Dorms object with updated properties.
  // =========================================================
  Dorms copyWith({
    int? dormId,
    String? dormName,
    String? dormNumber,
    String? dormLocation,
    String? dormDescription,
    String? dormImageAsset,
    String? genderCategory,
    String? priceCategory,
    double? latitude,
    double? longitude,
    String? createdAt,
  }) {
    return Dorms(
      dormId: dormId ?? this.dormId,
      dormName: dormName ?? this.dormName,
      dormNumber: dormNumber ?? this.dormNumber,
      dormLocation: dormLocation ?? this.dormLocation,
      dormDescription: dormDescription ?? this.dormDescription,
      dormImageAsset: dormImageAsset ?? this.dormImageAsset,
      genderCategory: genderCategory ?? this.genderCategory,
      priceCategory: priceCategory ?? this.priceCategory,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // =========================================================
  // 1. JSON Conversion (for API)
  // =========================================================

  factory Dorms.fromJson(Map<String, dynamic> json) => Dorms(
        dormId: json["dormId"] as int?,
        dormName: json["dormName"] as String,
        dormNumber: json["dormNumber"].toString(),
        dormLocation: json["dormLocation"] as String,
        dormDescription: (json["dormDescription"] ?? '')
            as String, // ADDED default empty string
        dormImageAsset: (json["dormImageAsset"] ??
            'assets/images/dorm_default.jpeg') as String,
        genderCategory: (json["genderCategory"] ?? 'Mixed/General') as String,
        priceCategory: (json["priceCategory"] ?? 'Standard') as String,
        createdAt: json["createdAt"] as String,
      );

  Map<String, dynamic> toJson() => {
        "dormId": dormId,
        "dormName": dormName,
        "dormNumber": dormNumber,
        "dormLocation": dormLocation,
        "dormDescription": dormDescription,
        // When sending to server, include coordinates if they are set
        "dormImageAsset": dormImageAsset,
        "genderCategory": genderCategory,
        "priceCategory": priceCategory,
        "latitude": latitude,
        "longitude": longitude,
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
        // Handle null/missing description for old entries
        dormDescription: (map["dormDescription"] ?? '') as String,
        // Safely read coordinates (SQLite stores REAL which Dart reads as double)
        dormImageAsset: (map["dormImageAsset"] ??
            'assets/images/dorm_default.jpeg') as String,
        genderCategory: (map["genderCategory"] ?? 'Mixed/General') as String,
        priceCategory: (map["priceCategory"] ?? 'Standard') as String,
        latitude: map['latitude'] as double?,
        longitude: map['longitude'] as double?,
        createdAt: map["createdAt"] as String,
      );

  Map<String, dynamic> toSqlite() => {
        "dormId": dormId,
        "dormName": dormName,
        "dormNumber": dormNumber,
        "dormLocation": dormLocation,
        "dormDescription": dormDescription,
        "dormImageAsset": dormImageAsset,
        "genderCategory": genderCategory,
        "priceCategory": priceCategory,
        'latitude': latitude,
        'longitude': longitude,
        "createdAt": createdAt,
      };
}
