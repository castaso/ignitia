// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HolidayResponseModel _$HolidayResponseModelFromJson(
        Map<String, dynamic> json) =>
    HolidayResponseModel(
      (json['data'] as List<dynamic>)
          .map((e) => HolidayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$HolidayResponseModelToJson(
        HolidayResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
