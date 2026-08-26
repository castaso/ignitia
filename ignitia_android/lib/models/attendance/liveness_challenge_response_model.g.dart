// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liveness_challenge_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LivenessChallengeResponseModel _$LivenessChallengeResponseModelFromJson(
  Map<String, dynamic> json,
) => LivenessChallengeResponseModel(
  json['isSuccess'] as bool,
  json['message'] as String,
  json['data'] == null
      ? null
      : LivenessChallengeData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LivenessChallengeResponseModelToJson(
  LivenessChallengeResponseModel instance,
) => <String, dynamic>{
  'isSuccess': instance.isSuccess,
  'message': instance.message,
  'data': instance.data,
};

LivenessChallengeData _$LivenessChallengeDataFromJson(
  Map<String, dynamic> json,
) => LivenessChallengeData(challengeId: json['challengeId'] as String?);

Map<String, dynamic> _$LivenessChallengeDataToJson(
  LivenessChallengeData instance,
) => <String, dynamic>{'challengeId': instance.challengeId};
