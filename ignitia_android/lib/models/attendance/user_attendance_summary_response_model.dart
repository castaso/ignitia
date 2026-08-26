

import 'package:i_employment/models/attendance/user_attendance_summary_model.dart';
import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_attendance_summary_response_model.g.dart';

@JsonSerializable()
class UserAttendanceSummaryResponseModel extends BaseResponseModel{

  @JsonKey(name: "data")
  UserAttendanceSummaryModel data;

  UserAttendanceSummaryResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory UserAttendanceSummaryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserAttendanceSummaryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserAttendanceSummaryResponseModelToJson(this);
}