import 'package:flutter/material.dart';
import 'package:rmscanner/core/constants/app_colors.dart';
import 'package:rmscanner/core/utils/styles.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;
  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLarge = false,
  });
  @override
  Widget build(BuildContext context) {
    final isSmallDevice = MediaQuery.of(context).size.width < 360;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallDevice ? 10 : 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Icon
                Container(
                  padding: EdgeInsets.all(isSmallDevice ? 6 : 8),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isLarge
                        ? (isSmallDevice ? 22 : 28)
                        : (isSmallDevice ? 18 : 20),
                  ),
                ),
                SizedBox(height: isSmallDevice ? 6 : 10),

                /// Title
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Styles.cardTitle(context).copyWith(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 2),

                /// Subtitle
                Flexible(
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Styles.cardSubtitle(context).copyWith(fontSize: 10),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
