
import 'package:i_employment/models/office/office_location_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../responses/base_response_model.dart';

part 'office_location_response_model.g.dart';

@JsonSerializable()
class OfficeLocationResponseModel extends BaseResponseModel{

  @JsonKey(name: "data")
  List<OfficeLocationModel> data;

  OfficeLocationResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory OfficeLocationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OfficeLocationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OfficeLocationResponseModelToJson(this);
}
