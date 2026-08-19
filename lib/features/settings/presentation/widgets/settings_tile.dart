import 'package:flutter/material.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/utils/styles.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  const SettingsTile({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDestructive
        ? colorScheme.error
        : colorScheme.primary;
    final Color bgColor = isDestructive
        ? colorScheme.error.withValues(alpha: isDark ? 0.2 : 0.1)
        : colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1);
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Dimensions.padding,
        vertical: 2,
      ),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Icon(icon, color: iconColor, size: Dimensions.iconSmall16),
      ),
      title: Text(
        title,
        style: Styles.settingsTitle(context, destructive: isDestructive),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Styles.settingsSubtitle(context))
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: Dimensions.iconSmall,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
    );
  }
}
