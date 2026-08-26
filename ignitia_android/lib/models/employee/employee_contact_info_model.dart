
import 'package:json_annotation/json_annotation.dart';

import '../../utils/string.dart';

part 'employee_contact_info_model.g.dart';

@JsonSerializable()
class EmployeeContactInfoModel{

  @JsonKey(name: "id")
  int employeeId;

  @JsonKey(name: "permanent_address")
  String? permanentAddress;

  @JsonKey(name: "personal_email")
  String? personalEmail;

  @JsonKey(name: "second_cell_no")
  String? secondCellNo;

  @JsonKey(name: "father_name")
  String? fatherName;

  @JsonKey(name: "father_cell_no")
  String? fatherCellNo;

  @JsonKey(name: "mother_name")
  String? motherName;

  @JsonKey(name: "mother_cell_no")
  String? motherCellNo;

  @JsonKey(name: "secondary_contact_name")
  String? secondaryContactName;

  @JsonKey(name: "secondary_contact_cell")
  String? secondaryContactCell;

  EmployeeContactInfoModel(
      this.employeeId,
      this.permanentAddress,
      this.personalEmail,
      this.secondCellNo,
      this.fatherName,
      this.fatherCellNo,
      this.motherName,
      this.motherCellNo,
      this.secondaryContactName,
      this.secondaryContactCell);

  factory EmployeeContactInfoModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeContactInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeContactInfoModelToJson(this);
}