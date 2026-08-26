import 'package:flutter/foundation.dart';
import 'package:i_employment/repo/api_service.dart';
import 'package:i_employment/repo/api_status.dart';
import 'package:dio/dio.dart' as dio;

import '../models/responses/response_model_without_data.dart';
import '../models/security/change_password_request_model.dart';
import '../models/security/login_request_model.dart';
import '../models/security/login_response_model.dart';
import '../utils/global_fields.dart';

class LoginServices {

  static Future<Object> doLogin(LoginRequestModel loginRequestModel) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      LoginResponseModel response = await apiService.Login(loginRequestModel);

      if (response.isSuccess)
        return Success(response: response);
      else
        return Failed(code: 103, failedReason: response.message);
    } on dio.DioError catch (obj) {
      return ApiError.getApiErrorMessage(obj);
    } catch (e) {
      if(kDebugMode) {print("Login ERROR : $e}");}
      return Failed(code: 103, failedReason:e.toString());
    }
  }

  static Future<Object> changePassword(ChangePasswordRequestModel model) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.changePassword('Bearer ${FieldValue.token}', model);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("changePassword API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("changePassword API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> forgetPassword(String email) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      ResponseModelWithoutData response =
      await apiService.forgetPassword('Bearer ${FieldValue.token}', email);
      if(response.isSuccess){
        return Success(response: response);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("forgetPassword API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("forgetPassword API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }
}
