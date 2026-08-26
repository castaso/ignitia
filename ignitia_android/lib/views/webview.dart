import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String targetURL;
  const WebViewPage({required this.targetURL,Key? key}) : super(key: key);

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {

  late final WebViewController _controller;

  late String targetURL;
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    targetURL = widget.targetURL;

    if (Platform.isAndroid || Platform.isIOS) {
      // Initialize the WebView controller
      _controller = WebViewController();
      _controller.loadRequest(Uri.parse(targetURL));
      // Enable JavaScript explicitly (if needed)
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text('i Employment'),
        ),
        body:  WebViewWidget(
          controller: _controller,  // Provide the controller here
        ));
  }
}