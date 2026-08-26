
import 'package:ignitia_dashboard/models/holiday/holiday_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../responses/base_response_model.dart';

part 'holiday_response_model.g.dart';

@JsonSerializable()
class HolidayResponseModel extends BaseResponseModel{

  @JsonKey(name: "data")
  List<HolidayModel> data;

  HolidayResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory HolidayResponseModel.fromJson(Map<String, dynamic> json) =>
      _$HolidayResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$HolidayResponseModelToJson(this);
}
