import 'package:flutter/material.dart';
import 'package:rmscanner/core/utils/app_images.dart';
import 'package:rmscanner/core/utils/dimensions.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.padding,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(Dimensions.radius),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Image.asset(
              AppImages.appLogo,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
