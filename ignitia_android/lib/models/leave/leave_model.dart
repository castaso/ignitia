
import 'package:json_annotation/json_annotation.dart';

part 'leave_model.g.dart';

@JsonSerializable()
class LeaveModel{

  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "leave_name")
  String leaveName;

  @JsonKey(name: "leave_short_name")
  String leaveShortName;

  @JsonKey(name: "leave_count")
  int leaveCount;

  LeaveModel(
      this.id, this.leaveName, this.leaveShortName, this.leaveCount);

  factory LeaveModel.fromJson(Map<String, dynamic> json) =>
      _$LeaveModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveModelToJson(this);
}