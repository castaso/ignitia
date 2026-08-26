import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:ignitia_dashboard/models/responses/response_model_without_data.dart';
import 'package:ignitia_dashboard/models/shift/employee_shift_assign_model.dart';
import 'package:ignitia_dashboard/models/shift/shift_model.dart';
import 'package:ignitia_dashboard/models/shift/shift_response_model.dart';
import 'package:ignitia_dashboard/repo/api_service.dart';
import 'package:ignitia_dashboard/repo/api_status.dart';
import 'package:ignitia_dashboard/utils/global_fields.dart';

class ShiftService {
  static Future<Object> getShiftList() async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ShiftResponseModel response =
      await apiService.getShiftList('Bearer ${FieldValue.token}');
      if (response.isSuccess) {
        return Success(response: response.data);
      } else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if (kDebugMode) {
        print("getShiftList API ERROR : $obj}");
      }
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if (kDebugMode) {
        print("getShiftList API ERROR : $e}");
      }
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> addShift(ShiftModel shiftModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.addShift(
          'Bearer ${FieldValue.token}', shiftModel, FieldValue.userName);
      if (response.isSuccess) {
        return Success(response: response);
      } else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if (kDebugMode) {
        print("addShift API ERROR : $obj}");
      }
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if (kDebugMode) {
        print("addShift API ERROR : $e}");
      }
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> updateShift(ShiftModel shiftModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.updateShift(
          'Bearer ${FieldValue.token}', shiftModel, FieldValue.userName);
      if (response.isSuccess) {
        return Success(response: response);
      } else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if (kDebugMode) {
        print("updateShift API ERROR : $obj}");
      }
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if (kDebugMode) {
        print("updateShift API ERROR : $e}");
      }
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> deleteShift(int id) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.deleteShift(
          'Bearer ${FieldValue.token}', id, FieldValue.userName);
      if (response.isSuccess) {
        return Success(response: response);
      } else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if (kDebugMode) {
        print("deleteShift API ERROR : $obj}");
      }
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if (kDebugMode) {
        print("deleteShift API ERROR : $e}");
      }
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> assignShift(
      EmployeeShiftAssignModel assignModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.assignShift(
          'Bearer ${FieldValue.token}', assignModel, FieldValue.userName);
      if (response.isSuccess) {
        return Success(response: response);
      } else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if (kDebugMode) {
        print("assignShift API ERROR : $obj}");
      }
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if (kDebugMode) {
        print("assignShift API ERROR : $e}");
      }
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }
}
