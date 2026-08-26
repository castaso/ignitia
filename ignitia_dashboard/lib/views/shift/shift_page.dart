import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/loading_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/shift/add_shift_page.dart';
import 'package:ignitia_dashboard/views/shift/assign_shift_page.dart';
import 'package:ignitia_dashboard/views/shift/delete_shift_page.dart';
import 'package:ignitia_dashboard/views/shift/edit_shift_page.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar_widget.dart';
import '../../components/error_popup_widget.dart';
import '../../models/toolbar_item_model.dart';
import '../../utils/constants.dart';
import '../../utils/message.dart';
import '../../view_models/shift_view_model.dart';
import '../menu_page.dart';

class ShiftPage extends StatefulWidget {
  const ShiftPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShiftPageState();
}

class _ShiftPageState extends State<ShiftPage> {
  GlobalKey key = GlobalKey();

  late final TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    var viewModel = Provider.of<ShiftViewModel>(context, listen: false);
    Future.delayed(Duration.zero, () async {
      await viewModel.getShiftList();
      stateManager.removeAllRows(notify: true);
      stateManager.setShowLoading(false, notify: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<ShiftViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    ToolBarItemModel item = ToolBarItemModel(
        1,
        const Icon(Icons.add_circle_outline),
        const AddShiftPage(),
        null);

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleShiftPage,
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
                                      openNewUI(context, const AssignShiftPage());
                                    },
                                    child: Text(
                                      Strings.btnTextAssign,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateColor
                                            .resolveWith((states) =>
                                                kPrimaryLightColor)),
                                  ),
                                )
                              : Container(),
                          mediaSize.width > webWidth ? const SizedBox(
                            height: 20,
                          ) : Container(),
                          _getTableForShift(viewModel),
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

  _getTableForShift(ShiftViewModel viewModel) {
    return SizedBox(
      key: key,
      width: double.infinity,
      height: _getGridHeight(),
      child: TrinaGrid(
        columns: _getTableColumnsForShift(viewModel),
        rows: _getTableRowsForShift(viewModel),
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

  _getTableColumnsForShift(ShiftViewModel viewModel) {
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
                  var shiftModel = viewModel.shiftList.firstWhere(
                          (element) => element.id == rendererContext.cell.value);
                  openNewUI(context, EditShiftPage(shiftModel: shiftModel));
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
                  var shiftModel = viewModel.shiftList.firstWhere(
                          (element) => element.id == rendererContext.cell.value);
                  openNewUI(context, DeleteShiftPage(shiftModel: shiftModel));
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
        title: Strings.colHeaderShiftName,
        field: 'shift_name',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        frozen: TrinaColumnFrozen.start,
        width: 160,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.colHeaderStartTime,
        field: 'start_time',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 120,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.colHeaderEndTime,
        field: 'end_time',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 120,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.textShiftDuration,
        field: 'duration',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 110,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.colHeaderShiftStatus,
        field: 'status',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 110,
        type: TrinaColumnType.text(),
        renderer: (rendererContext) {
          var status = rendererContext.cell.value.toString();
          return Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: status == Strings.textShiftActive
                  ? Colors.green
                  : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
    ];

    return columns;
  }

  _getTableRowsForShift(ShiftViewModel viewModel) {
    List<TrinaRow> rows = viewModel.shiftList
        .asMap()
        .entries
        .map((e) => TrinaRow(cells: {
              'id': TrinaCell(value: e.value.id),
              'shift_name': TrinaCell(value: e.value.shiftName),
              'start_time': TrinaCell(value: e.value.getStartTimeAsString()),
              'end_time': TrinaCell(value: e.value.getEndTimeAsString()),
              'duration': TrinaCell(value: e.value.getTotalHoursAsString()),
              'status': TrinaCell(value: e.value.getStatusAsString()),
            }))
        .toList();

    return rows;
  }
}
