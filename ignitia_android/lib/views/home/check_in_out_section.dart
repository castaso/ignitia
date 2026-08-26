import 'package:flutter/material.dart';
import 'package:i_employment/utils/common_functions.dart';
import 'package:i_employment/view_models/home_view_model.dart';
import 'package:provider/provider.dart';

import '../../components/textview_widget.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/pop_up.dart';
import '../../utils/string.dart';

class CheckInOutSectionWidget extends StatefulWidget {
  CheckInOutSectionWidget({Key? key}) : super(key: key);

  @override
  State<CheckInOutSectionWidget> createState() =>
      _CheckInOutSectionWidgetState();
}

class _CheckInOutSectionWidgetState extends State<CheckInOutSectionWidget> {
  @override
  Widget build(BuildContext context) {
    HomeViewModel viewModel = context.watch<HomeViewModel>();
    var mediaSize = MediaQuery.of(context).size;
    return mediaSize.width > webWidth ? _uiWeb(viewModel) : _uiMobile(viewModel);
  }

  _uiWeb(HomeViewModel viewModel){
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 3,
              child: Container(
                alignment: Alignment.center,
                child: _dataTableViewForAttendance(viewModel),
              ),
            ),
            Flexible(child: _buttonCheckInItem(viewModel)),
            Flexible(child: _buttonCheckOutItem(viewModel)),
          ],
        ),
      ),
    );
  }

  _uiMobile(HomeViewModel viewModel){
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: _dataTableViewForAttendance(viewModel),
            ),
            SizedBox(
              height: 100,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  _buttonCheckInItem(viewModel),
                  _buttonCheckOutItem(viewModel)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonCheckInItem(HomeViewModel viewModel) {
    return Card(
      elevation: 1,
      color: Colors.blue,
      child: SizedBox(
        width: (MediaQuery.of(context).size.width / 2) - 18,
        height: 100,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryLightColor),
          ),
          onPressed: () async {
            if(viewModel.loading) return;
            Popup.showCheckInPopup(context, viewModel);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.login),
                const SizedBox(height: 10),
                TitleTextView(
                  Strings.btnTextCheckIn,
                  textAlign: TextAlign.center,
                  textColor: Colors.white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonCheckOutItem(HomeViewModel viewModel) {
    return Card(
      elevation: 1,
      color: Colors.blue,
      child: SizedBox(
        width: (MediaQuery.of(context).size.width / 2) - 16,
        height: 100,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryLightColor),
          ),
          onPressed: () async {
            if(viewModel.loading) return;
            Popup.showCheckOutPopup(context, viewModel);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.logout),
                const SizedBox(height: 10),
                TitleTextView(
                  Strings.btnTextCheckOut,
                  textAlign: TextAlign.center,
                  textColor: Colors.white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _dataTableViewForAttendance(HomeViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowHeight: 20,
              dividerThickness: 1,
              columnSpacing: 20,
              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.shade300),
              dataRowHeight: 20,
              columns: const [
                DataColumn(label: Text(Strings.colHeaderDate)),
                DataColumn(label: Text(Strings.colHeaderStatus)),
                DataColumn(label: Text(Strings.colHeaderCheckIn)),
                DataColumn(label: Text(Strings.colHeaderCheckOut)),
                DataColumn(label: Text(Strings.colHeaderOvertimes)),
              ],
              rows: _getTableRowsForAttendance(viewModel),
            ),
          ),
        ),
      ),
    );
  }

  _getTableRowsForAttendance(HomeViewModel viewModel) {
    return viewModel
        .attendanceList // Loops through dataColumnText, each iteration assigning the value to element
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
                        element.value.getDateTimeAsString() ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: element.value.status.toLowerCase() == Strings.statusA.toLowerCase()
                                ? Colors.red
                                : (element.value.getCheckOut() == null &&
                                        element.value.status.toLowerCase() != Strings.statusWH.toLowerCase()
                                    ? Colors.orange
                                    : Colors.black)),
                        softWrap: true,
                      ))), //Extracting from Map element the value
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Text(
                        textAlign: TextAlign.center,
                        element.value.status,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: element.value.status.toLowerCase() == Strings.statusA.toLowerCase()
                                ? Colors.red
                                : (element.value.getCheckOut() == null &&
                                        element.value.status.toLowerCase() != Strings.statusWH.toLowerCase()
                                    ? Colors.orange
                                    : Colors.black)),
                        softWrap: true,
                      ))),
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Text(
                        element.value.getCheckInAsString() ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: TextStyle(
                            color: element.value.status.toLowerCase() == Strings.statusA.toLowerCase()
                                ? Colors.red
                                : (element.value.getCheckOut() == null &&
                                        element.value.status.toLowerCase() != Strings.statusWH.toLowerCase()
                                    ? Colors.orange
                                    : Colors.black)),
                        softWrap: true,
                      ))),
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Text(
                        element.value.getCheckOutAsString() ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: element.value.status.toLowerCase() == Strings.statusA.toLowerCase()
                                ? Colors.red
                                : (element.value.getCheckOut() == null &&
                                        element.value.status.toLowerCase() != Strings.statusWH.toLowerCase()
                                    ? Colors.orange
                                    : Colors.black)),
                        softWrap: true,
                      ))),
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          minWidth: 30), //SET max width
                      child: Text(
                        element.value.overtimeMinutes == 0
                            ? ""
                            : CommonFunctions.durationFormat(
                                element.value.overtimeMinutes),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: element.value.status.toLowerCase() == Strings.statusA.toLowerCase()
                                ? Colors.red
                                : (element.value.getCheckOut() == null &&
                                        element.value.status.toLowerCase() != Strings.statusWH.toLowerCase()
                                    ? Colors.orange
                                    : Colors.black)),
                        softWrap: true,
                      ))),
                ],
              )),
        )
        .toList();
  }
}
