import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/loading_widget.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/message.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/views/attendance/attendance_page.dart';
import 'package:i_employment/views/attendance/edit_attendance_page.dart';
import 'package:intl/intl.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar_widget.dart';
import '../../components/calendar_theme.dart';
import '../../components/custom_date_control.dart';
import '../../components/error_popup_widget.dart';
import '../../components/textview_widget.dart';
import '../../models/attendance/user_attendance_summary_model.dart';
import '../../utils/common_functions.dart';
import '../../utils/constants.dart';
import '../../utils/string.dart';
import '../../view_models/attendance_view_model.dart';
import '../home/home_screen.dart';
import '../menu_page.dart';
import 'delete_attendance_page.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  GlobalKey key = GlobalKey();

  DateTime selectedToDate = DateTime.now();
  DateTime selectedFromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  late AttendanceViewModel viewModel;
  late final TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<AttendanceViewModel>(context, listen: false);
    Future.delayed(Duration.zero, () {
      viewModel.requestList.clear();

      stateManager.removeAllRows(notify: true);
      stateManager.setShowLoading(false, notify: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    AttendanceViewModel viewModel = context.watch<AttendanceViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(title: Strings.titleRequestListPage),
        body: Stack(children: [
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
                      children: [_attendanceSection()],
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
        ]));
  }

  _attendanceSection() {
    return Column(
      children: [
        _datePickerSection(),
        const SizedBox(
          height: 10,
        ),
        const Divider(
          height: 1,
          color: Colors.black,
        ),
        _getTableForRequest()
      ],
    );
  }

  _datePickerSection() {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 45,
          child: Container(
            width: double.infinity,
            child: CustomDateControl(
              labelText: "${Strings.textFrom}: ",
              firstDate: DateTime(2021),
              lastDate: DateTime(2121),
              fixedWidth: 120,
              defulatDate: selectedFromDate,
              defaultFormat: "dd/MM/yy",
              onSelected: (value){
                selectedFromDate = value;
              },
            ),
          ),
        ),
        SizedBox(width: 10,),
        Expanded(
          flex: 40,
          child: CustomDateControl(
            labelText: "${Strings.textTo}: ",
            firstDate: DateTime(2021),
            lastDate: DateTime(2121),
            fixedWidth: 120,
            defulatDate: selectedToDate,
            defaultFormat: "dd/MM/yy",
            onSelected: (value){
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
                  viewModel
                      .getRequestList(selectedFromDate, selectedToDate)
                      .then((value) {
                    TrinaGridStateManager.initializeRowsAsync(
                      _getTableColumnsForRequest(),
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

  _getTableForRequest() {
    return SizedBox(
      key: key,
      width: double.infinity,
      height: _getGridHeight(),
      child: TrinaGrid(
        columns: _getTableColumnsForRequest(),
        rows: _getTableRowsForAttendanceDetail(),
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
          stateManager.setEditing(false);
          stateManager.setShowLoading(false);
        },
        onChanged: (TrinaGridOnChangedEvent event) {
          stateManager.notifyListeners();
          if(kDebugMode) {print(event);}
        },
        configuration: const TrinaGridConfiguration(
            style: TrinaGridStyleConfig(
                evenRowColor: buttonDisableBgColor,
                rowHeight: 30,
                cellTextStyle: TextStyle(color: Colors.black))),
      ),
    );
  }

  _getTableColumnsForRequest() {
    List<TrinaColumn> columns = <TrinaColumn>[
      TrinaColumn(
        title: Strings.colHeaderAction,
        field: 'id',
        width: 120,
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
                  ? const SizedBox()
                  : IconButton(
                      tooltip: Strings.hintEdit,
                      icon: const Icon(
                        Icons.mode_edit_outline_sharp,
                      ),
                      onPressed: () {
                        var attendance = viewModel.requestList.firstWhere(
                            (element) =>
                                element.id == rendererContext.cell.value);
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
              rendererContext.row.cells["approval_status"]?.value
                          .toString()
                          .toLowerCase() !=
                      Strings.statusPending.toLowerCase()
                  ? const SizedBox()
                  : IconButton(
                      tooltip: Strings.hintDelete,
                      icon: const Icon(
                        Icons.delete_outline_sharp,
                      ),
                      onPressed: () {
                        var attendance = viewModel.requestList.firstWhere(
                            (element) =>
                                element.id == rendererContext.cell.value);
                        openNewUI(
                            context,
                            DeleteAttendancePage(
                              attendanceModel: attendance,
                            ));
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
          title: Strings.colHeaderStatus,
          field: 'approval_status',
          enableAutoEditing: false,
          enableEditingMode: false,
          enableContextMenu: false,
          width: 100,
          textAlign: TrinaColumnTextAlign.center,
          type: TrinaColumnType.text(),
          renderer: (rendererContext) {
            var status = rendererContext.cell.value.toString().toLowerCase();

            return Text(
              rendererContext.cell.value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: status == Strings.statusRejected.toLowerCase()
                    ? Colors.red
                    : (status != Strings.statusApproved.toLowerCase() ? Colors.orange : Colors.black),
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
          title: Strings.colHeaderReason,
          field: 'missing_reason',
          enableAutoEditing: false,
          enableEditingMode: false,
          enableContextMenu: false,
          readOnly: true,
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
    ];

    return columns;
  }

  _getTableRowsForAttendanceDetail() {
    List<TrinaRow> rows = viewModel.requestList
        .asMap()
        .entries
        .map((e) => TrinaRow(cells: {
              'id': TrinaCell(value: e.value.id),
              'date': TrinaCell(value: e.value.getDateTime()),
              'approval_status': TrinaCell(value: e.value.approvalStatus),
              'check_in': TrinaCell(value: e.value.getCheckInAsString()),
              'check_out': TrinaCell(value: e.value.getCheckOutAsString()),
              'missing_reason': TrinaCell(value: e.value.missingReason ?? ""),
            }))
        .toList();

    return rows;
  }
}
