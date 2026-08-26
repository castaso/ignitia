// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'old_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OldResponseModel _$OldResponseModelFromJson(Map<String, dynamic> json) =>
    OldResponseModel(
      json['success'] as bool,
      json['message'] as String,
    );

Map<String, dynamic> _$OldResponseModelToJson(OldResponseModel instance) =>
    <String, dynamic>{
      'success': instance.isSuccess,
      'message': instance.message,
    };
