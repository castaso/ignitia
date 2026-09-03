import 'package:flutter/material.dart';
import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/utils/constants.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/views/menu_page.dart';

class IntegrationSettingsPage extends StatelessWidget {
  const IntegrationSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.titleIntegrationSettingsPage)),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.hub, color: Colors.amber)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView(Strings.titleIntegrationSettingsPage, textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 2), Text("Integrasi — email, webhook, storage", style: TextStyle(fontSize: 12, color: Colors.grey))])),
          ])),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const TitleTextView("Email / SMTP", textSize: 14, fontFamily: Fonts.gilroy_semibold),
            const SizedBox(height: 8),
            _row("SMTP_HOST", "env"),
            _row("SMTP_PORT", "587"),
            _row("FROM", "no-reply@ignitia.local"),
          ])),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const TitleTextView("Webhook & Storage", textSize: 14, fontFamily: Fonts.gilroy_semibold),
            const SizedBox(height: 8),
            _row("Webhook", "planned — events attendance/overtime/leave"),
            _row("CompanyFiles", "UPLOAD_DIR/company_files — 20MB"),
            _row("Liveness", "MIN_FRAMES 3 • TTL 60s"),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)), child: const Text("MVP placeholder — backend next iteration", style: TextStyle(fontSize: 11, color: Colors.grey))),
          ])),
          const SizedBox(height: 16),
          _apiHint(["SMTP_* env", "RESET_TOKEN_TTL_MINUTES", "CompanyFiles multipart", "LIVENESS_* env"]),
        ]))),
      ]),
    );
  }
  static Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]));
  static Widget _apiHint(List<String> e) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...e.map((x) => Text("• $x", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace")))]));
}
