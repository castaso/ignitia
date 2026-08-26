// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'office_location_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfficeLocationResponseModel _$OfficeLocationResponseModelFromJson(
        Map<String, dynamic> json) =>
    OfficeLocationResponseModel(
      (json['data'] as List<dynamic>)
          .map((e) => OfficeLocationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$OfficeLocationResponseModelToJson(
        OfficeLocationResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
