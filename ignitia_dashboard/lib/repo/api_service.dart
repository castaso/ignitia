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
import 'package:ignitia_dashboard/models/task/task_model.dart';
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

  // Time Management — Work Schedule (roster mingguan)
  @GET('WorkSchedule/templates')
  Future<dynamic> getWorkScheduleTemplates(@Header("Authorization") String token);

  @POST('WorkSchedule/templates')
  Future<ResponseModelWithoutData> addWorkScheduleTemplate(@Header("Authorization") String token, @Body() dynamic template);

  @PUT('WorkSchedule/templates')
  Future<ResponseModelWithoutData> updateWorkScheduleTemplate(@Header("Authorization") String token, @Body() dynamic template);

  @DELETE('WorkSchedule/templates')
  Future<ResponseModelWithoutData> deleteWorkScheduleTemplate(@Header("Authorization") String token, @Query("id") int id);

  @GET('WorkSchedule/rosters')
  Future<dynamic> getRosters(@Header("Authorization") String token, @Query("employee_id") int employeeId);

  @POST('WorkSchedule/rosters/bulk')
  Future<ResponseModelWithoutData> bulkAssignRoster(@Header("Authorization") String token, @Body() dynamic payload);

  // Time Management — Break (Istirahat, 1 tipe per company)
  @GET('Break/config')
  Future<dynamic> getBreakConfig(@Header("Authorization") String token);

  @PUT('Break/config')
  Future<ResponseModelWithoutData> updateBreakConfig(@Header("Authorization") String token, @Body() dynamic config);

  @GET('Break/sessions')
  Future<dynamic> getBreakSessions(@Header("Authorization") String token, @Query("employee_id") int employeeId, @Query("startDate") String startDate, @Query("endDate") String endDate);

  @GET('Liveness/challenge')
  Future<dynamic> getLivenessChallenge(@Header("Authorization") String token);

  // Time Management — Timesheet (weekly, HR approve + export)
  @GET('Timesheet')
  Future<dynamic> getTimesheet(@Header("Authorization") String token, @Query("employee_id") int employeeId, @Query("startDate") String startDate, @Query("endDate") String endDate);

  @POST('Timesheet/generate')
  Future<ResponseModelWithoutData> generateTimesheet(@Header("Authorization") String token, @Query("employee_id") int employeeId, @Query("startDate") String startDate, @Query("endDate") String endDate);

  @POST('Timesheet/submit')
  Future<ResponseModelWithoutData> submitTimesheet(@Header("Authorization") String token, @Body() dynamic payload);

  @POST('Timesheet/approve')
  Future<ResponseModelWithoutData> approveTimesheet(@Header("Authorization") String token, @Body() dynamic payload);

  // Company Hub — Aset, Activity, Announcements, Notifications, Files, Reports
  @GET('CompanyAssets')
  Future<dynamic> getCompanyAssets(@Header("Authorization") String token, @Query("company_id") int companyId, @Query("category") String category, @Query("status") String status);

  @POST('CompanyAssets')
  Future<ResponseModelWithoutData> addCompanyAsset(@Header("Authorization") String token, @Body() dynamic asset);

  @PUT('CompanyAssets')
  Future<ResponseModelWithoutData> updateCompanyAsset(@Header("Authorization") String token, @Body() dynamic asset);

  @DELETE('CompanyAssets')
  Future<ResponseModelWithoutData> deleteCompanyAsset(@Header("Authorization") String token, @Query("id") int id);

  @GET('ActivityLogs')
  Future<dynamic> getActivityLogs(@Header("Authorization") String token, @Query("employee_id") int employeeId, @Query("action") String action, @Query("startDate") String startDate, @Query("endDate") String endDate);

  @GET('Announcements')
  Future<dynamic> getAnnouncements(@Header("Authorization") String token, @Query("company_id") int companyId);

  @POST('Announcements')
  Future<ResponseModelWithoutData> addAnnouncement(@Header("Authorization") String token, @Body() dynamic ann);

  @POST('Announcements/{id}/publish')
  Future<ResponseModelWithoutData> publishAnnouncement(@Header("Authorization") String token, @Path("id") int id);

  @GET('Notifications')
  Future<dynamic> getNotifications(@Header("Authorization") String token, @Query("is_read") int isRead);

  @POST('Notifications/{id}/read')
  Future<ResponseModelWithoutData> markNotificationRead(@Header("Authorization") String token, @Path("id") int id);

  @POST('CompanyFiles')
  Future<ResponseModelWithoutData> uploadCompanyFile(@Header("Authorization") String token, @Body() dynamic formData);

  @GET('CompanyFiles')
  Future<dynamic> getCompanyFiles(@Header("Authorization") String token, @Query("all") int all);

  @GET('Employees')
  Future<EmployeeListResponseModel> getEmployeeList(@Header("Authorization") String token);

  @GET('Employees/GetContactInfo')
  Future<EmployeeContactInfoResponseModel> getContactInfo(@Header("Authorization") String token, @Query("id") int employeeId);

  @POST('Login/ForgetPassword')
  Future<ResponseModelWithoutData> forgetPassword(@Header("Authorization") String token, @Query("email") String email);

  // Dashboard — Super-Admin home aggregation
  @GET('Dashboard/summary')
  Future<dynamic> getDashboardSummary(@Header("Authorization") String token);

  @GET('Dashboard/employeeChart')
  Future<dynamic> getEmployeeChart(@Header("Authorization") String token, @Query("metric") String metric);

  @GET('Dashboard/whoIsOff')
  Future<dynamic> getWhoIsOff(@Header("Authorization") String token, @Query("days") int days);

  @GET('Dashboard/contractProbation')
  Future<dynamic> getContractProbation(@Header("Authorization") String token, @Query("window_days") int windowDays);

  @GET('Dashboard/aiSummary')
  Future<dynamic> getAiSummary(@Header("Authorization") String token);

  // Leave balance (Balance Time Off card)
  @GET('Leave/getEmployeeLeaveSummary')
  Future<dynamic> getEmployeeLeaveSummary(@Header("Authorization") String token, @Query("employeeId") int employeeId);

  // Dashboard — Tasks
  @GET('Tasks')
  Future<dynamic> getTasks(@Header("Authorization") String token, @Query("status") String? status, @Query("assigned_to") int? assignedTo);

  @POST('Tasks')
  Future<dynamic> addTask(@Header("Authorization") String token, @Body() TaskModel task);

  @PUT('Tasks')
  Future<dynamic> updateTask(@Header("Authorization") String token, @Body() TaskModel task);

  @DELETE('Tasks')
  Future<dynamic> deleteTask(@Header("Authorization") String token, @Query("id") int id);
}
