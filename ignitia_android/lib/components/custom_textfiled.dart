import 'package:flutter/material.dart';
class CustomTextField extends StatelessWidget {

  String? hintText;
  bool isPassword;
  TextEditingController textEditingController;
  TextInputAction inputAction;
  Widget? leftIcon;
  Widget? rightIcon;
  bool? isDisable;
  VoidCallback? onTap;
  TextInputType? textInputType;
  FloatingLabelBehavior? floatingLabelBehavior;
  int? maxLines;
  int? minLines;
  int? maxLength;
  String? labelText;
  double? textSize;
  Color? textColor;
  EdgeInsetsGeometry? contentPadding;

  InputBorder? focusedBorder;
  InputBorder? enabledBorder;

  final Function(String value)? onSubmit;
  final Function(String value)? onValueChange;

  CustomTextField({
    this.hintText,
    required this.textEditingController,
    this.isPassword = false,
    this.inputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.floatingLabelBehavior,
    this.leftIcon,
    this.rightIcon,
    this.onSubmit,
    this.onValueChange,
    this.isDisable,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.labelText,
    this.textSize,
    this.textColor,
    this.focusedBorder,
    this.enabledBorder,
    this.contentPadding,
    this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          contentPadding: contentPadding ?? const EdgeInsets.all(10.0),
          enabledBorder: enabledBorder ?? const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38),
          ),
          focusedBorder: focusedBorder ?? const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87),
          ),
          // pass the hint text parameter here
          labelText: labelText ?? hintText,
          hintText: hintText ?? "",
          labelStyle: const TextStyle(color: Colors.grey),
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: leftIcon,
          suffixIcon: rightIcon,
          floatingLabelBehavior: floatingLabelBehavior ?? FloatingLabelBehavior.never
      ),
      style: TextStyle(color: textColor ?? Colors.black,fontSize: textSize ?? 14),
      controller: textEditingController,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      minLines: minLines ?? 1,
      maxLength: maxLength,
      textInputAction: inputAction,
      readOnly: isDisable ?? false,
      cursorColor: Colors.black38,
      obscureText: isPassword,
      onChanged: onValueChange,
      onSubmitted: onSubmit,
      onTap: onTap,
    );
  }
}