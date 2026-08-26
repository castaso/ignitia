import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/global_fields.dart';
import 'package:ignitia_dashboard/utils/shared_preference.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/view_models/employee_view_model.dart';
import 'package:ignitia_dashboard/view_models/holiday_view_model.dart';
import 'package:ignitia_dashboard/view_models/login_view_model.dart';
import 'package:ignitia_dashboard/view_models/overtime_view_model.dart';
import 'package:ignitia_dashboard/view_models/shift_view_model.dart';
import 'package:ignitia_dashboard/views/dashboard_home_screen.dart';
import 'package:ignitia_dashboard/views/login_screen.dart';
import 'package:provider/provider.dart';

Future<void> _loadUserData() async {
  FieldValue.userId = await SessionManager.getUserId();
  FieldValue.employeeId = await SessionManager.getEmployeeId();
  FieldValue.userEmail = await SessionManager.getUserEmail();
  FieldValue.userTypeId = await SessionManager.getUserTypeId();
  FieldValue.userName = await SessionManager.getUserName();
  FieldValue.userDesignation = await SessionManager.getUserDesignation();
  FieldValue.lastLoginTime = await SessionManager.getLastLoginTime();
  FieldValue.isUserLoggedIn = await SessionManager.isUserLoggedIn();
  FieldValue.token = await SessionManager.getToken();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var loginStatus = await SessionManager.isUserLoggedIn();
  if (loginStatus) {
    await _loadUserData();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => EmployeeViewModel()),
        ChangeNotifierProvider(create: (_) => HolidayViewModel()),
        ChangeNotifierProvider(create: (_) => OvertimeViewModel()),
        ChangeNotifierProvider(create: (_) => ShiftViewModel()),
      ],
      child: MaterialApp(
        title: Strings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Palette.kToLight,
        ),
        home: FieldValue.isUserLoggedIn
            ? const DashboardHomeScreen()
            : const LoginScreen(),
      ),
    );
  }
}
