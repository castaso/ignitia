import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:i_employment/models/office/office_location_model.dart';
import 'package:i_employment/models/office/office_location_response_model.dart';
import 'package:i_employment/repo/api_status.dart';
import 'package:i_employment/utils/global_fields.dart';
import '../models/responses/response_model_without_data.dart';
import 'api_service.dart';

class OfficeLocationService{

  static Future<Object> getOfficeLocationList() async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      OfficeLocationResponseModel response =
      await apiService.getOfficeLocationList('Bearer ${FieldValue.token}');
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getOfficeLocationList API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getOfficeLocationList API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> addOfficeLocation(OfficeLocationModel officeLocationModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.addOfficeLocation('Bearer ${FieldValue.token}', officeLocationModel, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("addOfficeLocation API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("addOfficeLocation API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> updateOfficeLocation(OfficeLocationModel officeLocationModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.updateOfficeLocation('Bearer ${FieldValue.token}', officeLocationModel, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("updateOfficeLocation API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("updateOfficeLocation API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> deleteOfficeLocation(int id) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.deleteOfficeLocation('Bearer ${FieldValue.token}', id, FieldValue.userName);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("deleteOfficeLocation API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("deleteOfficeLocation API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

}
