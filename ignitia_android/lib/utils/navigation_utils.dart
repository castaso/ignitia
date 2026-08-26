
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/utils/shared_preference.dart';
import 'package:i_employment/views/admin/home/admin_home_screen.dart';
import 'package:i_employment/views/home/home_screen.dart';
import 'package:i_employment/views/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void openHomeUI(BuildContext context) async{
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context)=> FieldValue.userTypeId == 2 ? HomeScreen() : AdminHomeScreen(),
    ),
  );
}

void openNewUIWithReplacement(BuildContext context,Widget pageName) async{
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context)=> pageName,
    ),
  );
}

void backToPreviousUI(BuildContext context) async{
  Navigator.pop(context);
}

void openNewUI(BuildContext context,Widget pageName) async{
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context)=> pageName,
    ),
  );
}

void logout(BuildContext context) async{
  //SessionManager.setUserLoggedIn(false);
  SessionManager.clear();
  Navigator.pushAndRemoveUntil(
    context,
    CupertinoPageRoute<bool>(
      fullscreenDialog: true,
      builder: (BuildContext context) => LoginScreen(),
    ),
    // this function should return true when we're done removing routes
    // but because we want to remove all other screens, we make it
    // always return false
        (Route route) => false,
  );
}