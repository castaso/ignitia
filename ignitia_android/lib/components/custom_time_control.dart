import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/utils/common_functions.dart';

import 'calendar_theme.dart';
import 'custom_textfiled.dart';

class CustomTimeControl extends StatefulWidget {
  final String labelText;
  final String hintText;
  final String defaultFormat;
  final TimeOfDay defaultTime;
  final int leftFlex;
  final int rightFlex;
  final Function(TimeOfDay)? onSelected;
  const CustomTimeControl(
      {Key? key,
      required this.labelText,
      required this.defaultTime,
      this.hintText = "",
      this.defaultFormat = "hh:mm a",
        this.leftFlex = 50,
        this.rightFlex = 50,
      this.onSelected})
      : super(key: key);

  @override
  State<CustomTimeControl> createState() => _CustomTimeControlState(
      this.defaultTime,
      this.labelText,
      this.hintText,
      this.defaultFormat,
      this.leftFlex,
      this.rightFlex,
      this.onSelected);
}

class _CustomTimeControlState extends State<CustomTimeControl> {
  final String labelText, hintText;
  late TimeOfDay selectedTime;
  final String currentFormat;
  final int leftFlex;
  final int rightFlex;
  final Function(TimeOfDay)? onSelected;
  _CustomTimeControlState(this.selectedTime, this.labelText, this.hintText,
      this.currentFormat, this.leftFlex, this.rightFlex, this.onSelected);

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingController.text =
        CommonFunctions.getFormatedTime(currentFormat, selectedTime);
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
          child: _timeTextEditingWidget(hintText),
        )
      ],
    );
  }

  _timeTextEditingWidget(String hintText) {
    return CustomTextField(
      isDisable: true,
      labelText: labelText,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      textEditingController: textEditingController,
      rightIcon: const Icon(
        Icons.watch_later_outlined,
        size: 20,
        color: Colors.black45,
      ),
      onTap: () {
        _openTimePicker();
      },
    );
  }

  _openTimePicker() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return calendarTheme(context, child);
      },
    );

    if (pickedTime != null) {
      if (kDebugMode) {
        print(pickedTime);
      }
      selectedTime = pickedTime!;
      setState(() {
        textEditingController.text =
            CommonFunctions.getFormatedTime(currentFormat, selectedTime);
      });

      onSelected!(selectedTime);
    } else {
      if (kDebugMode) {
        print("Time is not selected");
      }
    }
  }
}
