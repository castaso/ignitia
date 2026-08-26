import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/toast_widget.dart';
import 'package:ignitia_dashboard/models/shift/shift_model.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar_widget.dart';
import '../../components/button_widget.dart';
import '../../components/custom_textfiled.dart';
import '../../components/error_popup_widget.dart';
import '../../components/loading_widget.dart';
import '../../components/textview_widget.dart';
import '../../utils/constants.dart';
import '../../utils/message.dart';
import '../../utils/string.dart';
import '../../view_models/shift_view_model.dart';
import '../menu_page.dart';
import 'shift_page.dart';

class DeleteShiftPage extends StatefulWidget {
  final ShiftModel shiftModel;
  const DeleteShiftPage({Key? key, required this.shiftModel})
      : super(key: key);

  @override
  State<DeleteShiftPage> createState() =>
      _DeleteShiftPageState(this.shiftModel);
}

class _DeleteShiftPageState extends State<DeleteShiftPage> {
  ShiftModel shiftModel;
  _DeleteShiftPageState(this.shiftModel);

  TextEditingController nameController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  late ShiftViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ShiftViewModel>(context, listen: false);

    nameController.text = shiftModel.shiftName;
    startTimeController.text = shiftModel.getStartTimeAsString();
    endTimeController.text = shiftModel.getEndTimeAsString();
    durationController.text = shiftModel.getTotalHoursAsString();
    statusController.text = shiftModel.getStatusAsString();
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<ShiftViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleDeleteShiftPage,
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
                          _nameWidget(),
                          const SizedBox(height: 20),
                          _timeWidget(true),
                          const SizedBox(height: 20),
                          _timeWidget(false),
                          const SizedBox(height: 20),
                          _durationWidget(),
                          const SizedBox(height: 20),
                          _statusWidget(),
                          const SizedBox(height: 20),
                          CustomButton(
                            onTap: () async {
                              if (viewModel.loading) return;
                              var isSuccess =
                                  await viewModel.deleteShift(shiftModel.id);
                              if (isSuccess) {
                                openNewUI(context, const ShiftPage());
                                CustomToast.showSuccessToast(
                                    Messages.successShiftDelete);
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

  _nameWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textShiftName}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            hintText: Strings.hintShiftName,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: nameController,
          ),
        )
      ],
    );
  }

  _timeWidget(bool isStart) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${isStart ? Strings.textStartTime : Strings.textEndTime}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController:
                isStart ? startTimeController : endTimeController,
          ),
        )
      ],
    );
  }

  _durationWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textShiftDuration}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: durationController,
          ),
        )
      ],
    );
  }

  _statusWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textShiftStatus}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: statusController,
          ),
        )
      ],
    );
  }
}
