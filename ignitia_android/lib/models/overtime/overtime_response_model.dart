

import 'package:i_employment/models/overtime/overtime_model.dart';
import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'overtime_response_model.g.dart';

@JsonSerializable()
class OvertimeResponseModel extends BaseResponseModel{
  @JsonKey(name: "data")
  List<OvertimeModel> data;

  OvertimeResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory OvertimeResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OvertimeResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OvertimeResponseModelToJson(this);
}