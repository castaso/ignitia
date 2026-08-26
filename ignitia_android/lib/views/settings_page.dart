import 'package:flutter/material.dart';
import 'package:i_employment/components/custom_switcher_control.dart';
import 'package:i_employment/components/custom_time_control.dart';
import 'package:i_employment/components/toast_widget.dart';
import 'package:i_employment/models/settings_model.dart';
import 'package:i_employment/utils/navigation_utils.dart';

import '../../components/button_widget.dart';
import '../../components/loading_widget.dart';
import '../../utils/message.dart';
import '../../utils/string.dart';
import '../components/custom_text_control.dart';
import '../utils/common_functions.dart';
import '../utils/shared_preference.dart';
import 'home/home_screen.dart';

class SettingsPage extends StatefulWidget {
  final SettingsModel settingsModel;
  const SettingsPage({Key? key,required this.settingsModel}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState(this.settingsModel);
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsModel settingsModel;
  _SettingsPageState(this.settingsModel);

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(Strings.titleSettingsPage),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: false,
            children: [
              _officeStartTimeWidget(),
              const SizedBox(
                height: 20,
              ),
              _officeEndTimeWidget(),
              const SizedBox(
                height: 20,
              ),
              _officeNetworkWidget(),
              const SizedBox(
                height: 20,
              ),
              _allowAutoCheckInWidget(),
              const SizedBox(
                height: 20,
              ),
              _alertForMissingCheckInWidget(),
              const SizedBox(
                height: 20,
              ),
              _alertForMissingCheckOutWidget(),
              const SizedBox(
                height: 20,
              ),
              _alertForMissingOvertimeWidget(),
              const SizedBox(
                height: 20,
              ),
              CustomButton(
                onTap: () async {
                  if(isLoading) return;
                  isLoading = true;
                  await update();
                  CustomToast.showSuccessToast(Messages.successSettingsUpdate);
                  openNewUI(context, HomeScreen());
                  isLoading = false;
                },
                text: Strings.btnTextUpdate,
                textSize: 16,
              ),
              if(isLoading) LoadingPage(msg: Messages.progressInProgress,)
            ],
          ),
        ));
  }

  update() async{
    await SessionManager.setOfficeStartTime(settingsModel.officeStartTime);
    await SessionManager.setOfficeEndTime(settingsModel.officeEndTime);
    await SessionManager.setOfficeNetwork(settingsModel.officeNetwork);
    await SessionManager.setAllowAutoCheckIn(settingsModel.allowAutoCheckIn);
    await SessionManager.setAlertForMissingCheckIn(settingsModel.alertForMissingCheckIn);
    await SessionManager.setAlertForMissingCheckOut(settingsModel.alertForMissingCheckOut);
    await SessionManager.setAlertForMissingOvertime(settingsModel.alertForMissingOvertime);
  }

  _officeStartTimeWidget() {
    return CustomTimeControl(
      labelText: Strings.textOfficeStartTime,
      defaultTime: CommonFunctions.parseTime("HH:mm", settingsModel.officeStartTime),
      defaultFormat: "hh:mm a",
      leftFlex: 60,
      rightFlex: 40,
      onSelected: (value){
        settingsModel.officeStartTime = CommonFunctions.getFormatedTime("HH:mm", value);
      },
    );
  }

  _officeEndTimeWidget() {
    return CustomTimeControl(
      labelText: Strings.textOfficeEndTime,
      defaultTime: CommonFunctions.parseTime("HH:mm", settingsModel.officeEndTime),
      defaultFormat: "hh:mm a",
      leftFlex: 60,
      rightFlex: 40,
      onSelected: (value){
        settingsModel.officeEndTime = CommonFunctions.getFormatedTime("HH:mm", value);
      },
    );
  }

  _officeNetworkWidget() {
    return CustomTextControl(
      labelText: Strings.textOfficeNetwork,
      defaultValue: settingsModel.officeNetwork,
      leftFlex: 60,
      rightFlex: 40,
      onChanged: (value){
        settingsModel.officeNetwork = value;
      },
    );
  }

  _allowAutoCheckInWidget() {
    return CustomSwitcherControl(
      labelText: Strings.textAllowAutoCheckIn,
      defaultValue: settingsModel.allowAutoCheckIn,
      leftFlex: 60,
      rightFlex: 40,
      onChanged: (value){
        settingsModel.allowAutoCheckIn = value;
      },
    );
  }

  _alertForMissingCheckInWidget() {
    return CustomSwitcherControl(
      labelText: Strings.textAlertForMissingCheckIn,
      defaultValue: settingsModel.alertForMissingCheckIn,
      leftFlex: 60,
      rightFlex: 40,
      onChanged: (value){
        settingsModel.alertForMissingCheckIn = value;
      },
    );
  }

  _alertForMissingCheckOutWidget() {
    return CustomSwitcherControl(
      labelText: Strings.textAlertForMissingCheckOut,
      defaultValue: settingsModel.alertForMissingCheckOut,
      leftFlex: 60,
      rightFlex: 40,
      onChanged: (value){
        settingsModel.alertForMissingCheckOut = value;
      },
    );
  }

  _alertForMissingOvertimeWidget() {
    return CustomSwitcherControl(
      labelText: Strings.textAlertForMissingOvertime,
      defaultValue: settingsModel.alertForMissingOvertime,
      leftFlex: 60,
      rightFlex: 40,
      onChanged: (value){
        settingsModel.alertForMissingOvertime = value;
      },
    );
  }
}
