import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';
import 'package:ignitia_dashboard/views/shift/shift_page.dart';
import 'package:ignitia_dashboard/views/shift/assign_shift_page.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';

class ScheduleTemplatePage extends StatelessWidget {
  const ScheduleTemplatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleSchedulePage),
      body: Row(
        children: [
          if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text("Weekly Roster Template (Senin-Minggu) — pola mingguan per company.", style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  ListTile(title: const Text(Strings.titleShiftPage), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () => openNewUI(context, const ShiftPage())),
                  ListTile(title: const Text(Strings.titleShiftCalendarPage), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () => openNewUI(context, const ShiftPage())),
                  ListTile(title: const Text(Strings.titleRosterPage), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () => openNewUI(context, const AssignShiftPage())),
                  const Divider(),
                  const Text("TODO: CRUD WorkScheduleTemplate weekly_pattern {1:Mon..7:Sun} + effective_from/to, bulk roster assign.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
