import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:switcher/core/switcher_size.dart';
import 'package:switcher/switcher.dart';
import 'custom_textfiled.dart';

class CustomSwitcherControl extends StatefulWidget {
  final String labelText;
  final bool defaultValue;
  final int leftFlex;
  final int rightFlex;
  final Function(bool) onChanged;
  const CustomSwitcherControl(
      {Key? key,
      required this.labelText,
        this.defaultValue = true,
        required this.onChanged,
        this.leftFlex = 50,
        this.rightFlex = 50
      })
      : super(key: key);

  @override
  State<CustomSwitcherControl> createState() => _CustomSwitcherControlState(
      this.labelText,
      this.defaultValue,
      this.leftFlex,
      this.rightFlex,
      this.onChanged);
}

class _CustomSwitcherControlState extends State<CustomSwitcherControl> {
  final String labelText;
  final bool defaultValue;
  final int leftFlex;
  final int rightFlex;
  final Function(bool) onChanged;
  _CustomSwitcherControlState(this.labelText,this.defaultValue, this.leftFlex, this.rightFlex, this.onChanged);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
          child: _switcherWidget(),
        )
      ],
    );
  }

  _switcherWidget() {
    return Switcher(
      value: defaultValue,
      colorOff: Colors.grey.shade300,
      colorOn: kPrimaryColor,
      size: SwitcherSize.medium,
      onChanged: onChanged,
    );
  }
}
