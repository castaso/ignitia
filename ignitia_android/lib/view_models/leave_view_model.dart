import 'dart:convert';

import 'package:i_employment/models/attendance/user_attendance_summary_model.dart';
import 'package:i_employment/models/dropdown_model.dart';
import 'package:i_employment/models/leave/leave_summary_model.dart';
import 'package:i_employment/models/leave/leave_summary_response_model.dart';
import 'package:i_employment/models/requests/base_request_model.dart';
import 'package:i_employment/repo/api_status.dart';
import 'package:i_employment/repo/attendance_services.dart';
import 'package:i_employment/repo/home_services.dart';
import 'package:i_employment/repo/leave_services.dart';
import 'package:i_employment/repo/location_service.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/view_models/base_view_model.dart';
import 'package:intl/intl.dart';
import '../models/attendance/attendance_model.dart';
import '../models/leave/leave_model.dart';
import '../models/leave/user_leave_model.dart';
import '../utils/message.dart';
import '../utils/shared_preference.dart';

class LeaveViewModel extends BaseViewModel {
  LeaveViewModel() {
    getLeaveList();
  }

  // Leave
  List<LeaveModel> _leaveList = [];
  List<LeaveModel> get leaveList => _leaveList;
  List<DropDownModel> _dropDownItems = [];
  List<DropDownModel> get dropDownItems => _dropDownItems;
  _setLeaveList(List<LeaveModel> list) {
    _leaveList = list;
    dropDownItems.clear();
    list.forEach((e) {
      dropDownItems.add(DropDownModel(e.id, e.leaveShortName));
    });
    notifyListeners();
  }

  Future getLeaveList() async {
    setErrorMsg("");
    setLoading(true);

    var res = await LeaveService.getLeaveList();
    if (res is Success) {
      var data = res.response as List<LeaveModel>;
      _setLeaveList(data);
      setLoading(false);
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

  // User Leave Summary
  List<LeaveSummaryModel> _leaveSummaryList = [];
  List<LeaveSummaryModel> get leaveSummaryList => _leaveSummaryList;
  _setLeaveSummaryModelList(List<LeaveSummaryModel> list) {
    _leaveSummaryList = list;
    notifyListeners();
  }

  Future getEmployeeLeaveSummary([int employeeId = -1]) async {
    setErrorMsg("");
    setLoading(true);

    var res = await LeaveService.getEmployeeLeaveSummary(employeeId);
    if (res is Success) {
      var data = res.response as List<LeaveSummaryModel>;
      _setLeaveSummaryModelList(data);
      setLoading(false);
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

  // User Leave detail
  List<UserLeaveModel> _userLeaveList = [];
  List<UserLeaveModel> get userLeaveList => _userLeaveList;
  _setUserLeaveList(List<UserLeaveModel> list) {
    _userLeaveList = list;
    notifyListeners();
  }

  Future getUserLeave([int employeeId = -1]) async {
    setErrorMsg("");
    setLoading(true);

    var res = await LeaveService.getUserLeave(employeeId);
    if (res is Success) {
      var data = res.response as List<UserLeaveModel>;
      _setUserLeaveList(data);
      setLoading(false);
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

  Future<bool> addUserLeave(UserLeaveModel userLeaveModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateUserLeaveForEdit(
        userLeaveModel.leaveId,
        userLeaveModel.getStartDate(),
        userLeaveModel.getEndDate(),
        userLeaveModel.reason,
        userLeaveModel.isApproved) ==
        false) {
      setLoading(false);
      return false;
    }
    try {
      var res = await LeaveService.addUserLeave(userLeaveModel);
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

  Future<bool> updateUserLeave(UserLeaveModel userLeaveModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateUserLeaveForEdit(
            userLeaveModel.leaveId,
            userLeaveModel.getStartDate(),
            userLeaveModel.getEndDate(),
            userLeaveModel.reason,
            userLeaveModel.isApproved) ==
        false) {
      setLoading(false);
      return false;
    }
    try {
      var res = await LeaveService.updateUserLeave(userLeaveModel);
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

  Future<bool> deleteUserLeave(UserLeaveModel userLeaveModel) async {
    setErrorMsg("");
    setLoading(true);
    if (userLeaveModel.isApproved > 0) {
      setErrorMsg(Messages.errorLeaveDeleteExist);
      setLoading(false);
      return false;
    }
    try {
      var res = await LeaveService.deleteUserLeave(userLeaveModel.id);
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

  bool _validateUserLeaveForEdit(leaveId, DateTime startDate, DateTime endDate,
      String reason, int isApproved) {
    var balance = 0;
    if (leaveId > 0) {
      var leave = leaveList.firstWhere((element) => element.id == leaveId);
      var summary = leaveSummaryList.firstWhere((element) =>
          element.leaveShortName.toLowerCase() ==
          leave.leaveShortName.toLowerCase());
      balance = summary.balance;
    }

    if (leaveId == 0) {
      setErrorMsg(Messages.errorLeaveTypeEmpty);
      return false;
    } else if (endDate.difference(startDate).inDays + 1 < 1) {
      setErrorMsg(Messages.errorDurationLeaveDayMin);
      return false;
    } else if (endDate.difference(startDate).inDays + 1 > balance) {
      setErrorMsg(Messages.errorDurationLeaveDayBalance);
      return false;
    } else if (endDate.difference(startDate).inDays + 1 > 10) {
      setErrorMsg(Messages.errorDurationLeaveDayMax);
      return false;
    } else if (reason.isEmpty) {
      setErrorMsg(Messages.errorReasonEmpty);
      return false;
    } else if (reason.length > 300) {
      setErrorMsg(Messages.errorReasonMaxLength);
      return false;
    } else if (isApproved > 0) {
      setErrorMsg(Messages.errorLeaveModifyExist);
      return false;
    } else {
      return true;
    }
  }

  Future<bool> approveEmployeeLeave(UserLeaveModel userLeaveModel) async {
    setErrorMsg("");
    setLoading(true);
    try {
      var res = await LeaveService.approveEmployeeLeave(userLeaveModel);
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
