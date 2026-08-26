import 'package:i_employment/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
class TitleTextView extends StatelessWidget {

  String text;
  double textSize;
  Color textColor;
  TextAlign textAlign;
  Fonts fontFamily;
  int? maxLines;
  TitleTextView(this.text, {this.textSize = 12.0,this.textColor = titleTextColor,this.textAlign = TextAlign.left,this.fontFamily = Fonts.gilroy_semibold,this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
        text,
        overflow: maxLines != null ? TextOverflow.ellipsis: null,
        maxLines: maxLines,
        softWrap: true,
        style: _getFontStyle(textSize, textColor, fontFamily),
        textAlign: textAlign
    );
  }
}

_getFontStyle(double textSize,Color textColor,Fonts fontFamily){
  switch(fontFamily){
    case Fonts.roboto_regular:
      return _robotoStyle(textSize, FontWeight.w400, textColor);
    case Fonts.roboto_medium:
      return _robotoStyle(textSize,FontWeight.w500, textColor);
    case Fonts.roboto_semibold:
      return _robotoStyle(textSize,FontWeight.w600, textColor);
    case Fonts.roboto_bold:
      return _robotoStyle(textSize,FontWeight.w700, textColor);
    case Fonts.questrial_regular:
      return _questrialStyleG(textSize,FontWeight.w400, textColor);
    case Fonts.questrial_medium:
      return _questrialStyleG(textSize,FontWeight.w500, textColor);
    case Fonts.questrial_semibold:
      return _questrialStyleG(textSize,FontWeight.w600, textColor);
    case Fonts.questrial_bold:
      return _questrialStyleG(textSize,FontWeight.w700, textColor);
    case Fonts.gilroy_regular:
      return _gilroyStyle(textSize,FontWeight.w400, textColor);
    case Fonts.gilroy_semibold:
      return _gilroyStyle(textSize,FontWeight.w600, textColor);
    case Fonts.gilroy_medium:
      return _gilroyStyle(textSize,FontWeight.w500, textColor);
    case Fonts.gilroy_bold:
      return _gilroyStyle(textSize,FontWeight.w700, textColor);
  }
}

_gilroyStyle(double textSize,FontWeight fontWeight,Color textColor){
  return TextStyle(
      fontSize: textSize,
      fontWeight: fontWeight,
      color: textColor,
      fontFamily: 'Gilory'
  );
}

_robotoStyle(double textSize,FontWeight fontWeight,Color textColor){
  return GoogleFonts.roboto(
      textStyle: TextStyle(
          fontSize: textSize,
          fontWeight: fontWeight,
          color: textColor
      ));
}

_questrialStyleG(double textSize,FontWeight fontWeight,Color textColor){
  return GoogleFonts.questrial(
      textStyle: TextStyle(
          fontSize: textSize,
          fontWeight: fontWeight,
          color: textColor
      ));
}

class SubTitleTextView extends StatelessWidget {
  String text;
  double textSize;
  Color textColor;
  TextAlign textAlign;
  Fonts fontFamily;
  SubTitleTextView(this.text, {this.textSize = 12.0,this.textColor = subTitleTextColor,this.textAlign = TextAlign.left,this.fontFamily = Fonts.gilroy_regular});

  @override
  Widget build(BuildContext context) {
    return Text(
        text,
        style: _getFontStyle(textSize, textColor, fontFamily),
        textAlign: textAlign
    );
  }
}

class MarqueeTextView extends StatelessWidget {
  String text;
  double textSize;
  MarqueeTextView(this.text, {this.textSize = 12.0});

  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: text,
      style: _robotoStyle(textSize, FontWeight.w400, subTitleTextColor),
      scrollAxis: Axis.horizontal, //scroll direction
      crossAxisAlignment: CrossAxisAlignment.start,
      blankSpace: 20.0,
      velocity: 50.0, //speed
      pauseAfterRound: const Duration(seconds: 1),
      startPadding: 4.0,
      accelerationDuration: const Duration(seconds: 1),
      accelerationCurve: Curves.linear,
      decelerationDuration: const Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
    );
  }
}

enum Fonts{
  roboto_regular,
  roboto_medium,
  roboto_semibold,
  roboto_bold,
  questrial_regular,
  questrial_medium,
  questrial_semibold,
  questrial_bold,
  gilroy_regular,
  gilroy_semibold,
  gilroy_medium,
  gilroy_bold,
}