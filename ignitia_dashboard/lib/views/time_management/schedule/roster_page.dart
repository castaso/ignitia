import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';
import 'package:ignitia_dashboard/views/shift/assign_shift_page.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';

class RosterPage extends StatelessWidget {
  const RosterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleRosterPage),
      body: Row(
        children: [
          if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text("Roster Assignment — assign template mingguan ke karyawan (bulk).", style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => openNewUI(context, const AssignShiftPage()), child: const Text(Strings.btnTextAssign)),
                  const SizedBox(height: 16),
                  const Text("TODO: 7 dropdown Senin-Minggu + bulk employee selector + date range.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
