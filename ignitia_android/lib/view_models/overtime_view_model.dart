import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:i_employment/models/overtime/overtime_model.dart';
import 'package:i_employment/utils/message.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/view_models/base_view_model.dart';
import 'package:intl/intl.dart';

import '../models/attendance/attendance_model.dart';
import '../models/attendance/user_attendance_summary_model.dart';
import '../repo/api_status.dart';
import '../repo/attendance_services.dart';
import '../repo/location_service.dart';
import '../repo/overtime_services.dart';
import '../utils/global_fields.dart';

class OvertimeViewModel extends BaseViewModel {
  int _approvedDuration = 0;
  int get approvedDuration => _approvedDuration;
  _setApprovedDuration(int duration) {
    _approvedDuration=duration;
    notifyListeners();
  }

  Clear(){
    overtimeList.clear();
    _approvedDuration = _pendingDuration = _rejectedDuration = 0;
    notifyListeners();
  }

  int _pendingDuration = 0;
  int get pendingDuration => _pendingDuration;
  _setPendingDuration(int duration) {
    _pendingDuration=duration;
    notifyListeners();
  }

  int _rejectedDuration = 0;
  int get rejectedDuration => _rejectedDuration;
  _setRejectedDuration(int duration) {
    _rejectedDuration=duration;
    notifyListeners();
  }

  // User home overtime
  List<OvertimeModel> _overtimeList = [];
  List<OvertimeModel> get overtimeList => _overtimeList;
  _setOvertimeModelList(List<OvertimeModel> list) {
    _overtimeList.clear();
    _overtimeList = list;
    notifyListeners();
  }

  Future getOvertimeList(DateTime startDate, DateTime endDate,[int employeeId = -1]) async {
    setErrorMsg("");
    setLoading(true);

    var res = await OvertimeService.getOvertimeList(startDate, endDate, employeeId);
    if (res is Success) {
      var data = res.response as List<OvertimeModel>;
      _setOvertimeModelList(data);
      _calculateSummary();
      setLoading(false);
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

  _calculateSummary(){
    var approvedDuration = 0;
    var pendingDuration = 0;
    var rejectedDuration =0;
    for (var element in overtimeList) {
      var status = element.status.toLowerCase();
      if (status == Strings.statusApproved.toLowerCase()) {
        approvedDuration += element.overtimeMinutes;
      } else if (status == Strings.statusPending.toLowerCase()) {
        pendingDuration += element.overtimeMinutes;
      } else {
        rejectedDuration += element.overtimeMinutes;
      }
    }
    _setApprovedDuration(approvedDuration);
    _setPendingDuration(pendingDuration);
    _setRejectedDuration(rejectedDuration);
  }

  Future<bool> addOvertime(OvertimeModel overtimeModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateOvertimeForEdit(
        overtimeModel.getCheckIn(), overtimeModel.getCheckOut(), overtimeModel.reason, overtimeModel.status) ==
        false) {
      setLoading(false);
      return false;
    }
    try{
      var res = await OvertimeService.addOvertime(overtimeModel);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res as Failed;
        setErrorMsg(result.failedReason.toString());
        setLoading(false);
        return false;
      }else {
        return false;
      }
    }catch(ex){
      setErrorMsg(ex.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> updateOvertime(OvertimeModel overtimeModel) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateOvertimeForEdit(
        overtimeModel.getCheckIn(), overtimeModel.getCheckOut(), overtimeModel.reason, overtimeModel.status) ==
        false) {
      setLoading(false);
      return false;
    }
    try{
      var res = await OvertimeService.updateOvertime(overtimeModel);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res as Failed;
        setErrorMsg(result.failedReason.toString());
        setLoading(false);
        return false;
      }else {
        return false;
      }
    }catch(ex){
      setErrorMsg(ex.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> deleteOvertime(OvertimeModel overtimeModel) async {
    setErrorMsg("");
    setLoading(true);
    if (overtimeModel.status.toLowerCase()==Strings.statusApproved.toLowerCase()) {
      setErrorMsg(Messages.errorOvertimeDeleteExist);
      setLoading(false);
      return false;
    }
    try{
      var res = await OvertimeService.deleteOvertime(overtimeModel.id);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res as Failed;
        setErrorMsg(result.failedReason.toString());
        setLoading(false);
        return false;
      }else {
        return false;
      }
    }catch(ex){
      setErrorMsg(ex.toString());
      setLoading(false);
      return false;
    }
  }

  bool _validateOvertimeForEdit(DateTime checkInDateTime,
      DateTime checkOutDateTime, String missingReason, String status) {
    if (checkOutDateTime.difference(checkInDateTime).inMinutes < 60) {
      setErrorMsg(Messages.errorDurationMin);
      return false;
    } else if (checkOutDateTime.difference(checkInDateTime).inMinutes > 1320) {
      setErrorMsg(Messages.errorDurationMax);
      return false;
    } else if (missingReason.isEmpty) {
      setErrorMsg(Messages.errorReasonEmpty);
      return false;
    } else if (missingReason.length>300) {
      setErrorMsg(Messages.errorReasonMaxLength);
      return false;
    } else if (status.toLowerCase()==Strings.statusApproved.toLowerCase()) {
      setErrorMsg(Messages.errorOvertimeModifyExist);
      return false;
    } else {
      return true;
    }
  }

  Future<bool> approveOvertime(OvertimeModel overtimeModel) async {
    setErrorMsg("");
    setLoading(true);
    try{
      var res = await OvertimeService.approveOvertime(overtimeModel);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res as Failed;
        setErrorMsg(result.failedReason.toString());
        setLoading(false);
        return false;
      }else {
        return false;
      }
    }catch(ex){
      setErrorMsg(ex.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> rejectOvertime(OvertimeModel overtimeModel) async {
    setErrorMsg("");
    setLoading(true);
    try{
      var res = await OvertimeService.rejectOvertime(overtimeModel);
      if (res is Success) {
        setLoading(false);
        return true;
      } else if (res is Failed) {
        Failed result = res as Failed;
        setErrorMsg(result.failedReason.toString());
        setLoading(false);
        return false;
      }else {
        return false;
      }
    }catch(ex){
      setErrorMsg(ex.toString());
      setLoading(false);
      return false;
    }
  }

}
