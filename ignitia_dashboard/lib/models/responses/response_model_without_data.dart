
import 'package:json_annotation/json_annotation.dart';

part 'response_model_without_data.g.dart';

@JsonSerializable()
class ResponseModelWithoutData{
  @JsonKey(name: "isSuccess")
  bool isSuccess;

  @JsonKey(name: "message")
  String message;

  ResponseModelWithoutData(this.isSuccess, this.message);

  factory ResponseModelWithoutData.fromJson(Map<String, dynamic> json) =>
      _$ResponseModelWithoutDataFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseModelWithoutDataToJson(this);

}