import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dropdown_model.dart';

class CommonFunctions {
  static getMonthFirstDate() {
    var date = DateTime.now();
    if (date.day > 26) {
      return DateTime(date.year, date.month, 26);
    } else {
      return DateTime(date.year, date.month - 1, 25);
    }
  }

  static String durationFormat(int durationAsMinutes) {
    if (durationAsMinutes <= 0) return "";
    var hours = (durationAsMinutes / 60).floor();
    var minutes = ((durationAsMinutes / 60 - hours) * 60).floor();
    return "$hours H $minutes M";
  }

  static String durationFormatFromDouble(double durationAsMinutes) {
    return durationFormat(int.parse(durationAsMinutes.toString()));
  }

  static TimeOfDay parseTime(String format, String time) {
    return TimeOfDay.fromDateTime(DateFormat(format).parse(time));
  }

  static String getFormatedTime(String format, TimeOfDay time) {
    return DateFormat(format).format(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
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
          DateFormat('MMM').format(DateTime(2000, i, 1))
      ));
    }
    for (var i = 12; i > date.month; i--) {
      months.add(DropDownModel(i,
          DateFormat('MMM').format(DateTime(2000, i, 1))
      ));
    }
    return months;
  }
}
