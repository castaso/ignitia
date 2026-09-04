import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/global_fields.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/home/dashboard/shortcut_card.dart';

/// Greeting header card per the reference layout:
/// "Good afternoon, NAME!" + current date + Shortcut pills row.
class GreetingCard extends StatelessWidget {
  const GreetingCard({Key? key}) : super(key: key);

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final name = FieldValue.userName.isEmpty
        ? "there"
        : FieldValue.userName.toUpperCase();
    final date = DateFormat("EEEE, d MMMM").format(DateTime.now());
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleTextView("$_greeting(), $name!", textSize: 20),
                const SizedBox(height: 4),
                TitleTextView(
                  "It's $date",
                  textSize: 13,
                  fontFamily: Fonts.gilroy_regular,
                  textColor: subTitleTextColor,
                ),
                const SizedBox(height: 16),
                TitleTextView(Strings.textShortcut,
                    textSize: 12,
                    fontFamily: Fonts.gilroy_semibold,
                    textColor: subTitleTextColor),
                const SizedBox(height: 8),
                const ShortcutPills(),
              ],
            ),
          ),
          Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_user_outlined,
                size: 64, color: kPrimaryColor),
          ),
        ],
      ),
    );
  }
}
