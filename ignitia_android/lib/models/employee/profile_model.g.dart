// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      EmployeeModel.fromJson(json['employeeInfo'] as Map<String, dynamic>),
      json['contactInfo'] == null
          ? null
          : EmployeeContactInfoModel.fromJson(
              json['contactInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'employeeInfo': instance.employeeInfo,
      'contactInfo': instance.contactInfo,
    };
