
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'fetching_data_widget.dart';

class ProgressDialog{
  static var _isShowingProgressDialog = false;
  static late AlertDialog? _progressAlert;
  static Future<void> showProgressAlert(BuildContext context,String msg) async {
    hideProgressDialog(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        _progressAlert = AlertDialog(
            content: SingleChildScrollView(
              child: fetchingDataView(msg: msg),
            )
        );
        _isShowingProgressDialog = true;
        return _progressAlert!;
      },
    );
  }
  static hideProgressDialog(BuildContext context){
    if(_isShowingProgressDialog && _progressAlert != null){
      if (kDebugMode) {
        print("Hiding Progress dialog");
      }
      Navigator.of(context).pop();
      _isShowingProgressDialog = false;
      _progressAlert = null;
    }
  }
}

