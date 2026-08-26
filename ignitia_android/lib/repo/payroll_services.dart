import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:i_employment/models/attendance/attendance_model.dart';
import 'package:i_employment/models/attendance/user_attendance_response_model.dart';
import 'package:i_employment/models/overtime/overtime_response_model.dart';
import 'package:i_employment/models/payroll/payslip_response_model.dart';
import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:i_employment/models/responses/response_model_without_data.dart';
import 'package:i_employment/repo/api_status.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:intl/intl.dart';
import '../models/attendance/user_attendance_summary_response_model.dart';
import '../models/overtime/overtime_model.dart';
import 'api_service.dart';

class PayrollService{

  static Future<Object> getPayslip(int year, int month) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      PayslipResponseModel response =
      await apiService.getPayslip('Bearer ${FieldValue.token}', FieldValue.userId, year, month);
      if(response.isSuccess){
        return Success(response: response.data);
      }else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      if(kDebugMode) {print("getPayslip API ERROR : $obj}");}
      return Failed(code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if(kDebugMode) {print("getPayslip API ERROR : $e}");}
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

}