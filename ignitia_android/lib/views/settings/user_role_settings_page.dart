import 'package:flutter/material.dart';
import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/utils/constants.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/views/menu_page.dart';

class UserRoleSettingsPage extends StatelessWidget {
  const UserRoleSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.titleUserRoleSettingsPage)),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.people, color: Colors.purple)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView(Strings.titleUserRoleSettingsPage, textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 2), Text("Pengguna & peran — akun, departemen, supervisor", style: TextStyle(fontSize: 12, color: Colors.grey))])),
          ])),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const TitleTextView("Users", textSize: 14, fontFamily: Fonts.gilroy_semibold),
            const SizedBox(height: 8),
            _row("Employee", "name • email • cell_no"),
            _row("Tipe", "1 Admin / 2 Employee"),
            _row("Supervisor", "supervisor_id"),
            _row("Departemen", "department_id + designation"),
          ])),
          const SizedBox(height: 16),
          _apiHint(["GET /Employees", "GET /Departments", "EmployeeTransfer — mutasi", "AuditLog — audit"]),
        ]))),
      ]),
    );
  }
  static Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)), Flexible(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))]));
  static Widget _apiHint(List<String> e) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...e.map((x) => Text("• $x", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace")))]));
}
