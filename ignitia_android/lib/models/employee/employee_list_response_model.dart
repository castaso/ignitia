import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../employee/employee_model.dart';

part 'employee_list_response_model.g.dart';

@JsonSerializable()
class EmployeeListResponseModel extends BaseResponseModel{

  @JsonKey(name: "data")
  List<EmployeeModel>? data;

  EmployeeListResponseModel(this.data) : super(isSuccess: false, message: "Error");

  factory EmployeeListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeListResponseModelToJson(this);
}
