import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleAnnouncementPage),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.campaign, color: Colors.purple)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView("Announcements / Pengumuman", textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 2), Text("Kirim ke seluruh karyawan — fan-out in-app notifications saja", style: TextStyle(fontSize: 12, color: Colors.grey))]))])),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Audience: ALL / DEPARTMENT / ROLE • Pin, publish_at/expires_at", style: TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 12), Row(children: [ElevatedButton(onPressed: (){}, child: const Text("New Announcement")), const SizedBox(width: 8), OutlinedButton(onPressed: (){}, child: const Text("Publish → Notify"))]), const SizedBox(height: 12), Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)), child: const Text("POST /Announcements/{id}/publish → fan-out Notification rows per employee (in-app only)", style: TextStyle(fontSize: 11, color: Colors.grey)))])),
          const SizedBox(height: 16),
          const _ApiHint(endpoints: ["GET /Announcements", "POST /Announcements {title,body,audience}", "POST /Announcements/{id}/publish"]),
        ]))),
      ]),
    );
  }
}
class _ApiHint extends StatelessWidget { final List<String> endpoints; const _ApiHint({required this.endpoints}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))))])) ;}
