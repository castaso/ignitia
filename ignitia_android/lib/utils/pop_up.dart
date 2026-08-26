import 'package:flutter/material.dart';
import 'package:i_employment/config/office_location_config.dart';
import 'package:i_employment/models/overtime/overtime_model.dart';
import 'package:i_employment/utils/common_functions.dart';
import 'package:i_employment/utils/shared_preference.dart';
import 'package:i_employment/utils/string.dart';

import '../components/button_widget.dart';
import '../components/textview_widget.dart';
import '../components/toast_widget.dart';
import '../repo/location_service.dart';
import '../services/face_detection_result.dart';
import '../view_models/home_view_model.dart';
import '../views/home/home_screen.dart';
import '../views/overtime/add_overtime_page.dart';
import '../views/security/face_verification_page.dart';
import 'colors.dart';
import 'message.dart';
import 'navigation_utils.dart';

class Popup{

  // Resolves the location that will be shown in the check-in / check-out
  // dialog. When the device is outside the office geo-fence the validation
  // error message is returned so the user understands why the attendance
  // cannot be recorded.
  static Future<String> _resolveLocationText() async {
    try {
      final position = await LocationService().getValidatedPosition();
      final address = await LocationService().GetAddressFromLatLong(position);
      return address.isEmpty ? Messages.warningLocationNotFound : address;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<void> showCheckInPopup(BuildContext context, HomeViewModel viewModel) async{
    String locationText = await _resolveLocationText();
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        builder: (BuildContext buildContext) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                height: MediaQuery.of(context).size.height / 2,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                        size: 70,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height/2 - 200,
                        child: ListView(
                          children: [
                            TitleTextView("${Messages.warningCheckInAddress}:"
                              , textSize: 16, textAlign: TextAlign.center,),
                            TitleTextView("$locationText"
                              , textSize: 12, textAlign: TextAlign.center,),
                            SizedBox(height: 20,),
                            TitleTextView("${Messages.warningDoContinue}?"
                              , textSize: 20, textAlign: TextAlign.center,),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),

                                  ),
                                  child: TitleTextView(Strings.btnTextNo,textSize: 18,),
                                ),
                                SizedBox(width: 10,),
                                OutlinedButton(
                                  onPressed: ()async{
                                    await _performAttendanceWithFaceVerification(
                                        context, viewModel, isCheckIn: true);
                                  },
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                                      backgroundColor: MaterialStateColor.resolveWith((states) => kPrimaryLightColor)
                                  ),
                                  child: TitleTextView(Strings.btnTextYes,textSize: 18,textColor: Colors.white),
                                ),
                              ]
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

        });
  }

  static Future<void> showCheckOutPopup(BuildContext context, HomeViewModel viewModel) async{
    String locationText = await _resolveLocationText();
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        builder: (BuildContext buildContext) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                height: MediaQuery.of(context).size.height / 2,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                        size: 70,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height/2 - 200,
                        child: ListView(
                          children: [
                            TitleTextView("${Messages.warningCheckOutAddress}:"
                              , textSize: 16, textAlign: TextAlign.center,),
                            TitleTextView("$locationText"
                              , textSize: 12, textAlign: TextAlign.center,),
                            SizedBox(height: 20,),
                            TitleTextView("${Messages.warningDoContinue}?"
                              , textSize: 20, textAlign: TextAlign.center,),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),

                                  ),
                                  child: TitleTextView(Strings.btnTextNo,textSize: 18,),
                                ),
                                SizedBox(width: 10,),
                                OutlinedButton(
                                  onPressed: ()async{
                                    await _performAttendanceWithFaceVerification(
                                        context, viewModel, isCheckIn: false);
                                  },
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                                      backgroundColor: MaterialStateColor.resolveWith((states) => kPrimaryLightColor)
                                  ),
                                  child: TitleTextView(Strings.btnTextYes,textSize: 18,textColor: Colors.white),
                                ),
                              ]
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

        });
  }

  // Runs the geo-fence + facial validation flow and then performs the actual
  // check-in / check-out. Attendance is never recorded unless both validations
  // succeed.
  static Future<void> _performAttendanceWithFaceVerification(
      BuildContext context, HomeViewModel viewModel,
      {required bool isCheckIn}) async {
    String? faceImage;
    String? challengeId;
    List<String> livenessFrames = const [];
    if (OfficeLocationConfig.faceValidationEnabled) {
      final faceResult = await Navigator.of(context).push<FaceVerificationResult>(
        MaterialPageRoute(builder: (_) => const FaceVerificationPage()),
      );
      if (faceResult == null) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        CustomToast.showErrorToast(Messages.warningFaceVerificationCancel);
        return;
      }
      faceImage = faceResult.faceBase64;
      livenessFrames = faceResult.livenessFrames;
      challengeId = faceResult.challengeId;
    }
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();

    final bool success = isCheckIn
        ? await viewModel.checkIn(
            faceImageBase64: faceImage,
            livenessFrames: livenessFrames,
            challengeId: challengeId)
        : await viewModel.checkOut(
            faceImageBase64: faceImage,
            livenessFrames: livenessFrames,
            challengeId: challengeId);
    if (!success) {
      if (viewModel.errorMsg.isNotEmpty) {
        CustomToast.showErrorToast(viewModel.errorMsg);
      }
      return;
    }

    if (isCheckIn) {
      openNewUI(context, HomeScreen());
    } else {
      var allow = await SessionManager.getAlertForMissingOvertime();
      if (!allow) {
        openNewUI(context, HomeScreen());
      }else {
        var attendance = viewModel.attendanceList
            .first;
        showOvertimePopup(context, viewModel,
            CommonFunctions.getNewOvertime(
                attendance));
      }
    }
  }

  static Future<void> showOvertimePopup(BuildContext context, HomeViewModel viewModel, OvertimeModel overtimeModel) async{
    var attendance = viewModel.attendanceList.first;
    var checkInTime = attendance.getCheckIn();
    if(DateTime.now().difference(checkInTime??DateTime.now()).inHours<10) {
      openNewUI(context, HomeScreen());
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        builder: (BuildContext buildContext) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                height: MediaQuery.of(context).size.height / 2,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                        size: 70,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height/2 - 200,
                        child: ListView(
                          children: [
                            TitleTextView("${Messages.warningCheckOutOvertime}:"
                              , textSize: 16, textAlign: TextAlign.center,),
                            SizedBox(height: 20,),
                            TitleTextView("${Messages.warningDoAddOvertime}?"
                              , textSize: 20, textAlign: TextAlign.center,),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: (){
                                    //Navigator.of(context).pop();
                                    openNewUI(context, HomeScreen());
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),

                                  ),
                                  child: TitleTextView(Strings.btnTextNo,textSize: 18,),
                                ),
                                SizedBox(width: 10,),
                                OutlinedButton(
                                  onPressed: ()async{
                                    Navigator.of(context).pop();

                                    openNewUI(context, AddOvertimePage(overtimeModel: overtimeModel));
                                  },
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                                      backgroundColor: MaterialStateColor.resolveWith((states) => kPrimaryLightColor)
                                  ),
                                  child: TitleTextView(Strings.btnTextYes,textSize: 18,textColor: Colors.white),
                                ),
                              ]
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

        });
  }
}