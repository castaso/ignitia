// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftModel _$ShiftModelFromJson(Map<String, dynamic> json) => ShiftModel(
      shiftName: json['shift_name'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      description: json['description'] as String? ?? "",
      statusId: json['status_id'] as int? ?? 1,
      id: json['id'] as int? ?? 0,
    );

Map<String, dynamic> _$ShiftModelToJson(ShiftModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shift_name': instance.shiftName,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'description': instance.description,
      'status_id': instance.statusId,
    };
