// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payslip_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayslipResponseModel _$PayslipResponseModelFromJson(
        Map<String, dynamic> json) =>
    PayslipResponseModel(
      json['data'] == null
          ? null
          : SalaryModel.fromJson(json['data'] as Map<String, dynamic>),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$PayslipResponseModelToJson(
        PayslipResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
