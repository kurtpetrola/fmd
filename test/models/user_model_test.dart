import 'package:flutter_test/flutter_test.dart';
import 'package:findmydorm/features/auth/domain/models/user_model.dart';

void main() {
  // --- Test Data ---
  final testUser = Users(
    usrId: 1,
    usrName: 'TestUser',
    usrEmail: 'test@fmd.com',
    usrPassword: 'hashed_pw_123',
    usrAddress: '123 Testing Lane',
    usrGender: 'Male',
    usrRole: 'User',
  );

  group('Users Model -', () {
    // -- Constructor & Defaults --
    test('default role should be "User"', () {
      final user = Users(
        usrName: 'New',
        usrEmail: 'new@fmd.com',
        usrPassword: 'pw',
        usrAddress: 'addr',
        usrGender: 'Female',
      );
      expect(user.usrRole, 'User');
      expect(user.usrId, isNull);
    });

    // -- toJson / fromJson --
    group('serialization', () {
      test('toJson should produce correct map', () {
        final json = testUser.toJson();
        expect(json['usrId'], 1);
        expect(json['usrName'], 'TestUser');
        expect(json['usrEmail'], 'test@fmd.com');
        expect(json['usrPassword'], 'hashed_pw_123');
        expect(json['usrAddress'], '123 Testing Lane');
        expect(json['usrGender'], 'Male');
        expect(json['usrRole'], 'User');
      });

      test('fromJson should reconstruct the object', () {
        final json = testUser.toJson();
        final restored = Users.fromJson(json);
        expect(restored, equals(testUser));
      });

      test('fromJson should default role to "User" when missing', () {
        final json = {
          'usrId': 2,
          'usrName': 'NoRole',
          'usrEmail': 'no@role.com',
          'usrPassword': 'pw',
          'usrAddress': 'addr',
          'usrGender': 'Male',
          // usrRole intentionally omitted
        };
        final user = Users.fromJson(json);
        expect(user.usrRole, 'User');
      });
    });

    // -- copyWith --
    group('copyWith', () {
      test('should return an identical copy when called with no arguments', () {
        final copy = testUser.copyWith();
        expect(copy, equals(testUser));
      });

      test('should override only the specified fields', () {
        final updated = testUser.copyWith(
          usrName: 'UpdatedUser',
          usrEmail: 'updated@fmd.com',
        );
        expect(updated.usrName, 'UpdatedUser');
        expect(updated.usrEmail, 'updated@fmd.com');
        // Unchanged fields:
        expect(updated.usrId, testUser.usrId);
        expect(updated.usrPassword, testUser.usrPassword);
        expect(updated.usrAddress, testUser.usrAddress);
        expect(updated.usrGender, testUser.usrGender);
        expect(updated.usrRole, testUser.usrRole);
      });
    });

    // -- Equality & hashCode --
    group('equality', () {
      test('two Users with the same data should be equal', () {
        final a = Users(
          usrId: 1,
          usrName: 'TestUser',
          usrEmail: 'test@fmd.com',
          usrPassword: 'hashed_pw_123',
          usrAddress: '123 Testing Lane',
          usrGender: 'Male',
          usrRole: 'User',
        );
        expect(a, equals(testUser));
        expect(a.hashCode, equals(testUser.hashCode));
      });

      test('Users with different data should not be equal', () {
        final different = testUser.copyWith(usrName: 'OtherUser');
        expect(different, isNot(equals(testUser)));
      });
    });
  });
}
