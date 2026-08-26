// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_contact_info_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeContactInfoResponseModel _$EmployeeContactInfoResponseModelFromJson(
        Map<String, dynamic> json) =>
    EmployeeContactInfoResponseModel(
      json['data'] == null
          ? null
          : EmployeeContactInfoModel.fromJson(
              json['data'] as Map<String, dynamic>),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$EmployeeContactInfoResponseModelToJson(
        EmployeeContactInfoResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
