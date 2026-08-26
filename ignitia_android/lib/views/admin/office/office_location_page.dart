import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/loading_widget.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/views/admin/office/add_office_location_page.dart';
import 'package:i_employment/views/admin/office/delete_office_location_page.dart';
import 'package:i_employment/views/admin/office/edit_office_location_page.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:provider/provider.dart';

import '../../../components/app_bar_widget.dart';
import '../../../components/error_popup_widget.dart';
import '../../../models/toolbar_item_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/message.dart';
import '../../../view_models/office_location_view_model.dart';
import '../../menu_page.dart';

class OfficeLocationPage extends StatefulWidget {
  const OfficeLocationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OfficeLocationPageState();
}

class _OfficeLocationPageState extends State<OfficeLocationPage> {
  GlobalKey key = GlobalKey();

  late final TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    var viewModel =
        Provider.of<OfficeLocationViewModel>(context, listen: false);
    Future.delayed(Duration.zero, () async {
      await viewModel.loadOfficeLocations();
      stateManager.removeAllRows(notify: true);
      stateManager.setShowLoading(false, notify: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<OfficeLocationViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    ToolBarItemModel item = ToolBarItemModel(
        1,
        const Icon(Icons.add_circle_outline),
        const AddOfficeLocationPage(),
        null);

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleOfficeLocationPage,
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
                                openNewUI(context, const AddOfficeLocationPage());
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
                          _getTableForOfficeLocation(viewModel),
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

  _getTableForOfficeLocation(OfficeLocationViewModel viewModel) {
    return SizedBox(
      key: key,
      width: double.infinity,
      height: _getGridHeight(),
      child: TrinaGrid(
        columns: _getTableColumnsForOfficeLocation(viewModel),
        rows: _getTableRowsForOfficeLocation(viewModel),
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

  _getTableColumnsForOfficeLocation(OfficeLocationViewModel viewModel) {
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
                  var officeLocationModel = viewModel.officeLocationList
                      .firstWhere((element) =>
                          element.id == rendererContext.cell.value);
                  openNewUI(context,
                      EditOfficeLocationPage(officeLocationModel: officeLocationModel));
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
                  var officeLocationModel = viewModel.officeLocationList
                      .firstWhere((element) =>
                          element.id == rendererContext.cell.value);
                  openNewUI(context,
                      DeleteOfficeLocationPage(officeLocationModel: officeLocationModel));
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
        title: Strings.colHeaderOfficeName,
        field: 'name',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        frozen: TrinaColumnFrozen.start,
        width: 180,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.colHeaderLatitude,
        field: 'latitude',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 130,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.colHeaderLongitude,
        field: 'longitude',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 130,
        type: TrinaColumnType.text(),
      ),
      TrinaColumn(
        title: Strings.colHeaderRadiusMeters,
        field: 'radius_meters',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 140,
        type: TrinaColumnType.text(),
      ),
    ];

    return columns;
  }

  _getTableRowsForOfficeLocation(OfficeLocationViewModel viewModel) {
    List<TrinaRow> rows = viewModel.officeLocationList
        .asMap()
        .entries
        .map((e) => TrinaRow(cells: {
              'id': TrinaCell(value: e.value.id),
              'name': TrinaCell(value: e.value.name),
              'latitude': TrinaCell(value: e.value.latitude),
              'longitude': TrinaCell(value: e.value.longitude),
              'radius_meters': TrinaCell(value: e.value.radiusMeters),
            }))
        .toList();

    return rows;
  }
}
