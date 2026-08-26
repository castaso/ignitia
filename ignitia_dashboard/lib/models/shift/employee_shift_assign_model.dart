import 'package:json_annotation/json_annotation.dart';

part 'employee_shift_assign_model.g.dart';

@JsonSerializable()
class EmployeeShiftAssignModel {
  @JsonKey(name: "shift_id")
  int shiftId;

  @JsonKey(name: "start_date")
  String startDate; // yyyy-MM-dd

  @JsonKey(name: "end_date")
  String endDate; // yyyy-MM-dd

  @JsonKey(name: "employee_ids")
  List<int> employeeIds;

  EmployeeShiftAssignModel({
    required this.shiftId,
    required this.startDate,
    required this.endDate,
    required this.employeeIds,
  });

  factory EmployeeShiftAssignModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeShiftAssignModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeShiftAssignModelToJson(this);
}
