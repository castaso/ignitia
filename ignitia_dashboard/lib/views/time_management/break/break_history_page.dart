import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'break_config_page.dart';

class BreakHistoryPage extends StatelessWidget {
  const BreakHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleBreakPage),
      body: Row(
        children: [
          if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text("Break History — sesi istirahat harian (start/end, duration)."),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => openNewUI(context, const BreakConfigPage()), child: const Text("Open Break Config")),
                  const SizedBox(height: 12),
                  const Text("TODO: TrinaGrid GET /Break/sessions?employee_id&startDate&endDate", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
