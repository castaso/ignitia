import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class PayrollSettingsPage extends StatelessWidget {
  const PayrollSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titlePayrollSettingsPage),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          _headerCard(),
          const SizedBox(height: 16),
          _ptkpCard(),
          const SizedBox(height: 12),
          _salaryCard(),
          const SizedBox(height: 16),
          const _ApiHint(endpoints: [
            "GET /PtkpStatuses — daftar TK/0, K/1 ... annual_value",
            "GET /Payroll/GetPayslip?employee_id&salary_year&salary_month",
            "Employee.basic_salary + department_id + ptkp_status_id (models.py)",
            "Report Builder → CSV Timesheet (TimesheetEntry work/overtime/break minutes)",
          ]),
        ]))),
      ]),
    );
  }

  Widget _headerCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.payments, color: Colors.green)),
    const SizedBox(width: 12),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView(Strings.titlePayrollSettingsPage, textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 2), Text("Penggajian — PTKP, gaji pokok & slip", style: TextStyle(fontSize: 12, color: Colors.grey))])),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text("Admin only", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold))),
  ]));

  Widget _ptkpCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const TitleTextView("PTKP / Tax Status", textSize: 14, fontFamily: Fonts.gilroy_semibold),
    const SizedBox(height: 8),
    Container(decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)), child: Column(children: [
      Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.vertical(top: Radius.circular(8))), child: const Row(children: [Expanded(child: Text("Code", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Expanded(child: Text("Description", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Expanded(child: Text("Annual Value", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))])),
      ...["TK/0 — Single 54jt", "K/1 — Married 1 dependent", "K/3 — Married 3 dependents"].map((e) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))), child: Row(children: [Expanded(child: Text(e.split(" — ").first, style: const TextStyle(fontSize: 12))), Expanded(flex: 2, child: Text(e.split(" — ").last, style: const TextStyle(fontSize: 12)))]))),
    ])),
    const SizedBox(height: 8),
    const Text("PTKP menentukan pengurang pajak; set di Employee.ptkp_status_id.", style: TextStyle(fontSize: 11, color: Colors.grey)),
  ]));

  Widget _salaryCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const TitleTextView("Gaji Pokok / Basic Salary", textSize: 14, fontFamily: Fonts.gilroy_semibold),
    const SizedBox(height: 8),
    _row("Employee.basic_salary", "Float — per karyawan"),
    _row("Department", "departments.id → Employee.department_id"),
    _row("Payslip", "GET /Payroll/GetPayslip"),
  ]));

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]));
}

class _ApiHint extends StatelessWidget {
  final List<String> endpoints; const _ApiHint({required this.endpoints});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))))]));
}
