// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_attendance_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAttendanceSummaryModel _$UserAttendanceSummaryModelFromJson(
        Map<String, dynamic> json) =>
    UserAttendanceSummaryModel(
      json['total_days'] as int,
      json['present_days'] as int,
      json['late_days'] as int,
      json['leave_days'] as int,
      json['weekend_holiday'] as int,
      json['overtime_duration'] as int,
    );

Map<String, dynamic> _$UserAttendanceSummaryModelToJson(
        UserAttendanceSummaryModel instance) =>
    <String, dynamic>{
      'total_days': instance.total_days,
      'present_days': instance.present_days,
      'late_days': instance.late_days,
      'leave_days': instance.leave_days,
      'weekend_holiday': instance.weekend_holiday,
      'overtime_duration': instance.overtime_duration,
    };
