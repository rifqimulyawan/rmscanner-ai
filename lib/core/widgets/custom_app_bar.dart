import 'package:flutter/material.dart';
import 'package:rmscanner/core/utils/app_images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? actionIcon;
  final VoidCallback? onActionTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actionIcon,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Container(
        height: kToolbarHeight,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Logo (~30%)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                          : colorScheme.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                      AppImages.appLogo,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // Center: Title
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            // Right: Action icon
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: actionIcon != null
                    ? IconButton(
                        onPressed: onActionTap,
                        icon: Icon(actionIcon, size: 22),
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
