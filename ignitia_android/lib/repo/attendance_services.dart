import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:i_employment/models/attendance/attendance_model.dart';
import 'package:i_employment/models/attendance/liveness_challenge_response_model.dart';
import 'package:i_employment/models/attendance/user_attendance_response_model.dart';
import 'package:i_employment/models/responses/response_model_without_data.dart';
import 'package:i_employment/repo/api_status.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:intl/intl.dart';
import '../models/attendance/user_attendance_summary_response_model.dart';
import 'api_service.dart';

class AttendanceService{

  static Future<Object> getUserAttendanceSummary(DateTime startDate, DateTime endDate) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      UserAttendanceSummaryResponseModel response =
      await apiService.getUserAttendanceSummary('Bearer ${FieldValue.token}', FieldValue.userId, DateFormat("dd-MMM-yyyy").format(startDate), DateFormat("dd-MMM-yyyy").format(endDate));
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getUserAttendanceSummary API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getUserAttendanceSummary API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> getUserAttendance(DateTime startDate, DateTime endDate, [int employeeId=-1, String token=""]) async {
    try {
      var userId = employeeId>-1 ? employeeId : FieldValue.userId;
      var bearerToken = token.isNotEmpty ? token : FieldValue.token;
      ApiService apiService = ApiService(dio.Dio());
      UserAttendanceResponseModel response =
      await apiService.getUserAttendance('Bearer ${bearerToken}', userId, DateFormat("dd-MMM-yyyy").format(startDate), DateFormat("dd-MMM-yyyy").format(endDate));
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getUserAttendance API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getUserAttendance API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  // Fetches a fresh single-use liveness challenge id that must accompany the
  // blink frames on the next check-in / check-out. Returns null on failure.
  static Future<String?> getLivenessChallenge() async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      LivenessChallengeResponseModel response =
          await apiService.getLivenessChallenge('Bearer ${FieldValue.token}');
      if (response.isSuccess && response.data?.challengeId != null) {
        return response.data!.challengeId;
      }
      return null;
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getLivenessChallenge API ERROR : $obj}");}
      return null;
    } catch (e) {
      if(kDebugMode) {print("getLivenessChallenge API ERROR : $e}");}
      return null;
    }
  }

  static Future<Object> checkIn(AttendanceModel attendanceModel,[String token=""]) async {
    try {
      var bearerToken = token.isNotEmpty ? token : FieldValue.token;
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.checkIn('Bearer ${bearerToken}', attendanceModel);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("checkIn API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("checkIn API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> checkOut(AttendanceModel attendanceModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.checkOut('Bearer ${FieldValue.token}', attendanceModel);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("checkOut API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("checkOut API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> requestEditAttendance(AttendanceModel attendanceModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.requestEditAttendance('Bearer ${FieldValue.token}', FieldValue.userId, FieldValue.userName, attendanceModel);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("requestEditAttendance API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("requestEditAttendance API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> getAttendanceRequest(DateTime startDate, DateTime endDate,[int employeeId = -1]) async {
    try {
      var userId = employeeId >-1 ? employeeId : FieldValue.userId;
      ApiService apiService = ApiService(dio.Dio());
      UserAttendanceResponseModel response =
      await apiService.getAttendanceRequest('Bearer ${FieldValue.token}', userId, DateFormat("dd-MMM-yyyy").format(startDate), DateFormat("dd-MMM-yyyy").format(endDate));
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getAttendanceRequest API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getAttendanceRequest API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> deleteAttendanceRequest(int requestId) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.deleteAttendanceRequest('Bearer ${FieldValue.token}', requestId);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("deleteAttendanceRequest API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("deleteAttendanceRequest API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> approveAttendanceRequest(int requestId, int approvalStatusId, String rejectionReason) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.approveAttendance('Bearer ${FieldValue.token}', requestId, FieldValue.userId, approvalStatusId, rejectionReason);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("approveAttendanceRequest API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("approveAttendanceRequest API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

}