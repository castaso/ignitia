// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HolidayModel _$HolidayModelFromJson(Map<String, dynamic> json) => HolidayModel(
  holidayName: json['holiday_name'] as String,
  holidayType: json['holiday_type'] as String,
  startDateUnformated: json['start_date'] as String,
  endDateUnformated: json['end_date'] as String,
  id: (json['id'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$HolidayModelToJson(HolidayModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'holiday_name': instance.holidayName,
      'holiday_type': instance.holidayType,
      'start_date': instance.startDateUnformated,
      'end_date': instance.endDateUnformated,
    };
