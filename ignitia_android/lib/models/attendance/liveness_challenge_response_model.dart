import 'package:json_annotation/json_annotation.dart';

part 'liveness_challenge_response_model.g.dart';

@JsonSerializable()
class LivenessChallengeResponseModel {
  @JsonKey(name: "isSuccess")
  bool isSuccess;

  @JsonKey(name: "message")
  String message;

  @JsonKey(name: "data")
  LivenessChallengeData? data;

  LivenessChallengeResponseModel(this.isSuccess, this.message, this.data);

  factory LivenessChallengeResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LivenessChallengeResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LivenessChallengeResponseModelToJson(this);
}

@JsonSerializable()
class LivenessChallengeData {
  @JsonKey(name: "challengeId")
  String? challengeId;

  LivenessChallengeData({this.challengeId});

  factory LivenessChallengeData.fromJson(Map<String, dynamic> json) =>
      _$LivenessChallengeDataFromJson(json);

  Map<String, dynamic> toJson() => _$LivenessChallengeDataToJson(this);
}
