import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/toast_widget.dart';
import 'package:ignitia_dashboard/models/holiday/holiday_model.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/app_bar_widget.dart';
import '../../../components/button_widget.dart';
import '../../../components/custom_textfiled.dart';
import '../../../components/error_popup_widget.dart';
import '../../../components/loading_widget.dart';
import '../../../components/textview_widget.dart';
import '../../../utils/constants.dart';
import '../../../utils/message.dart';
import '../../../utils/string.dart';
import '../../../view_models/holiday_view_model.dart';
import '../../menu_page.dart';
import 'holiday_page.dart';

class DeleteHolidayPage extends StatefulWidget {
  final HolidayModel holidayModel;
  const DeleteHolidayPage({Key? key, required this.holidayModel})
      : super(key: key);

  @override
  State<DeleteHolidayPage> createState() =>
      _DeleteHolidayPageState(this.holidayModel);
}

class _DeleteHolidayPageState extends State<DeleteHolidayPage> {
  HolidayModel holidayModel;
  _DeleteHolidayPageState(this.holidayModel);

  TextEditingController nameController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  late HolidayViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<HolidayViewModel>(context, listen: false);

    nameController.text = holidayModel.holidayName;
    typeController.text = holidayModel.holidayType;
    startDateController.text = DateFormat('dd/MM/yyyy')
        .format(holidayModel.getStartDate());
    endDateController.text =
        DateFormat('dd/MM/yyyy').format(holidayModel.getEndDate());
    durationController.text = holidayModel.getTotalDays().toString();
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<HolidayViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleDeleteHolidayPage,
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
                          const SizedBox(
                            height: 20,
                          ),
                          _typeWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          _dateWidget(true),
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
                          CustomButton(
                            onTap: () async {
                              if (viewModel.loading) return;
                              var isSuccess =
                                  await viewModel.deleteHoliday(holidayModel);
                              if (isSuccess) {
                                openNewUI(context, const HolidayPage());
                                CustomToast.showSuccessToast(
                                    Messages.successRequestDelete);
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
          child: TitleTextView("${Strings.textHolidayName}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            hintText: Strings.hintHolidayName,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: nameController,
          ),
        )
      ],
    );
  }

  _typeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textHolidayType}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            hintText: Strings.hintHolidayType,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: typeController,
          ),
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
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: durationController,
          ),
        )
      ],
    );
  }
}
