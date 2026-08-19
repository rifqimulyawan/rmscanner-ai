import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rmscanner/core/services/preferences_service.dart';
import 'package:rmscanner/core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    final prefService = PreferencesService();
    final hasSeenOnboarding = await prefService.getHasSeenOnboarding();
    if (!mounted) return;
    if (hasSeenOnboarding) {
      context.go('/');
    } else {
      context.go('/onboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.backgroundDark.withValues(alpha: 0.85),
                  ]
                : [
                    colorScheme.primary.withValues(alpha: 0.12),
                    colorScheme.secondary.withValues(alpha: 0.08),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/app_icon.png',
                  height: 130,
                  fit: BoxFit.contain,
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(),
                const SizedBox(height: 24),
                Text(
                  'RMScanner AI',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                )
                    .animate()
                    .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 300.ms)
                    .fadeIn(delay: 300.ms),
                const SizedBox(height: 8),
                Text(
                  'Total Free Premium Pro Scanner App',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )
                    .animate()
                    .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 500.ms)
                    .fadeIn(delay: 500.ms),
                const Spacer(),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
