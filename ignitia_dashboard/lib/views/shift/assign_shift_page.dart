import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/dropdown_widget.dart';
import 'package:ignitia_dashboard/components/toast_widget.dart';
import 'package:ignitia_dashboard/models/dropdown_model.dart';
import 'package:ignitia_dashboard/models/employee/employee_model.dart';
import 'package:ignitia_dashboard/models/shift/employee_shift_assign_model.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar_widget.dart';
import '../../components/button_widget.dart';
import '../../components/custom_date_control.dart';
import '../../components/error_popup_widget.dart';
import '../../components/loading_widget.dart';
import '../../components/textview_widget.dart';
import '../../utils/constants.dart';
import '../../utils/message.dart';
import '../../utils/string.dart';
import '../../view_models/employee_view_model.dart';
import '../../view_models/shift_view_model.dart';
import '../menu_page.dart';
import 'shift_page.dart';

class AssignShiftPage extends StatefulWidget {
  const AssignShiftPage({Key? key}) : super(key: key);

  @override
  State<AssignShiftPage> createState() => _AssignShiftPageState();
}

class _AssignShiftPageState extends State<AssignShiftPage> {
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  DropDownModel? selectedShift;
  List<int> selectedEmployeeIds = [];

  late ShiftViewModel shiftViewModel;
  late EmployeeViewModel employeeViewModel;

  @override
  void initState() {
    super.initState();
    shiftViewModel = Provider.of<ShiftViewModel>(context, listen: false);
    employeeViewModel = Provider.of<EmployeeViewModel>(context, listen: false);
    if (shiftViewModel.shiftList.isEmpty) {
      shiftViewModel.getShiftList();
    }
    if (employeeViewModel.employeeList.isEmpty) {
      employeeViewModel.getEmployeeList();
    }
  }

  @override
  Widget build(BuildContext context) {
    var shiftViewModel = context.watch<ShiftViewModel>();
    var employeeViewModel = context.watch<EmployeeViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    List<DropDownModel> shiftDropDownItems = shiftViewModel.shiftList
        .map((e) => DropDownModel(e.id, e.shiftName))
        .toList();

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleAssignShiftPage,
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
                          _shiftWidget(shiftDropDownItems),
                          const SizedBox(height: 20),
                          _dateWidget(true),
                          const SizedBox(height: 20),
                          _dateWidget(false),
                          const SizedBox(height: 20),
                          _employeeWidget(employeeViewModel.employeeList),
                          const SizedBox(height: 20),
                          CustomButton(
                            onTap: () async {
                              if (shiftViewModel.loading) return;
                              var assignModel = EmployeeShiftAssignModel(
                                  shiftId: selectedShift?.id ?? 0,
                                  startDate:
                                      DateFormat("yyyy-MM-dd").format(selectedStartDate),
                                  endDate:
                                      DateFormat("yyyy-MM-dd").format(selectedEndDate),
                                  employeeIds: selectedEmployeeIds);
                              var isSuccess =
                                  await shiftViewModel.assignShift(assignModel);
                              if (isSuccess) {
                                openNewUI(context, const ShiftPage());
                                CustomToast.showSuccessToast(
                                    Messages.successShiftAssign);
                              }
                            },
                            text: Strings.btnTextAssign,
                            textSize: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (shiftViewModel.loading || employeeViewModel.loading)
              LoadingPage(msg: Messages.progressInProgress),
            if(shiftViewModel.errorMsg.isNotEmpty)
              ErrorPopupPage(msg: shiftViewModel.errorMsg, onOkPressed: (){
                shiftViewModel.setErrorMsg("");
              },),
          ],
        )
    );
  }

  _shiftWidget(List<DropDownModel> shiftDropDownItems) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textShiftName}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: DropDown(
              shiftDropDownItems,
              selectedShift,
              Strings.hintShiftSelection,
              true,
              (DropDownModel? data) {
            setState(() {
              selectedShift = data;
            });
          }),
        )
      ],
    );
  }

  _dateWidget(bool isStart) {
    return CustomDateControl(
      labelText: "${isStart ? Strings.textFrom : Strings.textTo}: ",
      firstDate: DateTime(2021),
      lastDate: DateTime(2121),
      fixedWidth: 160,
      defulatDate: isStart ? selectedStartDate : selectedEndDate,
      defaultFormat: "dd/MM/yyyy",
      onSelected: (value) {
        setState(() {
          if (isStart) {
            selectedStartDate = value;
            if (selectedEndDate.isBefore(selectedStartDate)) {
              selectedEndDate = selectedStartDate;
            }
          } else {
            selectedEndDate = value;
          }
        });
      },
    );
  }

  _employeeWidget(List<EmployeeModel> employeeList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleTextView("${Strings.textAssignedTo}: ", textSize: 16),
        const SizedBox(height: 10),
        if (employeeList.isEmpty)
          TitleTextView(Strings.hintEmployeeSelectionForAssign,
              textColor: Colors.grey)
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: employeeList.map((e) {
              var isSelected = selectedEmployeeIds.contains(e.id);
              return FilterChip(
                label: Text(e.employeeName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedEmployeeIds.add(e.id);
                    } else {
                      selectedEmployeeIds.remove(e.id);
                    }
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }
}
