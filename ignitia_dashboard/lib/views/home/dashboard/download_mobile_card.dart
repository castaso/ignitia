import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dashboard_card.dart';

/// Download Ignitia Mobile card (spec item 19).
class DownloadMobileCard extends StatelessWidget {
  const DownloadMobileCard({Key? key}) : super(key: key);

  void _open(Uri uri) {
    launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {});
  }

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: Strings.textDownloadMobile,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: _StoreButton(
                icon: Icons.apple,
                label: Strings.textAppStore,
                onTap: () => _open(
                    Uri.parse("https://apps.apple.com/app/ignitia-mobile")),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StoreButton(
                icon: Icons.play_circle_outline,
                label: Strings.textGooglePlay,
                onTap: () => _open(
                    Uri.parse("https://play.google.com/store/apps/details?id=com.ignitia.mobile")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _StoreButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: kPrimaryColor),
          const SizedBox(width: 6),
          TitleTextView(label,
              textSize: 12,
              fontFamily: Fonts.gilroy_semibold,
              textColor: kPrimaryColor),
        ],
      ),
    );
  }
}
