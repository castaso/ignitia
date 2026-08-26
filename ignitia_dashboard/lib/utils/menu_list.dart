import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/admin/attendance/approve_overtime_page.dart';
import 'package:ignitia_dashboard/views/admin/leave/holiday_page.dart';
import 'package:ignitia_dashboard/views/dashboard_home_screen.dart';
import 'package:ignitia_dashboard/views/employee/employee_list_page.dart';
import 'package:ignitia_dashboard/views/shift/assign_shift_page.dart';
import 'package:ignitia_dashboard/views/shift/shift_page.dart';

import '../models/menu_item_model.dart';

class MenuList {
  final List<MenuItemModel> _menuList = [
    MenuItemModel(1, Strings.titleHome, [1], const DashboardHomeScreen()),
    MenuItemModel(3, Strings.titleEmployeeListPage, [1], const EmployeeListPage()),
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
