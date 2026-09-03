import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class AttendanceTMPage extends StatelessWidget {
  const AttendanceTMPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleAttendancePageTM),
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
                  Text("Kehadiran — Attendance list, summary, approval, settings."),
                  SizedBox(height: 8),
                  Text("Liveness add-on: per-company toggle (attendance_liveness_enabled).", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16),
                  Text("TODO: reuse Attendance list + ApproveAttendance + geo/face/liveness settings.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
