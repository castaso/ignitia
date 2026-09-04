import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/view_models/dashboard_view_model.dart';
import 'package:ignitia_dashboard/views/time_management/leave/leave_tm_page.dart';
import 'dashboard_card.dart';

/// Balance Time Off card (spec item 13): one block per leave type with its
/// balance, a request link, and a "View all" footer. Unlimited-balance
/// types are hidden.
class BalanceTimeOffCard extends StatelessWidget {
  const BalanceTimeOffCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final rows = viewModel.leaveBalance;
    return DashboardCard(
      title: Strings.textBalanceTimeOff,
      child: rows.isEmpty
          ? const EmptyBody()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final row in rows) _BalanceBlock(row: row),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: InkWell(
                    onTap: () =>
                        openNewUI(context, const LeaveTMPage()),
                    child: Text("View all",
                        style: TextStyle(
                            fontSize: 12,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
    );
  }
}

class _BalanceBlock extends StatelessWidget {
  final Map<String, dynamic> row;

  const _BalanceBlock({required this.row});

  @override
  Widget build(BuildContext context) {
    final short = (row["leavE_SHORT_NAME"] ?? row["leave_short_name"] ?? "")
        .toString();
    final name = (row["leavE_NAME"] ?? row["leave_name"] ?? short).toString();
    final balance = (row["balance"] as int? ?? 0);
    final title = name.isEmpty ? "Leave Balance" : "$name Leave Balance";
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TitleTextView(title,
                    textSize: 13, fontFamily: Fonts.gilroy_medium),
              ),
              const Icon(Icons.info_outline, size: 14, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 2),
          TitleTextView("$balance Day${balance == 1 ? "" : "s"}",
              textSize: 17, fontFamily: Fonts.gilroy_semibold),
          const SizedBox(height: 2),
          InkWell(
            onTap: () => openNewUI(context, const LeaveTMPage()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Request ${short.isEmpty ? "leave" : short.toLowerCase()} leave",
                    style: TextStyle(fontSize: 12, color: kPrimaryColor)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: kPrimaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
