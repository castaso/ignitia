import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../employee/employee_model.dart';
import 'employee_contact_info_model.dart';

part 'employee_contact_info_response_model.g.dart';

@JsonSerializable()
class EmployeeContactInfoResponseModel extends BaseResponseModel{

  @JsonKey(name: "data")
  EmployeeContactInfoModel? data;

  EmployeeContactInfoResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory EmployeeContactInfoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeContactInfoResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeContactInfoResponseModelToJson(this);
}
