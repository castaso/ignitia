import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart';
import 'package:i_employment/components/loading_widget.dart';
import 'package:i_employment/components/toast_widget.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/views/attendance/attendance_page.dart';
import 'package:i_employment/views/attendance/edit_attendance_page.dart';
import 'package:intl/intl.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar_widget.dart';
import '../../components/calendar_theme.dart';
import '../../components/dropdown_widget.dart';
import '../../components/error_popup_widget.dart';
import '../../components/textview_widget.dart';
import '../../models/attendance/user_attendance_summary_model.dart';
import '../../models/dropdown_model.dart';
import '../../models/toolbar_item_model.dart';
import '../../utils/common_functions.dart';
import '../../utils/constants.dart';
import '../../utils/message.dart';
import '../../utils/string.dart';
import '../../view_models/attendance_view_model.dart';
import '../../view_models/payroll_view_model.dart';
import '../home/home_screen.dart';
import '../menu_page.dart';

class PayslipPage extends StatefulWidget {
  const PayslipPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PayslipPageState();
}

class _PayslipPageState extends State<PayslipPage> {
  GlobalKey key = GlobalKey();

  DropDownModel? _selectedYear;
  DropDownModel? _selectedMonth;

  late PayrollViewModel viewModel;
  late final TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<PayrollViewModel>(context, listen: false);
    _selectedYear = CommonFunctions.getYearList()
        .firstWhere((element) => element.id == DateTime.now().year);
    _selectedMonth = CommonFunctions.getMonthList()
        .firstWhere((element) => element.id == DateTime.now().month);
    Future.delayed(Duration.zero, () {
      viewModel.payslip.clear();

      stateManager.removeAllRows(notify: true);
      stateManager.setShowLoading(false, notify: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    PayrollViewModel viewModel = context.watch<PayrollViewModel>();

    onTapToDownload() async {
      CustomToast.showErrorToast("This feature will be available soon!");
      // if (viewModel.payslip.isEmpty) {
      //   CustomToast.showErrorToast(Messages.errorNoRecordFound);
      //   return;
      // } else {
      //   // final themeData = pluto_grid_export.ThemeData.withFont(
      //   //   base: pluto_grid_export.Font.ttf(
      //   //     await rootBundle.load('fonts/open_sans/OpenSans-Regular.ttf'),
      //   //   ),
      //   //   bold: pluto_grid_export.Font.ttf(
      //   //     await rootBundle.load('fonts/open_sans/OpenSans-Bold.ttf'),
      //   //   ),
      //   // );
      //
      //   var plutoGridPdfExport = pluto_grid_export.TrinaGridDefaultPdfExport(
      //     title:
      //         "${Strings.titlePlutoExportPrefix} ${_selectedMonth!.name}' ${_selectedYear!.name}",
      //     creator: Strings.organizationName,
      //     format: pluto_grid_export.PdfPageFormat.a4.landscape,
      //     themeData: pluto_grid_export.ThemeData(
      //         textAlign: pluto_grid_export.TextAlign.left),
      //   );
      //
      //   await pluto_grid_export.Printing.sharePdf(
      //     bytes: await plutoGridPdfExport.export(stateManager),
      //     filename: plutoGridPdfExport.getFilename(),
      //   );
      // }
    }

    ToolBarItemModel item = ToolBarItemModel(1,
        const Icon(Icons.download_for_offline_outlined), null, onTapToDownload);
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(title: Strings.titlePayslipPage, list: [item]),
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
                              onTapToDownload();
                            },
                            child: Text(
                              Strings.btnTextDownload,
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
                        _payslipSection(),
                        //
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

  _payslipSection() {
    return Column(
      children: [
        Text(
          "* ${Messages.infoPaySlip} *",
          style: TextStyle(color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        ),
        _monthPickerSection(),
        const SizedBox(
          height: 10,
        ),
        const Divider(
          height: 1,
          color: Colors.black,
        ),
        _getTableForPayslip()
      ],
    );
  }

  _monthPickerSection() {
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
                flex: 2,
                child: DropDown(CommonFunctions.getYearList(), _selectedYear,
                    Strings.hintYearSelection, false, (DropDownModel? data) {
                  setState(() {
                    _selectedYear = data;
                  });
                }),
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
                flex: 2,
                child: DropDown(CommonFunctions.getMonthList(), _selectedMonth,
                    Strings.hintMonthSelection, false, (DropDownModel? data) {
                  setState(() {
                    _selectedMonth = data;
                  });
                }),
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
                if (viewModel.loading) return;
                viewModel
                    .getPayslip(_selectedYear!.id, _selectedMonth!.id)
                    .then((value) {
                  TrinaGridStateManager.initializeRowsAsync(
                    _getTableColumnsForPayslip(),
                    _getTableRowsForPayslipDetail(),
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
                    stateManager.setShowColumnFilter(false);
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

  _yearDropdown() {
    return DropdownSearch<DropDownModel>(
      items: CommonFunctions.getYearList(),
      itemAsString: (DropDownModel dropDownModel) => dropDownModel.name,
      selectedItem: _selectedYear,
      onChanged: (DropDownModel? data) {
        setState(() {
          _selectedYear = data!;
        });
      },
      dropdownDecoratorProps: dropDownStyle(Strings.hintYearSelection),
      popupProps: PopupProps.menu(
        fit: FlexFit.loose,
        showSearchBox: false,
        itemBuilder: customPopupItemBuilder,
      ),
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

  _getTableForPayslip() {
    return SizedBox(
      key: key,
      width: double.infinity,
      height: _getGridHeight(),
      child: TrinaGrid(
        columns: _getTableColumnsForPayslip(),
        rows: _getTableRowsForPayslipDetail(),
        onLoaded: (TrinaGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(false);
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

  _getTableColumnsForPayslip() {
    List<TrinaColumn> columns = <TrinaColumn>[
      TrinaColumn(
        title: Strings.colHeaderDescription,
        field: 'name',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        enableSorting: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        textAlign: TrinaColumnTextAlign.start,
        //width: gridWidh / 2,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.colHeaderValue,
        field: 'value',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        enableSorting: false,
        enableFilterMenuItem: false,
        enableSetColumnsMenuItem: false,
        textAlign: TrinaColumnTextAlign.right,
        //width: MediaQuery.of(context).size.width / 2 - 37,
        type: TrinaColumnType.text(),
      )
    ];

    return columns;
  }

  _getTableRowsForPayslipDetail() {
    List<TrinaRow> rows = viewModel.payslip
        .asMap()
        .entries
        .map((e) => TrinaRow(cells: {
              'name': TrinaCell(value: e.value.name),
              'value': TrinaCell(value: e.value.value),
            }))
        .toList();

    return rows;
  }
}
