import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:i_employment/models/attendance/attendance_model.dart';
import 'package:i_employment/models/attendance/user_attendance_response_model.dart';
import 'package:i_employment/models/overtime/overtime_response_model.dart';
import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:i_employment/models/responses/response_model_without_data.dart';
import 'package:i_employment/repo/api_status.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:intl/intl.dart';
import '../models/attendance/user_attendance_summary_response_model.dart';
import '../models/overtime/overtime_model.dart';
import 'api_service.dart';

class OvertimeService{

  static Future<Object> getOvertimeList(DateTime startDate, DateTime endDate, [int employeeId = -1]) async {
    try {
      var userId = employeeId>-1 ? employeeId : FieldValue.userId;
      ApiService apiService = ApiService(dio.Dio());
      OvertimeResponseModel response =
      await apiService.getOvertimeList('Bearer ${FieldValue.token}', userId, DateFormat("dd-MMM-yyyy").format(startDate), DateFormat("dd-MMM-yyyy").format(endDate));
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getOvertimeList API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getOvertimeList API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> addOvertime(OvertimeModel overtimeModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.addOvertime('Bearer ${FieldValue.token}', overtimeModel, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("addOvertime API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("addOvertime API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> updateOvertime(OvertimeModel overtimeModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.updateOvertime('Bearer ${FieldValue.token}', overtimeModel, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("updateOvertime API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("updateOvertime API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> deleteOvertime(int id) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.deleteOvertime('Bearer ${FieldValue.token}', id, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("deleteOvertime API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("deleteOvertime API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> approveOvertime(OvertimeModel model) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.approveOvertime('Bearer ${FieldValue.token}', model, FieldValue.userId);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("approveOvertime API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("approveOvertime API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> rejectOvertime(OvertimeModel model) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.rejectOvertime('Bearer ${FieldValue.token}', model, FieldValue.userId);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("rejectOvertime API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("rejectOvertime API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

}