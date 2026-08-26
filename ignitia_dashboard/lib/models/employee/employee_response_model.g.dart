// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeResponseModel _$EmployeeResponseModelFromJson(
        Map<String, dynamic> json) =>
    EmployeeResponseModel(
      json['data'] == null
          ? null
          : EmployeeModel.fromJson(json['data'] as Map<String, dynamic>),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$EmployeeResponseModelToJson(
        EmployeeResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
