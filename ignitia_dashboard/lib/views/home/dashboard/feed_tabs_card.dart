import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/view_models/dashboard_view_model.dart';
import 'package:ignitia_dashboard/views/company_admin/announcement/announcement_page.dart';
import 'package:ignitia_dashboard/views/task/task_page.dart';
import 'dashboard_card.dart';

/// Tabbed feed panel (spec items 15-17): Announcement, Contract & Probation,
/// Tasks tabs with a shared Filter + Search row, per the reference layout.
class FeedTabsCard extends StatefulWidget {
  const FeedTabsCard({Key? key}) : super(key: key);

  @override
  State<FeedTabsCard> createState() => _FeedTabsCardState();
}

class _FeedTabsCardState extends State<FeedTabsCard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final TextEditingController _search = TextEditingController();
  String _query = "";
  String _announcementFilter = "ALL";
  String _contractFilter = "All";
  String _taskFilter = "All";

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {}));
    _search.addListener(() => setState(() => _query = _search.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  List<String> get _filterOptions {
    switch (_tabs.index) {
      case 1:
        return ["All", "Probation", "Contract"];
      case 2:
        return ["All", Strings.taskStatusOpen, Strings.taskStatusInProgress, Strings.taskStatusDone];
      default:
        return ["ALL", "DEPARTMENT", "ROLE"];
    }
  }

  String get _currentFilter {
    switch (_tabs.index) {
      case 1:
        return _contractFilter;
      case 2:
        return _taskFilter;
      default:
        return _announcementFilter;
    }
  }

  void _setFilter(String value) {
    setState(() {
      switch (_tabs.index) {
        case 1:
          _contractFilter = value;
          break;
        case 2:
          _taskFilter = value;
          break;
        default:
          _announcementFilter = value;
      }
    });
  }

  bool _matches(String text) =>
      _query.isEmpty || text.toLowerCase().contains(_query);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    final announcements = viewModel.filteredAnnouncements
        .where((a) =>
            (_announcementFilter == "ALL" ||
                (a["audience"] ?? "") == _announcementFilter) &&
            _matches("${a["title"] ?? ""} ${a["body"] ?? ""}"))
        .toList();
    final contracts = viewModel.contractProbation
        .where((r) =>
            (_contractFilter == "All" || (r["type"] ?? "") == _contractFilter) &&
            _matches("${r["name"] ?? ""} ${r["designation"] ?? ""}"))
        .toList();
    final tasks = viewModel.tasks
        .where((t) =>
            (_taskFilter == "All" || t.status == _taskFilter) &&
            _matches("${t.title} ${t.description ?? ""} ${t.assigneeName}"))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabs,
            labelColor: kPrimaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: kPrimaryColor,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: Strings.textAnnouncement),
              Tab(text: Strings.textContractProbation),
              Tab(text: Strings.textTask),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _currentFilter,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(6),
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
                  style: const TextStyle(fontSize: 12, color: titleTextColor),
                  items: [
                    for (final o in _filterOptions)
                      DropdownMenuItem(value: o, child: Text(o)),
                  ],
                  onChanged: (v) {
                    if (v != null) _setFilter(v);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, size: 16),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                if (_tabs.index == 0)
                  CardActionButton(
                    label: Strings.textManage,
                    onTap: () =>
                        openNewUI(context, const AnnouncementPage()),
                  ),
                if (_tabs.index == 2)
                  CardActionButton(
                    label: Strings.textManage,
                    onTap: () => openNewUI(context, const TaskPage()),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 340,
            child: TabBarView(
              controller: _tabs,
              children: [
                _announcementList(announcements),
                _contractList(contracts),
                _taskList(viewModel, tasks),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _announcementList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const EmptyBody();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final title = (item["title"] ?? "").toString();
        final body = (item["body"] ?? "").toString();
        final audience = (item["audience"] ?? "ALL").toString();
        final published =
            (item["publish_at"] ?? item["created_at"] ?? "").toString();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.campaign_outlined,
                    size: 16, color: kPrimaryColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleTextView(title, textSize: 13, maxLines: 2),
                    if (body.isNotEmpty)
                      TitleTextView(body,
                          textSize: 12,
                          fontFamily: Fonts.gilroy_regular,
                          textColor: subTitleTextColor,
                          maxLines: 2),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(audience,
                              style: const TextStyle(
                                  fontSize: 10, color: kPrimaryColor)),
                        ),
                        const SizedBox(width: 8),
                        TitleTextView(published,
                            textSize: 11,
                            fontFamily: Fonts.gilroy_regular,
                            textColor: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _contractList(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const EmptyBody();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        final name = (row["name"] ?? "").toString();
        final designation = (row["designation"] ?? "").toString();
        final type = (row["type"] ?? "").toString();
        final endDate = (row["end_date"] ?? "").toString();
        final days = (row["days_remaining"] as int? ?? 0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                type == "Probation"
                    ? Icons.school_outlined
                    : Icons.description_outlined,
                size: 18,
                color: kPrimaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleTextView(name,
                        textSize: 13,
                        fontFamily: Fonts.gilroy_medium,
                        maxLines: 1),
                    if (designation.isNotEmpty)
                      TitleTextView(designation,
                          textSize: 11,
                          fontFamily: Fonts.gilroy_regular,
                          textColor: Colors.grey),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(type,
                      style:
                          const TextStyle(fontSize: 11, color: kPrimaryColor)),
                  Text(
                    days < 0
                        ? "${-days} ${Strings.textOverdue}"
                        : "$days ${Strings.textDaysRemaining} · $endDate",
                    style: TextStyle(
                        fontSize: 11,
                        color: days < 0
                            ? const Color(0xFFC62828)
                            : Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _taskList(DashboardViewModel viewModel, List tasks) {
    if (tasks.isEmpty) return const EmptyBody();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final color = task.status == Strings.taskStatusDone
            ? successColor
            : task.status == Strings.taskStatusInProgress
                ? blYellowColor
                : kPrimaryLightColor;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                  width: 9,
                  height: 9,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleTextView(task.title, textSize: 13, maxLines: 1),
                    if (task.assigneeName.isNotEmpty)
                      TitleTextView(task.assigneeName,
                          textSize: 11,
                          fontFamily: Fonts.gilroy_regular,
                          textColor: Colors.grey),
                  ],
                ),
              ),
              if (task.dueDate != null && task.dueDate!.isNotEmpty)
                TitleTextView(task.dueDate!,
                    textSize: 11,
                    fontFamily: Fonts.gilroy_regular,
                    textColor: Colors.grey),
            ],
          ),
        );
      },
    );
  }
}
