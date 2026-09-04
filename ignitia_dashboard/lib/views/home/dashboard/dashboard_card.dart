import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/string.dart';

/// Consistent card shell for the dashboard grid (title row + body + optional
/// trailing action). Mirrors the white-card style of the existing hubs.
class DashboardCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  final bool loading;
  final double? minHeight;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.child,
    this.trailing,
    this.loading = false,
    this.minHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TitleTextView(title, textSize: 15),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Expanded(
              child: minHeight != null
                  ? SizedBox(height: minHeight, child: child)
                  : child,
            ),
        ],
      ),
    );
  }
}

/// Small helper: "View all" style trailing button.
class CardActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const CardActionButton({Key? key, required this.label, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: const TextStyle(color: kPrimaryColor, fontSize: 12)),
    );
  }
}

/// One-line "nothing here yet" body.
class EmptyBody extends StatelessWidget {
  const EmptyBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TitleTextView(
          Strings.textEmpty,
          textSize: 13,
          fontFamily: Fonts.gilroy_regular,
          textColor: subTitleTextColor,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
