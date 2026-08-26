import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:i_employment/components/error_popup_widget.dart';
import 'package:i_employment/components/loading_dialog_widget.dart';
import 'package:i_employment/components/toast_widget.dart';
import 'package:i_employment/models/employee/employee_contact_info_model.dart';
import 'package:provider/provider.dart';

import '../../components/custom_text_control.dart';
import '../../components/loading_widget.dart';
import '../../models/employee/employee_model.dart';
import '../../utils/constants.dart';
import '../../utils/message.dart';
import '../../utils/string.dart';
import '../../view_models/employee_view_model.dart';
import '../menu_page.dart';

class EmployeeDetailPage extends StatefulWidget {
  final EmployeeModel employeeModel;
  final EmployeeContactInfoModel? contactInfoModel;
  const EmployeeDetailPage(
      {Key? key, required this.employeeModel, this.contactInfoModel})
      : super(key: key);

  @override
  State<EmployeeDetailPage> createState() =>
      _EmployeeDetailPageState(this.employeeModel, this.contactInfoModel);
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  EmployeeModel employeeModel;
  final EmployeeContactInfoModel? contactInfoModel;
  _EmployeeDetailPageState(this.employeeModel, this.contactInfoModel);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<EmployeeViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: const Text(Strings.titleEmployeeDetailPage),
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
                          _fieldWidget(Strings.textEmployeeId, employeeModel.employeeId),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textEmployeeName, employeeModel.employeeName),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textDesignation, employeeModel.designation),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textCellNo, employeeModel.cellNo ?? ""),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textSecondCellNo, contactInfoModel != null ? (contactInfoModel!.secondCellNo ?? "") : ""),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textEmail, employeeModel.email),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textPersonalEmail, contactInfoModel != null ? (contactInfoModel!.personalEmail ?? "") : ""),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textNID, employeeModel.nid ?? ""),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidgetMultiLine(Strings.textPresentAddress, employeeModel.presentAddress ?? ""),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidgetMultiLine(Strings.textPermanentAddress, contactInfoModel != null ? (contactInfoModel!.permanentAddress ?? "") : ""),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textFatherName, contactInfoModel != null ? (contactInfoModel!.fatherName ?? "") : ""),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textFatherCellNo, contactInfoModel != null ? (contactInfoModel!.fatherCellNo ?? "") : ""),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textMotherName, contactInfoModel != null ? (contactInfoModel!.motherName ?? "") : ""),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textMotherCellNo, contactInfoModel != null ? (contactInfoModel!.motherCellNo ?? "") : ""),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textSecondaryContactName, contactInfoModel != null ? (contactInfoModel!.secondaryContactName ?? "") : ""),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textSecondaryContactCellNo, contactInfoModel != null ? (contactInfoModel!.secondaryContactCell ?? "") : ""),
                          const SizedBox(
                            height: 20,
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.black,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _fieldWidget(Strings.textAttendanceLocationType, employeeModel.getAttendanceLocationAsString()),
                          if (employeeModel.isHomeBasedAttendance) ...[
                            const SizedBox(
                              height: 20,
                            ),
                            _fieldWidget(Strings.textHomeLatitude, employeeModel.homeLatitude != null ? "${employeeModel.homeLatitude}" : ""),
                            const SizedBox(
                              height: 20,
                            ),
                            _fieldWidget(Strings.textHomeLongitude, employeeModel.homeLongitude != null ? "${employeeModel.homeLongitude}" : ""),
                            const SizedBox(
                              height: 20,
                            ),
                            _fieldWidget(Strings.textHomeRadiusMeters, employeeModel.homeRadiusMeters != null ? "${employeeModel.homeRadiusMeters}" : ""),
                          ],

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if(viewModel.loading) LoadingPage(
              msg: Messages.progressInProgress,
            ),
            if(viewModel.errorMsg.isNotEmpty)
             ErrorPopupPage(msg: viewModel.errorMsg, onOkPressed: (){
               viewModel.setErrorMsg("");
             },)
          ],
        ));
  }

  _fieldWidget(String label, String value) {
    return CustomTextControl(
      labelText: label,
      defaultValue: value,
      readOnly: true,
      leftFlex: 30,
      rightFlex: 70,
    );
  }

  _fieldWidgetMultiLine(String label, String value) {
    return CustomTextControl(
      labelText: label,
      defaultValue: value,
      readOnly: true,
      minLines: 2,
      maxLines: 3,
      leftFlex: 30,
      rightFlex: 70,
    );
  }
}
