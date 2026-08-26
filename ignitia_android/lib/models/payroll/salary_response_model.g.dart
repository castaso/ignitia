// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalaryResponseModel _$SalaryResponseModelFromJson(Map<String, dynamic> json) =>
    SalaryResponseModel(
      (json['data'] as List<dynamic>)
          .map((e) => SalaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$SalaryResponseModelToJson(
        SalaryResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
