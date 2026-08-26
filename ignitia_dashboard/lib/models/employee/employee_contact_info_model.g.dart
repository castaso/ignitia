// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_contact_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeContactInfoModel _$EmployeeContactInfoModelFromJson(
        Map<String, dynamic> json) =>
    EmployeeContactInfoModel(
      json['id'] as int,
      json['permanent_address'] as String?,
      json['personal_email'] as String?,
      json['second_cell_no'] as String?,
      json['father_name'] as String?,
      json['father_cell_no'] as String?,
      json['mother_name'] as String?,
      json['mother_cell_no'] as String?,
      json['secondary_contact_name'] as String?,
      json['secondary_contact_cell'] as String?,
    );

Map<String, dynamic> _$EmployeeContactInfoModelToJson(
        EmployeeContactInfoModel instance) =>
    <String, dynamic>{
      'id': instance.employeeId,
      'permanent_address': instance.permanentAddress,
      'personal_email': instance.personalEmail,
      'second_cell_no': instance.secondCellNo,
      'father_name': instance.fatherName,
      'father_cell_no': instance.fatherCellNo,
      'mother_name': instance.motherName,
      'mother_cell_no': instance.motherCellNo,
      'secondary_contact_name': instance.secondaryContactName,
      'secondary_contact_cell': instance.secondaryContactCell,
    };
