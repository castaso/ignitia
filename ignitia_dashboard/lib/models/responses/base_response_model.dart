/*
class ApiResponse<T> extends BaseResponse{
  T data;
  ApiResponse({required super.isError, required super.message,required this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      ApiResponse(isError: json["isError"], message: json["message"], data: json["data"]);

}

class ApiListResponse extends BaseResponseModel{
  List<Object>? data;
  ApiListResponse({required super.isError, required super.message,required this.data});

  factory ApiListResponse.fromJson(Map<String, dynamic> json) =>
      ApiListResponse(isError: json["isError"], message: json["message"], data: json["data"]==null ? null : new List<Object>.from(json["data"]));
}
*/
abstract class BaseResponseModel{
  bool isSuccess;
  String message;

  BaseResponseModel({
    required this.isSuccess,
    required this.message
  });
}