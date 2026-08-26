import 'package:flutter/foundation.dart';
import 'package:i_employment/config/office_location_config.dart';
import 'package:i_employment/models/security/change_password_request_model.dart';
import 'package:i_employment/repo/login_services.dart';
import 'package:i_employment/repo/api_status.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/utils/message.dart';
import 'package:i_employment/utils/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/security/login_request_model.dart';
import '../models/security/login_response_model.dart';
import '../models/employee/employee_model.dart';
import '../repo/background_service.dart';
import '../repo/notification_service.dart';
import '../utils/string.dart';

class LoginViewModel extends ChangeNotifier{
  bool _loading = false;
  bool _isLoginSuccess = false;
  String _errorMsg = "";
  String _versionName = "";
  String _appName = "";

  bool get loading => _loading;

  String get errorMsg => _errorMsg;

  String get versionName => _versionName;

  String get appName => _appName;

  bool get isLoginSuccess => _isLoginSuccess;

  LoginViewModel(){
    _getAppInfo();
  }

  setLoading(bool loading){
    _loading = loading;
    notifyListeners();
  }

  setErrorMsg(String msg){
    _errorMsg = msg;
    notifyListeners();
  }

  setLoginStatus(bool status){
    _isLoginSuccess = status;
    notifyListeners();
  }

  doLogin(String userName, String password) async{
    setErrorMsg("");
    setLoginStatus(false);
    setLoading(true);
    LoginRequestModel loginRequestModel = new LoginRequestModel(userName, password);
    var res = await LoginServices.doLogin(loginRequestModel);
    if(res is Success){
      // setLoginResponseModel(res.response as LoginResponse);
      var data = res.response as LoginResponseModel;
      _storeData(data);
      setLoginStatus(data.isSuccess);
      if(!kIsWeb) {
        NotificationService().initNotification();
        BackgroundService().initializeService();
      }
    }else if (res is Failed){
      setErrorMsg(res.failedReason as String);
      setLoginStatus(false);
    }
    setLoading(false);
  }

  _storeData(LoginResponseModel responseModel) async{
    FieldValue.isUserLoggedIn = true;
    String loginTime = DateFormat("dd/MM/yyyy hh:mm a").format(DateTime.now());
    FieldValue.lastLoginTime = loginTime;
    FieldValue.userName = responseModel.data!.employeeName;
    FieldValue.userId = responseModel.data!.id;
    FieldValue.employeeId = responseModel.data!.employeeId;
    FieldValue.userDesignation = responseModel.data!.designation;
    FieldValue.userEmail = responseModel.data!.email;
    FieldValue.userTypeId = responseModel.data!.typeId;
    FieldValue.token = responseModel.message;
    _applyAttendanceLocationPolicy(responseModel.data!);

    SessionManager.setToken(responseModel.message);
    SessionManager.setUserId(responseModel.data!.id);
    SessionManager.setEmployeeId(responseModel.data!.employeeId);
    SessionManager.setUserName(responseModel.data!.employeeName);
    SessionManager.setUserDesignation(responseModel.data!.designation);
    SessionManager.setUserEmail(responseModel.data!.email);
    SessionManager.setUserTypeId(responseModel.data!.typeId);
    SessionManager.setUserLoggedIn(true);
    SessionManager.setLastLoginTime(loginTime);

  }

  // Copies the attendance location restriction (Office / Home / Anywhere) from
  // the login response into the app configuration and the local session so the
  // geo-fence validation uses the policy defined on the employee profile.
  void _applyAttendanceLocationPolicy(EmployeeModel employeeModel) {
    var type = employeeModel.attendanceLocationType.isEmpty
        ? Strings.attendanceLocationTypeOffice
        : employeeModel.attendanceLocationType;
    var homeLatitude = employeeModel.homeLatitude ?? 0;
    var homeLongitude = employeeModel.homeLongitude ?? 0;
    var homeRadius = employeeModel.homeRadiusMeters ?? 300;

    FieldValue.attendanceLocationType = type;
    FieldValue.homeLatitude = homeLatitude;
    FieldValue.homeLongitude = homeLongitude;
    FieldValue.homeRadiusMeters = homeRadius;

    OfficeLocationConfig.setEmployeeLocationRestriction(
      type,
      homeLatitude: homeLatitude,
      homeLongitude: homeLongitude,
      homeRadiusMeters: homeRadius,
    );

    SessionManager.setAttendanceLocationType(type);
    SessionManager.setHomeLatitude(homeLatitude);
    SessionManager.setHomeLongitude(homeLongitude);
    SessionManager.setHomeRadiusMeters(homeRadius);
  }

  _getAppInfo() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _versionName = "${packageInfo.version}";
      _appName = "${Strings.appName}";
      notifyListeners();
  }

  bool validateUserInformation(String username, String password){
    String msg = "";
    if(username.isEmpty){
      msg = Messages.errorUserNameEmpty;
    }else if(password.isEmpty){
      msg = Messages.errorPasswordEmpty;
    }else if(password.length<6){
      msg = Messages.errorPasswordDigit;
    }
    if(msg.isNotEmpty){
      setErrorMsg(msg);
      return false;
    }else{
      return true;
    }
  }

  bool validateChangePassword(String oldPassword, String newPassword, String confirmPassword){
    String msg = "";
    if(oldPassword.isEmpty){
      msg = Messages.errorOldPasswordEmpty;
    }else if(newPassword.isEmpty){
      msg = Messages.errorNewPasswordEmpty;
    }else if(newPassword.length<6){
      msg = Messages.errorNewPasswordDigit;
    }else if(confirmPassword!=newPassword){
      msg = Messages.errorConfirmPasswordMatch;
    }
    if(msg.isNotEmpty){
      setErrorMsg(msg);
      return false;
    }else{
      return true;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    setErrorMsg("");
    setLoading(true);
    if (validateChangePassword(oldPassword, newPassword, confirmPassword) ==
        false) {
      setLoading(false);
      return false;
    }
    try {
      var model = ChangePasswordRequestModel(FieldValue.userEmail, oldPassword, newPassword);
      var res = await LoginServices.changePassword(model);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res as Failed;
        setErrorMsg(result.failedReason.toString());
        setLoading(false);
        return false;
      } else {
        return false;
      }
    } catch (ex) {
      setErrorMsg(ex.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> forgetPassword(String email) async {
    setErrorMsg("");
    setLoading(true);
    try {
      var res = await LoginServices.forgetPassword(email);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res as Failed;
        setErrorMsg(result.failedReason.toString());
        setLoading(false);
        return false;
      } else {
        return false;
      }
    } catch (ex) {
      setErrorMsg(ex.toString());
      setLoading(false);
      return false;
    }
  }
}