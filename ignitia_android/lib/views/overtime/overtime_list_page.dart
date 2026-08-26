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

import '../../components/calendar_theme.dart';
import '../../components/error_popup_widget.dart';
import '../../components/loading_widget.dart';
import '../../components/textview_widget.dart';
import '../../utils/constants.dart';
import '../../utils/message.dart';
import '../../view_models/overtime_view_model.dart';
import '../menu_page.dart';
import 'delete_overtime_page.dart';
import 'edit_overtime_page.dart';

class OvertimeListPage extends StatefulWidget {
  const OvertimeListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OvertimeListPageState();
}

class _OvertimeListPageState extends State<OvertimeListPage> {
  GlobalKey key = GlobalKey();

  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  DateTime selectedToDate = DateTime.now();
  DateTime selectedFromDate = DateTime.now();

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

  _getNewOvertime() {
    var overtimeDateUnformated =
        DateFormat("yyyy-MM-ddT00:00:00").format(DateTime.now());
    var overtimeDate =
        DateFormat("yyyy-MM-ddTHH:mm:ss").parse(overtimeDateUnformated);
    var overtimeModel = OvertimeModel(
        id: 0,
        employeeId: FieldValue.userId,
        overtimeDateUnformated: overtimeDateUnformated,
        checkInUnformated: DateFormat("yyyy-MM-ddTHH:mm:ss")
            .format(overtimeDate.add(Duration(hours: 18))),
        checkOutUnformated: DateFormat("yyyy-MM-ddTHH:mm:ss")
            .format(overtimeDate.add(Duration(hours: 19))),
        overtimeMinutes: 60,
        status: Strings.statusPending,
        reason: "");

    return overtimeModel;
  }

  @override
  Widget build(BuildContext context) {
    OvertimeViewModel viewModel = context.watch<OvertimeViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    ToolBarItemModel item = ToolBarItemModel(
        1,
        const Icon(Icons.add_circle_outline),
        AddOvertimePage(overtimeModel: _getNewOvertime()),
        null);

    return Scaffold(
        appBar:
            CustomAppBar(title: Strings.titleOvertimeListPage, list: [item]),
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
                        mediaSize.width > webWidth
                            ? ListTile(
                          trailing: ElevatedButton(
                            onPressed: () async {
                              openNewUI(
                                  context,
                                  AddOvertimePage(overtimeModel: _getNewOvertime()));
                            },
                            child: Text(
                              Strings.btnTextAdd,
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
                        _overtimeSection(),
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
        _summarySection(viewModel),
        _getTableForRequest()
      ],
    );
  }

  _summarySection(OvertimeViewModel viewModel) {
    return Container(
        width: double.infinity,
        //height: 150,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4),
        child: Table(
          border: TableBorder.all(),
          children: [
            const TableRow(
              decoration: BoxDecoration(
                color: buttonDisableBgColor,

              ),
              children: [
                Center(
                    child: Text(Strings.statusApproved,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Center(
                    child: Text(Strings.statusPending,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Center(
                    child: Text(Strings.statusRejected,
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            TableRow(
              decoration: const BoxDecoration(color: Colors.white),
              children: [
                Center(
                    child:
                        Text(CommonFunctions.durationFormat(viewModel.approvedDuration))),
                Center(
                    child:
                        Text(CommonFunctions.durationFormat(viewModel.pendingDuration))),
                Center(
                    child:
                        Text(CommonFunctions.durationFormat(viewModel.rejectedDuration))),
              ],
            ),
          ],
        ));
  }

  _datePickerSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 49,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                  flex: 1,
                  child: SubTitleTextView(
                    "${Strings.textFrom}: ",
                    textSize: 13,
                  )),
              Flexible(
                flex: 2,
                child: _datePickerTextField(
                    fromDateController, "dd/MM/yyyy", true),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 49,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                  flex: 1,
                  child: SubTitleTextView(
                    "${Strings.textTo}: ",
                    textSize: 13,
                  )),
              Flexible(
                flex: 2,
                child:
                    _datePickerTextField(toDateController, "dd/MM/yyyy", false),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 15,
          child: Ink(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
            decoration: BoxDecoration(
                color: kPrimaryLightColor,
                borderRadius: BorderRadius.circular(4)),
            child: InkWell(
              onTap: () {
                viewModel
                    .getOvertimeList(selectedFromDate, selectedToDate)
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
      ],
    );
  }

  _datePickerTextField(
      TextEditingController controller, String hintText, bool isFromDate) {
    return TextField(
      style: const TextStyle(fontSize: 14, color: Colors.black),
      controller: controller, //editing controller of this TextField
      decoration: InputDecoration(
        border: const OutlineInputBorder(
            borderSide: BorderSide(width: 0, color: Colors.transparent)),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 0, color: Colors.transparent)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 0, color: Colors.transparent)),
        hintText: hintText,
        filled: true,
        suffixIconConstraints:
            const BoxConstraints(maxHeight: 24, maxWidth: 24),
        suffixIcon: const ImageIcon(
          AssetImage('assets/icons/ic_calendar.png'),
          size: 20,
          color: Colors.black45,
        ),
        fillColor: Colors.transparent,
        isDense: true, // Added this
        contentPadding: const EdgeInsets.all(0),
      ),
      readOnly: true, //set it true, so that user will not able to edit text

      onTap: () {
        _openDatePicker(controller, isFromDate);
      },
    );
  }

  _openDatePicker(
      TextEditingController textFieldController, bool isFromDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate ? selectedFromDate : selectedToDate,
      firstDate: DateTime(
          2000), //DateTime.now() - not to allow to choose before today.
      lastDate: DateTime(2101),
      builder: (context, child) {
        return calendarTheme(context, child);
      },
    );

    if (pickedDate != null) {
      if(kDebugMode) {print(pickedDate);} //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      if (isFromDate) {
        selectedFromDate = pickedDate;
      } else {
        selectedToDate = pickedDate;
      }
      if(kDebugMode) {print(
          formattedDate);} //formatted date output using intl package =>  2021-03-16
      //you can implement different kind of Date Format here according to your requirement

      setState(() {
        textFieldController.text =
            formattedDate; //set output date to TextField value.
      });
    } else {
      if(kDebugMode) {print("Date is not selected");}
    }
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
              rendererContext.row.cells["status"]?.value
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
                        var overtime = viewModel.overtimeList.firstWhere(
                            (element) =>
                                element.id == rendererContext.cell.value);
                        openNewUI(
                            context,
                            EditOvertimePage(
                              overtimeModel: overtime,
                            ));
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
                      tooltip: Strings.hintDelete,
                      icon: const Icon(
                        Icons.delete_outline_sharp,
                      ),
                      onPressed: () {
                        var overtime = viewModel.overtimeList.firstWhere(
                            (element) =>
                                element.id == rendererContext.cell.value);
                        openNewUI(
                            context,
                            DeleteOvertimePage(
                              overtimeModel: overtime,
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
