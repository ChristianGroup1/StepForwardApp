import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/utils/app_colors.dart';
import 'package:stepforward/core/utils/app_text_styles.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/core/utils/spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductsSectionHomeView extends StatelessWidget {
  const ProductsSectionHomeView({super.key});

  Future<void> _openWebsite(BuildContext context, String urlValue) async {
    final url = Uri.parse(urlValue);
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      final isEn = context.isEn;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEn ? 'Could not open website' : 'تعذر فتح الموقع'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isEn ? 'Our Websites' : 'مواقعنا',
                  style: TextStyles.bold16.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            verticalSpace(12),
            _WebsiteCard(
              title: 'Step Forward Team',
              subtitle: isEn
                  ? 'Visit the main Step Forward website.'
                  : 'افتح الموقع الرئيسي لفريق Step Forward.',
              icon: Icons.public_rounded,
              onTap: () => _openWebsite(context, kStepForwardTeamUrl),
            ),
            verticalSpace(10),
            _WebsiteCard(
              title: 'Bible Mystery',
              subtitle: isEn
                  ? 'Open cases, read clues, and solve the mystery.'
                  : 'افتح القضايا، اقرأ الدلائل، واكتشف السر.',
              icon: Icons.manage_search_rounded,
              onTap: () => _openWebsite(context, kBibleMysteryUrl),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebsiteCard extends StatelessWidget {
  const _WebsiteCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 30),
            ),
            horizontalSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.bold16.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  verticalSpace(6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.regular14.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            horizontalSpace(8),
            Icon(
              Icons.open_in_new_rounded,
              color: AppColors.primaryColor.withValues(alpha: 0.9),
            ),
          ],
        ),
      ),
    );
  }
}
