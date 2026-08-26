
import 'package:i_employment/components/textview_widget.dart';
import 'package:flutter/material.dart';

Future<void> showMessageInDialog(BuildContext context,String title, String msg) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: TitleTextView(title),
        content: SingleChildScrollView(
          child: SubTitleTextView(msg),
        ),
        actions: <Widget>[
          TextButton(
            child: TitleTextView('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
