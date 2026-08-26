import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:ignitia_dashboard/models/holiday/holiday_model.dart';
import 'package:ignitia_dashboard/models/holiday/holiday_response_model.dart';
import 'package:ignitia_dashboard/repo/api_status.dart';
import 'package:ignitia_dashboard/utils/global_fields.dart';
import '../models/responses/response_model_without_data.dart';
import 'api_service.dart';

class HolidayService{

  static Future<Object> getHolidayList() async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      HolidayResponseModel response =
      await apiService.getHolidayList('Bearer ${FieldValue.token}');
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getHolidayList API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getHolidayList API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> addHoliday(HolidayModel holidayModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.addHoliday('Bearer ${FieldValue.token}', holidayModel, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("addHoliday API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("addHoliday API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> updateHoliday(HolidayModel holidayModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.updateHoliday('Bearer ${FieldValue.token}', holidayModel, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("updateHoliday API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("updateHoliday API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> deleteHoliday(int id) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.deleteHoliday('Bearer ${FieldValue.token}', id, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("deleteHoliday API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("deleteHoliday API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

}
