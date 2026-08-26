import 'package:flutter_test/flutter_test.dart';
import 'package:ignitia_dashboard/models/shift/shift_model.dart';

void main() {
  group('ShiftModel', () {
    test('parses from json and serializes back', () {
      final json = {
        'id': 1,
        'shift_name': 'Morning',
        'start_time': '09:00',
        'end_time': '18:00',
        'description': 'Day shift',
        'status_id': 1,
      };

      final model = ShiftModel.fromJson(json);

      expect(model.id, 1);
      expect(model.shiftName, 'Morning');
      expect(model.startTime, '09:00');
      expect(model.endTime, '18:00');
      expect(model.description, 'Day shift');
      expect(model.statusId, 1);
      expect(model.isActive, true);
      expect(model.getStatusAsString(), 'Active');

      final serialized = model.toJson();
      expect(serialized['shift_name'], 'Morning');
      expect(serialized['start_time'], '09:00');
    });

    test('computes duration for a regular day shift', () {
      final model = ShiftModel(
        shiftName: 'Morning',
        startTime: '09:00',
        endTime: '18:00',
      );
      expect(model.getTotalHours(), 9.0);
      expect(model.getTotalHoursAsString(), '9 H');
    });

    test('computes duration for an overnight shift', () {
      final model = ShiftModel(
        shiftName: 'Night',
        startTime: '22:00',
        endTime: '06:00',
      );
      expect(model.getTotalHours(), 8.0);
      expect(model.getTotalHoursAsString(), '8 H');
    });

    test('defaults to active status and empty description', () {
      final model = ShiftModel(
        shiftName: 'Default',
        startTime: '08:00',
        endTime: '17:00',
      );
      expect(model.id, 0);
      expect(model.statusId, 1);
      expect(model.description, '');
    });
  });
}
