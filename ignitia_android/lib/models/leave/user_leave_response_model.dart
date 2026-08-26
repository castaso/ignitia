
import 'package:i_employment/models/leave/leave_summary_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../responses/base_response_model.dart';
import 'user_leave_model.dart';

part 'user_leave_response_model.g.dart';

@JsonSerializable()
class UserLeaveResponseModel extends BaseResponseModel{

  @JsonKey(name: "data")
  List<UserLeaveModel> data;

  UserLeaveResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory UserLeaveResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserLeaveResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserLeaveResponseModelToJson(this);
}