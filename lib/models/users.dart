// models/users.dart

class Users {
  final int? usrId;
  final String usrName;
  final String usrEmail;
  final String usrPassword;
  final String usrAddress;
  final String usrGender;

  Users({
    this.usrId,
    required this.usrName,
    required this.usrEmail,
    required this.usrPassword,
    required this.usrAddress,
    required this.usrGender,
  });

  // Convert a User object into a Map (for database insertion)
  Map<String, dynamic> toJson() {
    return {
      'usrId': usrId,
      'usrName': usrName,
      'usrEmail': usrEmail,
      'usrPassword': usrPassword,
      'usrAddress': usrAddress,
      'usrGender': usrGender,
    };
  }

  // Factory method to create a User object from a Map (for database retrieval)
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      usrId: json['usrId'] as int?,
      usrName: json['usrName'] as String,
      usrEmail: json['usrEmail'] as String,
      usrPassword: json['usrPassword'] as String,
      usrAddress: json['usrAddress'] as String,
      usrGender: json['usrGender'] as String,
    );
  }
}
