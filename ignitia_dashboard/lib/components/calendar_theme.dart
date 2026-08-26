
import 'package:flutter/material.dart';

import '../utils/colors.dart';

calendarTheme(BuildContext context,Widget? child){
  return Theme(
    data: Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: kPrimaryColor,
        onPrimary: Colors.white,
        onSurface: Colors.black87,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kPrimaryLightColor, // button text color
        ),
      ),
    ),
    child: child!,
  );
}
