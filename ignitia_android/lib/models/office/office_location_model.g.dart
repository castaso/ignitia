// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'office_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfficeLocationModel _$OfficeLocationModelFromJson(
        Map<String, dynamic> json) =>
    OfficeLocationModel(
      name: json['name'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      radiusMeters: json['radius_meters'] as double,
      id: json['id'] as int? ?? 0,
    );

Map<String, dynamic> _$OfficeLocationModelToJson(
        OfficeLocationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius_meters': instance.radiusMeters,
    };
