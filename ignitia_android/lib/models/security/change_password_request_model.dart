
import 'package:json_annotation/json_annotation.dart';

part 'change_password_request_model.g.dart';

@JsonSerializable()
class ChangePasswordRequestModel{

  @JsonKey(name: "email")
  String email;

  @JsonKey(name: "oldPassword")
  String oldPassword;

  @JsonKey(name: "newPassword")
  String newPassword;

  ChangePasswordRequestModel(this.email, this.oldPassword, this.newPassword);

  factory ChangePasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestModelToJson(this);
}