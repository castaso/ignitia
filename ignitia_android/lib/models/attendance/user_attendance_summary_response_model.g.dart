// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_attendance_summary_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAttendanceSummaryResponseModel _$UserAttendanceSummaryResponseModelFromJson(
        Map<String, dynamic> json) =>
    UserAttendanceSummaryResponseModel(
      UserAttendanceSummaryModel.fromJson(json['data'] as Map<String, dynamic>),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$UserAttendanceSummaryResponseModelToJson(
        UserAttendanceSummaryResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
