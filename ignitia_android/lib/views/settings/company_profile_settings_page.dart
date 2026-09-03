import 'package:flutter/material.dart';
import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/utils/constants.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/views/menu_page.dart';

class CompanyProfileSettingsPage extends StatelessWidget {
  const CompanyProfileSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.titleCompanySettingsPage)),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.business, color: Color(0xFF2563EB))),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView(Strings.titleCompanySettingsPage, textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 2), Text("Akun perusahaan — identitas & kontak", style: TextStyle(fontSize: 12, color: Colors.grey))])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text("Admin", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold))),
          ])),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const TitleTextView("Profil / Profile", textSize: 14, fontFamily: Fonts.gilroy_semibold),
            const SizedBox(height: 12),
            _row("Legal Name", "name / code / short_name"),
            _row("Alamat", "address"),
            _row("Kontak", "phone • email • website"),
            const Divider(height: 24),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(Icons.info_outline, size: 14, color: Colors.grey), SizedBox(width: 8), Expanded(child: Text("Edit via PUT /Companies — hanya admin.", style: TextStyle(fontSize: 11, color: Colors.grey)))])),
          ])),
          const SizedBox(height: 16),
          _apiHint(["GET /Companies", "PUT /Companies — {name, code, address, phone, email, website, contact_person}"]),
        ]))),
      ]),
    );
  }
  static Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 13, color: Colors.grey)), Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]));
  static Widget _apiHint(List<String> e) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...e.map((x) => Text("• $x", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace")))]));
}
