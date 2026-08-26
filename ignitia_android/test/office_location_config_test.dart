import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_employment/config/office_location_config.dart';
import 'package:i_employment/models/office/office_location_model.dart';
import 'package:i_employment/utils/string.dart';

Position _position(double lat, double lng) => Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime(2024, 1, 1),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

void main() {
  const officeLat = 23.810331;
  const officeLng = 90.412521;
  const officeRadius = 300.0;

  setUp(() {
    OfficeLocationConfig.setOffices([
      OfficeLocationModel(
        name: 'Head Office',
        latitude: officeLat,
        longitude: officeLng,
        radiusMeters: officeRadius,
      ),
    ]);
    OfficeLocationConfig.setEmployeeLocationRestriction(
      Strings.attendanceLocationTypeOffice,
    );
  });

  group('office restriction', () {
    test('allows a position at the office centre', () {
      expect(
        OfficeLocationConfig.isWithinAllowedRange(
            _position(officeLat, officeLng)),
        isTrue,
      );
    });

    test('allows a position inside the office radius', () {
      expect(
        OfficeLocationConfig.isWithinAllowedRange(
            _position(officeLat + 0.001, officeLng)),
        isTrue,
      );
    });

    test('rejects a position far from the office', () {
      expect(
        OfficeLocationConfig.isWithinAllowedRange(
            _position(officeLat + 1, officeLng)),
        isFalse,
      );
    });

    test('reports the nearest office distance', () {
      final distance = OfficeLocationConfig.nearestOfficeDistanceMeters(
          _position(officeLat + 0.001, officeLng));
      expect(distance, greaterThan(0));
      expect(distance, lessThan(officeRadius));
    });
  });

  group('home restriction', () {
    const homeLat = 24.0;
    const homeLng = 90.0;
    const homeRadius = 200.0;

    setUp(() {
      OfficeLocationConfig.setEmployeeLocationRestriction(
        Strings.attendanceLocationTypeHome,
        homeLatitude: homeLat,
        homeLongitude: homeLng,
        homeRadiusMeters: homeRadius,
      );
    });

    test('allows a position at the home centre', () {
      expect(
        OfficeLocationConfig.isWithinAllowedRange(_position(homeLat, homeLng)),
        isTrue,
      );
    });

    test('rejects a position outside the home radius', () {
      expect(
        OfficeLocationConfig.isWithinAllowedRange(
            _position(homeLat + 0.01, homeLng)),
        isFalse,
      );
    });

    test('rejects when no home coordinates are configured', () {
      OfficeLocationConfig.setEmployeeLocationRestriction(
        Strings.attendanceLocationTypeHome,
      );
      expect(
        OfficeLocationConfig.isWithinAllowedRange(_position(homeLat, homeLng)),
        isFalse,
      );
    });

    test('reports the nearest home distance', () {
      final distance =
          OfficeLocationConfig.nearestHomeDistanceMeters(_position(homeLat, homeLng));
      expect(distance, lessThan(homeRadius));
    });
  });

  group('anywhere restriction', () {
    test('allows any position', () {
      OfficeLocationConfig.setEmployeeLocationRestriction(
        Strings.attendanceLocationTypeAnywhere,
      );
      expect(
        OfficeLocationConfig.isWithinAllowedRange(_position(0, 0)),
        isTrue,
      );
      expect(
        OfficeLocationConfig.isWithinAllowedRange(
            _position(officeLat + 5, officeLng)),
        isTrue,
      );
    });
  });

  group('restriction fallback', () {
    test('empty type falls back to office restriction', () {
      OfficeLocationConfig.setEmployeeLocationRestriction('');
      expect(
        OfficeLocationConfig.isWithinAllowedRange(
            _position(officeLat + 1, officeLng)),
        isFalse,
      );
    });

    test('keeps the previous radius when a non-positive one is passed', () {
      OfficeLocationConfig.setEmployeeLocationRestriction(
        Strings.attendanceLocationTypeHome,
        homeLatitude: 24.0,
        homeLongitude: 90.0,
        homeRadiusMeters: 150,
      );
      OfficeLocationConfig.setEmployeeLocationRestriction(
        Strings.attendanceLocationTypeHome,
        homeLatitude: 24.0,
        homeLongitude: 90.0,
        homeRadiusMeters: 0,
      );
      expect(OfficeLocationConfig.homeRadiusMeters, 150);
    });
  });

  group('nearest allowed distance', () {
    test('uses the office fence for office restriction', () {
      expect(
        OfficeLocationConfig.nearestAllowedDistanceMeters(
            _position(officeLat, officeLng)),
        closeTo(0, 1),
      );
    });

    test('uses the home fence for home restriction', () {
      OfficeLocationConfig.setEmployeeLocationRestriction(
        Strings.attendanceLocationTypeHome,
        homeLatitude: 24.0,
        homeLongitude: 90.0,
        homeRadiusMeters: 200,
      );
      expect(
        OfficeLocationConfig.nearestAllowedDistanceMeters(_position(24.0, 90.0)),
        closeTo(0, 1),
      );
    });
  });
}
