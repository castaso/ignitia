// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overtime_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvertimeResponseModel _$OvertimeResponseModelFromJson(
        Map<String, dynamic> json) =>
    OvertimeResponseModel(
      (json['data'] as List<dynamic>)
          .map((e) => OvertimeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$OvertimeResponseModelToJson(
        OvertimeResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
