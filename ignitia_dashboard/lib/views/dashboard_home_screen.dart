import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/utils/shared_preference.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/view_models/dashboard_view_model.dart';
import 'package:ignitia_dashboard/views/admin/attendance/approve_overtime_page.dart';
import 'package:ignitia_dashboard/views/admin/leave/holiday_page.dart';
import 'package:ignitia_dashboard/views/employee/employee_list_page.dart';
import 'package:ignitia_dashboard/views/home/dashboard/applications_card.dart';
import 'package:ignitia_dashboard/views/home/dashboard/balance_time_off_card.dart';
import 'package:ignitia_dashboard/views/home/dashboard/chart_card.dart';
import 'package:ignitia_dashboard/views/home/dashboard/download_mobile_card.dart';
import 'package:ignitia_dashboard/views/home/dashboard/feed_tabs_card.dart';
import 'package:ignitia_dashboard/views/home/dashboard/greeting_card.dart';
import 'package:ignitia_dashboard/views/home/dashboard/promo_banner_card.dart';
import 'package:ignitia_dashboard/views/home/dashboard/quick_links_card.dart';
import 'package:ignitia_dashboard/views/home/dashboard/whos_off_card.dart';
import 'package:ignitia_dashboard/views/home/top_bar_widget.dart';
import 'package:ignitia_dashboard/views/inbox/inbox_page.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';
import 'package:ignitia_dashboard/views/shift/assign_shift_page.dart';
import 'package:ignitia_dashboard/views/shift/shift_page.dart';

/// Dashboard home (Ignitia Super-Admin layout per dashboard.docx).
/// When the user switches to the old navigation (spec item 8), the legacy
/// "Go To" grid layout is shown instead.
class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  bool _useOldNavigation = false;

  @override
  void initState() {
    super.initState();
    SessionManager.getUseOldNavigation().then((useOld) {
      if (mounted) setState(() => _useOldNavigation = useOld);
    });
    final viewModel =
        Provider.of<DashboardViewModel>(context, listen: false);
    viewModel.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    if (_useOldNavigation) {
      return _oldNavigationUI();
    }
    var mediaSize = MediaQuery.of(context).size;
    final viewModel = context.watch<DashboardViewModel>();
    return Scaffold(
      backgroundColor: pageBGColor,
      body: SafeArea(
        child: Column(
          children: [
            const TopBarWidget(),
            Divider(height: 1, color: Colors.grey.shade300),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  mediaSize.width > webWidth
                      ? Flexible(flex: 1, child: MenuPage())
                      : Container(),
                  Flexible(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (viewModel.pendingApprovalsTotal > 0)
                            _payrollAlertBanner(
                                context, viewModel.pendingApprovalsTotal),
                          if (viewModel.pendingApprovalsTotal > 0)
                            const SizedBox(height: 12),
                          const GreetingCard(),
                          const SizedBox(height: 12),
                          const ChartSection(),
                          const SizedBox(height: 12),
                          mediaSize.width > webWidth
                              ? Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: const [
                                    Expanded(
                                      child: _LeftColumn(),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: _CenterColumn(),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: _RightColumn(),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: const [
                                    _LeftColumn(),
                                    SizedBox(height: 12),
                                    _CenterColumn(),
                                    SizedBox(height: 12),
                                    _RightColumn(),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _payrollAlertBanner(BuildContext context, int pending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF0D48A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 18, color: Color(0xFFB7791F)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "There are $pending request(s) that need to be processed. Please review the pending approvals.",
              style: const TextStyle(fontSize: 12, color: Color(0xFF7A5A12)),
            ),
          ),
          TextButton(
            onPressed: () => openNewUI(context, const InboxPage()),
            child: const Text("View",
                style: TextStyle(fontSize: 12, color: kPrimaryColor)),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // Legacy layout (kept for the "Switch to old navigation" option)
  // ------------------------------------------------------------------------

  Widget _oldNavigationUI() {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: pageBGColor,
      appBar: AppBar(
        leading: Transform.scale(
            scale: 2.5,
            child: IconButton(
              icon: Image.asset(
                'assets/images/eb_logo.png',
                height: 15,
              ),
              onPressed: () {},
            )),
        title: const Text(Strings.titleDashboardHomePage),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () async {
                await SessionManager.setUseOldNavigation(false);
                openNewUIWithReplacement(context, const DashboardHomeScreen());
              },
              child: const Text("New navigation"),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mediaSize.width > webWidth
                ? Flexible(flex: 1, child: MenuPage())
                : Container(),
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleTextView("${Strings.titleGoTo}:", textSize: 14),
                    const SizedBox(height: 10),
                    Expanded(child: _quickAccessGrid(mediaSize)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAccessGrid(Size mediaSize) {
    var columns = mediaSize.width > webWidth ? 4 : 2;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _quickAccessList.length,
      itemBuilder: (BuildContext context, int index) {
        return _quickAccessItem(index);
      },
    );
  }

  List<_QuickItem> _quickAccessList = [
    _QuickItem(Strings.titleEmployeeListPage, const EmployeeListPage()),
    _QuickItem(Strings.titleApproveOvertimePage, const ApproveOvertimePage()),
    _QuickItem(Strings.titleHolidayPage, const HolidayPage()),
    _QuickItem(Strings.titleShiftPage, const ShiftPage()),
    _QuickItem(Strings.titleAssignShiftPage, const AssignShiftPage()),
  ];

  Widget _quickAccessItem(int index) {
    var item = _quickAccessList[index];
    return Card(
      elevation: 1,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          openNewUI(context, item.page);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.dashboard_outlined,
                size: 30, color: kPrimaryColor),
            const SizedBox(height: 10),
            TitleTextView(
              item.name,
              textAlign: TextAlign.center,
              fontFamily: Fonts.gilroy_regular,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickItem {
  final String name;
  final Widget page;

  const _QuickItem(this.name, this.page);
}

/// Left column: Quick Links, Applications, Download Mobile.
class _LeftColumn extends StatelessWidget {
  const _LeftColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        QuickLinksCard(),
        SizedBox(height: 12),
        ApplicationsCard(),
        SizedBox(height: 12),
        DownloadMobileCard(),
      ],
    );
  }
}

/// Center column: promo banner + tabbed feed.
class _CenterColumn extends StatelessWidget {
  const _CenterColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        PromoBannerCard(),
        SizedBox(height: 12),
        FeedTabsCard(),
      ],
    );
  }
}

/// Right column: balances + Who's Off.
class _RightColumn extends StatelessWidget {
  const _RightColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        BalanceTimeOffCard(),
        SizedBox(height: 12),
        WhosOffCard(),
      ],
    );
  }
}
