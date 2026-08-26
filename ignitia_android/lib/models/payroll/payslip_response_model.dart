

import 'package:i_employment/models/overtime/overtime_model.dart';
import 'package:i_employment/models/payroll/salary_model.dart';
import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payslip_response_model.g.dart';

@JsonSerializable()
class PayslipResponseModel extends BaseResponseModel{
  @JsonKey(name: "data")
  SalaryModel? data;

  PayslipResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory PayslipResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PayslipResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PayslipResponseModelToJson(this);
}