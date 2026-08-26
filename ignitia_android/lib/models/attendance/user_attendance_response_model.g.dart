// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_attendance_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAttendanceResponseModel _$UserAttendanceResponseModelFromJson(
        Map<String, dynamic> json) =>
    UserAttendanceResponseModel(
      (json['data'] as List<dynamic>)
          .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$UserAttendanceResponseModelToJson(
        UserAttendanceResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
