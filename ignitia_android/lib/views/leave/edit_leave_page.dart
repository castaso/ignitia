import 'package:flutter/foundation.dart';
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

class EditLeavePage extends StatefulWidget {
  final UserLeaveModel userLeaveModel;
  const EditLeavePage({Key? key, required this.userLeaveModel})
      : super(key: key);

  @override
  State<EditLeavePage> createState() =>
      _EditLeavePageState(this.userLeaveModel);
}

enum CheckInOutControlType { checkIn, checkOut }

class _EditLeavePageState extends State<EditLeavePage> {
  UserLeaveModel userLeaveModel;
  _EditLeavePageState(this.userLeaveModel);

  TextEditingController reasonController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  int selectedDuration = 0;
  int balance = 0;
  DropDownModel? selectedLeaveType;

  late LeaveViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<LeaveViewModel>(context, listen: false);

    selectedLeaveType = viewModel.dropDownItems.firstWhere((element) => element.id==userLeaveModel.leaveId);
    balance = viewModel.leaveSummaryList.firstWhere((element) => element.leaveShortName.toLowerCase()==selectedLeaveType!.name.toLowerCase()).balance;
    selectedStartDate = (userLeaveModel.getStartDate());
    selectedEndDate = (userLeaveModel.getEndDate());
    selectedDuration =
        selectedEndDate.difference(selectedStartDate).inDays+1;

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
          title: Strings.titleEditLeavePage,
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
                              userLeaveModel.leaveId = selectedLeaveType != null ? selectedLeaveType!.id : 0;
                              userLeaveModel.startDateUnformated =
                                  DateFormat("yyyy-MM-ddT00:00:00").format(selectedStartDate);
                              userLeaveModel.endDateUnformated =
                                  DateFormat("yyyy-MM-ddT00:00:00")
                                      .format(selectedEndDate);
                              userLeaveModel.reason = reasonController.text;
                              var isSuccess = await viewModel.updateUserLeave(userLeaveModel);
                              if (isSuccess) {
                                openNewUI(context, const LeavePage());
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
            child: DropDown(viewModel.dropDownItems, selectedLeaveType, Strings.hintLeaveType, false, (DropDownModel? data){
              var summary = viewModel.leaveSummaryList.firstWhere((element) => element.leaveShortName.toLowerCase() == data!.name.toLowerCase());
              setState(() {
                selectedLeaveType = data;
                balance = summary.balance;
              });
            })
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
              rightIcon: const Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: Colors.black45,
              ),
              onTap: () {
                _openDatePicker(isStart);
              },
            ))
      ],
    );
  }

  _getFirstDate() {
    var date = DateTime.now();
    if (date.day > 26) {
      return DateTime(date.year, date.month, 26);
    } else {
      return DateTime(date.year, date.month - 1, 25);
    }
  }

  _openDatePicker(bool isStart) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? selectedStartDate : selectedEndDate,
      firstDate:
          isStart ? _getFirstDate() : selectedStartDate, //DateTime.now() - not to allow to choose before today.
      lastDate: selectedStartDate.add(Duration(days: 9)),
      builder: (context, child) {
        return calendarTheme(context, child);
      },
    );

    if (pickedDate != null) {
      if(kDebugMode) {print(pickedDate);} //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      if(isStart){
        selectedStartDate = pickedDate;
        selectedEndDate = selectedEndDate.difference(selectedStartDate).inDays>9 ? selectedStartDate : selectedEndDate;
      }else{
        selectedEndDate = pickedDate;
      }
      selectedDuration =
          selectedEndDate.difference(selectedStartDate).inDays+1;

      if(kDebugMode) {print(
          formattedDate);} //formatted date output using intl package =>  2021-03-16
      //you can implement different kind of Date Format here according to your requirement

      setState(() {

          startDateController.text =
              DateFormat('dd/MM/yyyy').format(selectedStartDate);

          endDateController.text =
              DateFormat('dd/MM/yyyy').format(selectedEndDate);

       
        durationController.text =selectedDuration.toString();
      });
    } else {
      if(kDebugMode) {print("Date is not selected");}
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
