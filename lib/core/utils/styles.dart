import 'package:flutter/material.dart';
import 'package:rmscanner/core/utils/dimensions.dart';
import 'package:rmscanner/core/constants/app_colors.dart';

class Styles {
  static TextStyle appBarTitle(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: color);
  }

  static TextStyle sectionHeading(BuildContext context) {
    final color = AppColors.blueGrey.withValues(alpha: 0.8);
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: Dimensions.fontSmall,
      color: color,
      letterSpacing: 0.8,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: Dimensions.font,
      color: color,
    );
  }

  static TextStyle cardSubtitle(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return TextStyle(fontSize: Dimensions.fontSubtitle, color: color);
  }

  static TextStyle sectionTitle(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: Dimensions.font18,
      color: color,
    );
  }

  static TextStyle smallMutedWhite() {
    return const TextStyle(
      color: AppColors.white70,
      fontSize: Dimensions.fontSmall,
    );
  }

  static TextStyle settingsTitle(
    BuildContext context, {
    bool destructive = false,
  }) {
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: Dimensions.fontSmall,
      color: color,
    );
  }

  static TextStyle settingsSubtitle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: Dimensions.fontSubtitle,
    );
  }

  // Loader dialog title
  static TextStyle loaderTitle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: Dimensions.font15,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  // Loader subtitle/hint
  static TextStyle loaderSubtitle(BuildContext context) {
    return TextStyle(
      fontSize: Dimensions.fontSubtitle,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  // File item title
  static TextStyle fileItemTitle(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: Dimensions.font,
    );
  }

  // File item subtitle
  static TextStyle fileItemSubtitle(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return TextStyle(
      color: color.withValues(alpha: 0.7),
      fontSize: Dimensions.fontSubtitle,
    );
  }

  // Empty state title
  static TextStyle emptyStateTitle(BuildContext context) {
    return TextStyle(fontSize: Dimensions.font18, color: AppColors.grey400);
  }

  // Button text
  static TextStyle buttonText() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: Dimensions.fontSmall,
    );
  }

  // Tab text
  static TextStyle tabText(BuildContext context, {bool isSelected = false}) {
    final color = isSelected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      color: color,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      fontSize: Dimensions.fontBody,
    );
  }

  // Settings header
  static TextStyle settingsHeader(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
      fontSize: Dimensions.fontSmall,
    );
  }

  // Premium badge text
  static const TextStyle premiumBadgeTitle = TextStyle(
    color: AppColors.white,
    fontWeight: FontWeight.bold,
    fontSize: Dimensions.font18,
  );
  static const TextStyle premiumBadgeSubtitle = TextStyle(
    color: AppColors.white70,
    fontSize: Dimensions.fontSubtitle,
  );
}
