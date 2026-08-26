import 'package:ignitia_dashboard/utils/shared_preference.dart';
import 'package:ignitia_dashboard/views/dashboard_home_screen.dart';
import 'package:ignitia_dashboard/views/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void openHomeUI(BuildContext context) async {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => const DashboardHomeScreen(),
    ),
  );
}

void openNewUIWithReplacement(BuildContext context, Widget pageName) async {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => pageName,
    ),
  );
}

void backToPreviousUI(BuildContext context) async {
  Navigator.pop(context);
}

void openNewUI(BuildContext context, Widget pageName) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => pageName,
    ),
  );
}

void logout(BuildContext context) async {
  await SessionManager.clear();
  Navigator.pushAndRemoveUntil(
    context,
    CupertinoPageRoute<bool>(
      fullscreenDialog: true,
      builder: (BuildContext context) => const LoginScreen(),
    ),
    (Route route) => false,
  );
}
