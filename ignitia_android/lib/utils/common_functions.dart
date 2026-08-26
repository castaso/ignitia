
import 'package:flutter/material.dart';
import 'package:i_employment/utils/shared_preference.dart';
import 'package:i_employment/utils/string.dart';
import 'package:intl/intl.dart';

import '../models/attendance/attendance_model.dart';
import '../models/dropdown_model.dart';
import '../models/overtime/overtime_model.dart';
import '../models/settings_model.dart';
import 'global_fields.dart';

class CommonFunctions{

  static getMonthFirstDate() {
    var date = DateTime.now();
    if (date.day > 26) {
      return DateTime(date.year, date.month, 26);
    } else {
      return DateTime(date.year, date.month - 1, 25);
    }
  }

  static String durationFormat(int durationAsMinutes){
    if(durationAsMinutes<=0) return "";
    var hours = (durationAsMinutes/60).floor();
    var minutes = ((durationAsMinutes / 60 - hours) * 60).floor();
    return "$hours H $minutes M";
  }

  static String durationFormatFromDouble(double durationAsMinutes){
    return durationFormat(int.parse(durationAsMinutes.toString()));
  }

  static TimeOfDay parseTime(String format, String time) {
    return TimeOfDay.fromDateTime(DateFormat(format).parse(time));
  }

  static String getFormatedTime(String format, TimeOfDay time) {
    return DateFormat(format).format(DateTime(
        DateTime
            .now()
            .year,
        DateTime
            .now()
            .month,
        DateTime
            .now()
            .day,
        time.hour,
        time.minute));
  }

  // Years dropdown
  static List<DropDownModel> getYearList() {
  List<DropDownModel> years = [];
    for (var i = DateTime.now().year; i >= 2000; i--) {
      years.add(DropDownModel(i, i.toString()));
    }
    return years;
  }

  // Months dropdown

  static List<DropDownModel> getMonthList() {
    final List<DropDownModel> months = [];
    var date = DateTime.now();
    for (var i = date.month; i > 0; i--) {
      months.add(DropDownModel(i,
          DateFormat('MMM').format(DateTime(2000,i,1))
      ));
    }
    for (var i = 12; i > date.month; i--) {
      months.add(DropDownModel(i,
          DateFormat('MMM').format(DateTime(2000,i,1))
      ));
    }
    return months;
  }

  static getNewOvertime(AttendanceModel attendance) {
    var overtimeDateUnformated =
    DateFormat("yyyy-MM-ddT00:00:00").format(DateTime.now());
    var overtimeDate =
    DateFormat("yyyy-MM-ddTHH:mm:ss").parse(overtimeDateUnformated);
    var checkInUnformated = DateFormat("yyyy-MM-ddTHH:mm:ss")
        .format(overtimeDate.add(Duration(hours: 18)));

    if(attendance.status.toLowerCase().contains("h")){
      checkInUnformated =
          DateFormat("yyyy-MM-ddTHH:mm:ss")
              .format(attendance.getCheckIn()!.add(Duration(hours: 18)));

    }

    var checkOutUnformated = DateFormat("yyyy-MM-ddTHH:mm:ss")
        .format(DateTime.now());

    var duration = DateTime.now().difference(attendance.getCheckIn()!).inMinutes;

    var overtimeModel = OvertimeModel(
        id: 0,
        employeeId: FieldValue.userId,
        overtimeDateUnformated: overtimeDateUnformated,
        checkInUnformated: checkInUnformated,
        checkOutUnformated: checkOutUnformated,
        overtimeMinutes: duration,
        status: Strings.statusPending,
        reason: "");

    return overtimeModel;
  }

  static getSettings() async {
    var officeStartTime = await SessionManager.getOfficeStartTime();
    var officeEndTime = await SessionManager.getOfficeEndTime();
    var officeNetwork = await SessionManager.getOfficeNetwork();
    var allowAutoCheckIn = await SessionManager.getAllowAutoCheckIn();
    var alertForMissingCheckIn = await SessionManager.getAlertForMissingCheckIn();
    var alertForMissingCheckOut =
    await SessionManager.getAlertForMissingCheckOut();
    var alertForMissingOvertime =
    await SessionManager.getAlertForMissingOvertime();

    return SettingsModel(
        officeStartTime,
        officeEndTime,
        officeNetwork,
        allowAutoCheckIn,
        alertForMissingCheckIn,
        alertForMissingCheckOut,
        alertForMissingOvertime);
  }
}