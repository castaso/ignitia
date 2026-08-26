// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_leave_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLeaveResponseModel _$UserLeaveResponseModelFromJson(
        Map<String, dynamic> json) =>
    UserLeaveResponseModel(
      (json['data'] as List<dynamic>)
          .map((e) => UserLeaveModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$UserLeaveResponseModelToJson(
        UserLeaveResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
