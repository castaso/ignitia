import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/common/coming_soon_page.dart';
import 'package:ignitia_dashboard/views/shift/shift_page.dart';
import 'package:ignitia_dashboard/views/time_management/attendance/attendance_tm_page.dart';
import 'package:ignitia_dashboard/views/time_management/leave/leave_tm_page.dart';

/// Shortcut pills row (spec item 10), laid out horizontally inside the
/// greeting card per the reference layout.
class ShortcutPills extends StatelessWidget {
  const ShortcutPills({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Pill(
          label: Strings.textLiveAttendance,
          onTap: () => openNewUI(context, const AttendanceTMPage()),
        ),
        _Pill(
          label: Strings.textRequestBenefitReimbursement,
          onTap: () => openNewUI(context, const ComingSoonPage(
              feature: Strings.textRequestBenefitReimbursement,
              icon: Icons.receipt_long_outlined)),
        ),
        _Pill(
          label: Strings.textRequestTimeOff,
          onTap: () => openNewUI(context, const LeaveTMPage()),
        ),
        PopupMenuButton<int>(
          tooltip: Strings.textMoreRequest,
          onSelected: (value) {
            switch (value) {
              case 1:
                openNewUI(context, const ComingSoonPage(
                    feature: Strings.textCashAdvance,
                    icon: Icons.payments_outlined));
                break;
              case 2:
                openNewUI(context,
                    const ComingSoonPage(feature: "Overtime Request", icon: Icons.timelapse_outlined));
                break;
              case 3:
                openNewUI(context, const ShiftPage());
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 1, child: Text(Strings.textCashAdvance)),
            const PopupMenuItem(value: 2, child: Text(Strings.textOvertime)),
            const PopupMenuItem(
                value: 3, child: Text(Strings.textChangeShift)),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(Strings.textMoreRequest, style: TextStyle(fontSize: 12)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _Pill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
