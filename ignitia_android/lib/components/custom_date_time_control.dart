import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/utils/common_functions.dart';
import 'package:i_employment/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import 'calendar_theme.dart';
import 'custom_textfiled.dart';

class CustomDateTimeControl extends StatefulWidget {
  final String labelText;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime defulatDate;
  final String hintText;
  final String defaultFormat;
  final double? fixedWidth;
  final Function(DateTime)? onSelected;
  const CustomDateTimeControl(
      {Key? key,
      required this.labelText,
      required this.firstDate,
      required this.lastDate,
      required this.defulatDate,
      this.hintText = "",
      this.defaultFormat = "dd/MM/yyyy hh:mm a",
      this.fixedWidth,
      this.onSelected})
      : super(key: key);

  @override
  State<CustomDateTimeControl> createState() => _CustomDateTimeControlState(
      this.labelText,
      this.firstDate,
      this.lastDate,
      this.defulatDate,
      this.hintText,
      this.defaultFormat,
      this.fixedWidth,
      this.onSelected);
}

class _CustomDateTimeControlState extends State<CustomDateTimeControl> {
  final String labelText;
  final DateTime firstDate;
  final DateTime lastDate;
  late DateTime selectedDate;
  final String hintText;
  final String currentFormat;
  final double? fixedWidth;
  final Function(DateTime)? onSelected;
  _CustomDateTimeControlState(
      this.labelText,
      this.firstDate,
      this.lastDate,
      this.selectedDate,
      this.hintText,
      this.currentFormat,
      this.fixedWidth,
      this.onSelected);

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingController.text = DateFormat(currentFormat).format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return fixedWidth == null ? _notFixedWidthView(mediaSize.width > webWidth) : _fixedWidthView(mediaSize.width > webWidth);
  }

  _notFixedWidthView(bool isWeb){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView(labelText, textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: _dateTextEditingWidget(hintText, isWeb),
        )
      ],
    );
  }

  _fixedWidthView(bool isWeb){
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TitleTextView(
          labelText,
          textSize: 16,
        ),
        Flexible(
            child: Container(
              width: fixedWidth,
              child: _dateTextEditingWidget(hintText, isWeb),
            ))
      ],
    );
  }

  _dateTextEditingWidget(String hintText, bool isWeb) {
    return CustomTextField(
      isDisable: true,
      labelText: labelText,
      hintText: hintText,
      //contentPadding: EdgeInsets.fromLTRB(2, 0, 0, 0),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      textEditingController: textEditingController,
      rightIcon: const Icon(
        Icons.calendar_month_outlined,
        size: 20,
        color: Colors.black45,
      ),
      onTap: () {
        if (isWeb) {
          _openDatePickerWeb();
        } else {
          _openDatePicker();
        }
      },
    );
  }

  _openDatePicker() async {
    DateTime? pickedDateTime = await showOmniDateTimePicker(
        context: context,
        firstDate: firstDate,
        lastDate: lastDate,
        initialDate: selectedDate);

    if (pickedDateTime != null) {
      if (kDebugMode) {
        print(pickedDateTime);
      }
      selectedDate = pickedDateTime!;
      setState(() {
        textEditingController.text =
            DateFormat(currentFormat).format(selectedDate);
      });

      onSelected!(selectedDate);
    } else {
      if (kDebugMode) {
        print("Date is not selected");
      }
    }
  }

  _openDatePickerWeb() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: firstDate,
        lastDate: lastDate,
        initialDate: selectedDate);

    if (pickedDate != null) {
      if (kDebugMode) {
        print(pickedDate);
      }
      selectedDate = DateTime(pickedDate!.year, pickedDate!.month,
          pickedDate!.day, selectedDate.hour, selectedDate.minute);

      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute),
        builder: (context, child) {
          return calendarTheme(context, child);
        },
      );

      if (pickedTime != null) {
        if (kDebugMode) {
          print(pickedTime);
        }
        selectedDate = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, pickedTime.hour, pickedTime.minute);
      } else {
        if (kDebugMode) {
          print("Time is not selected");
        }
      }
      setState(() {
        textEditingController.text =
            DateFormat(currentFormat).format(selectedDate);
      });

      onSelected!(selectedDate);
    } else {
      if (kDebugMode) {
        print("Date is not selected");
      }
    }
  }
}
