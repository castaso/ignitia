// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_shift_assign_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeShiftAssignModel _$EmployeeShiftAssignModelFromJson(
        Map<String, dynamic> json) =>
    EmployeeShiftAssignModel(
      shiftId: json['shift_id'] as int,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      employeeIds: (json['employee_ids'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );

Map<String, dynamic> _$EmployeeShiftAssignModelToJson(
        EmployeeShiftAssignModel instance) =>
    <String, dynamic>{
      'shift_id': instance.shiftId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'employee_ids': instance.employeeIds,
    };
