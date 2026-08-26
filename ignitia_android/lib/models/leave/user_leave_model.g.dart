// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_leave_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLeaveModel _$UserLeaveModelFromJson(Map<String, dynamic> json) =>
    UserLeaveModel(
      employeeId: json['employee_id'] as int,
      applyDateUnformated: json['apply_date'] as String,
      startDateUnformated: json['start_date'] as String,
      endDateUnformated: json['end_date'] as String,
      id: json['id'] as int? ?? 0,
      leaveId: json['leave_id'] as int? ?? 0,
      reason: json['reason'] as String? ?? "",
      totalDays: json['total_days'] as int? ?? 0,
      isApproved: json['is_approved'] as int? ?? 0,
    )..employeeName = json['employeeName'] as String?;

Map<String, dynamic> _$UserLeaveModelToJson(UserLeaveModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'leave_id': instance.leaveId,
      'employee_id': instance.employeeId,
      'employeeName': instance.employeeName,
      'apply_date': instance.applyDateUnformated,
      'start_date': instance.startDateUnformated,
      'end_date': instance.endDateUnformated,
      'reason': instance.reason,
      'total_days': instance.totalDays,
      'is_approved': instance.isApproved,
    };
