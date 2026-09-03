import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
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
          IconButton(icon: const Icon(Icons.download), tooltip: Strings.btnTextDownload, onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Export: GET /Timesheet/export?format=csv")))),
        ],
      ),
      body: Row(
        children: [
          if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _summaryCard(),
                  const SizedBox(height: 16),
                  _legend(),
                  const SizedBox(height: 16),
                  _tablePlaceholder(),
                  const SizedBox(height: 16),
                  const _ApiHint(endpoints: ["GET /Timesheet?employee_id&startDate&endDate", "POST /Timesheet/generate?employee_id&startDate&endDate", "POST /Timesheet/submit  •  POST /Timesheet/approve", "GET /Timesheet/export?format=csv (→ xlsx/pdf next)"]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const TitleTextView("Timesheet — Weekly Review", textSize: 16, fontFamily: Fonts.gilroy_semibold),
        const SizedBox(height: 4),
        const Text("Harian/mingguan — submit & approval mingguan oleh HR + export. Work = check_out - check_in - break.", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        Row(children: [
          _kpi("Work", "work_minutes", Colors.blue),
          const SizedBox(width: 8),
          _kpi("Break", "break_minutes", Colors.orange),
          const SizedBox(width: 8),
          _kpi("Overtime", "overtime_minutes", Colors.green),
        ]),
      ]),
    );
  }

  Widget _kpi(String label, String field, Color c) {
    return Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: Column(children: [Text(label, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(field, style: const TextStyle(fontSize: 10, fontFamily: "monospace", color: Colors.grey))])) );
  }

  Widget _legend() {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      _chip("Draft", Colors.grey),
      _chip("Submitted", Colors.orange),
      _chip("Approved", Colors.green),
      _chip("Rejected", Colors.red),
    ]);
  }

  Widget _chip(String t, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(t, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.bold)));

  Widget _tablePlaceholder() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: const BorderRadius.vertical(top: Radius.circular(8))), child: const Row(children: [Expanded(child: Text("Date", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Expanded(child: Text("Check In/Out", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Expanded(child: Text("Break/Work/OT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Expanded(child: Text("Status", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))])),
        ...List.generate(3, (i) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))), child: Row(children: [Expanded(child: Text("2026-09-0${i+1}", style: const TextStyle(fontSize: 12))), const Expanded(child: Text("08:00 • 17:00", style: TextStyle(fontSize: 12))), const Expanded(child: Text("60 • 480 • 30", style: TextStyle(fontSize: 12))), Expanded(child: _chip(["Draft","Submitted","Approved"][i], [Colors.grey, Colors.orange, Colors.green][i]))]))),
        const Padding(padding: EdgeInsets.all(12), child: Text("TrinaGrid placeholder — wire to GET /Timesheet. Generate triggers POST /Timesheet/generate for range.", style: TextStyle(fontSize: 11, color: Colors.grey))),
      ]),
    );
  }
}

class _ApiHint extends StatelessWidget {
  final List<String> endpoints; const _ApiHint({required this.endpoints});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))))]));
}
