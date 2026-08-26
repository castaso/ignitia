import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/utils/common_functions.dart';
import 'package:intl/intl.dart';

import 'calendar_theme.dart';
import 'custom_textfiled.dart';

class CustomDateControl extends StatefulWidget {
  final String labelText;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime defulatDate;
  final String hintText;
  final String defaultFormat;
  final double? fixedWidth;
  final Function(DateTime)? onSelected;
  const CustomDateControl(
      {Key? key,
      required this.labelText,
      required this.firstDate,
      required this.lastDate,
      required this.defulatDate,
      this.hintText = "",
      this.defaultFormat = "dd/MM/yyyy",
      this.fixedWidth,
      this.onSelected})
      : super(key: key);

  @override
  State<CustomDateControl> createState() => _CustomDateControlState(
      this.labelText,
      this.firstDate,
      this.lastDate,
      this.defulatDate,
      this.hintText,
      this.defaultFormat,
      this.fixedWidth,
      this.onSelected);
}

class _CustomDateControlState extends State<CustomDateControl> {
  final String labelText;
  final DateTime firstDate;
  final DateTime lastDate;
  late DateTime selectedDate;
  final String hintText;
  final String currentFormat;
  final double? fixedWidth;
  final Function(DateTime)? onSelected;
  _CustomDateControlState(
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
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        fixedWidth==null ? Flexible(
          child: TitleTextView(
            labelText,
            textSize: 16,
          ),
        ) : TitleTextView(
          labelText,
          textSize: 16,
        ),
        Flexible(
            child: Container(
          width: fixedWidth,
          child: _dateTextEditingWidget(hintText),
        ))
      ],
    );
  }

  _dateTextEditingWidget(String hintText) {
    return CustomTextField(
      isDisable: true,
      labelText: labelText,
      hintText: hintText,
      contentPadding: EdgeInsets.fromLTRB(2,0,0,0),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      textEditingController: textEditingController,
      rightIcon: const Icon(
        Icons.calendar_month_outlined,
        size: 20,
        color: Colors.black45,
      ),
      onTap: () {
        _openDatePicker();
      },
    );
  }

  _openDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate:
          firstDate, //DateTime.now() - not to allow to choose before today.
      lastDate: lastDate,
      builder: (context, child) {
        return calendarTheme(context, child);
      },
    );

    if (pickedDate != null) {
      if (kDebugMode) {
        print(pickedDate);
      }
      selectedDate = pickedDate!;
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
