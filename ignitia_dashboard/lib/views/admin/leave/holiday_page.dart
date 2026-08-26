import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/loading_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/admin/leave/add_holiday_page.dart';
import 'package:ignitia_dashboard/views/admin/leave/delete_holiday_page.dart';
import 'package:ignitia_dashboard/views/admin/leave/edit_holiday_page.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:provider/provider.dart';

import '../../../components/app_bar_widget.dart';
import '../../../components/error_popup_widget.dart';
import '../../../models/toolbar_item_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/message.dart';
import '../../../view_models/holiday_view_model.dart';
import '../../menu_page.dart';

class HolidayPage extends StatefulWidget {
  const HolidayPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HolidayPageState();
}

class _HolidayPageState extends State<HolidayPage> {
  GlobalKey key = GlobalKey();

  late final TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    var viewModel = Provider.of<HolidayViewModel>(context, listen: false);
    Future.delayed(Duration.zero, () async {
      await viewModel.getHolidayList();
      stateManager.removeAllRows(notify: true);
      stateManager.setShowLoading(false, notify: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<HolidayViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    ToolBarItemModel item = ToolBarItemModel(
        1,
        const Icon(Icons.add_circle_outline),
        const AddHolidayPage(),
        null);

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleHolidayPage,
          list: [item],
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
                          mediaSize.width > webWidth
                              ? ListTile(
                            trailing: ElevatedButton(
                              onPressed: () async {
                                openNewUI(context, const AddHolidayPage());
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
                          _getTableForHoliday(viewModel),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if(viewModel.loading) LoadingPage(msg:Messages.progressInProgress),
            if(viewModel.errorMsg.isNotEmpty)
              ErrorPopupPage(msg: viewModel.errorMsg, onOkPressed: (){
                viewModel.setErrorMsg("");
              },),
          ],
        )
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

  _getTableForHoliday(HolidayViewModel viewModel) {
    return SizedBox(
      key: key,
      width: double.infinity,
      height: _getGridHeight(),
      child: TrinaGrid(
        columns: _getTableColumnsForHoliday(viewModel),
        rows: _getTableRowsForHoliday(viewModel),
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

  _getTableColumnsForHoliday(HolidayViewModel viewModel) {
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
              IconButton(
                tooltip: Strings.hintEdit,
                icon: const Icon(
                  Icons.mode_edit_outline_sharp,
                ),
                onPressed: () {
                  var holidayModel = viewModel.holidayList.firstWhere(
                          (element) => element.id == rendererContext.cell.value);
                  openNewUI(context, EditHolidayPage(holidayModel: holidayModel));
                },
                iconSize: 18,
                color: kPrimaryColor,
                padding: const EdgeInsets.all(0),
              ),
              IconButton(
                tooltip: Strings.hintDelete,
                icon: const Icon(
                  Icons.delete_outline_sharp,
                ),
                onPressed: () {
                  var holidayModel = viewModel.holidayList.firstWhere(
                          (element) => element.id == rendererContext.cell.value);
                  openNewUI(context, DeleteHolidayPage(holidayModel: holidayModel));
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
        title: Strings.colHeaderHolidayName,
        field: 'holiday_name',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        frozen: TrinaColumnFrozen.start,
        width: 160,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.colHeaderHolidayType,
        field: 'holiday_type',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 130,
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
        title: Strings.colHeaderTotalDays,
        field: 'total_days',
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

  _getTableRowsForHoliday(HolidayViewModel viewModel) {
    List<TrinaRow> rows = viewModel.holidayList
        .asMap()
        .entries
        .map((e) => TrinaRow(cells: {
              'id': TrinaCell(value: e.value.id),
              'holiday_name': TrinaCell(value: e.value.holidayName),
              'holiday_type': TrinaCell(value: e.value.holidayType),
              'start_date': TrinaCell(value: e.value.getStartDate()),
              'end_date': TrinaCell(value: e.value.getEndDate()),
              'total_days': TrinaCell(value: e.value.getTotalDays()),
            }))
        .toList();

    return rows;
  }
}
