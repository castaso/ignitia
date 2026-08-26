// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_model_without_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseModelWithoutData _$ResponseModelWithoutDataFromJson(
        Map<String, dynamic> json) =>
    ResponseModelWithoutData(
      json['isSuccess'] as bool,
      json['message'] as String,
    );

Map<String, dynamic> _$ResponseModelWithoutDataToJson(
        ResponseModelWithoutData instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
    };
