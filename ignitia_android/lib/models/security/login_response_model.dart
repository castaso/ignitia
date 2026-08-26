import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../employee/employee_model.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel extends BaseResponseModel{

  @JsonKey(name: "data")
  EmployeeModel? data;

  LoginResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
