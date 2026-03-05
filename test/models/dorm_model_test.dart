import 'package:flutter_test/flutter_test.dart';
import 'package:findmydorm/features/dorms/domain/models/dorm_model.dart';

void main() {
  // --- Test Data ---
  final testDorm = Dorms(
    dormId: 1,
    dormName: 'Anderson Hall',
    dormNumber: '101',
    dormLocation: 'Dagupan City',
    dormDescription: 'A modern dorm.',
    dormImageAsset: 'assets/images/dorm_general_luxury.png',
    genderCategory: 'Mixed/General',
    priceCategory: 'Luxury',
    isFeatured: true,
    latitude: 16.0371,
    longitude: 120.3340,
    createdAt: '2026-01-01T00:00:00.000',
  );

  group('Dorms Model -', () {
    // -- Constructor & Defaults --
    test('default values should be applied correctly', () {
      final dorm = Dorms(
        dormName: 'Minimal',
        dormNumber: '001',
        dormLocation: 'Test City',
        createdAt: '2026-01-01',
      );
      expect(dorm.dormId, isNull);
      expect(dorm.dormDescription, '');
      expect(dorm.dormImageAsset, 'assets/images/dorm_default.jpeg');
      expect(dorm.genderCategory, 'Mixed/General');
      expect(dorm.priceCategory, 'Standard');
      expect(dorm.isFeatured, false);
      expect(dorm.latitude, isNull);
      expect(dorm.longitude, isNull);
    });

    // -- toJson / fromJson --
    group('serialization', () {
      test('toJson should produce correct map with isFeatured as 0/1', () {
        final json = testDorm.toJson();
        expect(json['dormName'], 'Anderson Hall');
        expect(json['isFeatured'], 1); // bool → int
        expect(json['latitude'], 16.0371);
      });

      test('fromJson should reconstruct the object', () {
        final json = testDorm.toJson();
        final restored = Dorms.fromJson(json);
        expect(restored.dormName, testDorm.dormName);
        expect(restored.isFeatured, testDorm.isFeatured);
        expect(restored.dormId, testDorm.dormId);
      });

      test('fromJson should handle missing optional fields', () {
        final json = {
          'dormId': null,
          'dormName': 'Bare',
          'dormNumber': 1,
          'dormLocation': 'Loc',
          'createdAt': '2026-01-01',
          // optional fields omitted
        };
        final dorm = Dorms.fromJson(json);
        expect(dorm.dormDescription, '');
        expect(dorm.genderCategory, 'Mixed/General');
        expect(dorm.priceCategory, 'Standard');
        expect(dorm.isFeatured, false);
      });
    });

    // -- toSqlite / fromSqlite --
    group('SQLite serialization', () {
      test('toSqlite should convert isFeatured to 0/1', () {
        final map = testDorm.toSqlite();
        expect(map['isFeatured'], 1);

        final notFeatured = testDorm.copyWith(isFeatured: false).toSqlite();
        expect(notFeatured['isFeatured'], 0);
      });

      test('fromSqlite should reconstruct the object', () {
        final map = testDorm.toSqlite();
        final restored = Dorms.fromSqlite(map);
        expect(restored.dormName, testDorm.dormName);
        expect(restored.isFeatured, testDorm.isFeatured);
        expect(restored.latitude, testDorm.latitude);
      });
    });

    // -- copyWith --
    group('copyWith', () {
      test('should return identical copy when called with no arguments', () {
        final copy = testDorm.copyWith();
        expect(copy.dormName, testDorm.dormName);
        expect(copy.dormId, testDorm.dormId);
        expect(copy.isFeatured, testDorm.isFeatured);
      });

      test('should override only specified fields', () {
        final updated = testDorm.copyWith(
          dormName: 'New Hall',
          isFeatured: false,
        );
        expect(updated.dormName, 'New Hall');
        expect(updated.isFeatured, false);
        // Unchanged:
        expect(updated.dormId, testDorm.dormId);
        expect(updated.dormLocation, testDorm.dormLocation);
        expect(updated.latitude, testDorm.latitude);
      });
    });
  });
}
