import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class ReportBuilderPage extends StatelessWidget {
  const ReportBuilderPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(title: Strings.titleReportBuilderPage, actions: [IconButton(icon: const Icon(Icons.download), tooltip: Strings.btnTextDownload, onPressed: (){})]),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const TitleTextView("Report Builder", textSize: 16, fontFamily: Fonts.gilroy_semibold), const SizedBox(height: 4), const Text("CSV Timesheet export saja (MVP). Source locked to Timesheet — pilih range & download.", style: TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 12), Row(children: [ElevatedButton.icon(icon: const Icon(Icons.download, size: 16), label: const Text("Download CSV"), onPressed: (){}), const SizedBox(width: 8), const Text("GET /Timesheet/export?format=csv", style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))])])),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Scope", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), SizedBox(height: 6), Text("• Filters: employee_id, startDate, endDate\n• Columns: date, check_in/out, break/work/overtime/late, status\n• Future: save template, scheduled run (not MVP)", style: TextStyle(fontSize: 11, color: Colors.grey))])) ,
        ]))),
      ]),
    );
  }
}
