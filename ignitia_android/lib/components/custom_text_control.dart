import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/utils/colors.dart';
import 'custom_textfiled.dart';

class CustomTextControl extends StatefulWidget {
  final String labelText;
  final String hintText;
  final String defaultValue;
  final bool readOnly;
  final int leftFlex;
  final int rightFlex;
  final int? minLines;
  final int? maxLines;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  const CustomTextControl(
      {Key? key,
      required this.labelText,
        this.defaultValue = "",
        this.readOnly = false,
      this.hintText = "",
        this.leftFlex = 50,
        this.rightFlex = 50,
        this.minLines,
        this.maxLines,
      this.onChanged,
      this.onSubmitted})
      : super(key: key);

  @override
  State<CustomTextControl> createState() => _CustomTextControlState(
      this.labelText,
      this.defaultValue,
      this.readOnly,
      this.hintText,
      this.leftFlex,
      this.rightFlex,
      this.minLines,
      this.maxLines,
      this.onChanged,
  this.onSubmitted);
}

class _CustomTextControlState extends State<CustomTextControl> {
  final String labelText, hintText, defaultValue;
  final bool readOnly;
  final int leftFlex;
  final int rightFlex;
  final int? minLines;
  final int? maxLines;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  _CustomTextControlState(this.labelText,this.defaultValue, this.readOnly, this.hintText, this.leftFlex, this.rightFlex, this.minLines, this.maxLines, this.onChanged, this.onSubmitted);

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(defaultValue.isNotEmpty) {
      textEditingController.text =defaultValue;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: leftFlex,
          child: TitleTextView(
            labelText,
            textSize: 16,
          ),
        ),
        Flexible(
          flex: rightFlex,
          child: _textEditingWidget(hintText),
        )
      ],
    );
  }

  _textEditingWidget(String hintText) {
    return CustomTextField(
      isDisable: readOnly,
      labelText: labelText,
      hintText: hintText,
      minLines: minLines,
      maxLines: maxLines,
      textColor: readOnly ? buttonDisableTextColor : subTitleTextColor,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      textEditingController: textEditingController,
      onValueChange: onChanged,
      onSubmit: onSubmitted,
    );
  }
}
