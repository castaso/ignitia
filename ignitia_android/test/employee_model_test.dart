import 'package:flutter_test/flutter_test.dart';
import 'package:i_employment/models/employee/employee_model.dart';
import 'package:i_employment/utils/string.dart';

EmployeeModel _baseEmployee() => EmployeeModel(
      1,
      'John Doe',
      'Developer',
      '01700000000',
      'john@example.com',
      'Dhaka',
      '1234567890',
      2,
      'EMP-001',
      0,
      1,
      DateTime(2020, 1, 1),
      null,
    );

void main() {
  group('attendance location helpers', () {
    test('defaults to office', () {
      final e = _baseEmployee();
      expect(e.attendanceLocationType, Strings.attendanceLocationTypeOffice);
      expect(e.isHomeBasedAttendance, isFalse);
      expect(e.isAnywhereAttendance, isFalse);
      expect(e.getAttendanceLocationAsString(), 'Office');
    });

    test('identifies home based attendance', () {
      final e = _baseEmployee()
        ..attendanceLocationType = Strings.attendanceLocationTypeHome;
      expect(e.isHomeBasedAttendance, isTrue);
    });

    test('identifies anywhere attendance', () {
      final e = _baseEmployee()
        ..attendanceLocationType = Strings.attendanceLocationTypeAnywhere;
      expect(e.isAnywhereAttendance, isTrue);
    });

    test('empty type falls back to office string', () {
      final e = _baseEmployee()..attendanceLocationType = '';
      expect(
          e.getAttendanceLocationAsString(), Strings.attendanceLocationTypeOffice);
    });
  });

  group('json round trip', () {
    test('serializes and deserializes home fields', () {
      final e = _baseEmployee()
        ..attendanceLocationType = Strings.attendanceLocationTypeHome
        ..homeLatitude = 24.0
        ..homeLongitude = 90.0
        ..homeRadiusMeters = 250;

      final json = e.toJson();
      expect(json['attendance_location_type'], 'Home');
      expect(json['home_latitude'], 24.0);
      expect(json['home_longitude'], 90.0);
      expect(json['home_radius_meters'], 250.0);

      final parsed = EmployeeModel.fromJson(json);
      expect(parsed.attendanceLocationType, 'Home');
      expect(parsed.homeLatitude, 24.0);
      expect(parsed.homeLongitude, 90.0);
      expect(parsed.homeRadiusMeters, 250.0);
    });

    test('defaults a missing type to Office on parse', () {
      final json = _baseEmployee().toJson()
        ..remove('attendance_location_type');
      final parsed = EmployeeModel.fromJson(json);
      expect(parsed.attendanceLocationType, 'Office');
    });

    test('allows nullable home fields', () {
      final e = _baseEmployee()
        ..attendanceLocationType = Strings.attendanceLocationTypeOffice;
      final json = e.toJson();
      expect(json['home_latitude'], isNull);
      expect(json['home_longitude'], isNull);
      expect(json['home_radius_meters'], isNull);

      final parsed = EmployeeModel.fromJson(json);
      expect(parsed.homeLatitude, isNull);
      expect(parsed.homeLongitude, isNull);
      expect(parsed.homeRadiusMeters, isNull);
    });
  });
}
