// models/users.dart

/// Represents a user within the application.
class Users {
  final int? usrId;
  final String usrName;
  final String usrEmail;
  final String usrPassword;
  final String usrAddress;
  final String usrGender;
  final String usrRole;

  Users(
      {this.usrId,
      required this.usrName,
      required this.usrEmail,
      required this.usrPassword,
      required this.usrAddress,
      required this.usrGender,
      this.usrRole = 'User'});

  /// Converts a [Users] object into a map for database insertion.
  Map<String, dynamic> toJson() {
    return {
      'usrId': usrId,
      'usrName': usrName,
      'usrEmail': usrEmail,
      'usrPassword': usrPassword,
      'usrAddress': usrAddress,
      'usrGender': usrGender,
      "usrRole": usrRole,
    };
  }

  /// Creates a [Users] object from a map for database retrieval.
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      usrId: json['usrId'] as int?,
      usrName: json['usrName'] as String,
      usrEmail: json['usrEmail'] as String,
      usrPassword: json['usrPassword'] as String,
      usrAddress: json['usrAddress'] as String,
      usrGender: json['usrGender'] as String,
      usrRole: (json["usrRole"] ?? 'User') as String,
    );
  }
}
