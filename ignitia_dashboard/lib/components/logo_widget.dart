import 'package:flutter/cupertino.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/naas_logo.png",
      width: 150,
      height: 150,
      fit: BoxFit.contain,
    );
  }
}
