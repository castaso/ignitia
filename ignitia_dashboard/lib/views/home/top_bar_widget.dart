import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/global_fields.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/utils/shared_preference.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/view_models/dashboard_view_model.dart';
import 'package:ignitia_dashboard/views/admin/leave/add_holiday_page.dart';
import 'package:ignitia_dashboard/views/common/coming_soon_page.dart';
import 'package:ignitia_dashboard/views/company_admin/announcement/announcement_page.dart';
import 'package:ignitia_dashboard/views/dashboard_home_screen.dart';
import 'package:ignitia_dashboard/views/employee/employee_list_page.dart';
import 'package:ignitia_dashboard/views/inbox/inbox_page.dart';
import 'package:ignitia_dashboard/views/settings/company_profile_settings_page.dart';
import 'package:ignitia_dashboard/views/settings/user_role_settings_page.dart';
import 'package:ignitia_dashboard/views/shift/add_shift_page.dart';
import 'package:ignitia_dashboard/views/time_management/leave/leave_tm_page.dart';

/// Top bar for the Super-Admin dashboard (spec items 1-8):
/// logo, core/non-core, AI summarize, quick action, search, inbox,
/// switch app, profile menu.
class TopBarWidget extends StatelessWidget {
  const TopBarWidget({Key? key}) : super(key: key);

  void _openSearch(BuildContext context, String query) {
    if (query.trim().isEmpty) return;
    openNewUI(context, EmployeeListPage(searchQuery: query.trim()));
  }

  void _showAiSummaryDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AiSummaryDialog(),
    );
  }

  void _showPicContactDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: TitleTextView(Strings.textRequestPicContact, textSize: 16),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              TextField(
                decoration: InputDecoration(hintText: "Contact name"),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(hintText: "Email"),
              ),
              SizedBox(height: 10),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(hintText: "Message"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.btnTextCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("PIC contact request sent.")),
              );
            },
            child: const Text(Strings.btnTextOk),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleOldNavigation(BuildContext context) async {
    final useOld = await SessionManager.getUseOldNavigation();
    await SessionManager.setUseOldNavigation(!useOld);
    openNewUIWithReplacement(context, const DashboardHomeScreen());
  }

  void _showCoreNonCoreMenu(BuildContext context) {
    showMenu<int>(
      context: context,
      position: const RelativeRect.fromLTRB(40, 56, 0, 0),
      items: const [
        PopupMenuItem(value: 1, child: Text("Insight")),
        PopupMenuItem(value: 2, child: Text("Performance Management")),
        PopupMenuItem(value: 3, child: Text("Recruitment")),
        PopupMenuItem(value: 4, child: Text("Announcements")),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 1:
          openNewUI(context,
              const ComingSoonPage(feature: "Insight", icon: Icons.insights_outlined));
          break;
        case 2:
          openNewUI(context,
              const ComingSoonPage(feature: "Performance Management", icon: Icons.trending_up));
          break;
        case 3:
          openNewUI(context,
              const ComingSoonPage(feature: "Recruitment", icon: Icons.person_search_outlined));
          break;
        case 4:
          openNewUI(context, const AnnouncementPage());
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > webWidth;
    final viewModel = context.watch<DashboardViewModel>();
    final searchController = TextEditingController();

    return Container(
      height: 56,
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 8),
          // 1. Company logo (tap -> Company settings)
          InkWell(
            onTap: () =>
                openNewUI(context, const CompanyProfileSettingsPage()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Image.asset('assets/images/naas_logo.png', height: 34),
            ),
          ),
          const SizedBox(width: 12),
          if (wide) ...[
            // 2. HRIS (Core & Non-Core destinations)
            _TopBarButton(
              icon: Icons.arrow_drop_down,
              label: "HRIS",
              onTap: () => _showCoreNonCoreMenu(context),
            ),
            const SizedBox(width: 6),
            // 3. Summarize data (AI)
            _TopBarButton(
              icon: Icons.auto_awesome,
              label: Strings.textSummarizeData,
              onTap: () => _showAiSummaryDialog(context),
            ),
            const SizedBox(width: 12),
            // 5. Search
            SizedBox(
              width: 260,
              child: TextField(
                controller: searchController,
                onSubmitted: (q) => _openSearch(context, q),
                decoration: InputDecoration(
                  hintText: Strings.textSearchEmployee,
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    onPressed: () => _openSearch(context, searchController.text),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // 4. Quick action
          PopupMenuButton<int>(
            tooltip: Strings.textQuickAction,
            icon: const Icon(Icons.add_circle_outline),
            onSelected: (value) {
              switch (value) {
                case 1:
                  openNewUI(context, const EmployeeListPage());
                  break;
                case 2:
                  openNewUI(context, const AddHolidayPage());
                  break;
                case 3:
                  openNewUI(context, const AddShiftPage());
                  break;
                case 4:
                  openNewUI(context, const LeaveTMPage());
                  break;
                case 5:
                  openNewUI(context, const ComingSoonPage(
                      feature: "Overtime Request",
                      icon: Icons.timelapse_outlined));
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 1, child: Text("Add Employee")),
              PopupMenuItem(value: 2, child: Text("Add Holiday")),
              PopupMenuItem(value: 3, child: Text("Add Shift")),
              PopupMenuItem(value: 4, child: Text("Request Time Off")),
              PopupMenuItem(value: 5, child: Text("Request Overtime")),
            ],
          ),
          // 6. Inbox
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: Strings.textInbox,
                icon: const Icon(Icons.mark_email_unread_outlined),
                onPressed: () => openNewUI(context, const InboxPage()),
              ),
              if (viewModel.unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      viewModel.unreadCount > 99
                          ? "99+"
                          : "${viewModel.unreadCount}",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          // 7. Switch app
          if (wide)
            PopupMenuButton<int>(
              tooltip: Strings.textSwitchApp,
              icon: const Icon(Icons.apps_outlined),
              onSelected: (value) {
                openNewUI(context,
                    ComingSoonPage(feature: _switchAppLabel(value)));
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 1, child: Text("Insight")),
                PopupMenuItem(value: 2, child: Text("Performance Management")),
                PopupMenuItem(value: 3, child: Text("Recruitment")),
                PopupMenuItem(value: 4, child: Text("Marketplace")),
              ],
            ),
          const Spacer(),
          // 8. Profile
          _ProfileMenu(
            onPicContact: () => _showPicContactDialog(context),
            onToggleOldNav: () => _toggleOldNavigation(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _switchAppLabel(int value) {
    switch (value) {
      case 1:
        return "Insight";
      case 2:
        return "Performance Management";
      case 3:
        return "Recruitment";
      default:
        return "Marketplace";
    }
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TopBarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: kPrimaryColor),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(fontSize: 12, color: titleTextColor)),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final VoidCallback onPicContact;
  final VoidCallback onToggleOldNav;

  const _ProfileMenu({required this.onPicContact, required this.onToggleOldNav});

  @override
  Widget build(BuildContext context) {
    final name = FieldValue.userName.isEmpty ? "User" : FieldValue.userName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "U";
    return PopupMenuButton<String>(
      tooltip: name,
      onSelected: (value) {
        switch (value) {
          case "my_info":
            openNewUI(context,
                const ComingSoonPage(
                    feature: Strings.textMyInfo,
                    icon: Icons.badge_outlined));
            break;
          case "account_settings":
            openNewUI(context, const UserRoleSettingsPage());
            break;
          case "company_info":
            openNewUI(context, const CompanyProfileSettingsPage());
            break;
          case "company_list":
            openNewUI(context,
                const ComingSoonPage(
                    feature: Strings.textCompanyList,
                    icon: Icons.apartment_outlined));
            break;
          case "pic_contact":
            onPicContact();
            break;
          case "old_nav":
            onToggleOldNav();
            break;
          case "support":
            openNewUI(context,
                const ComingSoonPage(
                    feature: Strings.textSupportCenter,
                    icon: Icons.headset_mic_outlined));
            break;
          case "help":
            openNewUI(context,
                const ComingSoonPage(
                    feature: Strings.textHelp, icon: Icons.help_outline));
            break;
          case "sign_out":
            logout(context);
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: "my_info", child: Text(Strings.textMyInfo)),
        PopupMenuItem(
            value: "account_settings", child: Text(Strings.textAccountSettings)),
        PopupMenuItem(value: "company_info", child: Text(Strings.textCompanyInfo)),
        PopupMenuItem(value: "company_list", child: Text(Strings.textCompanyList)),
        PopupMenuItem(value: "pic_contact", child: Text(Strings.textRequestPicContact)),
        PopupMenuItem(value: "old_nav", child: Text(Strings.textSwitchToOldNavigation)),
        PopupMenuItem(value: "support", child: Text(Strings.textSupportCenter)),
        PopupMenuItem(value: "help", child: Text(Strings.textHelp)),
        PopupMenuItem(value: "sign_out", child: Text(Strings.titleSignOut)),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: kPrimaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(initial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: titleTextColor),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Rule-based AI summary dialog (spec item 3).
class AiSummaryDialog extends StatefulWidget {
  const AiSummaryDialog({Key? key}) : super(key: key);

  @override
  State<AiSummaryDialog> createState() => _AiSummaryDialogState();
}

class _AiSummaryDialogState extends State<AiSummaryDialog> {
  @override
  void initState() {
    super.initState();
    final viewModel =
        Provider.of<DashboardViewModel>(context, listen: false);
    if (viewModel.aiSummaryText.isEmpty) {
      viewModel.loadAiSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    return Dialog(
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: kPrimaryColor, size: 22),
                const SizedBox(width: 8),
                TitleTextView(Strings.textSummarizeData, textSize: 16),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CLOSE"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: viewModel.aiSummaryLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Text(
                        viewModel.aiSummaryText.isEmpty
                            ? Strings.textEmpty
                            : viewModel.aiSummaryText,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: titleTextColor),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => viewModel.loadAiSummary(),
                child: const Text("REFRESH"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
