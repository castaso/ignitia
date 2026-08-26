import 'package:flutter/gestures.dart';
import 'package:i_employment/components/button_widget.dart';
import 'package:i_employment/components/custom_textfiled.dart';
import 'package:i_employment/components/loading_widget.dart';
import 'package:i_employment/components/logo_widget.dart';
import 'package:i_employment/components/toast_widget.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/utils/shared_preference.dart';
import 'package:i_employment/view_models/login_view_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/message.dart';
import '../utils/string.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  bool isFlutterLocalNotificationsInitialized = false;

  var releaseDate = DateFormat('dd MMM yyyy').format(DateTime.now());

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkAuthentication() async {}

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  void loadFCM() async {
    if (!kIsWeb) {
      await setupFlutterNotifications();
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'launch_background',
          ),
        ),
      );
    }
  }

  void getFCMToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      SessionManager.setFCMToken(token ?? "");
    });
  }

  late LoginViewModel viewModel;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, ()
    {
      initialization();
    });
  }

  void initialization() async {
    viewModel = Provider.of<LoginViewModel>(context, listen: false);
    //loadFCM();
    //listenFCM();
    //getFCMToken();
    _listenChangeFromViewModel();
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.removeListener(() {});
  }

  void _listenChangeFromViewModel() {
    viewModel.addListener(() {
      if (viewModel.isLoginSuccess) {
        openHomeUI(context);
        if(kDebugMode) {print(SessionManager.getToken());}
      }
      if (!viewModel.loading && viewModel.errorMsg.isNotEmpty) {
        _showMsg(viewModel.errorMsg, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    LoginViewModel viewModel = context.watch<LoginViewModel>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        SafeArea(child: _loginUI(viewModel)),
        if (viewModel.loading) LoadingPage(msg: Messages.progressCheckAuth)
      ]),
    );
  }

  _loginUI(LoginViewModel viewModel) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(height: 80,),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        child: const LogoWidget()),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: CustomTextField(
                        hintText: Strings.hintEmailAddress,
                        textEditingController: nameController,
                        textInputType: TextInputType.emailAddress,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: CustomTextField(
                          hintText: Strings.hintPassword,
                          textEditingController: passwordController,
                          isPassword: true),
                    ),
                    Container(
                      height: 80,
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                      child: CustomButton(
                        onTap: () {
                          if(kDebugMode) {
                            if (nameController.text.isEmpty)
                              nameController.text = "admin1@sslebd.com";
                            if (passwordController.text.isEmpty)
                              passwordController.text = "#Ssle768";
                          }
                          if(viewModel.loading) return;
                          var status = viewModel.validateUserInformation(
                              nameController.text, passwordController.text);
                          if (status) {
                            viewModel.doLogin(nameController.text.trim(),
                                passwordController.text.trim());
                          } else {
                            _showMsg(viewModel.errorMsg, true);
                          }
                        },
                        text: Strings.btnTextLogin,
                      ),
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: TextButton(
                            onPressed: () async {
                              if(viewModel.loading) return;
                              if(nameController.text.isEmpty){
                                _showMsg(Messages.errorUserNameEmpty, true);
                                return;
                              }else {
                                var status = await viewModel.forgetPassword(nameController.text);
                                if (status) {
                                  _showMsg(Messages.successForgetPasswordRequest, false);
                                } else {
                                  _showMsg(viewModel.errorMsg, true);
                                }
                              }
                            },
                            child: Text(
                              "${Strings.btnTextForgetPassword}?",
                              style:
                              const TextStyle(fontSize: 16, color:buttonEnableBgColor ),
                            ),
                          ),
                        )),
                    Container(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0,16,2,0),
                          child: Text(
                            viewModel.appName,
                            style:
                                const TextStyle(fontSize: 16, color: Colors.orange),
                          ),
                        )),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "v${viewModel.versionName}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMsg(String msg, bool isError) {
    if(isError) {
      CustomToast.showErrorToast(msg);
    }else{
      CustomToast.showSuccessToast(msg);
    }
  }
}
