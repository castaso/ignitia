// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveResponseModel _$LeaveResponseModelFromJson(Map<String, dynamic> json) =>
    LeaveResponseModel(
      (json['data'] as List<dynamic>)
          .map((e) => LeaveModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$LeaveResponseModelToJson(LeaveResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
