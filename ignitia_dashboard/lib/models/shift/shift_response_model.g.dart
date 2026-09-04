// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftResponseModel _$ShiftResponseModelFromJson(Map<String, dynamic> json) =>
    ShiftResponseModel(
        (json['data'] as List<dynamic>)
            .map((e) => ShiftModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$ShiftResponseModelToJson(ShiftResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
