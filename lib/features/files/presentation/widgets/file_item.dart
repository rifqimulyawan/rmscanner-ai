import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/utils/styles.dart';

class FileItem extends StatelessWidget {
  final String title;
  final String date;
  final String size;
  final String type;
  // pdf, image, text
  final VoidCallback onTap;
  final VoidCallback onMoreTap;
  const FileItem({
    super.key,
    required this.title,
    required this.date,
    required this.size,
    required this.type,
    required this.onTap,
    required this.onMoreTap,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    IconData icon;
    Color iconColor;
    switch (type.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'image':
        icon = Icons.image;
        iconColor = Colors.blue;
        break;
      default:
        icon = Icons.description;
        iconColor = colorScheme.primary;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.gapSmall),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: isDark
            ? Border.all(color: colorScheme.outline.withValues(alpha: 0.15))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.padding, vertical: Dimensions.paddingSmall + 2),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: Dimensions.iconSmall20,
                  ),
                ),
                const Gap(Dimensions.padding),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Styles.fileItemTitle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(Dimensions.gapSmall),
                      Text(
                        '$date \u2022 $size',
                        style: Styles.fileItemSubtitle(context),
                      ),
                    ],
                  ),
                ),
                // More Action
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  onPressed: onMoreTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
