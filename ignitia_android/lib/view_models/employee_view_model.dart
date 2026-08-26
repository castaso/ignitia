import 'dart:async';

import 'package:i_employment/config/office_location_config.dart';
import 'package:i_employment/models/employee/employee_contact_info_model.dart';
import 'package:i_employment/models/employee/profile_model.dart';
import 'package:i_employment/repo/employee_services.dart';
import 'package:i_employment/repo/payroll_services.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/utils/shared_preference.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/view_models/base_view_model.dart';
import '../models/dropdown_model.dart';
import '../models/employee/employee_model.dart';
import '../repo/api_status.dart';
import '../utils/message.dart';

class EmployeeViewModel extends BaseViewModel {
  // User home employee
  List<EmployeeModel> _employeeList = [];
  List<EmployeeModel> get employeeList => _employeeList;
  List<DropDownModel> _dropDownItems = [];
  List<DropDownModel> get dropDownItems => _dropDownItems;
  _setEmployeeList(List<EmployeeModel> list) {
    _employeeList.clear();
    _employeeList = list;
    dropDownItems.clear();
    list.forEach((e) {
      dropDownItems.add(DropDownModel(e.id, e.employeeName));
    });
    notifyListeners();
  }
  Future getEmployeeList() async {
    setErrorMsg("");
    setLoading(true);

    var res = await EmployeeService.getEmployeeList();
    if (res is Success) {
      var data = res.response as List<EmployeeModel>;
      _setEmployeeList(data);
      setLoading(false);
    } else if (res is Failed) {
      _employeeList.clear();
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

  Future getProfile(int employeeId) async {
    setErrorMsg("");
    setLoading(true);

    var res = await EmployeeService.getProfile(employeeId);
    if (res is Success) {
      var data = res.response as EmployeeModel?;
      if (data != null &&
          (employeeId == 0 || employeeId == FieldValue.userId)) {
        await _applyAttendanceLocationPolicy(data);
      }
      setLoading(false);
      return data;
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
      return null;
    }
    notifyListeners();
  }

  Future getContactInfo(int employeeId) async {
    setErrorMsg("");
    setLoading(true);

    var res = await EmployeeService.getContactInfo(employeeId);
    if (res is Success) {
      var data = res.response as EmployeeContactInfoModel?;
      setLoading(false);
      return data;
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
      return null;
    }
    notifyListeners();
  }

  bool _validateUserForEdit(String cellNo, String name) {

    if (cellNo.isEmpty) {
      setErrorMsg(Messages.errorCellNoEmpty);
      return false;
    } else if (cellNo.length != 11) {
      setErrorMsg(Messages.errorCellNoDigit);
      return false;
    } else if (name.isEmpty) {
      setErrorMsg(Messages.errorNameEmpty);
      return false;
    } else {
      return true;
    }
  }

  Future<bool> updateProfile(EmployeeModel employeeModel, EmployeeContactInfoModel? contactInfoModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateUserForEdit(
        employeeModel.cellNo!, employeeModel.employeeName) ==
        false) {
      setLoading(false);
      return false;
    }
    if (_validateAttendanceLocation(employeeModel) == false) {
      setLoading(false);
      return false;
    }
    try {
      var profile = ProfileModel(employeeModel, contactInfoModel);
      var res = await EmployeeService.updateProfile(profile);
      if (res is Success) {
        await SessionManager.setUserName(employeeModel.employeeName);
        FieldValue.userName = employeeModel.employeeName;
        await _applyAttendanceLocationPolicy(employeeModel);
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

  bool _validateAttendanceLocation(EmployeeModel employeeModel) {
    var type = employeeModel.attendanceLocationType.isEmpty
        ? Strings.attendanceLocationTypeOffice
        : employeeModel.attendanceLocationType;
    if (type.toLowerCase() == Strings.attendanceLocationTypeHome.toLowerCase()) {
      if (employeeModel.homeLatitude == null ||
          employeeModel.homeLongitude == null ||
          (employeeModel.homeLatitude == 0 &&
              employeeModel.homeLongitude == 0)) {
        setErrorMsg(Messages.errorHomeCoordinatesRequired);
        return false;
      }
      if ((employeeModel.homeRadiusMeters ?? 0) <= 0) {
        setErrorMsg(Messages.errorHomeRadiusRange);
        return false;
      }
    }
    return true;
  }

  // Copies the attendance location restriction from the employee profile into
  // the app configuration and the local session so the geo-fence validation
  // uses the policy defined on the employee profile.
  Future<void> _applyAttendanceLocationPolicy(EmployeeModel employeeModel) async {
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

    await SessionManager.setAttendanceLocationType(type);
    await SessionManager.setHomeLatitude(homeLatitude);
    await SessionManager.setHomeLongitude(homeLongitude);
    await SessionManager.setHomeRadiusMeters(homeRadius);
  }
}
