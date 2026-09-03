import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class TimesheetPage extends StatelessWidget {
  const TimesheetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(
        title: Strings.titleTimesheetPage,
        actions: [
          IconButton(icon: const Icon(Icons.download), tooltip: Strings.btnTextDownload, onPressed: () {}),
        ],
      ),
      body: Row(
        children: [
          if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
          const Flexible(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Timesheet — harian/mingguan, submit & approval mingguan oleh HR + export."),
                  SizedBox(height: 8),
                  Text("Kalkulasi: work = check_out - check_in - break_minutes. Generate dari Attendance+Break.", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16),
                  Text("TODO: Filter minggu, TrinaGrid, actions Submit/Approve/Reject, GET /Timesheet/export?format=csv", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
