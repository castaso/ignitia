import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/admin/leave/holiday_page.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';

class LeaveTMPage extends StatelessWidget {
  const LeaveTMPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleLeavePageTM),
      body: Row(
        children: [
          if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text("Cuti — Leave types, balances, requests, approval + Holidays."),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => openNewUI(context, const HolidayPage()), child: const Text(Strings.titleHolidayPage)),
                  const SizedBox(height: 12),
                  const Text("TODO: Leave TM aggregation (reuse holiday_page + leave APIs).", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
