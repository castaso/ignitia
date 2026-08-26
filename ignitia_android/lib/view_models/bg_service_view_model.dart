import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_employment/config/office_location_config.dart';
import 'package:i_employment/repo/notification_service.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/utils/message.dart';
import 'package:i_employment/utils/shared_preference.dart';
import 'package:i_employment/view_models/base_view_model.dart';
import 'package:intl/intl.dart';

import '../models/attendance/attendance_model.dart';
import '../repo/api_status.dart';
import '../repo/attendance_services.dart';
import '../repo/location_service.dart';
import '../utils/string.dart';

class BackgroundServiceViewModel extends BaseViewModel {

  Future<void> AlertForCheckIn() async {
    var allow = await SessionManager.getAlertForMissingCheckIn();
    if (!allow) return;
    var userId = await SessionManager.getUserId();
    if (userId == 0) return;
    var strTime = await SessionManager.getOfficeStartTime();
    var token = await SessionManager.getToken();
    var officeStartTime = DateFormat("HH:mm").parse(strTime);
    var startTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, officeStartTime.hour, officeStartTime.minute);
    if (DateTime.now().isAfter(startTime)) {
      var res = await AttendanceService.getUserAttendance(
          DateTime.now(), DateTime.now(), userId, token);
      if (res is Success) {
        var data = res.response as List<AttendanceModel>;
        if (data.first.status == Strings.statusA &&
            data.first.checkInUnformated == null) {
          NotificationService().showNotification(
              Strings.titleNotificationCheckIn,
              Messages.warningNotificationCheckIn);
        }
      }
    }
  }

  Future<void> AlertForCheckOut() async {
    var allow = await SessionManager.getAlertForMissingCheckOut();
    if (!allow) return;
    var userId = await SessionManager.getUserId();
    if (userId == 0) return;
    var strTime = await SessionManager.getOfficeEndTime();
    var officeEndTime = DateFormat("HH:mm").parse(strTime);
    var token = await SessionManager.getToken();
    var endTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, officeEndTime.hour, officeEndTime.minute);
    if (DateTime.now().isAfter(endTime) &&
        DateTime.now().isBefore(endTime.add(Duration(hours: 3)))) {
      var res = await AttendanceService.getUserAttendance(
          DateTime.now(), DateTime.now(), userId, token);
      if (res is Success) {
        var data = res.response as List<AttendanceModel>;
        if (data.first.checkInUnformated != null &&
            data.first.checkOutUnformated == null) {
          NotificationService().showNotification(
              Strings.titleNotificationCheckOut,
              Messages.warningNotificationCheckOut);
        }
      }
    }
  }

  Future checkIn(String currentNetwork) async {
    if(loading) return;
    setLoading(true);
    try{
      var allow = await SessionManager.getAllowAutoCheckIn();
      if (!allow) {
        setLoading(false);
        return;
      }
      var userId = await SessionManager.getUserId();
      if (userId == 0) {
        setLoading(false);
        return;
      }

      var officeNetwork = await SessionManager.getOfficeNetwork();
      if(officeNetwork.toLowerCase() != currentNetwork.toLowerCase()){
        setLoading(false);
        return;
      }

      var token = await SessionManager.getToken();

      // The background auto check-in is also guarded by the office geo-fence so
      // a device connected to a spoofed / relayed network cannot record a
      // proxy attendance from outside the office.
      Position? position;
      var address = "Address not found";
      try {
        position = await LocationService().getValidatedPosition();
      } catch (e) {
        if (OfficeLocationConfig.requireLocation) {
          setLoading(false);
          return;
        }
      }
      if (position != null) {
        address = await  LocationService().GetAddressFromLatLong(position);
      }
      AttendanceModel attendanceModel = AttendanceModel(
          dateTimeUnformated: DateFormat("yyyy-MM-dd").format(DateTime.now()),
          employeeId: userId,
          checkInLatitude: position?.latitude,
          checkInLongitude: position?.longitude,
          checkInAddress: address);
      var res = await AttendanceService.checkIn(attendanceModel,token);
      if (res is Success) {
        if (kDebugMode) {
          print(DateTime.now());
        }
        setLoading(false);
      }else{
        if (kDebugMode) {
          print((res as Failed).failedReason);
        }
        setLoading(false);
      }
    }catch(e){
      setLoading(false);
      if (kDebugMode) {
        print(e);
      }
    }

  }

}
