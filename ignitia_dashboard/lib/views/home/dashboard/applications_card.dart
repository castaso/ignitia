import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/common/coming_soon_page.dart';
import 'package:ignitia_dashboard/views/time_management/timesheet/timesheet_page.dart';
import 'dashboard_card.dart';

/// Applications card (spec item 14): Ignitia non-core apps.
class ApplicationsCard extends StatelessWidget {
  const ApplicationsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apps = <_AppDef>[
      const _AppDef("Forms", Icons.assignment_outlined),
      const _AppDef("Performance Review", Icons.trending_up),
      const _AppDef("Talent Management", Icons.groups_outlined, isNew: true),
      const _AppDef("Insight", Icons.insights_outlined),
      _AppDef("Timesheet", Icons.timer_outlined, real: const TimesheetPage()),
      const _AppDef("Document Template", Icons.description_outlined),
      const _AppDef("Recruitment", Icons.person_search_outlined, isNew: true),
      const _AppDef("Talentics", Icons.psychology_outlined),
      const _AppDef("Marketplace", Icons.storefront_outlined),
    ];
    return DashboardCard(
      title: Strings.titleApplications,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final app in apps)
              _AppTile(
                label: app.label,
                icon: app.icon,
                isNew: app.isNew,
                onTap: () {
                  if (app.real != null) {
                    openNewUI(context, app.real!);
                  } else {
                    openNewUI(context,
                        ComingSoonPage(feature: app.label, icon: app.icon));
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AppDef {
  final String label;
  final IconData icon;
  final Widget? real;
  final bool isNew;

  const _AppDef(this.label, this.icon, {this.real, this.isNew = false});
}

class _AppTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isNew;

  const _AppTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 118,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: kPrimaryColor),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: TitleTextView(
                      label,
                      textSize: 11,
                      fontFamily: Fonts.gilroy_medium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (isNew) ...[
                    const SizedBox(width: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC62828),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("New",
                          style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
