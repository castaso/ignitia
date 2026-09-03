import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
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
                children: const [
                  Text("Istirahat — Single type per company (60 min default).", style: TextStyle(fontSize: 14)),
                  SizedBox(height: 12),
                  Text("Fields: duration_minutes, allowed_start/end (e.g. 12:00-13:00), is_paid, liveness_required, is_active"),
                  SizedBox(height: 12),
                  Text("Liveness: per-company addon (break_liveness_enabled) + per-config liveness_required. Reuse /Liveness/challenge + face + geo.", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16),
                  Text("TODO: Form GET/PUT /Break/config + Switch liveness.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
