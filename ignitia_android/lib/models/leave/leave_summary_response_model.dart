
import 'package:i_employment/models/leave/leave_summary_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../responses/base_response_model.dart';

part 'leave_summary_response_model.g.dart';

@JsonSerializable()
class LeaveSummaryResponseModel extends BaseResponseModel{

  @JsonKey(name: "data")
  List<LeaveSummaryModel> data;

  LeaveSummaryResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory LeaveSummaryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveSummaryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveSummaryResponseModelToJson(this);
}