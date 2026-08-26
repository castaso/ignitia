import 'package:i_employment/firebase_options.dart';
import 'package:i_employment/config/office_location_config.dart';
import 'package:i_employment/repo/background_service.dart';
import 'package:i_employment/repo/connectivity_service.dart';
import 'package:i_employment/repo/notification_service.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/utils/shared_preference.dart';
import 'package:i_employment/view_models/attendance_view_model.dart';
import 'package:i_employment/view_models/bg_service_view_model.dart';
import 'package:i_employment/view_models/employee_view_model.dart';
import 'package:i_employment/view_models/home_view_model.dart';
import 'package:i_employment/view_models/holiday_view_model.dart';
import 'package:i_employment/view_models/leave_view_model.dart';
import 'package:i_employment/view_models/login_view_model.dart';
import 'package:i_employment/view_models/office_location_view_model.dart';
import 'package:i_employment/view_models/overtime_view_model.dart';
import 'package:i_employment/view_models/payroll_view_model.dart';
import 'package:i_employment/views/admin/home/admin_home_screen.dart';
import 'package:i_employment/views/home/home_screen.dart';
import 'package:i_employment/views/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:io';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  if(kDebugMode) {
    print('Handling a background message ${message.messageId}');
  }

}

_loadUserData() async{
  FieldValue.userId = await SessionManager.getUserId();
  FieldValue.employeeId = await SessionManager.getEmployeeId();
  FieldValue.userEmail = await SessionManager.getUserEmail();
  FieldValue.userTypeId = await SessionManager.getUserTypeId();
  FieldValue.userName = await SessionManager.getUserName();
  FieldValue.userDesignation = await SessionManager.getUserDesignation();
  FieldValue.lastLoginTime = await SessionManager.getLastLoginTime();
  FieldValue.isUserLoggedIn = await SessionManager.isUserLoggedIn();
  FieldValue.token = await SessionManager.getToken();
  FieldValue.officeStartTime = await SessionManager.getOfficeStartTime();
  FieldValue.officeEndTime = await SessionManager.getOfficeEndTime();
  FieldValue.attendanceLocationType =
      await SessionManager.getAttendanceLocationType();
  FieldValue.homeLatitude = await SessionManager.getHomeLatitude();
  FieldValue.homeLongitude = await SessionManager.getHomeLongitude();
  FieldValue.homeRadiusMeters = await SessionManager.getHomeRadiusMeters();
  OfficeLocationConfig.setEmployeeLocationRestriction(
    FieldValue.attendanceLocationType,
    homeLatitude: FieldValue.homeLatitude,
    homeLongitude: FieldValue.homeLongitude,
    homeRadiusMeters: FieldValue.homeRadiusMeters,
  );
  if(kDebugMode) {print("after data load");}
}

void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

Future<String?> _getLocationPermission() async {
  var locationStatus = await Permission.location.status;
  if (locationStatus.isDenied) {
    await Permission.locationWhenInUse.request();
  }
  if (await Permission.location.isRestricted) {
    openAppSettings();
  }
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(!kIsWeb) {
    await _getLocationPermission();
  }
  _enablePlatformOverrideForDesktop();
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Set the background messaging handler early on, as a named top-level function
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  var loginStatus = await SessionManager.isUserLoggedIn();
  if(loginStatus){
    await _loadUserData();
    if(!kIsWeb) {
      NotificationService().initNotification();
      BackgroundService().initializeService();
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ChangeNotifierProvider(create: (_) => AttendanceViewModel()),
      ChangeNotifierProvider(create: (_) => OvertimeViewModel()),
      ChangeNotifierProvider(create: (_) => PayrollViewModel()),
      ChangeNotifierProvider(create: (_) => LeaveViewModel()),
      ChangeNotifierProvider(create: (_) => HolidayViewModel()),
      ChangeNotifierProvider(create: (_) => OfficeLocationViewModel()),
      ChangeNotifierProvider(create: (_) => BackgroundServiceViewModel()),
      ChangeNotifierProvider(create: (_) => EmployeeViewModel()),
    ],child: MaterialApp(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Palette.kToLight,
      ),
      home: FieldValue.isUserLoggedIn ? (FieldValue.userTypeId == 2 ? const HomeScreen() : AdminHomeScreen()):const LoginScreen(),
    ),);
  }
}
