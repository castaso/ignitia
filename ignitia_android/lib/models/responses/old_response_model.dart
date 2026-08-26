
import 'package:json_annotation/json_annotation.dart';

part 'old_response_model.g.dart';

@JsonSerializable()
class OldResponseModel{
  @JsonKey(name: "success")
  bool isSuccess;

  @JsonKey(name: "message")
  String message;

  OldResponseModel(this.isSuccess, this.message);

  factory OldResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OldResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OldResponseModelToJson(this);
}
