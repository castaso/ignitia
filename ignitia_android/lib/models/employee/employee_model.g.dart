// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeModel _$EmployeeModelFromJson(Map<String, dynamic> json) =>
    EmployeeModel(
      json['id'] as int,
      json['name'] as String,
      json['designation'] as String,
      json['cell_no'] as String?,
      json['email'] as String,
      json['address'] as String?,
      json['nid'] as String?,
      json['type_id'] as int,
      json['employee_id'] as String,
      json['supervisor_id'] as int,
      json['status_id'] as int,
      DateTime.parse(json['joining_date'] as String),
      json['permanent_date'] == null
          ? null
          : DateTime.parse(json['permanent_date'] as String),
      attendanceLocationType:
          json['attendance_location_type'] as String? ?? 'Office',
      homeLatitude: (json['home_latitude'] as num?)?.toDouble(),
      homeLongitude: (json['home_longitude'] as num?)?.toDouble(),
      homeRadiusMeters: (json['home_radius_meters'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EmployeeModelToJson(EmployeeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.employeeName,
      'designation': instance.designation,
      'cell_no': instance.cellNo,
      'email': instance.email,
      'address': instance.presentAddress,
      'nid': instance.nid,
      'type_id': instance.typeId,
      'employee_id': instance.employeeId,
      'supervisor_id': instance.supervisorId,
      'status_id': instance.statusId,
      'joining_date': instance.joiningDate.toIso8601String(),
      'permanent_date': instance.permanentDate?.toIso8601String(),
      'attendance_location_type': instance.attendanceLocationType,
      'home_latitude': instance.homeLatitude,
      'home_longitude': instance.homeLongitude,
      'home_radius_meters': instance.homeRadiusMeters,
    };
