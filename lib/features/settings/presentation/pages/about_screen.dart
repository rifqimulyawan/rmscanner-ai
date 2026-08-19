import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/widgets/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: loc.tr('about')),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                    : colorScheme.primaryContainer.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/app_icon.png',
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
            const Gap(16),
            Text(
              'RMScanner AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(4),
            Text(
              '${loc.tr('app_version')}: v1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const Gap(8),
            Text(
              'Total Free Premium Pro Scanner App',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
            const Gap(24),
            Text(
              loc.tr('about_description'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const Gap(32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                loc.tr('features'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const Gap(12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.document_scanner_outlined,
                  label: loc.tr('scan_doc'),
                  color: AppColors.primary,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.text_fields,
                  label: loc.tr('ocr'),
                  color: AppColors.blue,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.picture_as_pdf_outlined,
                  label: loc.tr('pdf_tools'),
                  color: AppColors.red,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.qr_code_scanner,
                  label: loc.tr('qr_scanner'),
                  color: AppColors.purple,
                ),
              ],
            ),
            const Gap(32),
            _buildLinkTile(
              context,
              icon: Icons.privacy_tip_outlined,
              label: loc.tr('privacy_policy'),
              onTap: () => _launchUrl(
                'https://rmdigital.co.id/kebijakan-privasi/',
              ),
            ),
            const Gap(8),
            _buildLinkTile(
              context,
              icon: Icons.support_agent,
              label: loc.tr('contact_support'),
              onTap: () => _launchUrl('mailto:rmdigital.co.id@gmail.com'),
            ),
            const Gap(40),
            Text(
              '${loc.tr('developed_by')} RM Digital',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const Gap(8),
            Text(
              '© 2024 RM Digital. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const Gap(24),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const Gap(10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colorScheme.primary),
            const Gap(12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
