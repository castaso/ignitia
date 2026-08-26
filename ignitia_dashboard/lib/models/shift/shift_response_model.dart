import 'package:json_annotation/json_annotation.dart';

import '../responses/base_response_model.dart';
import 'shift_model.dart';

part 'shift_response_model.g.dart';

@JsonSerializable()
class ShiftResponseModel extends BaseResponseModel {
  @JsonKey(name: "data")
  List<ShiftModel> data;

  ShiftResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory ShiftResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ShiftResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftResponseModelToJson(this);
}
