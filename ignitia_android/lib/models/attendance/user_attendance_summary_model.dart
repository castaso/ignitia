

import 'package:json_annotation/json_annotation.dart';

part 'user_attendance_summary_model.g.dart';

@JsonSerializable()
class UserAttendanceSummaryModel{

  @JsonKey(name: "total_days")
  int total_days;

  @JsonKey(name: "present_days")
  int present_days;

  @JsonKey(name: "late_days")
  int late_days;

  @JsonKey(name: "leave_days")
  int leave_days;

  @JsonKey(name: "weekend_holiday")
  int weekend_holiday;

  @JsonKey(name: "overtime_duration")
  int overtime_duration;

  int getAbsentDays(){
    var absentDays = total_days - (leave_days+weekend_holiday+present_days);
    return absentDays < 0 ? 0 : absentDays;
  }

  int getWorkingDays(){
    return total_days - weekend_holiday;
  }

  UserAttendanceSummaryModel(this.total_days, this.present_days, this.late_days,
      this.leave_days, this.weekend_holiday, this.overtime_duration);

  factory UserAttendanceSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$UserAttendanceSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserAttendanceSummaryModelToJson(this);
}