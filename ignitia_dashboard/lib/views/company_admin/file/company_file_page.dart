import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class CompanyFilePage extends StatelessWidget {
  const CompanyFilePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(title: Strings.titleFilePage, actions: [IconButton(icon: const Icon(Icons.upload_file), onPressed: (){}, tooltip: "Upload")]),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView("Files / Berkas", textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 4), Text("Private per-uploader — employee lihat miliknya, admin monitor semua (?all=1). Max 20MB.", style: TextStyle(fontSize: 12, color: Colors.grey))])),
          const SizedBox(height: 16),
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(children: [Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFFF8F9FA), borderRadius: BorderRadius.vertical(top: Radius.circular(8))), child: const Row(children: [Expanded(child: Text("File", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Expanded(child: Text("Uploader", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))), Expanded(child: Text("Size", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))] )), ...List.generate(2, (i) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))), child: Row(children: [Expanded(child: Text("file_${i+1}.pdf", style: const TextStyle(fontSize: 12))), Expanded(child: Text("User ${i+1}", style: const TextStyle(fontSize: 12))), Expanded(child: Text("${(i+1)*2} MB", style: const TextStyle(fontSize: 12)))] )))])),
          const SizedBox(height: 16),
          const _ApiHint(endpoints: ["GET /CompanyFiles (own) • GET /CompanyFiles?all=1 (admin)", "POST /CompanyFiles multipart (file, company_id, category)", "DELETE /CompanyFiles?id="]),
        ]))),
      ]),
    );
  }
}
class _ApiHint extends StatelessWidget { final List<String> endpoints; const _ApiHint({required this.endpoints}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))))])) ;}
