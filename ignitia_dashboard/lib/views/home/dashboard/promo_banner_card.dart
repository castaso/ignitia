import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/views/common/coming_soon_page.dart';

/// Decorative promo banner above the feed tabs (Marketplace cross-promo),
/// per the reference layout.
class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B2BD9), Color(0xFF3B1A9E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                size: 38, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleTextView(
                  "Support employee financial wellness with Earned Wage Access",
                  textSize: 14,
                  fontFamily: Fonts.gilroy_semibold,
                  textColor: Colors.white,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => openNewUI(
                      context,
                      const ComingSoonPage(
                          feature: "Marketplace",
                          icon: Icons.storefront_outlined)),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6D00),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("Visit Marketplace",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward,
                            size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
