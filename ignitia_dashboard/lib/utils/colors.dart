import 'dart:ui';

import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF0B5394);
const kPrimaryLightColor = Color(0xFF6294FF);
const pageBGColor = Color(0xFFEFF3F6);
const titleTextColor = Color(0xFF1E1E1E);
const subTitleTextColor = Color(0xFF555555);
const blYellowColor = Color(0xFFFFD34A);
const sliderIndicatorActiveColor = Color(0xFFF7781D);
const sliderIndicatorDeActiveColor = Color(0xCDDEDEDE);
const successColor = Color(0xFF0DB14B);
const salesBgColor = Color(0xFFEAB24D);
const chartColor = Color(0x80FFCA25);
const dropDownBgColor = Color(0xFFF7F6F5);

const buttonEnableBgColor = Colors.blue;
const buttonEnableTextColor = Colors.white;
 const buttonDisableBgColor = Colors.black12;
const buttonDisableTextColor = Colors.black45;

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class Palette {
  // http://mcg.mbitson.com/#!?mcgpalette0=%233f51b5
  static MaterialColor kToDark = const MaterialColor(
    0xffFFCB09, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xFFE2EAF2),
      100: Color(0xFFB6CBDF),
      200: Color(0xFF85A9CA),
      300: Color(0xFF5487B4),
      400: Color(0xFF306DA4),
      500: Color(_ktolightPrimaryValue),
      600: Color(0xFF0A4C8C),
      700: Color(0xFF084281),
      800: Color(0xFF063977),
      900: Color(0xFF032965),
    },
  );

  static const MaterialColor kToLight = MaterialColor(_ktolightPrimaryValue, <int, Color>{
    50: Color(0xFFE2EAF2),
    100: Color(0xFFB6CBDF),
    200: Color(0xFF85A9CA),
    300: Color(0xFF5487B4),
    400: Color(0xFF306DA4),
    500: Color(_ktolightPrimaryValue),
    600: Color(0xFF0A4C8C),
    700: Color(0xFF084281),
    800: Color(0xFF063977),
    900: Color(0xFF032965),
  });
  static const int _ktolightPrimaryValue = 0xFF0B5394;

  static const MaterialColor ktolightAccent = MaterialColor(_ktolightAccentValue, <int, Color>{
    100: Color(0xFF95B6FF),
    200: Color(_ktolightAccentValue),
    400: Color(0xFF2F71FF),
    700: Color(0xFF155FFF),
  });
  static const int _ktolightAccentValue = 0xFF6294FF;
}