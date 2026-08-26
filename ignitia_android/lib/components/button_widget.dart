import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  CustomButton({
    required this.onTap,
    this.borderRadius,
    this.buttonColor,
    this.textColor,
    this.borderColor,
    this.textSize,
    this.buttonWidth,
    required this.text,
    Key? key,
  }) : super(key: key);

  VoidCallback onTap;
  Color? buttonColor;
  double? borderRadius;
  Color? textColor;
  String text;
  double? textSize;
  double? buttonWidth;
  Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: buttonWidth ?? double.infinity,
      decoration: BoxDecoration(
          color: buttonColor ?? buttonEnableBgColor,
          border: Border.all(color: borderColor ?? Colors.white),
          borderRadius: BorderRadius.circular(borderRadius ?? 8)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: TitleTextView(text,textSize: textSize ?? 18, textColor: textColor ?? buttonEnableTextColor,),
            ),
          ),
        ),
      ),
    );
  }
}