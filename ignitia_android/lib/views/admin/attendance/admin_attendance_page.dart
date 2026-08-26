import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/custom_date_control.dart';
import 'package:i_employment/components/dropdown_widget.dart';
import 'package:i_employment/components/loading_widget.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/message.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/view_models/employee_view_model.dart';
import 'package:i_employment/views/attendance/edit_attendance_page.dart';
import 'package:intl/intl.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:provider/provider.dart';

import '../../../components/app_bar_widget.dart';
import '../../../components/error_popup_widget.dart';
import '../../../components/textview_widget.dart';
import '../../../models/attendance/user_attendance_summary_model.dart';
import '../../../models/dropdown_model.dart';
import '../../../utils/common_functions.dart';
import '../../../utils/constants.dart';
import '../../../view_models/attendance_view_model.dart';
import '../../menu_page.dart';

class AdminAttendancePage extends StatefulWidget {
  const AdminAttendancePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdminAttendancePageState();
}

class _AdminAttendancePageState extends State<AdminAttendancePage> {
  GlobalKey key = GlobalKey();

  DateTime selectedToDate = DateTime.now();
  DateTime selectedFromDate = DateTime.now();
  int selectedEmployeeId = 0;

  late AttendanceViewModel viewModel;
  late final TrinaGridStateManager stateManager;
  late EmployeeViewModel employeeViewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<AttendanceViewModel>(context, listen: false);
    employeeViewModel = Provider.of<EmployeeViewModel>(context, listen: false);
    Future.delayed(Duration.zero, () async {
      await employeeViewModel.getEmployeeList();

      viewModel.attendanceList.clear();
      viewModel.setUserAttendanceSummaryModel(null);

      stateManager.removeAllRows(notify: true);
      stateManager.setShowLoading(false, notify: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    AttendanceViewModel viewModel = context.watch<AttendanceViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleAtttendancePage,
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
                          _attendanceSection(mediaSize.width > webWidth)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (viewModel.loading)
              LoadingPage(
                msg: Messages.progressInProgress,
              ),
            if (viewModel.errorMsg.isNotEmpty)
              ErrorPopupPage(
                msg: viewModel.errorMsg,
                onOkPressed: () {
                  viewModel.setErrorMsg("");
                },
              ),
          ],
        ));
  }

  _attendanceSection(bool isWeb) {
    return Column(
      children: [
        isWeb ? _datePickerSectionWeb() : _datePickerSectionMobile(),
        const SizedBox(
          height: 10,
        ),
        const Divider(
          height: 1,
          color: Colors.black,
        ),
        _getTableForAttendanceSummary(),
        const SizedBox(
          height: 10,
        ),
        Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(4), bottom: Radius.zero),
                color: buttonDisableBgColor),
            child: TitleTextView(
              Strings.titleAttendanceDetail,
              textSize: 17,
            )),
        _getTableForAttendanceDetail()
      ],
    );
  }

  _datePickerSectionWeb() {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            flex: 24,
            child: DropDown(employeeViewModel.dropDownItems, null,
                Strings.hintEmployeeSelection, true, (DropDownModel? value) {
              selectedEmployeeId = value == null ? 0 : value.id;
            })),
        SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 24,
          child: Container(
            width: double.infinity,
            child: CustomDateControl(
              labelText: "${Strings.textFrom}: ",
              firstDate: DateTime(2021),
              lastDate: DateTime(2121),
              fixedWidth: 130,
              defulatDate: selectedFromDate,
              defaultFormat: "dd/MM/yy",
              onSelected: (value) {
                selectedFromDate = value;
              },
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 24,
          child: CustomDateControl(
            labelText: "${Strings.textTo}: ",
            firstDate: DateTime(2021),
            lastDate: DateTime(2121),
            fixedWidth: 130,
            defulatDate: selectedToDate,
            defaultFormat: "dd/MM/yy",
            onSelected: (value) {
              selectedToDate = value;
            },
          ),
        ),
        Flexible(
          flex: 10,
          child: Center(
            child: Ink(
              padding: const EdgeInsets.fromLTRB(2, 2, 0, 2),
              decoration: BoxDecoration(
                  color: kPrimaryLightColor,
                  borderRadius: BorderRadius.circular(4)),
              child: InkWell(
                onTap: () {
                  _getData();
                },
                child: const Icon(
                  Icons.arrow_forward,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _datePickerSectionMobile() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 1,
                child: DropDown(
                    employeeViewModel.dropDownItems,
                    null,
                    Strings.hintEmployeeSelection,
                    true, (DropDownModel? value) {
                  selectedEmployeeId = value == null ? 0 : value.id;
                })),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 40,
              child: Container(
                width: double.infinity,
                child: CustomDateControl(
                  labelText: "${Strings.textFrom}: ",
                  firstDate: DateTime(2021),
                  lastDate: DateTime(2121),
                  fixedWidth: 130,
                  defulatDate: selectedFromDate,
                  defaultFormat: "dd/MM/yy",
                  onSelected: (value) {
                    selectedFromDate = value;
                  },
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 40,
              child: CustomDateControl(
                labelText: "${Strings.textTo}: ",
                firstDate: DateTime(2021),
                lastDate: DateTime(2121),
                fixedWidth: 130,
                defulatDate: selectedToDate,
                defaultFormat: "dd/MM/yy",
                onSelected: (value) {
                  selectedToDate = value;
                },
              ),
            ),
            Flexible(
              flex: 10,
              child: Center(
                child: Ink(
                  padding: const EdgeInsets.fromLTRB(2, 2, 0, 2),
                  decoration: BoxDecoration(
                      color: kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(4)),
                  child: InkWell(
                    onTap: () {
                      _getData();
                    },
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 25.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _getData(){
    viewModel
        .getAttendanceList(selectedFromDate, selectedToDate, selectedEmployeeId)
        .then((value) {
      TrinaGridStateManager.initializeRowsAsync(
        _getTableColumnsForAttendanceDetail(),
        _getTableRowsForAttendanceDetail(),
      ).then((value) {
        if (stateManager.refRows.isEmpty) {
          final newRows = stateManager.getNewRows(count: 1);
          stateManager.refRows.add(newRows.first);
        }
        stateManager.removeAllRows(notify: true);
        stateManager.refRows
            .addAll(FilteredList(initialList: value));
        stateManager.setEditing(false);
        stateManager.setAutoEditing(false);
        stateManager.setShowColumnFilter(true);
        stateManager.setShowLoading(false, notify: true);
      });
    });
  }

  _getTableForAttendanceSummary() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowHeight: 30,
            dividerThickness: 1,
            columnSpacing: 20,
            dataRowHeight: 30,
            headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.grey.shade300),
            showBottomBorder: true,
            columns: const [
              DataColumn(label: Text(Strings.colHeaderTD)),
              DataColumn(label: Text(Strings.colHeaderWH)),
              DataColumn(label: Text(Strings.colHeaderPD)),
              DataColumn(label: Text(Strings.colHeaderLE)),
              DataColumn(label: Text(Strings.colHeaderAD)),
              DataColumn(label: Text(Strings.colHeaderLT)),
              DataColumn(
                  label: Text(
                Strings.colHeaderOT,
                textAlign: TextAlign.center,
              )),
            ],
            rows: _getTableRowsForAttendanceSummary(),
          ),
        ),
      ),
    );
  }

  _getTableRowsForAttendanceSummary() {
    List<UserAttendanceSummaryModel> list = [];
    if (viewModel.userAttendanceSummaryModel != null) {
      list.add(viewModel.userAttendanceSummaryModel!);
    }
    return list // Loops through dataColumnText, each iteration assigning the value to element
        .asMap()
        .entries
        .map(
          ((element) => DataRow(
                color: MaterialStateColor.resolveWith(
                  (states) {
                    if (element.key % 2 == 0) {
                      return Colors.white;
                    } else {
                      return Colors.grey.shade100;
                    }
                  },
                ),
                cells: <DataCell>[
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Text(
                        element.value.total_days.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                      ))), //Extracting from Map element the value
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Text(
                        textAlign: TextAlign.center,
                        element.value.weekend_holiday.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                      ))),
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Text(
                        element.value.present_days.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        softWrap: true,
                      ))),
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Text(
                        element.value.leave_days.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                      ))),
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Text(
                        (element.value.getAbsentDays()).toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                      ))),
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Text(
                        element.value.late_days.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                      ))),
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Text(
                        CommonFunctions.durationFormat(
                            element.value.overtime_duration),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                      ))),
                ],
              )),
        )
        .toList();
  }

  _getGridHeight() {
    if (key.currentContext != null) {
      RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
      Offset position =
          box.localToGlobal(Offset.zero); //this is global position
      double y = position.dy + 40;
      return (MediaQuery.of(context).size.height - y) < 300
          ? 300.0
          : MediaQuery.of(context).size.height - y;
    } else {
      return 300.0;
    }
  }

  _getTableForAttendanceDetail() {
    return SizedBox(
      key: key,
      width: double.infinity,
      height: _getGridHeight(),
      child: TrinaGrid(
        columns: _getTableColumnsForAttendanceDetail(),
        rows: _getTableRowsForAttendanceDetail(),
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
          stateManager.setEditing(false);
          stateManager.setShowLoading(false);
        },
        onChanged: (TrinaGridOnChangedEvent event) {
          stateManager.notifyListeners();
          if (kDebugMode) {
            print(event);
          }
        },
        configuration: const TrinaGridConfiguration(
            style: TrinaGridStyleConfig(
                evenRowColor: buttonDisableBgColor,
                rowHeight: 30,
                cellTextStyle: TextStyle(color: Colors.black))),
      ),
    );
  }

  _getTableColumnsForAttendanceDetail() {
    List<TrinaColumn> columns = <TrinaColumn>[
      TrinaColumn(
        title: Strings.colHeaderRequest,
        field: 'id',
        width: 80,
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        enableSorting: false,
        enableFilterMenuItem: false,
        frozen: TrinaColumnFrozen.start,
        type: TrinaColumnType.text(),
        renderer: (rendererContext) {
          return Row(
            children: [
              rendererContext.row.cells["approval_status"]?.value
                          .toString()
                          .toLowerCase() ==
                      Strings.statusApproved.toLowerCase()
                  ? SizedBox(
                      width: 5,
                    )
                  : IconButton(
                      icon: Icon(
                        rendererContext.row.cells["approval_status"]?.value
                                    .toString()
                                    .trim()
                                    .length ==
                                0
                            ? (rendererContext.cell.value == 0
                                ? Icons.add_outlined
                                : Icons.mode_edit_outline_sharp)
                            : Icons.mode_edit_outline_sharp,
                      ),
                      onPressed: () {
                        var attendance = viewModel.attendanceList.firstWhere(
                            (element) =>
                                element.id == rendererContext.cell.value);
                        if (attendance.id == 0) {
                          String? date = rendererContext
                              .row.cells["date"]?.value
                              .toString();
                          DateTime dt = DateFormat("dd-MM-yyyy").parse(date!);
                          attendance.dateTimeUnformated =
                              DateFormat("yyyy-MM-ddTHH:mm:ss").format(dt);
                        }
                        openNewUI(
                            context,
                            EditAttendancePage(
                              attendanceModel: attendance,
                            ));
                      },
                      iconSize: 18,
                      color: kPrimaryColor,
                      padding: const EdgeInsets.all(0),
                    ),
            ],
          );
        },
      ),
      TrinaColumn(
        title: Strings.colHeaderDate,
        field: 'date',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        frozen: TrinaColumnFrozen.start,
        width: 110,
        type: TrinaColumnType.date(
            defaultValue: DateTime.now(),
            format: 'dd-MM-yyyy',
            applyFormatOnInit: true),
      ),
      TrinaColumn(
        title: Strings.colHeaderName,
        field: 'employee_name',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        frozen: TrinaColumnFrozen.start,
        width: 160,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
          title: Strings.colHeaderStatus,
          field: 'status',
          enableAutoEditing: false,
          enableEditingMode: false,
          enableContextMenu: false,
          width: 100,
          textAlign: TrinaColumnTextAlign.center,
          type: TrinaColumnType.text(),
          renderer: (rendererContext) {
            var status = rendererContext.cell.value.toString();
            var checkOut = rendererContext.row.cells["check_out"]?.value;

            return Text(
              rendererContext.cell.value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: status.toLowerCase() == Strings.statusA.toLowerCase()
                    ? Colors.red
                    : (checkOut == "" &&
                            status.toLowerCase() !=
                                Strings.statusWH.toLowerCase()
                        ? Colors.orange
                        : Colors.black),
                fontWeight: FontWeight.bold,
              ),
            );
          }),
      TrinaColumn(
        title: Strings.colHeaderCheckIn,
        field: 'check_in',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 110,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.colHeaderCheckOut,
        field: 'check_out',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 120,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.colHeaderOvertimes,
        field: 'overtime',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        width: 110,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: '${Strings.colHeaderApproved}?',
        field: 'approval_status',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        width: 120,
        type: TrinaColumnType.text(),
      ),
    ];

    return columns;
  }

  _getTableRowsForAttendanceDetail() {
    List<TrinaRow> rows = viewModel.attendanceList
        .asMap()
        .entries
        .map((e) => TrinaRow(cells: {
              'id': TrinaCell(value: e.value.id),
              'date': TrinaCell(value: e.value.getDateTime()),
              'employee_name': TrinaCell(value: e.value.employeeName),
              'status': TrinaCell(value: e.value.status),
              'check_in': TrinaCell(value: e.value.getCheckInAsString()),
              'check_out': TrinaCell(value: e.value.getCheckOutAsString()),
              'overtime': TrinaCell(
                  value:
                      CommonFunctions.durationFormat(e.value.overtimeMinutes)),
              'approval_status': TrinaCell(value: e.value.approvalStatus),
            }))
        .toList();

    return rows;
  }
}
