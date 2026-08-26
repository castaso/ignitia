
import 'package:i_employment/models/leave/leave_summary_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../responses/base_response_model.dart';
import 'leave_model.dart';

part 'leave_response_model.g.dart';

@JsonSerializable()
class LeaveResponseModel extends BaseResponseModel{

  @JsonKey(name: "data")
  List<LeaveModel> data;

  LeaveResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory LeaveResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveResponseModelToJson(this);
}