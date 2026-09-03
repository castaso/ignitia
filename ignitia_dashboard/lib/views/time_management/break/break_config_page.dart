import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class BreakConfigPage extends StatelessWidget {
  const BreakConfigPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleBreakConfigPage),
      body: Row(
        children: [
          if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _configCard(),
                  const SizedBox(height: 16),
                  _livenessCard(),
                  const SizedBox(height: 16),
                  const _ApiHint(endpoints: ["GET /Break/config", "PUT /Break/config", "POST /Break/start  •  POST /Break/end", "GET /Break/sessions?employee_id&startDate&endDate", "GET /Liveness/challenge (generic)"]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _configCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.coffee, color: Colors.orange)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TitleTextView(Strings.titleBreakPage, textSize: 16, fontFamily: Fonts.gilroy_semibold),
            SizedBox(height: 2),
            Text("Single type per company • 1 tipe per perusahaan", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text("Active", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold))),
        ]),
        const Divider(height: 24),
        _row(Strings.textBreakDuration, "60 min"),
        _row(Strings.textBreakWindow, "12:00 – 13:00"),
        _row(Strings.textBreakPaid, "No / Tidak (configurable)"),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(Icons.info_outline, size: 14, color: Colors.grey), SizedBox(width: 8), Expanded(child: Text("PUT /Break/config → {duration_minutes, allowed_start/end, is_paid, liveness_required}", style: TextStyle(fontSize: 11, color: Colors.grey)))])),
      ]),
    );
  }

  Widget _livenessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const TitleTextView(Strings.textLivenessAddon, textSize: 14, fontFamily: Fonts.gilroy_semibold),
        const SizedBox(height: 8),
        _livenessRow(Strings.textAttendanceLiveness, "attendance_liveness_enabled"),
        _livenessRow(Strings.textBreakLiveness, "break_liveness_enabled"),
        const SizedBox(height: 8),
        const Text("Per-company billing: companies.liveness_addon_active + expires_at. Start/End validate face + geo + liveness frames (challengeId single-use).", style: TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }

  Widget _livenessRow(String label, String field) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      const Icon(Icons.verified_user, size: 16, color: kPrimaryColor),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)), child: Text(field, style: const TextStyle(fontSize: 10, fontFamily: "monospace", color: Colors.grey))),
    ]));
  }

  Widget _row(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]));
  }
}

class _ApiHint extends StatelessWidget {
  final List<String> endpoints; const _ApiHint({required this.endpoints});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))))]));
  }
}
