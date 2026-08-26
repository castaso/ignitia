import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/dropdown_widget.dart';
import 'package:ignitia_dashboard/components/toast_widget.dart';
import 'package:ignitia_dashboard/models/dropdown_model.dart';
import 'package:ignitia_dashboard/models/holiday/holiday_model.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/app_bar_widget.dart';
import '../../../components/button_widget.dart';
import '../../../components/calendar_theme.dart';
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

class AddHolidayPage extends StatefulWidget {
  const AddHolidayPage({Key? key}) : super(key: key);

  @override
  State<AddHolidayPage> createState() => _AddHolidayPageState();
}

class _AddHolidayPageState extends State<AddHolidayPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  DropDownModel? selectedHolidayType;

  late HolidayViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<HolidayViewModel>(context, listen: false);

    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();
    startDateController.text = DateFormat('dd/MM/yyyy').format(selectedStartDate);
    endDateController.text = DateFormat('dd/MM/yyyy').format(selectedEndDate);
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<HolidayViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleAddHolidayPage,
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
                          CustomButton(
                            onTap: () async {
                              if (viewModel.loading) return;
                              var holidayModel = HolidayModel(
                                  holidayName: nameController.text,
                                  holidayType: selectedHolidayType != null
                                      ? selectedHolidayType!.name
                                      : "",
                                  startDateUnformated: DateFormat(
                                          "yyyy-MM-ddT00:00:00")
                                      .format(selectedStartDate),
                                  endDateUnformated: DateFormat(
                                          "yyyy-MM-ddT00:00:00")
                                      .format(selectedEndDate));
                              var isSuccess =
                                  await viewModel.addHoliday(holidayModel);
                              if (isSuccess) {
                                openNewUI(context, const HolidayPage());
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
          child: DropDown(
              viewModel.holidayTypeDropDownItems,
              selectedHolidayType,
              Strings.hintHolidayType,
              false,
              (DropDownModel? data) {
            setState(() {
              selectedHolidayType = data;
            });
          }),
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

  _openDatePicker(bool isStart) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? selectedStartDate : selectedEndDate,
      firstDate: isStart
          ? DateTime(DateTime.now().year - 1, 1, 1)
          : selectedStartDate,
      lastDate: isStart
          ? DateTime(DateTime.now().year + 2, 12, 31)
          : selectedEndDate.add(const Duration(days: 30)),
      builder: (context, child) {
        return calendarTheme(context, child);
      },
    );

    if (pickedDate != null) {
      if (isStart) {
        selectedStartDate = pickedDate;
        if (selectedEndDate.isBefore(selectedStartDate)) {
          selectedEndDate = selectedStartDate;
        }
      } else {
        selectedEndDate = pickedDate;
      }
      setState(() {
        startDateController.text =
            DateFormat('dd/MM/yyyy').format(selectedStartDate);
        endDateController.text =
            DateFormat('dd/MM/yyyy').format(selectedEndDate);
      });
    }
  }
}
