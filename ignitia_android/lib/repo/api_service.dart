

import 'package:dio/dio.dart';
import 'package:i_employment/models/attendance/attendance_model.dart';
import 'package:i_employment/models/attendance/liveness_challenge_response_model.dart';
import 'package:i_employment/models/attendance/user_attendance_summary_response_model.dart';
import 'package:i_employment/models/attendance/user_attendance_response_model.dart';
import 'package:i_employment/models/employee/employee_contact_info_response_model.dart';
import 'package:i_employment/models/employee/employee_list_response_model.dart';
import 'package:i_employment/models/holiday/holiday_model.dart';
import 'package:i_employment/models/holiday/holiday_response_model.dart';
import 'package:i_employment/models/leave/leave_response_model.dart';
import 'package:i_employment/models/leave/leave_summary_response_model.dart';
import 'package:i_employment/models/leave/user_leave_model.dart';
import 'package:i_employment/models/leave/user_leave_response_model.dart';
import 'package:i_employment/models/office/office_location_model.dart';
import 'package:i_employment/models/office/office_location_response_model.dart';
import 'package:i_employment/models/overtime/overtime_model.dart';
import 'package:i_employment/models/overtime/overtime_response_model.dart';
import 'package:i_employment/models/payroll/payslip_response_model.dart';
import 'package:i_employment/models/responses/base_response_model.dart';
import 'package:i_employment/models/responses/response_model_without_data.dart';
import 'package:i_employment/models/security/change_password_request_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/http.dart';
import 'package:i_employment/models/security/login_request_model.dart';
import 'package:i_employment/models/security/login_response_model.dart';

import '../models/employee/employee_response_model.dart';
import '../models/employee/profile_model.dart';

part 'api_service.g.dart';

/// Base URL of the backend, overridable at build time:
///   flutter build/run --dart-define=API_BASE_URL=http://<host>:<port>/api/
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://27.147.159.195:86/api/', // "http://27.147.159.195:86/api/" ---- localhost:5000
);

@RestApi(baseUrl: kApiBaseUrl)
abstract class ApiService{
  factory ApiService(Dio dio, {String baseUrl=kApiBaseUrl}){
    dio.options = BaseOptions(
        receiveTimeout: Duration(milliseconds: 30000),
        connectTimeout: Duration(milliseconds: 30000),
        contentType: 'application/json',
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST,GET,DELETE,PUT,OPTIONS'
        }
    );

    return _ApiService(dio, baseUrl:baseUrl);
  }

  @POST('Login')
  Future<LoginResponseModel> Login(@Body() LoginRequestModel loginRequestModel);

  @GET('Attendance/userAttendanceSummary')
  Future<UserAttendanceSummaryResponseModel> getUserAttendanceSummary(@Header("Authorization") String token, @Query("id") int id, @Query("startDate") String startDate, @Query("endDate") String endDate);

  @GET('Attendance/livenessChallenge')
  Future<LivenessChallengeResponseModel> getLivenessChallenge(@Header("Authorization") String token);

  @GET('Attendance/searchAttendanceByDate')
  Future<UserAttendanceResponseModel> getUserAttendance(@Header("Authorization") String token, @Query("id") int id, @Query("startDate") String startDate, @Query("endDate") String endDate);

  @POST('Attendance/v2/checkin')
  Future<ResponseModelWithoutData> checkIn(@Header("Authorization") String token, @Body() AttendanceModel attendanceModel);

  @POST('Attendance/v2/checkout')
  Future<ResponseModelWithoutData> checkOut(@Header("Authorization") String token, @Body() AttendanceModel attendanceModel);

  @PUT('Attendance/requestEditAttendance')
  Future<ResponseModelWithoutData> requestEditAttendance(@Header("Authorization") String token, @Query("id") int employeeId, @Query("name") String employeeName, @Body() AttendanceModel attendanceModel);

  @GET('Attendance/getAttendanceRequest')
  Future<UserAttendanceResponseModel> getAttendanceRequest(@Header("Authorization") String token, @Query("id") int id, @Query("startDate") String startDate, @Query("endDate") String endDate);

  @DELETE('Attendance/deleteAttendanceRequest')
  Future<ResponseModelWithoutData> deleteAttendanceRequest(@Header("Authorization") String token, @Query("requestId") int requestId);

  @POST('Attendance/approveAttendance')
  Future<ResponseModelWithoutData> approveAttendance(@Header("Authorization") String token, @Query("requestId") int requestId, @Query("approvedBy") int approvedBy,  @Query("approvalStatusId") int approvalStatusId,  @Query("rejectionReason") String rejectionReason);

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

  @GET('Payroll/GetPayslip')
  Future<PayslipResponseModel> getPayslip(@Header("Authorization") String token, @Query("employee_id") int employeeId, @Query("salary_year") int salaryYear, @Query("salary_month") int salaryMonth);

  @GET('Leave/getEmployeeLeaveSummary')
  Future<LeaveSummaryResponseModel> getEmployeeLeaveSummary(@Header("Authorization") String token, @Query("employeeId") int employeeID);

  @GET('Leave/getLeaveList')
  Future<LeaveResponseModel> getLeaveList(@Header("Authorization") String token);

  @GET('Holiday/getHolidayList')
  Future<HolidayResponseModel> getHolidayList(@Header("Authorization") String token);

  @POST('Holiday')
  Future<ResponseModelWithoutData> addHoliday(@Header("Authorization") String token, @Body() HolidayModel holidayModel, @Query("employeeName") String employeeName);

  @PUT('Holiday')
  Future<ResponseModelWithoutData> updateHoliday(@Header("Authorization") String token, @Body() HolidayModel holidayModel, @Query("employeeName") String employeeName);

  @DELETE('Holiday')
  Future<ResponseModelWithoutData> deleteHoliday(@Header("Authorization") String token, @Query("id") int id, @Query("employeeName") String employeeName);

  @GET('OfficeLocation/getOfficeLocationList')
  Future<OfficeLocationResponseModel> getOfficeLocationList(@Header("Authorization") String token);

  @POST('OfficeLocation')
  Future<ResponseModelWithoutData> addOfficeLocation(@Header("Authorization") String token, @Body() OfficeLocationModel officeLocationModel, @Query("employeeName") String employeeName);

  @PUT('OfficeLocation')
  Future<ResponseModelWithoutData> updateOfficeLocation(@Header("Authorization") String token, @Body() OfficeLocationModel officeLocationModel, @Query("employeeName") String employeeName);

  @DELETE('OfficeLocation')
  Future<ResponseModelWithoutData> deleteOfficeLocation(@Header("Authorization") String token, @Query("id") int id, @Query("employeeName") String employeeName);

  @GET('Leave')
  Future<UserLeaveResponseModel> getUserLeave(@Header("Authorization") String token, @Query("employeeId") int employeeID);

  @POST('Leave')
  Future<ResponseModelWithoutData> addEmployeeLeave(@Header("Authorization") String token, @Body() UserLeaveModel userLeaveModel, @Query("employeeName") String employeeName);

  @PUT('Leave')
  Future<ResponseModelWithoutData> updateEmployeeLeave(@Header("Authorization") String token, @Body() UserLeaveModel userLeaveModel, @Query("employeeName") String employeeName);

  @PUT('Leave/approveEmployeeLeave')
  Future<ResponseModelWithoutData> approveEmployeeLeave(@Header("Authorization") String token, @Body() UserLeaveModel userLeaveModel, @Query("supervisorId") int supervisorId);

  @DELETE('Leave')
  Future<ResponseModelWithoutData> deleteEmployeeLeave(@Header("Authorization") String token, @Query("id") int id, @Query("employeeName") String employeeName);

  @GET('Employees')
  Future<EmployeeListResponseModel> getEmployeeList(@Header("Authorization") String token);

  @GET('Employees/profile')
  Future<EmployeeResponseModel> getProfile(@Header("Authorization") String token, @Query("id") int employeeId);

  @GET('Employees/GetContactInfo')
  Future<EmployeeContactInfoResponseModel> getContactInfo(@Header("Authorization") String token, @Query("id") int employeeId);

  @PUT('Employees')
  Future<ResponseModelWithoutData> updateEmployee(@Header("Authorization") String token, @Body() ProfileModel profile);

  @POST('Login/ChangePassword')
  Future<ResponseModelWithoutData> changePassword(@Header("Authorization") String token, @Body() ChangePasswordRequestModel userLeaveModel);

  @POST('Login/ForgetPassword')
  Future<ResponseModelWithoutData> forgetPassword(@Header("Authorization") String token, @Query("email") String email);
}