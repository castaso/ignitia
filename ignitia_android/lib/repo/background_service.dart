import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:i_employment/view_models/bg_service_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'connectivity_service.dart';

class BackgroundService {
  static final BackgroundService _backgroundService =
      BackgroundService._internal();

  //static late BackgroundServiceViewModel viewModel;

  factory BackgroundService() {
    return _backgroundService;
  }

  static const channelId = "high_importance_channel";
  static const notificationId = 888;

  BackgroundService._internal();

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });

      var connectivity = ConnectivityService();
      if (!connectivity.isRunning) connectivity.initConnectivity();
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // bring to foreground
    Timer.periodic(const Duration(hours: 1), (timer) async {
      // if (service is AndroidServiceInstance) {
      //   print("AndroidServiceInstance detected");
      //   if (await service.isForegroundService()) {
      //     print("AndroidServiceInstance detected");
      //
      //   }
      // }

      //await viewModel.Init();
      BackgroundServiceViewModel().AlertForCheckIn();
      BackgroundServiceViewModel().AlertForCheckOut();

      if(kDebugMode) {print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');}
    });
  }

  Future<void> initializeService() async {
    //viewModel = BackgroundServiceViewModel();

    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId, // id
      'MY FOREGROUND SERVICE', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: true,
        isForegroundMode: true,
        autoStartOnBoot: false,

        notificationChannelId: channelId,
        initialNotificationTitle: 'i Employment',
        initialNotificationContent:
            'Service is started at ${DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.now())}',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
    if (await service.isRunning() == false) {
      await service.startService();
      _isRunning = true;
    }
      BackgroundServiceViewModel().AlertForCheckIn();
      BackgroundServiceViewModel().AlertForCheckOut();

  }

  static bool _isRunning= false;

  bool get isRunning => _isRunning;

  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    if(kDebugMode) {print("onIosBackground");}
    return true;
  }
}
