// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseRequestModel _$BaseRequestModelFromJson(Map<String, dynamic> json) =>
    BaseRequestModel(
      json['user_name'] as String,
      json['access_key'] as String,
    );

Map<String, dynamic> _$BaseRequestModelToJson(BaseRequestModel instance) =>
    <String, dynamic>{
      'user_name': instance.userName,
      'access_key': instance.accessKey,
    };
