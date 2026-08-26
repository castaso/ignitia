import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../utils/string.dart';

part 'user_leave_model.g.dart';

@JsonSerializable()
class UserLeaveModel {
  @JsonKey(name: "id")
  int id;

  @JsonKey(name: "leave_id")
  int leaveId;

  @JsonKey(name: "employee_id")
  int employeeId;

  String? employeeName;

  @JsonKey(name: "apply_date")
  String applyDateUnformated;

  DateTime getApplyDate() {
    try {
      return DateFormat("MM/dd/yyyy HH:mm:ss").parse(applyDateUnformated);
    } catch (e) {
      return DateFormat("yyyy-MM-ddTHH:mm:ss").parse(applyDateUnformated);
    }
  }

  String getApplyDateAsString() {
    return DateFormat("dd/MM/yyyy").format(getApplyDate());
  }

  @JsonKey(name: "start_date")
  String startDateUnformated;

  DateTime getStartDate() {
    try {
      return DateFormat("MM/dd/yyyy HH:mm:ss").parse(startDateUnformated);
    } catch (e) {
      return DateFormat("yyyy-MM-ddTHH:mm:ss").parse(startDateUnformated);
    }
  }

  String getStartDateAsString() {
    return DateFormat("dd/MM/yyyy").format(getStartDate());
  }

  @JsonKey(name: "end_date")
  String endDateUnformated;

  DateTime getEndDate() {
    try {
      return DateFormat("MM/dd/yyyy HH:mm:ss").parse(endDateUnformated);
    } catch (e) {
      return DateFormat("yyyy-MM-ddTHH:mm:ss").parse(endDateUnformated);
    }
  }

  String getEndDateAsString() {
    return DateFormat("dd/MM/yyyy").format(getEndDate());
  }

  @JsonKey(name: "reason")
  String reason;

  @JsonKey(name: "total_days")
  int totalDays;

  @JsonKey(name: "is_approved")
  int isApproved;

  String getApproveAsString() {
    return isApproved == 1 ? Strings.yes : Strings.no;
  }

  UserLeaveModel(
      {required this.employeeId,
      required this.applyDateUnformated,
      required this.startDateUnformated,
      required this.endDateUnformated,
      this.id = 0,
      this.leaveId = 0,
      this.reason = "",
      this.totalDays = 0,
      this.isApproved = 0});

  factory UserLeaveModel.fromJson(Map<String, dynamic> json) =>
      _$UserLeaveModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserLeaveModelToJson(this);
}
