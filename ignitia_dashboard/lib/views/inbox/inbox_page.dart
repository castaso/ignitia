import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/repo/api_status.dart';
import 'package:ignitia_dashboard/repo/dashboard_services.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

/// Inbox (spec item 6): system notifications + employee requests that need
/// processing, with mark-as-read.
class InboxPage extends StatefulWidget {
  const InboxPage({Key? key}) : super(key: key);

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final Map<String, IconData> _typeIcons = {
    "announcement": Icons.campaign_outlined,
    "asset": Icons.inventory_2_outlined,
    "system": Icons.notifications_outlined,
  };

  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    var res = await DashboardService.getNotifications();
    if (res is Success && res.response is List) {
      _items = (res.response as List)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _markRead(int id) async {
    // The read endpoint lives on the server; best-effort call.
    try {
      await DashboardService.markNotificationRead(id);
    } catch (_) {}
    _items = [
      for (final item in _items)
        if (item["id"] == id)
          {...item, "is_read": 1}
        else
          item
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(title: Strings.textInbox),
      body: Row(
        children: [
          mediaSize.width > webWidth
              ? Flexible(flex: 1, child: MenuPage())
              : Container(),
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? const Center(
                          child: TitleTextView(
                            Strings.textEmpty,
                            textAlign: TextAlign.center,
                            textColor: subTitleTextColor,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final title = (item["title"] ?? "").toString();
                            final body = (item["body"] ?? "").toString();
                            final type = (item["type"] ?? "system").toString();
                            final isRead = (item["is_read"] ?? 0) == 1;
                            final time = (item["created_at"] ?? "").toString();
                            return Card(
                              elevation: 0,
                              color: isRead ? Colors.white : kPrimaryLightColor.withValues(alpha: 0.06),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () => _markRead((item["id"] as int? ?? 0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _typeIcons[type] ??
                                            Icons.notifications_outlined,
                                        color: kPrimaryColor,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                if (!isRead)
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    margin: const EdgeInsets.only(right: 6),
                                                    decoration: const BoxDecoration(
                                                        color: kPrimaryLightColor,
                                                        shape: BoxShape.circle),
                                                  ),
                                                Expanded(
                                                  child: TitleTextView(
                                                    title,
                                                    textSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (body.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              TitleTextView(
                                                body,
                                                textSize: 12,
                                                fontFamily: Fonts.gilroy_regular,
                                                textColor: subTitleTextColor,
                                                maxLines: 2,
                                              ),
                                            ],
                                            const SizedBox(height: 4),
                                            TitleTextView(
                                              time,
                                              textSize: 11,
                                              fontFamily: Fonts.gilroy_regular,
                                              textColor: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isRead)
                                        IconButton(
                                          tooltip: "Mark as read",
                                          icon: const Icon(
                                              Icons.mark_email_read, size: 18),
                                          color: kPrimaryColor,
                                          onPressed: () =>
                                              _markRead((item["id"] as int? ?? 0)),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
