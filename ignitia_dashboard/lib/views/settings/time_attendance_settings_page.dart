import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

class TimeAttendanceSettingsPage extends StatelessWidget {
  const TimeAttendanceSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CustomAppBar(title: Strings.titleTimeAttendanceSettingsPage),
      body: Row(children: [
        if (mediaSize.width > webWidth) const Flexible(flex: 1, child: MenuPage()),
        Flexible(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: ListView(children: [
          _headerCard(),
          const SizedBox(height: 16),
          _attendanceCard(),
          const SizedBox(height: 12),
          _shiftCard(),
          const SizedBox(height: 12),
          _breakCard(),
          const SizedBox(height: 12),
          _holidayCard(),
          const SizedBox(height: 16),
          const _ApiHint(endpoints: [
            "GET /OfficeLocation/getOfficeLocationList • POST/PUT/DELETE /OfficeLocation",
            "GET /Shift/getShiftList • POST/PUT/DELETE /Shift",
            "GET /WorkSchedule/templates • POST /WorkSchedule/templates + /Rosters",
            "GET /Break/config • PUT /Break/config • GET /Break/sessions",
            "GET /Holiday/getHolidayList • POST/PUT/DELETE /Holiday",
            "GET /Liveness/challenge • companies.liveness_addon_* + attendance/break_liveness_enabled",
          ]),
        ]))),
      ]),
    );
  }

  Widget _headerCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.schedule, color: Colors.teal)),
    const SizedBox(width: 12),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TitleTextView(Strings.titleTimeAttendanceSettingsPage, textSize: 16, fontFamily: Fonts.gilroy_semibold), SizedBox(height: 2), Text("Ketentuan waktu kehadiran — lokasi, jadwal, istirahat, libur & liveness", style: TextStyle(fontSize: 12, color: Colors.grey))])),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text("Admin only", style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold))),
  ]));

  Widget _attendanceCard() => _section("Kehadiran / Attendance", Icons.how_to_reg, Colors.blue, [
    _row("Office Locations", "OfficeLocation + radius geo-fence"),
    _row("Liveness", "attendance_liveness_enabled per company"),
    _row("Challenge", "GET /Liveness/challenge (single-use)"),
  ]);

  Widget _shiftCard() => _section("Jadwal Kerja / Work Schedule", Icons.calendar_today, Colors.indigo, [
    _row("Shifts", "shift_name 08:00-16:00 + cross-midnight"),
    _row("Weekly Pattern", "{1:shiftId Mon … 7:Sun}"),
    _row("Roster", "EmployeeRoster override per karyawan"),
  ]);

  Widget _breakCard() => _section("Istirahat / Break", Icons.coffee, Colors.orange, [
    _row(Strings.textBreakDuration, "60 min default"),
    _row(Strings.textBreakWindow, "12:00 – 13:00"),
    _row(Strings.textBreakPaid, "is_paid + liveness_required"),
  ]);

  Widget _holidayCard() => _section("Libur / Holidays", Icons.event, Colors.pink, [
    _row("Holiday List", "Holidays + tipe"),
    _row("Timesheet", "exclude weekend_holiday dari working days"),
  ]);

  Widget _section(String title, IconData icon, Color color, List<Widget> rows) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]),
    const Divider(height: 16),
    ...rows,
  ]));

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]));
}

class _ApiHint extends StatelessWidget {
  final List<String> endpoints; const _ApiHint({required this.endpoints});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("API", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 6), ...endpoints.map((e) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Text("• $e", style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "monospace"))))]));
}
