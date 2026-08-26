// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveModel _$LeaveModelFromJson(Map<String, dynamic> json) => LeaveModel(
      json['id'] as int,
      json['leave_name'] as String,
      json['leave_short_name'] as String,
      json['leave_count'] as int,
    );

Map<String, dynamic> _$LeaveModelToJson(LeaveModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'leave_name': instance.leaveName,
      'leave_short_name': instance.leaveShortName,
      'leave_count': instance.leaveCount,
    };
