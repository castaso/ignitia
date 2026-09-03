import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
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
                  _headerCard(),
                  const SizedBox(height: 16),
                  _weeklyPreview(),
                  const SizedBox(height: 16),
                  _actionTiles(context),
                  const SizedBox(height: 16),
                  const _ApiHint(
                    title: "API Ready",
                    endpoints: [
                      "GET/POST/PUT /WorkSchedule/templates",
                      "GET /WorkSchedule/rosters  •  POST /WorkSchedule/rosters/bulk",
                      "GET /Shift/getShiftList (existing)",
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kPrimaryLightColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.calendar_view_week, color: kPrimaryColor)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TitleTextView("Weekly Roster Template", textSize: 16, fontFamily: Fonts.gilroy_semibold),
            SizedBox(height: 4),
            Text("Pola mingguan Senin–Minggu per company • Weekly pattern Mon–Sun (1..7 → shiftId). Effective from/to.", style: TextStyle(fontSize: 13, color: Colors.grey)),
          ])),
        ],
      ),
    );
  }

  Widget _weeklyPreview() {
    const days = ["Mon/Senin", "Tue/Selasa", "Wed/Rabu", "Thu/Kamis", "Fri/Jumat", "Sat/Sabtu", "Sun/Minggu"];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const TitleTextView(Strings.textWeeklyPattern, textSize: 14, fontFamily: Fonts.gilroy_semibold),
        const SizedBox(height: 12),
        ...days.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(width: 120, child: Text(days[e.key], style: const TextStyle(fontSize: 13))),
            const Icon(Icons.arrow_right, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(6)), child: const Text("Shift — select on edit", style: TextStyle(fontSize: 12, color: Colors.grey))),
          ]),
        )),
        const SizedBox(height: 8),
        const Text("Cross-midnight handled (22:00→06:00).", style: TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }

  Widget _actionTiles(BuildContext context) {
    return Column(children: [
      _tile(context, Strings.titleShiftPage, "Manage shifts (existing)", Icons.schedule, const ShiftPage()),
      _tile(context, Strings.titleRosterPage, "Assign template to employees (bulk)", Icons.group_add, const AssignShiftPage()),
      _tile(context, "Shift Calendar / Kalender Shift", "Calendar view by date", Icons.calendar_month, const ShiftPage()),
    ]);
  }

  Widget _tile(BuildContext context, String title, String subtitle, IconData icon, Widget page) {
    return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: Icon(icon, color: kPrimaryColor), title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () => openNewUI(context, page)));
  }
}

class _ApiHint extends StatelessWidget {
  final String title; final List<String> endpoints;
  const _ApiHint({required this.title, required this.endpoints});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 6),
        ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace")))),
      ]),
    );
  }
}
