import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:i_employment/view_models/bg_service_view_model.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ConnectivityService{
  static final ConnectivityService _connectivityService =
  ConnectivityService._internal();

  late BackgroundServiceViewModel viewModel;

  factory ConnectivityService() {
    return _connectivityService;
  }

  static bool _isRunning= false;

  bool get isRunning => _isRunning;

  ConnectivityResult connectionResult = ConnectivityResult.none;
  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ConnectivityService._internal();

  Future<void> initConnectivity() async {

      _connectivity = Connectivity();

    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      List<ConnectivityResult> connectivityResults = await _connectivity.checkConnectivity();
      result = connectivityResults.first;  // Get the first item from the list
    } on PlatformException catch (e) {
      //developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    //viewModel = Provider.of<BackgroundServiceViewModel>(context, listen: false);
      viewModel  = BackgroundServiceViewModel();

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) {
    //   return Future.value(null);
    // }
      _connectivitySubscription = _connectivity.onConnectivityChanged
          .map((List<ConnectivityResult> results) => results.isNotEmpty ? results.first : ConnectivityResult.none)
          .listen(_updateConnectionStatus);

    _isRunning = true;
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if(result== ConnectivityResult.wifi){
      String? wifiName = await getNetwork();
      viewModel.checkIn(wifiName != null ? wifiName.replaceAll('\"', '') : "");
    }
  }

  Future<String?> getNetwork() async {
    final info = NetworkInfo();

    // Request location permission if needed
    if (await Permission.location.isDenied) {
      await Permission.locationWhenInUse.request();
    }
    if (await Permission.location.isRestricted) {
      openAppSettings();
    }

    if (await Permission.location.isGranted) {
      return await info.getWifiName();
    } else {
      return null;
    }
  }
}