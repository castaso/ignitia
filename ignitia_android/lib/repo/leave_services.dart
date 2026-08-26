import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:i_employment/models/leave/leave_response_model.dart';
import 'package:i_employment/models/leave/leave_summary_response_model.dart';
import 'package:i_employment/models/leave/user_leave_model.dart';
import 'package:i_employment/models/leave/user_leave_response_model.dart';
import 'package:i_employment/repo/api_status.dart';
import 'package:i_employment/utils/global_fields.dart';
import '../models/responses/response_model_without_data.dart';
import 'api_service.dart';

class LeaveService{

  static Future<Object> getLeaveList() async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      LeaveResponseModel response =
      await apiService.getLeaveList('Bearer ${FieldValue.token}');
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getLeaveList API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getLeaveList API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> getEmployeeLeaveSummary([int employeeId = -1]) async {
    try {
      var userId = employeeId >-1 ? employeeId : FieldValue.userId;
      ApiService apiService = ApiService(dio.Dio());
      LeaveSummaryResponseModel response =
      await apiService.getEmployeeLeaveSummary('Bearer ${FieldValue.token}', userId);
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getEmployeeLeaveSummary API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getEmployeeLeaveSummary API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> getUserLeave([int employeeId = -1]) async {
    try {
      var userId = employeeId >-1 ? employeeId : FieldValue.userId;
      ApiService apiService = ApiService(dio.Dio());
      UserLeaveResponseModel response =
      await apiService.getUserLeave('Bearer ${FieldValue.token}', userId);
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getUserLeave API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getUserLeave API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> addUserLeave(UserLeaveModel leaveModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.addEmployeeLeave('Bearer ${FieldValue.token}', leaveModel, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("addUserLeave API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("addUserLeave API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> updateUserLeave(UserLeaveModel leaveModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.updateEmployeeLeave('Bearer ${FieldValue.token}', leaveModel, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("updateUserLeave API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("updateUserLeave API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> deleteUserLeave(int id) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.deleteEmployeeLeave('Bearer ${FieldValue.token}', id, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("deleteUserLeave API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("deleteUserLeave API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> approveEmployeeLeave(UserLeaveModel model) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.approveEmployeeLeave('Bearer ${FieldValue.token}', model, FieldValue.userId);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("approveEmployeeLeave API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("approveEmployeeLeave API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

}