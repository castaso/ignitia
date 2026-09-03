
import 'package:flutter/foundation.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/views/Security/change_password_page.dart';
import 'package:i_employment/views/admin/attendance/approve_attendance_page.dart';
import 'package:i_employment/views/admin/attendance/approve_overtime_page.dart';
import 'package:i_employment/views/admin/home/admin_home_screen.dart';
import 'package:i_employment/views/attendance/attendance_page.dart';
import 'package:i_employment/views/attendance/request_list_page.dart';
import 'package:i_employment/views/employee/employee_list_page.dart';
import 'package:i_employment/views/leave/leave_page.dart';
import 'package:i_employment/views/overtime/overtime_list_page.dart';
import 'package:i_employment/views/payroll/payslip_page.dart';
import 'package:i_employment/views/settings_page.dart';

import '../models/menu_item_model.dart';
import '../views/admin/attendance/admin_attendance_page.dart';
import '../views/admin/leave/approve_leave_page.dart';
import '../views/admin/leave/holiday_page.dart';
import '../views/admin/office/office_location_page.dart';
import '../views/employee/profile_page.dart';
import '../views/home/home_screen.dart';
import '../views/webview.dart';
import 'global_fields.dart';

class MenuList{
  final List<MenuItemModel> _menuList = [
    MenuItemModel(1, Strings.titleHome,[1,2], FieldValue.userTypeId == 2 ? HomeScreen() : AdminHomeScreen()),
    MenuItemModel(2, Strings.titleProfilePage,[1,2], ProfilePage()),
    MenuItemModel(3, Strings.titleAdminEmployeeListPage,[1], EmployeeListPage()),
    MenuItemModel(30, Strings.titleTimeManagement, [1,2], null, isParent: true, children: [
      MenuItemModel(31, Strings.titleSchedulePage, [1,2], const AdminAttendancePage()),
      MenuItemModel(33, Strings.titleBreakPage, [1,2], const AttendancePage()),
      MenuItemModel(35, Strings.titleTimesheetPage, [1,2], const RequestListPage()),
    ]),
    MenuItemModel(5, Strings.titleAtttendanceListPage,[1], const AdminAttendancePage()),
    MenuItemModel(6, Strings.titleApproveAttendancePage,[1], ApproveAttendancePage()),
    MenuItemModel(13, Strings.titleApproveOvertimePage,[1], ApproveOvertimePage()),
    MenuItemModel(13, Strings.titleApproveLeavePage,[1], ApproveLeavePage()),
    MenuItemModel(18, Strings.titleHolidayPage,[1], const HolidayPage()),
    MenuItemModel(19, Strings.titleOfficeLocationPage,[1], const OfficeLocationPage()),
    MenuItemModel(7, "Process Salary",[1], null),
    MenuItemModel(8, "Salary Sheet",[1], null),
    MenuItemModel(9, Strings.titleAtttendancePage,[2], const AttendancePage()),
    MenuItemModel(10, Strings.titleRequestListPage,[2], const RequestListPage()),
    MenuItemModel(11, Strings.titleOvertimeListPage,[2], const OvertimeListPage()),
    MenuItemModel(12, Strings.titleLeavePage,[2], const LeavePage()),
    MenuItemModel(14, Strings.titlePayslipPage,[2], PayslipPage()),
    MenuItemModel(15, Strings.titleEmployeeListPage,[2], EmployeeListPage()),
    MenuItemModel(16, Strings.titleChangePasswordPage,[1,2], ChangePasswordPage()),
    MenuItemModel(17, Strings.titleWebPage,[1,2], WebViewPage(targetURL: FieldValue.webAppAddress)),
    MenuItemModel(98, Strings.titleSettingPage,[1,2], null),
    MenuItemModel(99, Strings.titleSignOut,[1,2], null),

  ];

  List<MenuItemModel> getMenuList(){
    if(kIsWeb) _menuList.removeWhere((element) => element.id==98);
    return _menuList;
  }
}