import 'package:i_employment/components/textview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPage extends StatelessWidget {
  String msg;
  LoadingPage({this.msg = "Fetching data...",Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: SizedBox(
          width: 200,
          height: 150,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SpinKitFadingCircle(
                  color: Colors.black87,
                  size: 50,
                ),
                const SizedBox(height: 20,),
                TitleTextView(msg,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
