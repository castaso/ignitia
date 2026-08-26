import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_employment/config/office_location_config.dart';
import 'package:i_employment/utils/message.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/view_models/base_view_model.dart';
import 'package:intl/intl.dart';

import '../models/attendance/attendance_model.dart';
import '../models/attendance/user_attendance_summary_model.dart';
import '../repo/api_status.dart';
import '../repo/attendance_services.dart';
import '../repo/location_service.dart';
import '../utils/global_fields.dart';

class AttendanceViewModel extends BaseViewModel {
  // User home attendance
  List<AttendanceModel> _attendanceList = [];
  List<AttendanceModel> get attendanceList => _attendanceList;
  _setAttendanceModelList(List<AttendanceModel> list) {
    _attendanceList.clear();
    _attendanceList = list;
    notifyListeners();
  }

  Future getAttendanceList(DateTime startDate, DateTime endDate,[int employeeId=-1]) async {
    setErrorMsg("");
    setLoading(true);
    var res = await AttendanceService.getUserAttendance(startDate, endDate, employeeId);
    if (res is Success) {
      var data = res.response as List<AttendanceModel>;
      _setAttendanceModelList(data);
      setLoading(false);
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

// User Attendance Summary
  UserAttendanceSummaryModel? _userAttendanceSummaryModel;
  UserAttendanceSummaryModel? get userAttendanceSummaryModel =>
      _userAttendanceSummaryModel;
  setUserAttendanceSummaryModel(UserAttendanceSummaryModel? model) {
    _userAttendanceSummaryModel = model;
    notifyListeners();
  }

  Future getUserAttendanceSummary(DateTime startDate, DateTime endDate) async {
    setErrorMsg("");
    setLoading(true);

    var res =
        await AttendanceService.getUserAttendanceSummary(startDate, endDate);
    if (res is Success) {
      var data = res.response as UserAttendanceSummaryModel;
      setUserAttendanceSummaryModel(data);
      setLoading(false);
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

  Future<bool> editAttendanceRequest(DateTime date, DateTime checkInDateTime,
      DateTime checkOutDateTime, String missingReason, {String? faceImageBase64, List<String> livenessFrames = const [], String? challengeId}) async {
    setErrorMsg("");
    setLoading(true);
    if (_validateAttendanceForEdit(
            checkInDateTime, checkOutDateTime, missingReason) ==
        false) {
      setLoading(false);
      return false;
    }
    try{
      Position? position;
      var address = "Address not found";
      try {
        position = await LocationService().getValidatedPosition();
      } catch (e) {
        if (OfficeLocationConfig.requireLocation) {
          setLoading(false);
          setErrorMsg(e.toString());
          return false;
        }
      }
      if (position != null) {
        address = await  LocationService().GetAddressFromLatLong(position);
      }
      AttendanceModel attendanceModel = AttendanceModel(
          employeeId: FieldValue.userId,
          dateTimeUnformated: DateFormat("yyyy-MM-dd").format(date),
          checkInUnformated:
          DateFormat("yyyy-MM-ddTHH:mm:ss").format(checkInDateTime),
          checkOutUnformated:
          DateFormat("yyyy-MM-ddTHH:mm:ss").format(checkOutDateTime),
          lateDuration: 0,
          checkInLatitude: position?.latitude,
          checkInLongitude: position?.longitude,
          checkInAddress: address,
          checkInFaceBase64: faceImageBase64,
          livenessFrames: livenessFrames,
          challengeId: challengeId,
          missingReason: missingReason);
      var res = await AttendanceService.requestEditAttendance(attendanceModel);
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

  bool _validateAttendanceForEdit(DateTime checkInDateTime,
      DateTime checkOutDateTime, String missingReason) {
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
    } else {
      return true;
    }
  }

  // User home request
  List<AttendanceModel> _requestList = [];
  List<AttendanceModel> get requestList => _requestList;
  _setRequestList(List<AttendanceModel> list) {
    _requestList.clear();
    _requestList = list;
    notifyListeners();
  }

  Future getRequestList(DateTime startDate, DateTime endDate,[int employeeId=-1]) async {
    setErrorMsg("");
    setLoading(true);

    var res = await AttendanceService.getAttendanceRequest(startDate, endDate, employeeId);
    if (res is Success) {
      var data = res.response as List<AttendanceModel>;
      _setRequestList(data);
      setLoading(false);
    } else if (res is Failed) {
      setErrorMsg(res.failedReason.toString());
      setLoading(false);
    }
  }

  Future<bool> deleteAttendanceRequest(int requestId) async {
    setErrorMsg("");
    setLoading(true);
    try{
      var res = await AttendanceService.deleteAttendanceRequest(requestId);
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

  Future<bool> approveAttendanceRequest(int requestId, int approvalStatusId, String rejectionReason) async {
    setErrorMsg("");
    setLoading(true);
    try{
      var res = await AttendanceService.approveAttendanceRequest(requestId, approvalStatusId, rejectionReason);
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
