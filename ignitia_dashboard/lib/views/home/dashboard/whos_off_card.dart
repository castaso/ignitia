import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/view_models/dashboard_view_model.dart';
import 'dashboard_card.dart';

/// Who's Off card (spec item 18): employees on approved leave within the
/// selected period, with a date header per the reference layout.
class WhosOffCard extends StatelessWidget {
  const WhosOffCard({Key? key}) : super(key: key);

  static const List<Map<String, dynamic>> _windows = [
    {"days": 1, "label": "Today"},
    {"days": 7, "label": "Next 7 days"},
    {"days": 14, "label": "Next 14 days"},
    {"days": 30, "label": "Next 30 days"},
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final rows = viewModel.whoIsOff;
    final current = _windows.firstWhere(
      (w) => w["days"] == viewModel.whoIsOffDays,
      orElse: () => _windows[0],
    );
    return DashboardCard(
      title: Strings.textWhosOff,
      trailing: DropdownButton<int>(
        value: current["days"] as int,
        isDense: true,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(6),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down, size: 16),
        style: const TextStyle(fontSize: 11, color: titleTextColor),
        items: [
          for (final w in _windows)
            DropdownMenuItem(
                value: w["days"] as int,
                child: Text(w["label"] as String)),
        ],
        onChanged: (value) {
          if (value != null) viewModel.setWhoIsOffDays(value);
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TitleTextView(
              DateFormat("EEE, dd MMM yyyy")
                  .format(DateTime.now())
                  .toUpperCase(),
              textSize: 11,
              fontFamily: Fonts.gilroy_semibold,
              textColor: Colors.grey,
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? const EmptyBody()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                final name = (row["name"] ?? "").toString();
                final designation = (row["designation"] ?? "").toString();
                final leaveName = (row["leave_name"] ?? "").toString();
                final start = (row["start_date"] ?? "").toString();
                final end = (row["end_date"] ?? "").toString();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(
                              fontSize: 13,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TitleTextView(name,
                                      textSize: 13,
                                      fontFamily: Fonts.gilroy_medium,
                                      maxLines: 1),
                                ),
                                if (leaveName.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(leaveName,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: kPrimaryColor)),
                                  ),
                              ],
                            ),
                            if (designation.isNotEmpty)
                              TitleTextView(designation,
                                  textSize: 11,
                                  fontFamily: Fonts.gilroy_regular,
                                  textColor: Colors.grey),
                          ],
                        ),
                      ),
                      TitleTextView(
                        start == end ? start : "$start → $end",
                        textSize: 11,
                        fontFamily: Fonts.gilroy_regular,
                        textColor: Colors.grey,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
