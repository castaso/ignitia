import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/custom_time_control.dart';
import 'package:i_employment/components/toast_widget.dart';
import 'package:i_employment/config/office_location_config.dart';
import 'package:i_employment/models/attendance/attendance_model.dart';
import 'package:i_employment/utils/common_functions.dart';
import 'package:i_employment/utils/message.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/views/attendance/attendance_page.dart';
import 'package:i_employment/views/attendance/request_list_page.dart';
import 'package:i_employment/views/security/face_verification_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../components/app_bar_widget.dart';
import '../../components/button_widget.dart';
import '../../components/calendar_theme.dart';
import '../../components/custom_date_time_control.dart';
import '../../components/custom_textfiled.dart';
import '../../components/error_popup_widget.dart';
import '../../components/loading_widget.dart';
import '../../components/textview_widget.dart';
import '../../services/face_detection_result.dart';
import '../../utils/constants.dart';
import '../../view_models/attendance_view_model.dart';
import '../menu_page.dart';

class EditAttendancePage extends StatefulWidget {
  final AttendanceModel attendanceModel;
  const EditAttendancePage({Key? key, required this.attendanceModel})
      : super(key: key);

  @override
  State<EditAttendancePage> createState() =>
      _EditAttendancePageState(this.attendanceModel);
}

enum CheckInOutControlType { checkIn, checkOut }

class _EditAttendancePageState extends State<EditAttendancePage> {
  AttendanceModel attendanceModel;
  _EditAttendancePageState(this.attendanceModel);

  TextEditingController dateController = TextEditingController();
  TextEditingController checkInDateController = TextEditingController();
  TextEditingController checkOutDateController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController missingReasonController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime selectedCheckInDate = DateTime.now();
  DateTime selectedCheckOutDate = DateTime.now();
  int selectedDuration = 0;

  late AttendanceViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<AttendanceViewModel>(context, listen: false);

    selectedDate = (attendanceModel.getDateTime() ?? DateTime.now());
    selectedCheckInDate = (attendanceModel.getCheckIn() ??
        selectedDate.add(const Duration(hours: 9)));
    selectedCheckOutDate = (attendanceModel.getCheckOut() ??
        selectedDate.add(const Duration(hours: 18)));
    selectedDuration =
        selectedCheckOutDate.difference(selectedCheckInDate).inMinutes;

    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    checkInDateController.text =
        DateFormat('dd/MM/yyyy hh:mm a').format(selectedCheckInDate);
    checkOutDateController.text = attendanceModel.getCheckOut() == null
        ? ""
        : DateFormat('dd/MM/yyyy hh:mm a').format(selectedCheckOutDate);
    durationController.text = attendanceModel.getCheckOut() == null
        ? ""
        : CommonFunctions.durationFormat(selectedDuration);
    missingReasonController.text = attendanceModel.missingReason ?? "";
  }

  @override
  Widget build(BuildContext context) {
    AttendanceViewModel viewModel = context.watch<AttendanceViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleEditAttendancePage,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
              child: Row(
                children: [
                  mediaSize.width > webWidth
                      ? Flexible(flex: 1, child: MenuPage())
                      : Container(),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        shrinkWrap: false,
                        children: [
                          _dateWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          // _timeWidget(
                          //     checkInDateController,
                          //     "dd/MM/yyyy hh:mm a",
                          //     CheckInOutControlType.checkIn),
                          _checkInWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          // _timeWidget(
                          //     checkOutDateController,
                          //     "dd/MM/yyyy hh:mm a",
                          //     CheckInOutControlType.checkOut),
                          _checkOutWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          _durationWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          _missingReasonWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomButton(
                            onTap: () async {
                              if (viewModel.loading) return;
                              String? faceImageBase64;
                              String? challengeId;
                              List<String> livenessFrames = const [];
                              if (OfficeLocationConfig.faceValidationEnabled) {
                                final faceResult =
                                    await Navigator.of(context)
                                        .push<FaceVerificationResult>(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const FaceVerificationPage()),
                                );
                                if (faceResult == null) {
                                  CustomToast.showErrorToast(
                                      Messages.warningFaceVerificationCancel);
                                  return;
                                }
                                faceImageBase64 = faceResult.faceBase64;
                                livenessFrames = faceResult.livenessFrames;
                                challengeId = faceResult.challengeId;
                              }
                              var isSuccess =
                                  await viewModel.editAttendanceRequest(
                                      selectedDate,
                                      selectedCheckInDate,
                                      selectedCheckOutDate,
                                      missingReasonController.text,
                                      faceImageBase64: faceImageBase64,
                                      livenessFrames: livenessFrames,
                                      challengeId: challengeId);
                              if (isSuccess) {
                                openNewUI(context, const RequestListPage());
                                CustomToast.showSuccessToast(
                                    Messages.successRequestSent);
                              }
                            },
                            text: Strings.btnTextUpdate,
                            textSize: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (viewModel.loading)
              LoadingPage(msg: Messages.progressInProgress),
            if (viewModel.errorMsg.isNotEmpty)
              ErrorPopupPage(
                msg: viewModel.errorMsg,
                onOkPressed: () {
                  viewModel.setErrorMsg("");
                },
              ),
          ],
        ));
  }

  _dateWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textDate}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: dateController,
          ),
        )
      ],
    );
  }

  _checkInWidget() {
    return CustomDateTimeControl(
      labelText: "${Strings.textCheckIn}: ",
      firstDate: selectedDate,
      lastDate: selectedDate,
      defulatDate: selectedCheckInDate,
      onSelected: (value) {
        setState(() {
          selectedCheckInDate=value;
          int duration =
              selectedCheckOutDate.difference(selectedCheckInDate).inMinutes;
          selectedDuration = duration;
          durationController.text = duration < 60
              ? Messages.errorDurationMin
              : (duration > 1320
              ? Messages.errorDurationMax
              : CommonFunctions.durationFormat(duration));
        });
      },
    );
  }

  _checkOutWidget() {
    return CustomDateTimeControl(
      labelText: "${Strings.textCheckOut}: ",
      firstDate: selectedCheckInDate,
      lastDate: selectedDate.add(const Duration(days: 1)),
      defulatDate: selectedCheckOutDate,
      onSelected: (value) {
        setState(() {
          selectedCheckOutDate=value;
          int duration =
              selectedCheckOutDate.difference(selectedCheckInDate).inMinutes;
          selectedDuration = duration;
          durationController.text = duration < 60
              ? Messages.errorDurationMin
              : (duration > 1320
              ? Messages.errorDurationMax
              : CommonFunctions.durationFormat(duration));
        });
      },
    );
  }

  _timeWidget(TextEditingController controller, String hintText,
      CheckInOutControlType type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView(
            type == CheckInOutControlType.checkIn
                ? "${Strings.textCheckIn}: "
                : "${Strings.textCheckOut}: ",
            textSize: 16,
          ),
        ),
        Flexible(
          flex: 70,
          child: _timeTextEditingWidget(controller, type),
        )
      ],
    );
  }

  _timeTextEditingWidget(
      TextEditingController textEditingController, CheckInOutControlType type) {
    return CustomTextField(
      isDisable: true,
      labelText: type == CheckInOutControlType.checkIn
          ? Strings.hintCheckInTime
          : Strings.hintCheckOutTime,
      hintText: type == CheckInOutControlType.checkIn
          ? Strings.hintCheckInTime
          : Strings.hintCheckOutTime,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      textEditingController: textEditingController,
      rightIcon: const Icon(
        Icons.watch_later_outlined,
        size: 20,
        color: Colors.black45,
      ),
      onTap: () {
        _openTimePicker(textEditingController, type);
      },
    );
  }

  _openTimePicker(TextEditingController textFieldController,
      CheckInOutControlType type) async {
    DateTime? pickedTime = await showOmniDateTimePicker(
        context: context,
        firstDate: type == CheckInOutControlType.checkIn
            ? selectedDate
            : selectedCheckInDate,
        lastDate: type == CheckInOutControlType.checkIn
            ? selectedDate
            : selectedDate.add(const Duration(days: 1)),
        initialDate: type == CheckInOutControlType.checkIn
            ? selectedCheckInDate
            : selectedCheckOutDate);

    if (pickedTime != null) {
      if (kDebugMode) {
        print(pickedTime);
      } //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedTime =
          DateFormat('dd/MM/yyyy hh:mm a').format(pickedTime);

      //selectedDate = pickedTime;
      //print(formattedDate); //formatted date output using intl package =>  2021-03-16
      //you can implement different kind of Date Format here according to your requirement

      setState(() {
        if (type == CheckInOutControlType.checkIn) {
          selectedCheckInDate = pickedTime;
        } else {
          selectedCheckOutDate = pickedTime;
        }
        int duration =
            selectedCheckOutDate.difference(selectedCheckInDate).inMinutes;
        selectedDuration = duration;
        textFieldController.text =
            formattedTime; //set output date to TextField value.
        durationController.text = duration < 60
            ? Messages.errorDurationMin
            : (duration > 1320
                ? Messages.errorDurationMax
                : CommonFunctions.durationFormat(duration));
      });
    } else {
      if (kDebugMode) {
        print("Date is not selected");
      }
    }
  }

  _durationWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textDuration}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            textColor: selectedDuration < 60
                ? Colors.red
                : selectedDuration > 1320
                    ? Colors.red
                    : Colors.black,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: durationController,
          ),
        )
      ],
    );
  }

  _missingReasonWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textMissingReason}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            maxLength: 300,
            maxLines: 3,
            hintText: Strings.hintReason,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: missingReasonController,
          ),
        )
      ],
    );
  }
}
