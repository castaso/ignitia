import 'package:i_employment/components/textview_widget.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

fetchingDataView({String msg = "Fetching data..."}){
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          backgroundColor: Colors.grey,
          color: blYellowColor,
        ),
        const SizedBox(height: 20,),
        SubTitleTextView(msg)
      ],
    ),
  );
}