import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/dropdown_widget.dart';
import 'package:ignitia_dashboard/components/toast_widget.dart';
import 'package:ignitia_dashboard/models/dropdown_model.dart';
import 'package:ignitia_dashboard/models/shift/shift_model.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar_widget.dart';
import '../../components/button_widget.dart';
import '../../components/custom_textfiled.dart';
import '../../components/custom_time_control.dart';
import '../../components/error_popup_widget.dart';
import '../../components/loading_widget.dart';
import '../../components/textview_widget.dart';
import '../../utils/constants.dart';
import '../../utils/message.dart';
import '../../utils/string.dart';
import '../../view_models/shift_view_model.dart';
import '../menu_page.dart';
import 'shift_page.dart';

class EditShiftPage extends StatefulWidget {
  final ShiftModel shiftModel;
  const EditShiftPage({Key? key, required this.shiftModel}) : super(key: key);

  @override
  State<EditShiftPage> createState() =>
      _EditShiftPageState(this.shiftModel);
}

class _EditShiftPageState extends State<EditShiftPage> {
  ShiftModel shiftModel;
  _EditShiftPageState(this.shiftModel);

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  TimeOfDay selectedStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay selectedEndTime = const TimeOfDay(hour: 18, minute: 0);
  DropDownModel? selectedStatus;

  List<DropDownModel> get statusDropDownItems => [
        DropDownModel(1, Strings.textShiftActive),
        DropDownModel(2, Strings.textShiftInactive),
      ];

  late ShiftViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ShiftViewModel>(context, listen: false);

    nameController.text = shiftModel.shiftName;
    descriptionController.text = shiftModel.description;
    selectedStartTime = _parseTime(shiftModel.startTime);
    selectedEndTime = _parseTime(shiftModel.endTime);
    selectedStatus = statusDropDownItems.firstWhere(
        (element) => element.id == shiftModel.statusId,
        orElse: () => statusDropDownItems.first);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(":");
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<ShiftViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleEditShiftPage,
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
                          _descriptionWidget(),
                          const SizedBox(height: 20),
                          _statusWidget(),
                          const SizedBox(height: 20),
                          CustomButton(
                            onTap: () async {
                              if (viewModel.loading) return;
                              shiftModel.shiftName = nameController.text;
                              shiftModel.startTime = _timeToString(selectedStartTime);
                              shiftModel.endTime = _timeToString(selectedEndTime);
                              shiftModel.description = descriptionController.text;
                              shiftModel.statusId = selectedStatus?.id ?? 1;
                              var isSuccess =
                                  await viewModel.updateShift(shiftModel);
                              if (isSuccess) {
                                openNewUI(context, const ShiftPage());
                                CustomToast.showSuccessToast(
                                    Messages.successRequestSent);
                              }
                            },
                            text: Strings.btnTextSave,
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

  String _timeToString(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
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
            hintText: Strings.hintShiftName,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: nameController,
          ),
        )
      ],
    );
  }

  _timeWidget(bool isStart) {
    return CustomTimeControl(
      labelText: "${isStart ? Strings.textStartTime : Strings.textEndTime}: ",
      hintText: isStart ? Strings.hintStartTime : Strings.hintEndTime,
      defaultTime: isStart ? selectedStartTime : selectedEndTime,
      defaultFormat: "hh:mm a",
      onSelected: (time) {
        setState(() {
          if (isStart) {
            selectedStartTime = time;
          } else {
            selectedEndTime = time;
          }
        });
      },
    );
  }

  _descriptionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textShiftDescription}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            hintText: Strings.hintShiftDescription,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: descriptionController,
            maxLines: 3,
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
          child: DropDown(
              statusDropDownItems,
              selectedStatus,
              Strings.textShiftStatus,
              false,
              (DropDownModel? data) {
            setState(() {
              selectedStatus = data;
            });
          }),
        )
      ],
    );
  }
}
