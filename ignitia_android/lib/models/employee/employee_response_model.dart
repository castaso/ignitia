import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../employee/employee_model.dart';

part 'employee_response_model.g.dart';

@JsonSerializable()
class EmployeeResponseModel extends BaseResponseModel{

  @JsonKey(name: "data")
  EmployeeModel? data;

  EmployeeResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory EmployeeResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeResponseModelToJson(this);
}
