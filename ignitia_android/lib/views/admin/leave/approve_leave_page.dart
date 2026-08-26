import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/loading_widget.dart';
import 'package:i_employment/models/leave/leave_summary_model.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/view_models/employee_view_model.dart';
import 'package:i_employment/views/leave/delete_leave_page.dart';
import 'package:i_employment/views/leave/edit_leave_page.dart';
import 'package:intl/intl.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:provider/provider.dart';

import '../../../components/app_bar_widget.dart';
import '../../../components/error_popup_widget.dart';
import '../../../models/employee/employee_model.dart';
import '../../../models/leave/user_leave_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/message.dart';
import '../../../view_models/leave_view_model.dart';
import '../../menu_page.dart';

class ApproveLeavePage extends StatefulWidget {
  const ApproveLeavePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ApproveLeavePageState();
}

class _ApproveLeavePageState extends State<ApproveLeavePage> {
  GlobalKey key = GlobalKey();

  late final TrinaGridStateManager stateManager;
  late List<EmployeeModel> employeeList;

  @override
  void initState() {
    super.initState();
    var viewModel = Provider.of<LeaveViewModel>(context, listen: false);
    var empViewModel = Provider.of<EmployeeViewModel>(context, listen: false);
    Future.delayed(Duration.zero, () async {
      await empViewModel.getEmployeeList();
      employeeList = empViewModel.employeeList;
      stateManager.removeAllRows(notify: true);
      stateManager.setShowLoading(false, notify: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<LeaveViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleApproveLeavePage,
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
                          _leaveSection(viewModel),
                          //
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (viewModel.loading)
              LoadingPage(msg: Messages.progressInProgress),
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

  _leaveSection(LeaveViewModel viewModel) {
    return Column(
      children: [
        _getTableForLeaveSummary(viewModel),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () {
                _loadData(viewModel);
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith(
                      (states) => kPrimaryLightColor)),
              child: Text(
                Strings.btnTextShowDetail,
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ),
        _getTableForLeaveDetail(viewModel)
      ],
    );
  }

  _loadData(LeaveViewModel viewModel) {
    viewModel.getUserLeave(0).then((value) {
      TrinaGridStateManager.initializeRowsAsync(
        _getTableColumnsForLeaveDetail(viewModel),
        _getTableRowsForLeaveDetail(viewModel),
      ).then((value) {
        if (stateManager.refRows.isEmpty) {
          final newRows = stateManager.getNewRows(count: 1);
          stateManager.refRows.add(newRows.first);
        }
        stateManager.removeAllRows(notify: true);
        stateManager.refRows.addAll(FilteredList(initialList: value));
        stateManager.setEditing(false);
        stateManager.setAutoEditing(false);
        stateManager.setShowColumnFilter(true);
        stateManager.setShowLoading(false, notify: true);
      });
    });
  }

  _getTableForLeaveSummary(LeaveViewModel viewModel) {
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
            headingRowColor: MaterialStateColor.resolveWith(
                (states) => Colors.grey.shade300),
            dataRowHeight: 30,
            showBottomBorder: true,
            columns: const [
              DataColumn(label: Text(Strings.colHeaderType)),
              DataColumn(label: Text(Strings.colHeaderEntitlement)),
              DataColumn(label: Text(Strings.colHeaderTaken)),
              DataColumn(label: Text(Strings.colHeaderBalance)),
            ],
            rows: _getTableRowsForLeaveSummary(viewModel),
          ),
        ),
      ),
    );
  }

  _getTableRowsForLeaveSummary(LeaveViewModel viewModel) {
    List<LeaveSummaryModel> list = [];
    return viewModel
        .leaveSummaryList // Loops through dataColumnText, each iteration assigning the value to element
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
                      child: Center(
                        child: Text(
                          element.value.leaveShortName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                        ),
                      ))), //Extracting from Map element the value
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          element.value.entitlement.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                        ),
                      ))),
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Center(
                        child: Text(
                          element.value.taken.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          softWrap: true,
                        ),
                      ))),
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Center(
                        child: Text(
                          element.value.balance.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                        ),
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

  _getTableForLeaveDetail(LeaveViewModel viewModel) {
    return SizedBox(
      key: key,
      width: double.infinity,
      height: _getGridHeight(),
      child: TrinaGrid(
        columns: _getTableColumnsForLeaveDetail(viewModel),
        rows: _getTableRowsForLeaveDetail(viewModel),
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

  _getTableColumnsForLeaveDetail(LeaveViewModel viewModel) {
    List<TrinaColumn> columns = <TrinaColumn>[
      TrinaColumn(
        title: Strings.colHeaderRequest,
        field: 'id',
        width: 180,
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
              IconButton(
                tooltip: Strings.hintViewSummary,
                icon: const Icon(
                  Icons.remove_red_eye,
                ),
                onPressed: () {
                  var userLeaveModel = viewModel.userLeaveList.firstWhere(
                      (element) => element.id == rendererContext.cell.value);
                  viewModel.getEmployeeLeaveSummary(userLeaveModel.employeeId);
                },
                iconSize: 18,
                color: kPrimaryColor,
                padding: const EdgeInsets.all(0),
              ),
              rendererContext.row.cells["is_approved"]?.value
                          .toString()
                          .toLowerCase() ==
                      Strings.yes.toLowerCase()
                  ? const SizedBox()
                  : IconButton(
                      tooltip: Strings.hintApprove,
                      icon: const Icon(
                        Icons.check,
                      ),
                      onPressed: () async {
                        var userLeaveModel = viewModel.userLeaveList.firstWhere(
                            (element) =>
                                element.id == rendererContext.cell.value);
                        var isSuccess =
                            await viewModel.approveEmployeeLeave(userLeaveModel);
                        if (isSuccess) {
                          _loadData(viewModel);
                        }
                      },
                      iconSize: 18,
                      color: kPrimaryColor,
                      padding: const EdgeInsets.all(0),
                    ),
              rendererContext.row.cells["is_approved"]?.value
                          .toString()
                          .toLowerCase() ==
                      Strings.yes.toLowerCase()
                  ? const SizedBox()
                  : IconButton(
                      tooltip: Strings.hintDelete,
                      icon: const Icon(
                        Icons.delete_outline_outlined,
                      ),
                      onPressed: () async {
                        var userLeaveModel = viewModel.userLeaveList.firstWhere(
                            (element) =>
                                element.id == rendererContext.cell.value);
                        var isSuccess =
                            await viewModel.deleteUserLeave(userLeaveModel);
                        if (isSuccess) {
                          _loadData(viewModel);
                        }
                      },
                      iconSize: 18,
                      color: Colors.red,
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
        title: Strings.colHeaderType,
        field: 'leave_type',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 110,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
          title: Strings.colHeaderReason,
          field: 'reason',
          enableAutoEditing: false,
          enableEditingMode: false,
          enableContextMenu: false,
          textAlign: TrinaColumnTextAlign.left,
          width: 110,
          type: TrinaColumnType.text(),
          renderer: (rendererContext) {
            return Tooltip(
              message: rendererContext.cell.value.toString(),
              child: Text(
                rendererContext.cell.value.toString(),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
      TrinaColumn(
        title: Strings.colHeaderTotalDays,
        field: 'total_days',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 120,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.colHeaderStartDate,
        field: 'start_date',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        width: 110,
        type: TrinaColumnType.date(
            defaultValue: DateTime.now(),
            format: 'dd-MM-yyyy',
            applyFormatOnInit: true),
      ),
      TrinaColumn(
        title: Strings.colHeaderEndDate,
        field: 'end_date',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        width: 110,
        type: TrinaColumnType.date(
            defaultValue: DateTime.now(),
            format: 'dd-MM-yyyy',
            applyFormatOnInit: true),
      ),
      TrinaColumn(
        title: '${Strings.colHeaderApproved}?',
        field: 'is_approved',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 120,
        type: TrinaColumnType.text(),
      ),
    ];

    return columns;
  }

  _getTableRowsForLeaveDetail(LeaveViewModel viewModel) {
    List<TrinaRow> rows = viewModel.userLeaveList
        .asMap()
        .entries
        .map((e) => TrinaRow(cells: {
              'id': TrinaCell(value: e.value.id),
              'date': TrinaCell(value: e.value.getApplyDate()),
              'employee_name': TrinaCell(
                  value: employeeList
                      .firstWhere((element) => element.id == e.value.employeeId)
                      .employeeName),
              'leave_type': TrinaCell(
                  value: viewModel.leaveList
                      .firstWhere((element) => element.id == e.value.leaveId)
                      .leaveShortName),
              'reason': TrinaCell(value: e.value.reason),
              'total_days': TrinaCell(value: e.value.totalDays),
              'start_date': TrinaCell(value: e.value.getStartDate()),
              'end_date': TrinaCell(value: e.value.getEndDate()),
              'is_approved': TrinaCell(value: e.value.getApproveAsString()),
            }))
        .toList();

    return rows;
  }
}
