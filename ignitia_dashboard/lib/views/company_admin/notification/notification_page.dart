import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleNotificationPage),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView("Notifications / Notifikasi", textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 4), Text("In-app only — dari publish announcement. Mark read / read-all.", style: TextStyle(fontSize: 12, color: Colors.grey))])),
          const SizedBox(height: 16),
          ...List.generate(3, (i) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: Icon(i==0? Icons.mark_email_unread: Icons.mark_email_read, color: i==0? Colors.blue: Colors.grey), title: Text("Notification ${i+1}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), subtitle: const Text("In-app notification body", style: TextStyle(fontSize: 11)), trailing: Text(i==0? "Unread": "Read", style: TextStyle(fontSize: 11, color: i==0? Colors.blue: Colors.grey))))),
          const SizedBox(height: 16),
          const _ApiHint(endpoints: ["GET /Notifications?is_read", "POST /Notifications/{id}/read", "POST /Notifications/read-all"]),
        ]))),
      ]),
    );
  }
}
class _ApiHint extends StatelessWidget { final List<String> endpoints; const _ApiHint({required this.endpoints}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))))])) ;}
