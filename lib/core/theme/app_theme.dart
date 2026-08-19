import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static bool useSystemFont = false;

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface: AppColors.background,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: useSystemFont
          ? ThemeData.light().textTheme.apply(
              bodyColor: AppColors.onSurface,
              displayColor: AppColors.onSurface,
            )
          : ThemeData.light().textTheme.apply(
              fontFamily: 'SamsungOne',
              bodyColor: AppColors.onSurface,
              displayColor: AppColors.onSurface,
            ),
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        titleTextStyle: useSystemFont
            ? const TextStyle(
                color: AppColors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )
            : const TextStyle(
                color: AppColors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'SamsungOne',
              ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF5B7BD9),
        onPrimary: AppColors.white,
        secondary: const Color(0xFF4FC4F0),
        onSecondary: AppColors.black,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.white,
        surfaceContainerHighest: AppColors.white10,
        onSurfaceVariant: AppColors.white70,
        outline: AppColors.white24,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: useSystemFont
          ? ThemeData.dark().textTheme.apply(
              bodyColor: AppColors.white,
              displayColor: AppColors.white,
            )
          : ThemeData.dark().textTheme.apply(
              fontFamily: 'SamsungOne',
              bodyColor: AppColors.white,
              displayColor: AppColors.white,
            ),
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.white10, width: 1),
        ),
      ),
    );
  }
}
