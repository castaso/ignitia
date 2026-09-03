import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class AssetPage extends StatelessWidget {
  const AssetPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleAssetPage),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          _header(),
          const SizedBox(height: 16),
          _categoryLegend(),
          const SizedBox(height: 16),
          _tablePlaceholder(),
          const SizedBox(height: 16),
          const _ApiHint(endpoints: ["GET /CompanyAssets?company_id&category&status", "POST /CompanyAssets {name,category,status,location,assigned_employee_id}", "PUT /CompanyAssets", "DELETE /CompanyAssets?id="]),
        ]))),
      ]),
    );
  }
  Widget _header() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.inventory_2, color: Colors.indigo)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView("Assets / Aset", textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 2), Text("Semua kategori: IT • Kendaraan • Furniture • Lainnya — status: Active/Disposed/Maintenance/Lost/On Loan", style: TextStyle(fontSize: 12, color: Colors.grey))]))]));
  Widget _categoryLegend() => Wrap(spacing: 8, runSpacing: 8, children: [for (var c in ["IT","Kendaraan","Furniture","Lainnya"]) _chip(c, Colors.indigo), for (var s in ["Active","On Loan","Maintenance","Lost","Disposed"]) _chip(s, Colors.teal)]);
  Widget _chip(String t, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(t, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)));
  Widget _tablePlaceholder() => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(children: [Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.vertical(top: Radius.circular(8))), child: const Row(children: [Expanded(child: Text("Asset Code", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Expanded(child: Text("Name", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Expanded(child: Text("Category/Status", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))] )), ...List.generate(3, (i) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))), child: Row(children: [Expanded(child: Text("AST-${100+i}", style: const TextStyle(fontSize: 12))), Expanded(child: Text("Asset ${i+1}", style: const TextStyle(fontSize: 12))), Expanded(child: Text("IT • Active", style: const TextStyle(fontSize: 12)))] ))), const Padding(padding: EdgeInsets.all(12), child: Text("TrinaGrid placeholder — wire to GET /CompanyAssets", style: TextStyle(fontSize: 11, color: Colors.grey)))]));
}
class _ApiHint extends StatelessWidget { final List<String> endpoints; const _ApiHint({required this.endpoints}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))))]));}
