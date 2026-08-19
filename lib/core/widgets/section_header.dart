import 'package:flutter/material.dart';
import 'package:rmscanner/core/utils/styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
  });
  @override
  Widget build(BuildContext context) {
    if (actionText != null && onActionTap != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Styles.sectionTitle(context)),
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerRight,
            ),
            child: Text(
              actionText!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      );
    }
    return Text(title, style: Styles.sectionTitle(context));
  }
}
