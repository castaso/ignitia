import 'package:flutter/material.dart';
import 'package:i_employment/components/dropdown_widget.dart';
import 'package:i_employment/components/toast_widget.dart';
import 'package:i_employment/models/dropdown_model.dart';
import 'package:i_employment/models/leave/leave_model.dart';
import 'package:i_employment/models/leave/user_leave_model.dart';
import 'package:i_employment/utils/common_functions.dart';
import 'package:i_employment/utils/navigation_utils.dart';
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
import '../../view_models/leave_view_model.dart';
import '../menu_page.dart';
import 'leave_page.dart';

class DeleteLeavePage extends StatefulWidget {
  final UserLeaveModel userLeaveModel;
  const DeleteLeavePage({Key? key, required this.userLeaveModel})
      : super(key: key);

  @override
  State<DeleteLeavePage> createState() =>
      _DeleteLeavePageState(this.userLeaveModel);
}

enum CheckInOutControlType { checkIn, checkOut }

class _DeleteLeavePageState extends State<DeleteLeavePage> {
  UserLeaveModel userLeaveModel;
  _DeleteLeavePageState(this.userLeaveModel);

  TextEditingController leaveTypeController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  int selectedDuration = 0;
  int balance = 0;
  String selectedLeaveType="";

  late LeaveViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<LeaveViewModel>(context, listen: false);

    selectedLeaveType = viewModel.dropDownItems.firstWhere((element) => element.id==userLeaveModel.leaveId).name;
    balance = viewModel.leaveSummaryList.firstWhere((element) => element.leaveShortName.toLowerCase()==selectedLeaveType.toLowerCase()).balance;
    selectedStartDate = (userLeaveModel.getStartDate());
    selectedEndDate = (userLeaveModel.getEndDate());
    selectedDuration =
        selectedEndDate.difference(selectedStartDate).inDays+1;

    leaveTypeController.text = selectedLeaveType;
    startDateController.text = DateFormat('dd/MM/yyyy').format(selectedStartDate);
    endDateController.text =
        DateFormat('dd/MM/yyyy').format(selectedEndDate);
    durationController.text = selectedDuration.toString();
    reasonController.text = userLeaveModel.reason;
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<LeaveViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleDeleteLeavePage,
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
                          _leaveTypeWidget(),
                          const SizedBox(
                            height: 20,
                          ),_dateWidget(true),
                          const SizedBox(
                            height: 20,
                          ),
                          _dateWidget(false),
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
                              var isSuccess = await viewModel.deleteUserLeave(userLeaveModel);
                              if (isSuccess) {
                                openNewUI(context, const LeavePage());
                                CustomToast.showSuccessToast(Messages.successRequestSent);
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
            if (viewModel.loading) LoadingPage(msg: Messages.progressInProgress),
            if(viewModel.errorMsg.isNotEmpty)
              ErrorPopupPage(msg: viewModel.errorMsg, onOkPressed: (){
                viewModel.setErrorMsg("");
              },),
          ],
        )
    );
  }

  _leaveTypeWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textLeaveType}: ", textSize: 16),
        ),
        Flexible(
            flex: 70,
            child: CustomTextField(
              isDisable: true,
              labelText: Strings.hintLeaveType,
              hintText: Strings.hintLeaveType,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              textEditingController: leaveTypeController,
            )
        )
      ],
    );
  }

  _dateWidget(bool isStart) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${ isStart ? Strings.textFrom : Strings.textTo}: ", textSize: 16),
        ),
        Flexible(
            flex: 70,
            child: CustomTextField(
              isDisable: true,
              labelText: Strings.hintDate,
              hintText: Strings.hintDate,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              textEditingController: isStart ? startDateController : endDateController,

            ))
      ],
    );
  }

  _getFirstDate() {
    var date = DateTime.now();
    if (date.day > 25) {
      return DateTime(date.year, date.month, 26);
    } else {
      return DateTime(date.year, date.month - 1, 26);
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
            textColor: selectedDuration < 1
                ? Colors.red
                : selectedDuration > 10 || selectedDuration >balance
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
            isDisable:true,
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
