import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/app_bar_widget.dart';
import 'package:i_employment/models/overtime/overtime_model.dart';
import 'package:i_employment/models/toolbar_item_model.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/common_functions.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/views/overtime/add_overtime_page.dart';

import 'package:intl/intl.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:provider/provider.dart';

import '../../../components/calendar_theme.dart';
import '../../../components/custom_date_control.dart';
import '../../../components/error_popup_widget.dart';
import '../../../components/loading_widget.dart';
import '../../../components/textview_widget.dart';
import '../../../utils/constants.dart';
import '../../../utils/message.dart';
import '../../../view_models/overtime_view_model.dart';
import '../../menu_page.dart';

class ApproveOvertimePage extends StatefulWidget {
  const ApproveOvertimePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ApproveOvertimePageState();
}

class _ApproveOvertimePageState extends State<ApproveOvertimePage> {
  GlobalKey key = GlobalKey();

  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  DateTime selectedToDate = DateTime.now();
  DateTime selectedFromDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  late OvertimeViewModel viewModel;
  late final TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<OvertimeViewModel>(context, listen: false);
    Future.delayed(Duration.zero, () {
      viewModel.Clear();

      selectedFromDate = DateTime(selectedToDate.year, selectedToDate.month, 1);
      selectedToDate = DateTime(
          selectedToDate.year, selectedToDate.month, selectedToDate.day);

      fromDateController.text =
          DateFormat('dd/MM/yyyy').format(selectedFromDate);
      toDateController.text = DateFormat('dd/MM/yyyy').format(selectedToDate);
      stateManager.removeAllRows(notify: true);
      stateManager.setShowLoading(false, notify: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    OvertimeViewModel viewModel = context.watch<OvertimeViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(title: Strings.titleApproveOvertimePage),
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
                      children: [
                        _overtimeSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (viewModel.loading) LoadingPage(msg: Messages.progressInProgress),
          if (viewModel.errorMsg.isNotEmpty)
            ErrorPopupPage(
              msg: viewModel.errorMsg,
              onOkPressed: () {
                viewModel.setErrorMsg("");
              },
            ),
        ]));
  }

  _overtimeSection() {
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
        const SizedBox(
          height: 10,
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
            fixedWidth: 120,
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
                  _loadData();
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

  _loadData() {
    viewModel
        .getOvertimeList(selectedFromDate, selectedToDate, 0)
        .then((value) {
      TrinaGridStateManager.initializeRowsAsync(
        _getTableColumnsForRequest(),
        _getTableRowsForOvertimeDetail(),
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
        rows: _getTableRowsForOvertimeDetail(),
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
              rendererContext.row.cells["status"]?.value
                          .toString()
                          .toLowerCase() !=
                      Strings.statusPending.toLowerCase()
                  ? const SizedBox()
                  : IconButton(
                      tooltip: Strings.hintApprove,
                      icon: const Icon(
                        Icons.check,
                      ),
                      onPressed: () async {
                        var overtime = viewModel.overtimeList.firstWhere(
                                (element) =>
                            element.id == rendererContext.cell.value);
                        overtime.overtimeDateUnformated =
                            DateFormat("yyyy-MM-ddTHH:mm:ss").format(overtime.getDateTime());
                        var isSuccess = await viewModel.approveOvertime(overtime);
                        if(isSuccess){
                          _loadData();
                        }
                      },
                      iconSize: 18,
                      color: kPrimaryColor,
                      padding: const EdgeInsets.all(0),
                    ),
              rendererContext.row.cells["status"]?.value
                          .toString()
                          .toLowerCase() !=
                      Strings.statusPending.toLowerCase()
                  ? const SizedBox()
                  : IconButton(
                      tooltip: Strings.hintReject,
                      icon: const Icon(
                        Icons.close_outlined,
                      ),
                      onPressed: () async {
                        var overtime = viewModel.overtimeList.firstWhere(
                            (element) =>
                                element.id == rendererContext.cell.value);
                        overtime.overtimeDateUnformated =
                            DateFormat("yyyy-MM-ddTHH:mm:ss").format(overtime.getDateTime());
                        var isSuccess = await viewModel.rejectOvertime(overtime);
                        if(isSuccess){
                          _loadData();
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
        title: Strings.colHeaderDuration,
        field: 'duration',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 120,
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
            var status = rendererContext.cell.value.toString().toLowerCase();

            return Text(
              rendererContext.cell.value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: status == Strings.statusRejected.toLowerCase()
                    ? Colors.red
                    : (status != Strings.statusApproved.toLowerCase()
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
          title: Strings.colHeaderReason,
          field: 'reason',
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

  _getTableRowsForOvertimeDetail() {
    List<TrinaRow> rows = viewModel.overtimeList
        .asMap()
        .entries
        .map((e) => TrinaRow(cells: {
              'id': TrinaCell(value: e.value.id),
              'date': TrinaCell(value: e.value.getDateTime()),
              'employee_name': TrinaCell(value: e.value.employeeName),
              'duration': TrinaCell(
                  value:
                      CommonFunctions.durationFormat(e.value.overtimeMinutes)),
              'status': TrinaCell(value: e.value.status),
              'check_in': TrinaCell(value: e.value.getCheckInAsString()),
              'check_out': TrinaCell(value: e.value.getCheckOutAsString()),
              'reason': TrinaCell(value: e.value.reason),
            }))
        .toList();

    return rows;
  }
}
