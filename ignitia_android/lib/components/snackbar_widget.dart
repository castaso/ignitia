import 'package:flutter/material.dart';

class CustomSnackbar{
  CustomSnackbar._();
  static showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
