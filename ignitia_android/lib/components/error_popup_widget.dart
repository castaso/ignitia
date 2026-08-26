import 'package:i_employment/components/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/utils/string.dart';

import '../utils/constants.dart';

class ErrorPopupPage extends StatelessWidget {
  String msg;
  VoidCallback onOkPressed;
  ErrorPopupPage(
      {required this.onOkPressed, this.msg = "Unknown Error, pleaes contact system admin", Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: SizedBox(
          width: mediaSize.width < webWidth ? mediaSize.width - 20 : (mediaSize.width/2) - 20,
          height: mediaSize.height / 3 < 300 ? 300 : mediaSize.height / 3,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 100,
                ),
                const SizedBox(
                  height: 20,
                ),
                SelectableText(
                  msg,
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CustomButton(
                      onTap: onOkPressed,
                      text: Strings.btnTextOk,
                      buttonWidth: 100,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
