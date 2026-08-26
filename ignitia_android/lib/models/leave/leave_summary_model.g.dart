// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveSummaryModel _$LeaveSummaryModelFromJson(Map<String, dynamic> json) =>
    LeaveSummaryModel(
      json['employeE_ID'] as int,
      json['employeE_NAME'] as String,
      json['leavE_SHORT_NAME'] as String,
      json['entitlement'] as int,
      json['taken'] as int,
      json['balance'] as int,
    );

Map<String, dynamic> _$LeaveSummaryModelToJson(LeaveSummaryModel instance) =>
    <String, dynamic>{
      'employeE_ID': instance.employeeId,
      'employeE_NAME': instance.employeeName,
      'leavE_SHORT_NAME': instance.leaveShortName,
      'entitlement': instance.entitlement,
      'taken': instance.taken,
      'balance': instance.balance,
    };
