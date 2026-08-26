

import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

import 'attendance_model.dart';

part 'user_attendance_response_model.g.dart';

@JsonSerializable()
class UserAttendanceResponseModel extends BaseResponseModel{
  @JsonKey(name: "data")
  List<AttendanceModel> data;

  UserAttendanceResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory UserAttendanceResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserAttendanceResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserAttendanceResponseModelToJson(this);
}