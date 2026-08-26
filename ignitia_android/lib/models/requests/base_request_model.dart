
import 'package:json_annotation/json_annotation.dart';

part 'base_request_model.g.dart';

@JsonSerializable()
class BaseRequestModel{

  @JsonKey(name: "user_name")
  String userName;

  @JsonKey(name: "access_key")
  String accessKey;

  BaseRequestModel(this.userName, this.accessKey);

  factory BaseRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BaseRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$BaseRequestModelToJson(this);
}