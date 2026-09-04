import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/common/coming_soon_page.dart';
import 'package:ignitia_dashboard/views/employee/employee_list_page.dart';
import 'package:ignitia_dashboard/views/settings/company_profile_settings_page.dart';
import 'package:ignitia_dashboard/views/settings/integration_settings_page.dart';
import 'dashboard_card.dart';

/// Quick Links card (spec item 12).
class QuickLinksCard extends StatelessWidget {
  const QuickLinksCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: Strings.textQuickLinks,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuickLink(
            icon: Icons.badge_outlined,
            label: Strings.textMyInfo,
            onTap: () => openNewUI(context, const EmployeeListPage()),
          ),
          _QuickLink(
            icon: Icons.person_add_alt_1,
            label: Strings.textAddEmployee,
            onTap: () => openNewUI(context,
                const ComingSoonPage(feature: Strings.textAddEmployee, icon: Icons.person_add_alt_1)),
          ),
          _QuickLink(
            icon: Icons.swap_horiz,
            label: Strings.textEmployeeTransfer,
            onTap: () => openNewUI(context, const ComingSoonPage(
                feature: Strings.textEmployeeTransfer,
                icon: Icons.swap_horiz)),
          ),
          _QuickLink(
            icon: Icons.apartment_outlined,
            label: Strings.textCompanySettings,
            onTap: () =>
                openNewUI(context, const CompanyProfileSettingsPage()),
          ),
          _QuickLink(
            icon: Icons.extension_outlined,
            label: Strings.textIntegration,
            onTap: () =>
                openNewUI(context, const IntegrationSettingsPage()),
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: kPrimaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: TitleTextView(label,
                  textSize: 13, fontFamily: Fonts.gilroy_medium),
            ),
            Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
