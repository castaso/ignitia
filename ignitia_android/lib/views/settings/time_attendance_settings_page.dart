import 'package:flutter/material.dart';
import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/utils/constants.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/views/menu_page.dart';

class TimeAttendanceSettingsPage extends StatelessWidget {
  const TimeAttendanceSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.titleTimeAttendanceSettingsPage)),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.schedule, color: Colors.teal)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView(Strings.titleTimeAttendanceSettingsPage, textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 2), Text("Waktu & kehadiran — lokasi, jadwal, istirahat, libur", style: TextStyle(fontSize: 12, color: Colors.grey))])),
          ])),
          const SizedBox(height: 16),
          _section("Kehadiran", Icons.how_to_reg, Colors.blue, ["Office Locations + radius", "attendance_liveness_enabled", "GET /Liveness/challenge"]),
          const SizedBox(height: 12),
          _section("Jadwal Kerja", Icons.calendar_today, Colors.indigo, ["Shifts 08:00-16:00", "Weekly {1..7: shiftId}", "EmployeeRoster override"]),
          const SizedBox(height: 12),
          _section("Istirahat", Icons.coffee, Colors.orange, ["60 min", "12:00-13:00", "is_paid + liveness"]),
          const SizedBox(height: 16),
          _apiHint(["GET /OfficeLocation/getOfficeLocationList", "GET /Shift/getShiftList", "GET /Break/config", "GET /Holiday/getHolidayList", "GET /Liveness/challenge"]),
        ]))),
      ]),
    );
  }
  static Widget _section(String t, IconData ic, Color c, List<String> rows) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(ic, size: 18, color: c), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]), const Divider(height: 16), ...rows.map((r) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text("• $r", style: const TextStyle(fontSize: 12, color: Colors.grey))))]));
  static Widget _apiHint(List<String> e) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...e.map((x) => Text("• $x", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace")))]));
}
