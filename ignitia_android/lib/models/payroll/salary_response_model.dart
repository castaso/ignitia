

import 'package:i_employment/models/overtime/overtime_model.dart';
import 'package:i_employment/models/payroll/salary_model.dart';
import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'salary_response_model.g.dart';

@JsonSerializable()
class SalaryResponseModel extends BaseResponseModel{
  @JsonKey(name: "data")
  List<SalaryModel> data;

  SalaryResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory SalaryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SalaryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalaryResponseModelToJson(this);
}