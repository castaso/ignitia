import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/admin/attendance/approve_overtime_page.dart';
import 'package:ignitia_dashboard/views/admin/leave/holiday_page.dart';
import 'package:ignitia_dashboard/views/common/coming_soon_page.dart';
import 'package:ignitia_dashboard/views/company_admin/activity/activity_history_page.dart';
import 'package:ignitia_dashboard/views/company_admin/announcement/announcement_page.dart';
import 'package:ignitia_dashboard/views/company_admin/asset/asset_page.dart';
import 'package:ignitia_dashboard/views/company_admin/file/company_file_page.dart';
import 'package:ignitia_dashboard/views/company_admin/notification/notification_page.dart';
import 'package:ignitia_dashboard/views/company_admin/report/report_builder_page.dart';
import 'package:ignitia_dashboard/views/dashboard_home_screen.dart';
import 'package:ignitia_dashboard/views/employee/employee_list_page.dart';
import 'package:ignitia_dashboard/views/settings/company_profile_settings_page.dart';
import 'package:ignitia_dashboard/views/settings/integration_settings_page.dart';
import 'package:ignitia_dashboard/views/settings/payroll_settings_page.dart';
import 'package:ignitia_dashboard/views/settings/time_attendance_settings_page.dart';
import 'package:ignitia_dashboard/views/settings/user_role_settings_page.dart';
import 'package:ignitia_dashboard/views/shift/assign_shift_page.dart';
import 'package:ignitia_dashboard/views/shift/shift_page.dart';
import 'package:ignitia_dashboard/views/time_management/attendance/attendance_tm_page.dart';
import 'package:ignitia_dashboard/views/time_management/break/break_config_page.dart';
import 'package:ignitia_dashboard/views/time_management/break/break_history_page.dart';
import 'package:ignitia_dashboard/views/time_management/leave/leave_tm_page.dart';
import 'package:ignitia_dashboard/views/time_management/schedule/roster_page.dart';
import 'package:ignitia_dashboard/views/time_management/schedule/schedule_template_page.dart';
import 'package:ignitia_dashboard/views/time_management/timesheet/timesheet_page.dart';

import '../models/menu_item_model.dart';

/// Super-Admin menu bar (spec item 9): Home, Employee profile, Employees,
/// Recruitment, Time, Finance, Payroll, Productivity, Company, Applications,
/// Integrations, Settings.
class MenuList {
  final List<MenuItemModel> _menuList = [
    MenuItemModel(1, Strings.titleHome, [1], const DashboardHomeScreen()),
    MenuItemModel(2, Strings.titleEmployeeProfile, [1],
        const ComingSoonPage(feature: Strings.titleEmployeeProfile, icon: Icons.badge_outlined)),
    MenuItemModel(3, Strings.titleAdminEmployeeListPage, [1], const EmployeeListPage()),
    MenuItemModel(10, Strings.titleRecruitment, [1],
        const ComingSoonPage(feature: Strings.titleRecruitment, icon: Icons.person_search_outlined)),
    MenuItemModel(30, Strings.titleTime, [1], null, isParent: true, children: [
      MenuItemModel(31, Strings.titleSchedulePage, [1], const ScheduleTemplatePage()),
      MenuItemModel(310, Strings.titleRosterPage, [1], const RosterPage()),
      MenuItemModel(32, Strings.titleAttendancePageTM, [1], const AttendanceTMPage()),
      MenuItemModel(33, Strings.titleBreakPage, [1], const BreakHistoryPage()),
      MenuItemModel(330, Strings.titleBreakConfigPage, [1], const BreakConfigPage()),
      MenuItemModel(34, Strings.titleLeavePageTM, [1], const LeaveTMPage()),
      MenuItemModel(35, Strings.titleTimesheetPage, [1], const TimesheetPage()),
      MenuItemModel(36, Strings.titleShiftPage, [1], const ShiftPage()),
      MenuItemModel(37, Strings.titleHolidayPage, [1], const HolidayPage()),
      MenuItemModel(38, Strings.titleApproveOvertimePage, [1], const ApproveOvertimePage()),
      MenuItemModel(39, Strings.titleAssignShiftPage, [1], const AssignShiftPage()),
    ]),
    MenuItemModel(11, Strings.titleFinance, [1],
        const ComingSoonPage(feature: Strings.titleFinance, icon: Icons.account_balance_wallet_outlined)),
    MenuItemModel(12, Strings.titlePayroll, [1],
        const ComingSoonPage(feature: Strings.titlePayroll, icon: Icons.payments_outlined)),
    MenuItemModel(13, Strings.titleProductivity, [1],
        const ComingSoonPage(feature: Strings.titleProductivity, icon: Icons.query_stats_outlined)),
    MenuItemModel(40, Strings.titleCompany, [1], null, isParent: true, children: [
      MenuItemModel(41, Strings.titleAssetPage, [1], const AssetPage()),
      MenuItemModel(42, Strings.titleActivityHistoryPage, [1], const ActivityHistoryPage()),
      MenuItemModel(43, Strings.titleAnnouncementPage, [1], const AnnouncementPage()),
      MenuItemModel(44, Strings.titleNotificationPage, [1], const NotificationPage()),
      MenuItemModel(45, Strings.titleFilePage, [1], const CompanyFilePage()),
      MenuItemModel(46, Strings.titleReportBuilderPage, [1], const ReportBuilderPage()),
    ]),
    MenuItemModel(47, Strings.titleApplications, [1], null, isParent: true, children: [
      MenuItemModel(471, Strings.textAppForms, [1],
          const ComingSoonPage(feature: Strings.textAppForms, icon: Icons.assignment_outlined)),
      MenuItemModel(472, Strings.textAppPerformanceReview, [1],
          const ComingSoonPage(feature: Strings.textAppPerformanceReview, icon: Icons.trending_up)),
      MenuItemModel(473, Strings.textAppTalentManagement, [1],
          const ComingSoonPage(feature: Strings.textAppTalentManagement, icon: Icons.groups_outlined)),
      MenuItemModel(474, Strings.textAppInsight, [1],
          const ComingSoonPage(feature: Strings.textAppInsight, icon: Icons.insights_outlined)),
      MenuItemModel(475, Strings.textAppTimesheet, [1], const TimesheetPage()),
      MenuItemModel(476, Strings.textAppDocumentTemplate, [1],
          const ComingSoonPage(feature: Strings.textAppDocumentTemplate, icon: Icons.description_outlined)),
      MenuItemModel(477, Strings.textAppRecruitment, [1],
          const ComingSoonPage(feature: Strings.textAppRecruitment, icon: Icons.person_search_outlined)),
      MenuItemModel(478, Strings.textAppTalentics, [1],
          const ComingSoonPage(feature: Strings.textAppTalentics, icon: Icons.psychology_outlined)),
      MenuItemModel(479, Strings.textAppMarketplace, [1],
          const ComingSoonPage(feature: Strings.textAppMarketplace, icon: Icons.storefront_outlined)),
    ]),
    MenuItemModel(48, Strings.titleIntegrations, [1], const IntegrationSettingsPage()),
    MenuItemModel(90, Strings.titleSettings, [1], null, isParent: true, children: [
      MenuItemModel(91, Strings.titleCompanySettingsPage, [1], const CompanyProfileSettingsPage()),
      MenuItemModel(92, Strings.titleTimeAttendanceSettingsPage, [1], const TimeAttendanceSettingsPage()),
      MenuItemModel(93, Strings.titlePayrollSettingsPage, [1], const PayrollSettingsPage()),
      MenuItemModel(94, Strings.titleUserRoleSettingsPage, [1], const UserRoleSettingsPage()),
      MenuItemModel(95, Strings.titleIntegrationSettingsPage, [1], const IntegrationSettingsPage()),
    ]),
    MenuItemModel(99, Strings.titleSignOut, [1], null),
  ];

  List<MenuItemModel> getMenuList() {
    return _menuList;
  }
}
