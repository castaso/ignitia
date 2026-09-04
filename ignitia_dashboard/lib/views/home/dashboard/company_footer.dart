import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/view_models/dashboard_view_model.dart';
import 'package:ignitia_dashboard/views/settings/company_profile_settings_page.dart';

/// Company ID footer pinned to the bottom of the sidebar per the reference
/// layout. Hidden when no company record exists.
class CompanyFooter extends StatelessWidget {
  const CompanyFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    if (viewModel.companyCode.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.apartment_outlined, size: 22, color: kPrimaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleTextView(
                  Strings.textCompanyId,
                  textSize: 11,
                  fontFamily: Fonts.gilroy_regular,
                  textColor: Colors.grey,
                ),
                TitleTextView(
                  viewModel.companyCode,
                  textSize: 15,
                  fontFamily: Fonts.gilroy_semibold,
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () =>
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CompanyProfileSettingsPage())),
            child: const Text(Strings.textLearnMore,
                style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
