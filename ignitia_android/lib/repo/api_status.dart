import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';

class Success{
  int code;
  Object? response;
  Success({this.code = 0,required this.response});
}

class Failed{
  int code;
  Object failedReason;
  Failed({required this.code,required this.failedReason});
}

class ApiError{

  static Object getApiErrorMessage(Object obj){
    switch (obj.runtimeType) {
      case dio.DioError:
      // Here's the sample to get the failed response error code and message
        if ((obj as dio.DioError).response == null) {
          if(kDebugMode) {print("API ERROR : ${(obj as dio.DioError).message}");}
          return Failed(
              code: 103, failedReason: "${(obj as dio.DioError).message}");
        } else {
          final res = (obj as dio.DioError).response;
          //logger.e("Got error : ${res!.statusCode} -> ${res.statusMessage}");
          if(kDebugMode) {print("API ERROR : ${res!.statusMessage!}" );}
          return Failed(
              code: res!.statusCode!,
              failedReason: ApiError.getErrorMsgByCode(res!.statusCode!));
        }
        break;
      default:
        return obj;
        break;
    }
  }

  static String getErrorMsgByCode(int statusCode){
    var msg = "";
    switch(statusCode) {
      case 101:
        msg = "No Internet";
        break;

      case 102:
        msg = "Invalid Format";
        break;

      case 400:
        msg = "Bad Request";
      break;

      case 401:
        msg = "Unauthorized";
        break;

      case 403:
        msg = "Forbidden";
        break;

      case 404:
        msg = "Not Found";
        break;

      case 408:
        msg = "Request Timeout";
        break;

      case 500:
        msg = "Internal Server Error";
        break;

      case 502:
        msg = "Bad Gateway";
        break;

      case 503:
        msg = "Service Unavailable";
        break;

      case 504:
        msg = "Gateway Timeout";
        break;

      default:
        msg = "Unknown Error: $statusCode";
      break;
    }

    return msg;
  }
}