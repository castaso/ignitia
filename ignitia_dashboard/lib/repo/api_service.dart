import 'package:dio/dio.dart';
import 'package:ignitia_dashboard/models/employee/employee_contact_info_response_model.dart';
import 'package:ignitia_dashboard/models/employee/employee_list_response_model.dart';
import 'package:ignitia_dashboard/models/holiday/holiday_model.dart';
import 'package:ignitia_dashboard/models/holiday/holiday_response_model.dart';
import 'package:ignitia_dashboard/models/overtime/overtime_model.dart';
import 'package:ignitia_dashboard/models/overtime/overtime_response_model.dart';
import 'package:ignitia_dashboard/models/responses/response_model_without_data.dart';
import 'package:ignitia_dashboard/models/security/login_request_model.dart';
import 'package:ignitia_dashboard/models/security/login_response_model.dart';
import 'package:ignitia_dashboard/models/shift/employee_shift_assign_model.dart';
import 'package:ignitia_dashboard/models/shift/shift_model.dart';
import 'package:ignitia_dashboard/models/shift/shift_response_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/http.dart';

part 'api_service.g.dart';

/// Base URL of the backend, overridable at build time:
///   flutter build/run --dart-define=API_BASE_URL=http://<host>:<port>/api/
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://27.147.159.195:86/api/',
);

@RestApi(baseUrl: kApiBaseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl = kApiBaseUrl}) {
    dio.options = BaseOptions(
      receiveTimeout: const Duration(milliseconds: 30000),
      connectTimeout: const Duration(milliseconds: 30000),
      contentType: 'application/json',
      headers: {
        'Content-Type': 'application/json',
      }
    );
    return _ApiService(dio, baseUrl: baseUrl);
  }

  @POST('Login')
  Future<LoginResponseModel> Login(@Body() LoginRequestModel loginRequestModel);

  @GET('Overtime')
  Future<OvertimeResponseModel> getOvertimeList(@Header("Authorization") String token, @Query("id") int id, @Query("startDate") String startDate, @Query("endDate") String endDate);

  @POST('Overtime')
  Future<ResponseModelWithoutData> addOvertime(@Header("Authorization") String token, @Body() OvertimeModel overtimeModel, @Query("employeeName") String employeeName);

  @PUT('Overtime')
  Future<ResponseModelWithoutData> updateOvertime(@Header("Authorization") String token, @Body() OvertimeModel overtimeModel, @Query("employeeName") String employeeName);

  @DELETE('Overtime')
  Future<ResponseModelWithoutData> deleteOvertime(@Header("Authorization") String token, @Query("id") int id, @Query("employeeName") String employeeName);

  @PUT('Overtime/ApproveOvertime')
  Future<ResponseModelWithoutData> approveOvertime(@Header("Authorization") String token, @Body() OvertimeModel overtimeModel, @Query("supervisorId") int supervisorId);

  @PUT('Overtime/RejectOvertime')
  Future<ResponseModelWithoutData> rejectOvertime(@Header("Authorization") String token, @Body() OvertimeModel overtimeModel, @Query("supervisorId") int supervisorId);

  @GET('Holiday/getHolidayList')
  Future<HolidayResponseModel> getHolidayList(@Header("Authorization") String token);

  @POST('Holiday')
  Future<ResponseModelWithoutData> addHoliday(@Header("Authorization") String token, @Body() HolidayModel holidayModel, @Query("employeeName") String employeeName);

  @PUT('Holiday')
  Future<ResponseModelWithoutData> updateHoliday(@Header("Authorization") String token, @Body() HolidayModel holidayModel, @Query("employeeName") String employeeName);

  @DELETE('Holiday')
  Future<ResponseModelWithoutData> deleteHoliday(@Header("Authorization") String token, @Query("id") int id, @Query("employeeName") String employeeName);

  @GET('Shift/getShiftList')
  Future<ShiftResponseModel> getShiftList(@Header("Authorization") String token);

  @POST('Shift')
  Future<ResponseModelWithoutData> addShift(@Header("Authorization") String token, @Body() ShiftModel shiftModel, @Query("employeeName") String employeeName);

  @PUT('Shift')
  Future<ResponseModelWithoutData> updateShift(@Header("Authorization") String token, @Body() ShiftModel shiftModel, @Query("employeeName") String employeeName);

  @DELETE('Shift')
  Future<ResponseModelWithoutData> deleteShift(@Header("Authorization") String token, @Query("id") int id, @Query("employeeName") String employeeName);

  @POST('Shift/assignShift')
  Future<ResponseModelWithoutData> assignShift(@Header("Authorization") String token, @Body() EmployeeShiftAssignModel assignModel, @Query("employeeName") String employeeName);

  @GET('Employees')
  Future<EmployeeListResponseModel> getEmployeeList(@Header("Authorization") String token);

  @GET('Employees/GetContactInfo')
  Future<EmployeeContactInfoResponseModel> getContactInfo(@Header("Authorization") String token, @Query("id") int employeeId);

  @POST('Login/ForgetPassword')
  Future<ResponseModelWithoutData> forgetPassword(@Header("Authorization") String token, @Query("email") String email);
}
