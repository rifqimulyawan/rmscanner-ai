import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/utils/styles.dart';

class ToolItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const ToolItem({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingLarge),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: Dimensions.iconLarge),
            ),
            const Gap(Dimensions.gapLarge),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Styles.cardTitle(context),
            ),
          ],
        ),
      ),
    );
  }
}
