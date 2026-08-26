// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overtime_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvertimeModel _$OvertimeModelFromJson(Map<String, dynamic> json) =>
    OvertimeModel(
      id: json['id'] as int,
      employeeId: json['employeE_ID'] as int,
      overtimeDateUnformated: json['overtimE_DATE'] as String,
      checkInUnformated: json['checK_IN'] as String,
      checkOutUnformated: json['checK_OUT'] as String,
      overtimeMinutes: json['overtimE_MINUTES'] as int,
      status: json['status'] as String,
      reason: json['reason'] as String,
      supervisorID: json['supervisoR_ID'] as int?,
      employeeName: json['name'] as String?,
      designation: json['designation'] as String?,
    );

Map<String, dynamic> _$OvertimeModelToJson(OvertimeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeE_ID': instance.employeeId,
      'overtimE_DATE': instance.overtimeDateUnformated,
      'checK_IN': instance.checkInUnformated,
      'checK_OUT': instance.checkOutUnformated,
      'overtimE_MINUTES': instance.overtimeMinutes,
      'status': instance.status,
      'reason': instance.reason,
      'supervisoR_ID': instance.supervisorID,
      'name': instance.employeeName,
      'designation': instance.designation,
    };
