import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:i_employment/models/employee/employee_contact_info_response_model.dart';
import 'package:i_employment/models/employee/employee_response_model.dart';
import 'package:i_employment/models/employee/profile_model.dart';
import 'package:i_employment/repo/api_status.dart';
import 'package:i_employment/utils/global_fields.dart';
import '../models/employee/employee_list_response_model.dart';
import '../models/responses/response_model_without_data.dart';
import 'api_service.dart';

class EmployeeService{

  static Future<Object> getEmployeeList() async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      EmployeeListResponseModel response =
      await apiService.getEmployeeList('Bearer ${FieldValue.token}');
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getEmployeeList API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getEmployeeList API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> getProfile([int employeeId=0]) async {
    try {
      var id = employeeId==0? FieldValue.userId : employeeId;
      ApiService apiService = ApiService(dio.Dio());
      EmployeeResponseModel response =
      await apiService.getProfile('Bearer ${FieldValue.token}', id);
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getProfile API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getProfile API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> getContactInfo([int employeeId=0]) async {
    try {
      var id = employeeId==0? FieldValue.userId : employeeId;
      ApiService apiService = ApiService(dio.Dio());
      EmployeeContactInfoResponseModel response =
      await apiService.getContactInfo('Bearer ${FieldValue.token}', id);
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getContactInfo API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getContactInfo API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> updateProfile(ProfileModel profileModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.updateEmployee('Bearer ${FieldValue.token}', profileModel);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("updateProfile API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("updateProfile API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }
}