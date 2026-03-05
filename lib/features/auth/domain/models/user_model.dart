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

  /// Returns a copy of this [Users] with the given fields replaced.
  Users copyWith({
    int? usrId,
    String? usrName,
    String? usrEmail,
    String? usrPassword,
    String? usrAddress,
    String? usrGender,
    String? usrRole,
  }) {
    return Users(
      usrId: usrId ?? this.usrId,
      usrName: usrName ?? this.usrName,
      usrEmail: usrEmail ?? this.usrEmail,
      usrPassword: usrPassword ?? this.usrPassword,
      usrAddress: usrAddress ?? this.usrAddress,
      usrGender: usrGender ?? this.usrGender,
      usrRole: usrRole ?? this.usrRole,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Users &&
        other.usrId == usrId &&
        other.usrName == usrName &&
        other.usrEmail == usrEmail &&
        other.usrPassword == usrPassword &&
        other.usrAddress == usrAddress &&
        other.usrGender == usrGender &&
        other.usrRole == usrRole;
  }

  @override
  int get hashCode => Object.hash(
        usrId,
        usrName,
        usrEmail,
        usrPassword,
        usrAddress,
        usrGender,
        usrRole,
      );
}
