import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/loading_widget.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/views/employee/employee_detail_page.dart';
import 'package:trina_grid/trina_grid.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../../components/app_bar_widget.dart';
import '../../components/error_popup_widget.dart';
import '../../utils/constants.dart';
import '../../utils/message.dart';
import '../../utils/navigation_utils.dart';
import '../../view_models/employee_view_model.dart';
import '../menu_page.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  GlobalKey key = GlobalKey();

  late final TrinaGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    var viewModel = Provider.of<EmployeeViewModel>(context, listen: false);
    Future.delayed(Duration.zero, () async {
      //await viewModel.getEmployeeList();
      stateManager.removeAllRows(notify: true);
      stateManager.setShowLoading(false, notify: true);

      _loadData(viewModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<EmployeeViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleEmployeeListPage,
        ),
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
                        _employeeSection(viewModel),
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
          if(viewModel.errorMsg.isNotEmpty)
            ErrorPopupPage(msg: viewModel.errorMsg, onOkPressed: (){
              viewModel.setErrorMsg("");
            },)
        ]));
  }

  _loadData(EmployeeViewModel viewModel) {
    viewModel.getEmployeeList().then((value) {
      TrinaGridStateManager.initializeRowsAsync(
        _getTableColumnsForEmployeeDetail(viewModel),
        _getTableRowsForEmployeeDetail(viewModel),
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

  _employeeSection(EmployeeViewModel viewModel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            "* ${Messages.infoLongTapTooltip} *",
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ),
        _getTableForEmployeeDetail(viewModel),
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

  _getTableForEmployeeDetail(EmployeeViewModel viewModel) {
    return SizedBox(
      key: key,
      width: double.infinity,
      height: _getGridHeight(),
      child: TrinaGrid(
        columns: _getTableColumnsForEmployeeDetail(viewModel),
        rows: _getTableRowsForEmployeeDetail(viewModel),
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
              rowHeight: 35,
              cellTextStyle: TextStyle(color: Colors.black)),
          columnSize: TrinaGridColumnSizeConfig(
            autoSizeMode: TrinaAutoSizeMode.none,
            resizeMode: TrinaResizeMode.normal,
          ),
        ),
      ),
    );
  }

  _getTableColumnsForEmployeeDetail(EmployeeViewModel viewModel) {
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
              IconButton(
                tooltip: Strings.hintViewDetail,
                icon: const Icon(
                  Icons.remove_red_eye,
                ),
                onPressed: () async {
                  var userEmployeeModel = viewModel.employeeList.firstWhere(
                      (element) => element.id == rendererContext.cell.value);
                  var contactInfo  = await viewModel.getContactInfo(userEmployeeModel.id);
                  if(viewModel.errorMsg.isEmpty) {
                    openNewUI(
                        context,
                        EmployeeDetailPage(employeeModel: userEmployeeModel,
                          contactInfoModel: contactInfo,));
                  }
                },
                iconSize: 18,
                color: Colors.orangeAccent,
                padding: const EdgeInsets.all(0),
              ),
            ],
          );
        },
      ),
      TrinaColumn(
          title: Strings.colHeaderName,
          field: 'name',
          enableAutoEditing: false,
          enableEditingMode: false,
          enableContextMenu: false,
          enableDropToResize: true,
          frozen: TrinaColumnFrozen.start,
          width: 160,
          type: TrinaColumnType.text(),
          renderer: (rendererContext) {
            return SelectableText(
              rendererContext.cell.value.toString(),
            );
          }),
      TrinaColumn(
          title: Strings.colHeaderCellNo,
          field: 'cell_no',
          enableAutoEditing: false,
          enableEditingMode: false,
          enableContextMenu: false,
          textAlign: TrinaColumnTextAlign.start,
          width: 220,
          type: TrinaColumnType.text(),
          renderer: (rendererContext) {
            return Row(children: [
              IconButton(
                tooltip: Strings.hintWhatsApp,
                icon: Image.asset(
                  "assets/icons/whatsapp.png",
                  width: 20,
                ),
                onPressed: () async {
                  var id = rendererContext.row.cells['id']!.value;
                  var employee = viewModel.employeeList
                      .firstWhere((element) => element.id == id);
                  var link = WhatsAppUnilink(
                    phoneNumber: employee.cellNo!.contains('+880')
                        ? employee.cellNo
                        : "+880${employee.cellNo}",
                  );
                  await launch('$link').catchError((e) {
    if(kDebugMode) {print(e.toString());}
                  });
                },
                iconSize: 18,
                color: Colors.green.shade300,
                padding: const EdgeInsets.all(0),
              ),
              SelectableText(
                rendererContext.cell.value.toString(),
              ),
              IconButton(
                tooltip: Strings.hintPhoneCall,
                icon: Icon(Icons.call),
                onPressed: () async {
                  var id = rendererContext.row.cells['id']!.value;
                  var employee = viewModel.employeeList
                      .firstWhere((element) => element.id == id);
                  var uri = Uri(scheme: 'tel', path: employee.cellNo);
                  await launchUrl(uri).catchError((e) {
    if(kDebugMode) {print(e.toString());}
                  });
                  // openNewUI(
                  //     context,
                  //     DeleteEmployeePage(userEmployeeModel: userEmployeeModel));
                },
                iconSize: 18,
                color: Colors.green.shade500,
                padding: const EdgeInsets.all(0),
              ),
            ]);
          }),
      TrinaColumn(
          title: Strings.colHeaderEmail,
          field: 'email',
          enableAutoEditing: false,
          enableEditingMode: false,
          enableContextMenu: false,
          textAlign: TrinaColumnTextAlign.start,
          width: 240,
          type: TrinaColumnType.text(),
          renderer: (rendererContext) {
            return Row(children: [
              IconButton(
                tooltip: Strings.hintEmail,
                icon: Icon(Icons.email),
                onPressed: () async {
                  var id = rendererContext.row.cells['id']!.value;
                  var employee = viewModel.employeeList
                      .firstWhere((element) => element.id == id);
                  var uri = Uri(scheme: 'mailto', path: employee.email);
                  await launchUrl(uri).catchError((e) {
    if(kDebugMode) {print(e.toString());}
                  });

                },
                iconSize: 18,
                color: kPrimaryLightColor,
                padding: const EdgeInsets.all(0),
              ),
              SelectableText(
                rendererContext.cell.value.toString(),
              ),
            ]);
          }),
      TrinaColumn(
          title: Strings.colHeaderDesignation,
          field: 'designation',
          enableAutoEditing: false,
          enableEditingMode: false,
          enableContextMenu: false,
          textAlign: TrinaColumnTextAlign.start,
          width: 150,
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
        title: '${Strings.colHeaderActive}?',
        field: 'status_id',
        enableAutoEditing: false,
        enableEditingMode: false,
        enableContextMenu: false,
        textAlign: TrinaColumnTextAlign.center,
        width: 80,
        type: TrinaColumnType.text(),
      ),
    ];

    return columns;
  }

  _getTableRowsForEmployeeDetail(EmployeeViewModel viewModel) {
    List<TrinaRow> rows = viewModel.employeeList
        .asMap()
        .entries
        .map((e) => TrinaRow(cells: {
              'id': TrinaCell(value: e.value.id),
              'name': TrinaCell(value: e.value.employeeName),
              'cell_no': TrinaCell(value: e.value.cellNo),
              'email': TrinaCell(value: e.value.email),
              'designation': TrinaCell(value: e.value.designation),
              'status_id': TrinaCell(value: e.value.getIsActiveAsString()),
            }))
        .toList();

    return rows;
  }
}
