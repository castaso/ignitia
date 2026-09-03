import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/admin/attendance/approve_overtime_page.dart';
import 'package:ignitia_dashboard/views/admin/leave/holiday_page.dart';
import 'package:ignitia_dashboard/views/dashboard_home_screen.dart';
import 'package:ignitia_dashboard/views/employee/employee_list_page.dart';
import 'package:ignitia_dashboard/views/shift/assign_shift_page.dart';
import 'package:ignitia_dashboard/views/shift/shift_page.dart';
import 'package:ignitia_dashboard/views/time_management/attendance/attendance_tm_page.dart';
import 'package:ignitia_dashboard/views/time_management/break/break_config_page.dart';
import 'package:ignitia_dashboard/views/time_management/break/break_history_page.dart';
import 'package:ignitia_dashboard/views/time_management/schedule/schedule_template_page.dart';
import 'package:ignitia_dashboard/views/time_management/schedule/roster_page.dart';
import 'package:ignitia_dashboard/views/time_management/timesheet/timesheet_page.dart';
import 'package:ignitia_dashboard/views/time_management/leave/leave_tm_page.dart';

import '../models/menu_item_model.dart';

class MenuList {
  final List<MenuItemModel> _menuList = [
    MenuItemModel(1, Strings.titleHome, [1], const DashboardHomeScreen()),
    MenuItemModel(3, Strings.titleEmployeeListPage, [1], const EmployeeListPage()),
    MenuItemModel(30, Strings.titleTimeManagement, [1], null, isParent: true, children: [
      MenuItemModel(31, Strings.titleSchedulePage, [1], const ScheduleTemplatePage()),
      MenuItemModel(310, Strings.titleRosterPage, [1], const RosterPage()),
      MenuItemModel(32, Strings.titleAttendancePageTM, [1], const AttendanceTMPage()),
      MenuItemModel(33, Strings.titleBreakPage, [1], const BreakHistoryPage()),
      MenuItemModel(330, Strings.titleBreakConfigPage, [1], const BreakConfigPage()),
      MenuItemModel(34, Strings.titleLeavePageTM, [1], const LeaveTMPage()),
      MenuItemModel(35, Strings.titleTimesheetPage, [1], const TimesheetPage()),
    ]),
    // Legacy flat entries kept for backward compat (hidden under Time Management now)
    MenuItemModel(13, Strings.titleApproveOvertimePage, [1], const ApproveOvertimePage()),
    MenuItemModel(18, Strings.titleHolidayPage, [1], const HolidayPage()),
    MenuItemModel(20, Strings.titleShiftPage, [1], const ShiftPage()),
    MenuItemModel(21, Strings.titleAssignShiftPage, [1], const AssignShiftPage()),
    MenuItemModel(99, Strings.titleSignOut, [1], null),
  ];

  List<MenuItemModel> getMenuList() {
    return _menuList;
  }
}
