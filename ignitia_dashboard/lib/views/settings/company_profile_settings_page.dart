import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class CompanyProfileSettingsPage extends StatelessWidget {
  const CompanyProfileSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleCompanySettingsPage),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          _headerCard(),
          const SizedBox(height: 16),
          _fieldsCard(),
          const SizedBox(height: 16),
          const _ApiHint(endpoints: [
            "GET /Companies — list/search",
            "GET /Companies?id= — detail",
            "POST /Companies — create {name, code, short_name, address, phone, email, website, contact_person, status_id}",
            "PUT /Companies — update",
            "DELETE /Companies?id=",
          ]),
        ]))),
      ]),
    );
  }

  Widget _headerCard() {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.business, color: Color(0xFF2563EB))),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TitleTextView(Strings.titleCompanySettingsPage, textSize: 16, fontFamily: Fonts.gilroy_semibold),
        SizedBox(height: 2),
        Text("Akun perusahaan — identitas, kontak & status aktif", style: TextStyle(fontSize: 12, color: Colors.grey)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text("Admin only", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold))),
    ]));
  }

  Widget _fieldsCard() {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const TitleTextView("Profil / Profile", textSize: 14, fontFamily: Fonts.gilroy_semibold),
      const SizedBox(height: 12),
      _row(Strings.textCompanyLegalName, "name / code / short_name"),
      _row(Strings.textCompanyCode, "code (unik)"),
      _row("Alamat / Address", "address"),
      _row("Kontak / Contact", "phone • email • website • contact_person"),
      _row("Status", "status_id 1=Active"),
      const Divider(height: 24),
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(Icons.info_outline, size: 14, color: Colors.grey), SizedBox(width: 8), Expanded(child: Text("Edit via PUT /Companies — hanya admin. Perubahan tercatat di AuditLog.", style: TextStyle(fontSize: 11, color: Colors.grey)))])),
    ]));
  }

  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]));
}

class _ApiHint extends StatelessWidget {
  final List<String> endpoints; const _ApiHint({required this.endpoints});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))))]));
}
