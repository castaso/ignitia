import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/toast_widget.dart';
import 'package:i_employment/models/overtime/overtime_model.dart';
import 'package:i_employment/utils/common_functions.dart';
import 'package:i_employment/utils/message.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/utils/string.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../components/app_bar_widget.dart';
import '../../components/button_widget.dart';
import '../../components/custom_date_time_control.dart';
import '../../components/custom_textfiled.dart';
import '../../components/error_popup_widget.dart';
import '../../components/loading_widget.dart';
import '../../components/textview_widget.dart';
import '../../utils/constants.dart';
import '../../view_models/overtime_view_model.dart';
import '../menu_page.dart';
import 'overtime_list_page.dart';

class EditOvertimePage extends StatefulWidget {
  final OvertimeModel overtimeModel;
  const EditOvertimePage({Key? key, required this.overtimeModel})
      : super(key: key);

  @override
  State<EditOvertimePage> createState() =>
      _EditOvertimePageState(this.overtimeModel);
}

enum CheckInOutControlType { checkIn, checkOut }

class _EditOvertimePageState extends State<EditOvertimePage> {
  OvertimeModel overtimeModel;
  _EditOvertimePageState(this.overtimeModel);

  TextEditingController dateController = TextEditingController();
  TextEditingController checkInDateController = TextEditingController();
  TextEditingController checkOutDateController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime selectedCheckInDate = DateTime.now();
  DateTime selectedCheckOutDate = DateTime.now();
  int selectedDuration = 0;

  late OvertimeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<OvertimeViewModel>(context, listen: false);

    selectedDate = (overtimeModel.getDateTime());
    selectedCheckInDate = (overtimeModel.getCheckIn());
    selectedCheckOutDate = (overtimeModel.getCheckOut());
    selectedDuration =
        selectedCheckOutDate.difference(selectedCheckInDate).inMinutes;

    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    checkInDateController.text =
        DateFormat('dd/MM/yyyy hh:mm a').format(selectedCheckInDate);
    checkOutDateController.text =
        DateFormat('dd/MM/yyyy hh:mm a').format(selectedCheckOutDate);
    durationController.text = CommonFunctions.durationFormat(selectedDuration);
    reasonController.text = overtimeModel.reason ?? "";
  }

  @override
  Widget build(BuildContext context) {
    OvertimeViewModel viewModel = context.watch<OvertimeViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleEditOvertimePage,
        ),
        body: Stack(children: [
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
                        _checkInWidget(),
                        const SizedBox(
                          height: 20,
                        ),
                        // _timeWidget(checkOutDateController, "dd/MM/yyyy hh:mm a",
                        //     CheckInOutControlType.checkOut),
                        _checkOutWidget(),
                        const SizedBox(
                          height: 20,
                        ),
                        _durationWidget(),
                        const SizedBox(
                          height: 20,
                        ),
                        _reasonWidget(),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomButton(
                          onTap: () async {
                            if (viewModel.loading) return;
                            overtimeModel.overtimeDateUnformated =
                                DateFormat("yyyy-MM-ddTHH:mm:ss").format(selectedDate);
                            overtimeModel.checkInUnformated =
                                DateFormat("yyyy-MM-ddTHH:mm:ss")
                                    .format(selectedCheckInDate);
                            overtimeModel.checkOutUnformated =
                                DateFormat("yyyy-MM-ddTHH:mm:ss")
                                    .format(selectedCheckOutDate);
                            overtimeModel.reason = reasonController.text;
                            var isSuccess =
                                await viewModel.updateOvertime(overtimeModel);
                            if (isSuccess) {
                              openNewUI(context, const OvertimeListPage());
                              CustomToast.showSuccessToast(Messages.successRequestSent);
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
          if (viewModel.loading) LoadingPage(msg: Messages.progressInProgress),
          if(viewModel.errorMsg.isNotEmpty)
            ErrorPopupPage(msg: viewModel.errorMsg, onOkPressed: (){
              viewModel.setErrorMsg("");
            },),
        ]));
  }

  _checkInWidget() {
    return CustomDateTimeControl(
      labelText: "${Strings.textCheckIn}: ",
      firstDate: CommonFunctions.getMonthFirstDate(),
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
      firstDate: CommonFunctions.getMonthFirstDate(),
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
                : selectedDuration > 720
                    ? Colors.red
                    : Colors.black,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: durationController,
          ),
        )
      ],
    );
  }

  _reasonWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textReason}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            maxLength: 300,
            maxLines: 3,
            hintText: Strings.hintReason,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: reasonController,
          ),
        )
      ],
    );
  }
}
