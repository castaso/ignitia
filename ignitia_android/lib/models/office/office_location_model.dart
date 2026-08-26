import 'package:json_annotation/json_annotation.dart';

part 'office_location_model.g.dart';

@JsonSerializable()
class OfficeLocationModel {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "latitude")
  double latitude;

  @JsonKey(name: "longitude")
  double longitude;

  @JsonKey(name: "radius_meters")
  double radiusMeters;

  OfficeLocationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.id = 0,
  });

  factory OfficeLocationModel.fromJson(Map<String, dynamic> json) =>
      _$OfficeLocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$OfficeLocationModelToJson(this);
}
