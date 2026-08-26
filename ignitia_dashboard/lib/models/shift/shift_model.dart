import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../utils/string.dart';

part 'shift_model.g.dart';

@JsonSerializable()
class ShiftModel {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "shift_name")
  String shiftName;

  @JsonKey(name: "start_time")
  String startTime; // "HH:mm"

  @JsonKey(name: "end_time")
  String endTime; // "HH:mm"

  @JsonKey(name: "description")
  String description;

  @JsonKey(name: "status_id")
  int statusId; // 1 = Active, 2 = Inactive

  DateTime _parseTime(String time) {
    final parts = time.split(":");
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return DateTime(2000, 1, 1, hour, minute);
  }

  // Handles shifts that cross midnight (e.g. 22:00 -> 06:00).
  double getTotalHours() {
    var start = _parseTime(startTime);
    var end = _parseTime(endTime);
    if (end.isBefore(start)) {
      end = end.add(const Duration(hours: 24));
    }
    return end.difference(start).inMinutes / 60.0;
  }

  String getTotalHoursAsString() {
    var hours = getTotalHours();
    return hours == hours.roundToDouble()
        ? "${hours.toInt()} H"
        : "${hours.toStringAsFixed(1)} H";
  }

  String getStartTimeAsString() {
    return DateFormat("hh:mm a").format(_parseTime(startTime));
  }

  String getEndTimeAsString() {
    return DateFormat("hh:mm a").format(_parseTime(endTime));
  }

  String getStatusAsString() {
    return statusId == 1 ? Strings.textShiftActive : Strings.textShiftInactive;
  }

  bool get isActive => statusId == 1;

  ShiftModel({
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    this.description = "",
    this.statusId = 1,
    this.id = 0,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) =>
      _$ShiftModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftModelToJson(this);
}
