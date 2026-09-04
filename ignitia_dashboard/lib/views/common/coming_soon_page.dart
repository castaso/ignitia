import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/app_bar_widget.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';

/// Generic "Coming Soon" placeholder used by every module that has no
/// implementation yet (Recruitment, Finance, Payroll, Productivity, Forms,
/// Performance Review, Talent Management, Insight, Document Template,
/// Talentics, Marketplace, etc.).
class ComingSoonPage extends StatelessWidget {
  final String feature;
  final IconData icon;

  const ComingSoonPage({Key? key, required this.feature, this.icon = Icons.construction_outlined})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(title: feature),
      body: Row(
        children: [
          mediaSize.width > webWidth
              ? Flexible(flex: 1, child: MenuPage())
              : Container(),
          Flexible(
            flex: 3,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 64, color: kPrimaryLightColor),
                    const SizedBox(height: 16),
                    TitleTextView(feature, textSize: 20),
                    const SizedBox(height: 10),
                    TitleTextView(
                      Strings.textComingSoon,
                      textSize: 16,
                      fontFamily: Fonts.gilroy_semibold,
                      textColor: kPrimaryColor,
                    ),
                    const SizedBox(height: 12),
                    TitleTextView(
                      Strings.textComingSoonHint,
                      textSize: 13,
                      fontFamily: Fonts.gilroy_regular,
                      textAlign: TextAlign.center,
                      textColor: subTitleTextColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
