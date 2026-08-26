// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      dateTimeUnformated: json['date_time'] as String?,
      id: (json['id'] as num?)?.toInt() ?? 0,
      overtimeMinutes: (json['overtimE_MINUTES'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? "",
      employeeId: (json['employee_id'] as num?)?.toInt(),
      employeeName: json['employee_name'] as String?,
      checkInUnformated: json['check_in'] as String?,
      checkOutUnformated: json['check_out'] as String?,
      lateDuration: (json['late_duration'] as num?)?.toInt(),
      checkInLatitude: (json['latitude'] as num?)?.toDouble(),
      checkInLongitude: (json['longitude'] as num?)?.toDouble(),
      checkOutLatitude: (json['check_out_latitude'] as num?)?.toDouble(),
      checkOutLongitude: (json['check_out_longitude'] as num?)?.toDouble(),
      checkInAddress: json['check_in_address'] as String?,
      checkOutAddress: json['check_out_address'] as String?,
      checkInFaceBase64: json['check_in_face'] as String?,
      checkOutFaceBase64: json['check_out_face'] as String?,
      livenessFrames:
          (json['liveness_frames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      challengeId: json['challenge_id'] as String?,
      missingReason: json['missinG_REASON'] as String?,
      approvalStatusId: (json['approval_status_id'] as num?)?.toInt(),
      approvalStatus: json['approval_status'] as String?,
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_id': instance.employeeId,
      'employee_name': instance.employeeName,
      'date_time': instance.dateTimeUnformated,
      'check_in': instance.checkInUnformated,
      'check_out': instance.checkOutUnformated,
      'late_duration': instance.lateDuration,
      'latitude': instance.checkInLatitude,
      'longitude': instance.checkInLongitude,
      'overtimE_MINUTES': instance.overtimeMinutes,
      'check_out_latitude': instance.checkOutLatitude,
      'check_out_longitude': instance.checkOutLongitude,
      'check_in_address': instance.checkInAddress,
      'check_out_address': instance.checkOutAddress,
      'check_in_face': instance.checkInFaceBase64,
      'check_out_face': instance.checkOutFaceBase64,
      'liveness_frames': instance.livenessFrames,
      'challenge_id': instance.challengeId,
      'status': instance.status,
      'missinG_REASON': instance.missingReason,
      'approval_status_id': instance.approvalStatusId,
      'approval_status': instance.approvalStatus,
    };
