import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class ActivityHistoryPage extends StatelessWidget {
  const ActivityHistoryPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleActivityHistoryPage),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView("Activity History / Riwayat Aktivitas", textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 4), Text("Talenta-like — reuse AuditLog (login, attendance, leave, asset, announcement). Tidak track view.", style: TextStyle(fontSize: 12, color: Colors.grey))])),
          const SizedBox(height: 16),
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(children: [Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.vertical(top: Radius.circular(8))), child: const Row(children: [Expanded(child: Text("Action", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Expanded(child: Text("User", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Expanded(child: Text("Time", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))) ])), ...List.generate(3, (i) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))), child: Row(children: [Expanded(child: Text(["login","check_in","asset_assign"][i], style: const TextStyle(fontSize: 12))), Expanded(child: Text("User ${i+1}", style: const TextStyle(fontSize: 12))), Expanded(child: Text("2026-09-03", style: const TextStyle(fontSize: 12)))] ))), const Padding(padding: EdgeInsets.all(12), child: Text("GET /ActivityLogs?employee_id&action&startDate&endDate (limit 500)", style: TextStyle(fontSize: 11, color: Colors.grey)))])),
        ]))),
      ]),
    );
  }
}
