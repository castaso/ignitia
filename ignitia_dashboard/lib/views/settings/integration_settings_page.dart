import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class IntegrationSettingsPage extends StatelessWidget {
  const IntegrationSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleIntegrationSettingsPage),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          _headerCard(),
          const SizedBox(height: 16),
          _emailCard(),
          const SizedBox(height: 12),
          _webhookCard(),
          const SizedBox(height: 12),
          _storageCard(),
          const SizedBox(height: 16),
          const _ApiHint(endpoints: [
            "SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, SMTP_FROM (config.py / .env)",
            "RESET_TOKEN_TTL_MINUTES — expiry reset password",
            "Webhook (planned) — POST /Integrations/webhooks {url, events, secret}",
            "CompanyFiles — multipart upload, max 20MB, ?all=1 admin",
            "Liveness: MIN_LIVENESS_FRAMES, LIVENESS_MIN_DIVERSITY, CHALLENGE_TTL_SECONDS",
          ]),
        ]))),
      ]),
    );
  }

  Widget _headerCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.hub, color: Colors.amber)),
    const SizedBox(width: 12),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView(Strings.titleIntegrationSettingsPage, textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 2), Text("Integrasi — email, webhook, storage & liveness config", style: TextStyle(fontSize: 12, color: Colors.grey))])),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: const Text("Admin only", style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.bold))),
  ]));

  Widget _emailCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const TitleTextView("Email / SMTP", textSize: 14, fontFamily: Fonts.gilroy_semibold),
    const SizedBox(height: 8),
    _row("SMTP_HOST", "env — host"),
    _row("SMTP_PORT", "587 default"),
    _row("SMTP_USER / FROM", "no-reply@ignitia.local"),
    _row("RESET_TOKEN_TTL", "30 min"),
    const SizedBox(height: 8),
    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(Icons.mail_outline, size: 14, color: Colors.grey), SizedBox(width: 8), Expanded(child: Text("Konfigurasi via .env — restart server untuk apply. Test via POST /Login/forgot-password.", style: TextStyle(fontSize: 11, color: Colors.grey)))])),
  ]));

  Widget _webhookCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const TitleTextView("Webhook & API", textSize: 14, fontFamily: Fonts.gilroy_semibold),
    const SizedBox(height: 8),
    _row("Webhook URL", Strings.hintWebhookUrl),
    _row("Events", "attendance, overtime, leave, announcement"),
    _row("API Key", "Bearer token — header Authorization"),
    const SizedBox(height: 8),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)), child: const Text("Planned — MVP tampil placeholder, backend next iteration", style: TextStyle(fontSize: 11, color: Colors.grey))),
  ]));

  Widget _storageCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const TitleTextView("Storage & Liveness", textSize: 14, fontFamily: Fonts.gilroy_semibold),
    const SizedBox(height: 8),
    _row("CompanyFiles", "UPLOAD_DIR/company_files — 20MB"),
    _row("Liveness", "MIN_FRAMES 3 • DIVERSITY 0.03 • TTL 60s"),
    _row("Break", "BREAK_DEFAULT_* 60m 12:00-13:00"),
  ]));

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)), Flexible(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))]));
}

class _ApiHint extends StatelessWidget {
  final List<String> endpoints; const _ApiHint({required this.endpoints});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))))]));
}
