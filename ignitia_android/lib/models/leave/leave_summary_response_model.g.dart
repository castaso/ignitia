// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_summary_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveSummaryResponseModel _$LeaveSummaryResponseModelFromJson(
        Map<String, dynamic> json) =>
    LeaveSummaryResponseModel(
      (json['data'] as List<dynamic>)
          .map((e) => LeaveSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..isSuccess = json['isSuccess'] as bool
      ..message = json['message'] as String;

Map<String, dynamic> _$LeaveSummaryResponseModelToJson(
        LeaveSummaryResponseModel instance) =>
    <String, dynamic>{
      'isSuccess': instance.isSuccess,
      'message': instance.message,
      'data': instance.data,
    };
