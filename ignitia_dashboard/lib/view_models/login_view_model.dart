import 'package:flutter/foundation.dart';
import 'package:ignitia_dashboard/repo/login_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ignitia_dashboard/repo/api_status.dart';
import 'package:ignitia_dashboard/utils/global_fields.dart';
import 'package:ignitia_dashboard/utils/message.dart';
import 'package:ignitia_dashboard/utils/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/security/login_request_model.dart';
import '../models/security/login_response_model.dart';
import '../models/employee/employee_model.dart';
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

  bool get isSupabaseConfigured {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  doLogin(String userName, String password) async{
    setErrorMsg("");
    setLoginStatus(false);
    setLoading(true);
    LoginRequestModel loginRequestModel = new LoginRequestModel(userName, password);
    var res = await LoginServices.doLogin(loginRequestModel);
    if(res is Success){
      var data = res.response as LoginResponseModel;
      _storeData(data);
      setLoginStatus(data.isSuccess);
    }else if (res is Failed){
      setErrorMsg(res.failedReason as String);
      setLoginStatus(false);
    }
    setLoading(false);
  }

  Future<void> doGoogleLogin() async {
    setErrorMsg("");
    setLoginStatus(false);
    if (!isSupabaseConfigured) {
      setErrorMsg("Google SSO not configured");
      return;
    }
    setLoading(true);
    try {
      final supabase = Supabase.instance.client;
      final redirected = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.origin,
      );
      if (!redirected) {
        setErrorMsg("Google sign-in was cancelled");
        setLoading(false);
        return;
      }
      // After redirect, session should be available on next app load;
      // for web, poll briefly for session.
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        final session = supabase.auth.currentSession;
        if (session?.accessToken != null) {
          final res = await LoginServices.supabaseLogin(session!.accessToken);
          if (res is Success) {
            final data = res.response as LoginResponseModel;
            _storeData(data);
            setLoginStatus(data.isSuccess);
          } else if (res is Failed) {
            setErrorMsg(res.failedReason as String);
            setLoginStatus(false);
          }
          setLoading(false);
          return;
        }
      }
      // Fallback: listen for auth change
      final sub = supabase.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session?.accessToken != null) {
          final res = await LoginServices.supabaseLogin(session!.accessToken);
          if (res is Success) {
            final d = res.response as LoginResponseModel;
            _storeData(d);
            setLoginStatus(d.isSuccess);
          } else if (res is Failed) {
            setErrorMsg(res.failedReason as String);
          }
          setLoading(false);
        }
      });
      await Future.delayed(const Duration(seconds: 5));
      await sub.cancel();
      if (!isLoginSuccess) setErrorMsg("Google sign-in timed out. Please try again.");
    } catch (e) {
      setErrorMsg(e.toString());
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
  // the login response into the local session so the policy is kept consistent.
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

    SessionManager.setAttendanceLocationType(type);
    SessionManager.setHomeLatitude(homeLatitude);
    SessionManager.setHomeLongitude(homeLongitude);
    SessionManager.setHomeRadiusMeters(homeRadius);
  }

  _getAppInfo() async {
    _versionName = "1.0.0";
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

  Future<bool> forgetPassword(String email) async {
    setErrorMsg("");
    setLoading(true);
    try {
      var res = await LoginServices.forgetPassword(email);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res;
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
