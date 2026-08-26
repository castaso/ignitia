import 'package:i_employment/models/employee/employee_contact_info_model.dart';
import 'package:i_employment/models/employee/employee_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel{
  @JsonKey(name: "employeeInfo")
  EmployeeModel employeeInfo;

  @JsonKey(name: "contactInfo")
  EmployeeContactInfoModel? contactInfo;

  ProfileModel(this.employeeInfo, this.contactInfo);

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}