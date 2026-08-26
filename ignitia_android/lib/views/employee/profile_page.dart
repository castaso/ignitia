import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:i_employment/components/error_popup_widget.dart';
import 'package:i_employment/components/loading_dialog_widget.dart';
import 'package:i_employment/components/toast_widget.dart';
import 'package:i_employment/models/employee/employee_contact_info_model.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/views/employee/employee_edit_page.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar_widget.dart';
import '../../components/button_widget.dart';
import '../../components/custom_text_control.dart';
import '../../components/loading_widget.dart';
import '../../models/employee/employee_model.dart';
import '../../models/employee/profile_model.dart';
import '../../models/toolbar_item_model.dart';
import '../../utils/constants.dart';
import '../../utils/message.dart';
import '../../utils/string.dart';
import '../../view_models/employee_view_model.dart';
import '../menu_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late EmployeeViewModel viewModel;
  Future<ProfileModel>? profile;
  late EmployeeModel employeeModel;
  late EmployeeContactInfoModel? contactInfoModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<EmployeeViewModel>(context, listen: false);
    Future.delayed(Duration.zero, () async {
      setState(() {
        profile = _loadData();
      });
    });
  }

  Future<ProfileModel> _loadData() async {
    employeeModel = await viewModel.getProfile(0);
    contactInfoModel = await viewModel.getContactInfo(0);
    return ProfileModel(employeeModel, contactInfoModel);
  }

  @override
  Widget build(BuildContext context) {
    ToolBarItemModel item =
        ToolBarItemModel(1, const Icon(Icons.edit_outlined), null, () {
      openNewUI(
          context,
          EmployeeEditPage(
            employeeModel: employeeModel,
            contactInfoModel: contactInfoModel,
          ));
    });

    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(title: Strings.titleProfilePage, list: [item]),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
              child: Row(children: [
                mediaSize.width > webWidth
                    ? Flexible(flex: 1, child: MenuPage())
                    : Container(),
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<ProfileModel?>(
                        future: profile,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              var employeeModel = snapshot.data!.employeeInfo;
                              var contactInfoModel = snapshot.data!.contactInfo;
                              return ListView(
                                shrinkWrap: false,
                                children: [
                                  mediaSize.width > webWidth
                                      ? ListTile(
                                          trailing: ElevatedButton(
                                            onPressed: () async {
                                              openNewUI(
                                                  context,
                                                  EmployeeEditPage(
                                                    employeeModel:
                                                        employeeModel,
                                                    contactInfoModel:
                                                        contactInfoModel,
                                                  ));
                                            },
                                            child: Text(
                                              Strings.btnTextEdit,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateColor
                                                        .resolveWith((states) =>
                                                            kPrimaryLightColor)),
                                          ),
                                        )
                                      : Container(),
                                  mediaSize.width > webWidth ? const SizedBox(
                                    height: 20,
                                  ) : Container(),
                                  _fieldWidget(Strings.textEmployeeId,
                                      employeeModel.employeeId),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(Strings.textEmployeeName,
                                      employeeModel.employeeName),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(Strings.textDesignation,
                                      employeeModel.designation),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(Strings.textCellNo,
                                      employeeModel.cellNo ?? ""),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(
                                      Strings.textSecondCellNo,
                                      contactInfoModel != null
                                          ? (contactInfoModel!.secondCellNo
                                                  .toString() ??
                                              "")
                                          : ""),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(
                                      Strings.textEmail, employeeModel.email),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(
                                      Strings.textPersonalEmail,
                                      contactInfoModel != null
                                          ? (contactInfoModel!.personalEmail ??
                                              "")
                                          : ""),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(
                                      Strings.textNID, employeeModel.nid ?? ""),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidgetMultiLine(
                                      Strings.textPresentAddress,
                                      employeeModel.presentAddress ?? ""),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidgetMultiLine(
                                      Strings.textPermanentAddress,
                                      contactInfoModel != null
                                          ? (contactInfoModel!
                                                  .permanentAddress ??
                                              "")
                                          : ""),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(
                                      Strings.textFatherName,
                                      contactInfoModel != null
                                          ? (contactInfoModel!.fatherName ?? "")
                                          : ""),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(
                                      Strings.textFatherCellNo,
                                      contactInfoModel != null
                                          ? (contactInfoModel!.fatherCellNo ??
                                              "")
                                          : ""),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(
                                      Strings.textMotherName,
                                      contactInfoModel != null
                                          ? (contactInfoModel!.motherName ?? "")
                                          : ""),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(
                                      Strings.textMotherCellNo,
                                      contactInfoModel != null
                                          ? (contactInfoModel!.motherCellNo ??
                                              "")
                                          : ""),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(
                                      Strings.textSecondaryContactName,
                                      contactInfoModel != null
                                          ? (contactInfoModel!
                                                  .secondaryContactName ??
                                              "")
                                          : ""),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  _fieldWidget(
                                      Strings.textSecondaryContactCellNo,
                                      contactInfoModel != null
                                          ? (contactInfoModel!
                                                  .secondaryContactCell ??
                                              "")
                                          : ""),
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
                                  _fieldWidget(
                                      Strings.textAttendanceLocationType,
                                      employeeModel
                                          .getAttendanceLocationAsString()),
                                  if (employeeModel
                                      .isHomeBasedAttendance) ...[
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    _fieldWidget(
                                        Strings.textHomeLatitude,
                                        employeeModel.homeLatitude != null
                                            ? "${employeeModel.homeLatitude}"
                                            : ""),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    _fieldWidget(
                                        Strings.textHomeLongitude,
                                        employeeModel.homeLongitude != null
                                            ? "${employeeModel.homeLongitude}"
                                            : ""),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    _fieldWidget(
                                        Strings.textHomeRadiusMeters,
                                        employeeModel.homeRadiusMeters != null
                                            ? "${employeeModel.homeRadiusMeters}"
                                            : ""),
                                  ],
                                ],
                              );
                            }
                          }
                          return LoadingPage(
                            msg: Messages.progressInProgress,
                          );
                        }),
                  ),
                ),
              ]),
            ),
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
