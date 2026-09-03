import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class UserRoleSettingsPage extends StatelessWidget {
  const UserRoleSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleUserRoleSettingsPage),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          _headerCard(),
          const SizedBox(height: 16),
          _usersCard(),
          const SizedBox(height: 12),
          _rolesCard(),
          const SizedBox(height: 12),
          _securityCard(),
          const SizedBox(height: 16),
          const _ApiHint(endpoints: [
            "GET /Employees — list, GET /Employees?id= — detail",
            "POST /Employees — create, PUT /Employees — update, DELETE /Employees?id=",
            "GET /Departments • POST/PUT/DELETE /Departments",
            "Employee.type_id 1=Admin 2=Employee • supervisor_id • status_id 1=Active",
            "EmployeeTransfer, PtkpStatusHistory, AuditLog — riwayat & audit",
          ]),
        ]))),
      ]),
    );
  }

  Widget _headerCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.people, color: Colors.purple)),
    const SizedBox(width: 12),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView(Strings.titleUserRoleSettingsPage, textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 2), Text("Pengguna & peran — akun, departemen, supervisor & status", style: TextStyle(fontSize: 12, color: Colors.grey))])),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text("Admin only", style: TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.bold))),
  ]));

  Widget _usersCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const TitleTextView("Pengguna / Users", textSize: 14, fontFamily: Fonts.gilroy_semibold),
    const SizedBox(height: 8),
    _row("Employee", "name • email (unik) • cell_no • nid"),
    _row("Tipe", "type_id 1 Admin / 2 Employee"),
    _row("Supervisor", "supervisor_id → atasan langsung"),
    _row("Status", "status_id 1 Active / 2 Inactive"),
    const Divider(height: 16),
    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(Icons.badge, size: 14, color: Colors.grey), SizedBox(width: 8), Expanded(child: Text("Tambah/edit pengguna via Employee API; password_hash & reference_face server-only.", style: TextStyle(fontSize: 11, color: Colors.grey)))])),
  ]));

  Widget _rolesCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const TitleTextView("Departemen & Peran / Departments & Roles", textSize: 14, fontFamily: Fonts.gilroy_semibold),
    const SizedBox(height: 8),
    _row("Departments", "departments {id, name, code, is_active}"),
    _row("Jabatan", "Employee.designation"),
    _row("Mutasi", "EmployeeTransfer — riwayat pindah dept/jabatan"),
  ]));

  Widget _securityCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const TitleTextView("Keamanan / Security", textSize: 14, fontFamily: Fonts.gilroy_semibold),
    const SizedBox(height: 8),
    _row("Password", "PasswordResetToken — reset via email"),
    _row("Audit", "AuditLog — action, target_employee_id, changed_fields"),
    _row("Face", "reference_face — verifikasi liveness"),
  ]));

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)), Flexible(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))]));
}

class _ApiHint extends StatelessWidget {
  final List<String> endpoints; const _ApiHint({required this.endpoints});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))))]));
}
