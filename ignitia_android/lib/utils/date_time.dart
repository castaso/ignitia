import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../components/custom_textfiled.dart';
import '../components/textview_widget.dart';

class CustomDateTime{

  static timeWidget(BuildContext context, TextEditingController controller, String hintText, String labelText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView(labelText,
            textSize: 16,
          ),
        ),
        Flexible(
          flex: 70,
          child: _timeTextEditingWidget(context, controller, hintText, labelText),
        )
      ],
    );
  }

  static _timeTextEditingWidget(BuildContext context,
      TextEditingController textEditingController, String hintText, String labelText) {
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
        _openTimePicker(context, textEditingController);
      },
    );
  }

  static _openTimePicker(BuildContext context, TextEditingController textFieldController) async {
    TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        );

    if (pickedTime != null) {
      if(kDebugMode) {print(pickedTime);} //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedTime = DateFormat("HH:mm").format(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute));

      textFieldController.text = formattedTime;

    } else {
      if(kDebugMode) {
        print("Date is not selected");
      }
    }
  }
}