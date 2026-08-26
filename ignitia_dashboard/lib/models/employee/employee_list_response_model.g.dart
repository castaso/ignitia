// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeListResponseModel _$EmployeeListResponseModelFromJson(
        Map<String, dynamic> json) =>
    EmployeeListResponseModel(
      (json['data'] as List<dynamic>?)
          ?.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$EmployeeListResponseModelToJson(
        EmployeeListResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
