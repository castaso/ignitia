import 'package:flutter/material.dart';
import 'package:i_employment/components/toast_widget.dart';
import 'package:i_employment/models/overtime/overtime_model.dart';
import 'package:i_employment/utils/common_functions.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/views/overtime/overtime_list_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../components/app_bar_widget.dart';
import '../../components/button_widget.dart';
import '../../components/calendar_theme.dart';
import '../../components/custom_textfiled.dart';
import '../../components/error_popup_widget.dart';
import '../../components/loading_widget.dart';
import '../../components/textview_widget.dart';
import '../../utils/constants.dart';
import '../../utils/message.dart';
import '../../utils/string.dart';
import '../../view_models/overtime_view_model.dart';
import '../menu_page.dart';

class DeleteOvertimePage extends StatefulWidget {
  final OvertimeModel overtimeModel;
  const DeleteOvertimePage({Key? key, required this.overtimeModel})
      : super(key: key);

  @override
  State<DeleteOvertimePage> createState() =>
      _DeleteOvertimePageState(this.overtimeModel);
}

enum CheckInOutControlType { checkIn, checkOut }

class _DeleteOvertimePageState extends State<DeleteOvertimePage> {
  OvertimeModel overtimeModel;
  _DeleteOvertimePageState(this.overtimeModel);

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

    selectedDate = (overtimeModel.getDateTime() ?? DateTime.now());
    selectedCheckInDate = (overtimeModel.getCheckIn() ?? DateTime.now());
    selectedCheckOutDate =
        (overtimeModel.getCheckOut() ?? selectedCheckInDate);
    selectedDuration =
        selectedCheckOutDate.difference(selectedCheckInDate).inMinutes;

    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    checkInDateController.text =
        DateFormat('dd/MM/yyyy hh:mm a').format(selectedCheckInDate);
    checkOutDateController.text = overtimeModel.getCheckOut() == null
        ? ""
        : DateFormat('dd/MM/yyyy hh:mm a').format(selectedCheckOutDate);
    durationController.text = overtimeModel.getCheckOut() == null
        ? ""
        : CommonFunctions.durationFormat(selectedDuration);
    reasonController.text = overtimeModel.reason ?? "";
  }

  @override
  Widget build(BuildContext context) {
    OvertimeViewModel viewModel = context.watch<OvertimeViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleDeleteOvertimePage,
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
                          _timeWidget(checkInDateController, "dd/MM/yyyy hh:mm a",
                              CheckInOutControlType.checkIn),
                          const SizedBox(
                            height: 20,
                          ),
                          _timeWidget(checkOutDateController, "dd/MM/yyyy hh:mm a",
                              CheckInOutControlType.checkOut),
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
                              if(viewModel.loading) return;
                              var isSuccess = await viewModel.deleteOvertime(overtimeModel);
                              if (isSuccess) {
                                openNewUI(context, const OvertimeListPage());
                                CustomToast.showSuccessToast(Messages.successOvertimeDelete);
                              }
                            },
                            text: Strings.btnTextDelete,
                            textSize: 16,
                            buttonColor: Colors.red,
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if(viewModel.loading) LoadingPage(msg: Messages.progressInProgress,),
            if(viewModel.errorMsg.isNotEmpty)
              ErrorPopupPage(msg: viewModel.errorMsg, onOkPressed: (){
                viewModel.setErrorMsg("");
              },),
          ],
        )
    );
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

  _timeWidget(TextEditingController controller, String hintText,
      CheckInOutControlType type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView(
            type == CheckInOutControlType.checkIn ? "${Strings.textCheckIn}: " : "${Strings.textCheckOut}: ",
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
        //_openTimePicker(textEditingController, type);
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
            maxLength: 500,
            maxLines: 5,
            isDisable: true,
            hintText: Strings.hintReason,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: reasonController,
          ),
        )
      ],
    );
  }
}
