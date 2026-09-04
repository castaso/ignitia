import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:ignitia_dashboard/models/task/task_model.dart';
import 'package:ignitia_dashboard/repo/api_status.dart';
import 'package:ignitia_dashboard/utils/global_fields.dart';
import 'api_service.dart';

class DashboardService {
  static Future<Object> _call(
      Future<Map<String, dynamic>> Function() request) async {
    try {
      ApiService apiService = ApiService(dio.Dio());
      Map<String, dynamic> response = await request();
      if (response["isSuccess"] == true) {
        return Success(response: response["data"]);
      } else {
        return Failed(code: 103, failedReason: response["message"]);
      }
    } on dio.DioError catch (obj) {
      if (kDebugMode) {
        print("dashboard API ERROR : $obj}");
      }
      return Failed(
          code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      if (kDebugMode) {
        print("dashboard API ERROR : $e}");
      }
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  static Future<Object> getSummary() => _call(() {
        var api = ApiService(dio.Dio());
        return api.getDashboardSummary('Bearer ${FieldValue.token}')
            .then((d) => d as Map<String, dynamic>);
      });

  static Future<Object> getEmployeeChart(String metric) => _call(() {
        var api = ApiService(dio.Dio());
        return api
            .getEmployeeChart('Bearer ${FieldValue.token}', metric)
            .then((d) => d as Map<String, dynamic>);
      });

  static Future<Object> getWhoIsOff([int days = 7]) => _call(() {
        var api = ApiService(dio.Dio());
        return api
            .getWhoIsOff('Bearer ${FieldValue.token}', days)
            .then((d) => d as Map<String, dynamic>);
      });

  static Future<Object> getContractProbation([int windowDays = 30]) =>
      _call(() {
        var api = ApiService(dio.Dio());
        return api
            .getContractProbation('Bearer ${FieldValue.token}', windowDays)
            .then((d) => d as Map<String, dynamic>);
      });

  static Future<Object> getAiSummary() => _call(() {
        var api = ApiService(dio.Dio());
        return api.getAiSummary('Bearer ${FieldValue.token}')
            .then((d) => d as Map<String, dynamic>);
      });

  static Future<Object> getLeaveSummary([int employeeId = 0]) => _call(() {
        var api = ApiService(dio.Dio());
        var id = employeeId == 0 ? FieldValue.userId : employeeId;
        return api
            .getEmployeeLeaveSummary('Bearer ${FieldValue.token}', id)
            .then((d) => d as Map<String, dynamic>);
      });

  static Future<Object> getAnnouncements([int companyId = 0]) => _call(() {
        var api = ApiService(dio.Dio());
        return api
            .getAnnouncements('Bearer ${FieldValue.token}', companyId)
            .then((d) => d as Map<String, dynamic>);
      });

  static Future<Object> getNotifications([int isRead = 0]) => _call(() {
        var api = ApiService(dio.Dio());
        return api
            .getNotifications('Bearer ${FieldValue.token}', isRead)
            .then((d) => d as Map<String, dynamic>);
      });

  static Future<Object> markNotificationRead(int id) async {
    try {
      var api = ApiService(dio.Dio());
      var response =
          await api.markNotificationRead('Bearer ${FieldValue.token}', id);
      if (response.isSuccess) {
        return Success(response: true);
      } else {
        return Failed(code: 103, failedReason: response.message);
      }
    } on dio.DioError catch (obj) {
      return Failed(
          code: 103, failedReason: ApiError.getApiErrorMessage(obj));
    } catch (e) {
      return Failed(code: 103, failedReason: ApiError.getErrorMsgByCode(103));
    }
  }

  // ---- Tasks ----

  static Future<Object> getTasks({String? status, int? assignedTo}) =>
      _call(() {
        var api = ApiService(dio.Dio());
        return api
            .getTasks('Bearer ${FieldValue.token}', status, assignedTo)
            .then((d) => d as Map<String, dynamic>);
      });

  static Future<Object> addTask(TaskModel task) => _call(() {
        var api = ApiService(dio.Dio());
        return api.addTask('Bearer ${FieldValue.token}', task)
            .then((d) => d as Map<String, dynamic>);
      });

  static Future<Object> updateTask(TaskModel task) => _call(() {
        var api = ApiService(dio.Dio());
        return api.updateTask('Bearer ${FieldValue.token}', task)
            .then((d) => d as Map<String, dynamic>);
      });

  static Future<Object> deleteTask(int id) => _call(() {
        var api = ApiService(dio.Dio());
        return api.deleteTask('Bearer ${FieldValue.token}', id)
            .then((d) => d as Map<String, dynamic>);
      });
}
