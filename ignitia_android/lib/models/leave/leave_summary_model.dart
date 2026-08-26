
import 'package:json_annotation/json_annotation.dart';

part 'leave_summary_model.g.dart';

@JsonSerializable()
class LeaveSummaryModel{

  @JsonKey(name: "employeE_ID")
  int employeeId;

  @JsonKey(name: "employeE_NAME")
  String employeeName;

  @JsonKey(name: "leavE_SHORT_NAME")
  String leaveShortName;

  @JsonKey(name: "entitlement")
  int entitlement;

  @JsonKey(name: "taken")
  int taken;

  @JsonKey(name: "balance")
  int balance;

  LeaveSummaryModel(this.employeeId, this.employeeName, this.leaveShortName,
      this.entitlement, this.taken, this.balance);

  factory LeaveSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveSummaryModelToJson(this);
}