import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rmscanner/core/services/preferences_service.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/constants/app_colors.dart';

class OnboardData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Color iconColor;
  OnboardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.iconColor,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;
  List<OnboardData> getPages(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final tertiary = Theme.of(context).colorScheme.tertiary;
    return [
      OnboardData(
        title: loc.tr('onboard_title_1'),
        description: loc.tr('onboard_desc_1'),
        icon: Icons.document_scanner_outlined,
        gradientColors: isDark
            ? [primary.withValues(alpha: 0.3), primary.withValues(alpha: 0.1)]
            : [primary, AppColors.blue],
        iconColor: Colors.white,
      ),
      OnboardData(
        title: loc.tr('onboard_title_2'),
        description: loc.tr('onboard_desc_2'),
        icon: Icons.text_snippet_outlined,
        gradientColors: isDark
            ? [secondary.withValues(alpha: 0.3), secondary.withValues(alpha: 0.1)]
            : [AppColors.blue, secondary],
        iconColor: Colors.white,
      ),
      OnboardData(
        title: loc.tr('onboard_title_3'),
        description: loc.tr('onboard_desc_3'),
        icon: Icons.share_outlined,
        gradientColors: isDark
            ? [tertiary.withValues(alpha: 0.3), tertiary.withValues(alpha: 0.1)]
            : [tertiary, AppColors.purple],
        iconColor: Colors.white,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefService = PreferencesService();
    await prefService.setHasSeenOnboarding(true);
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == getPages(context).length - 1;
              });
            },
            itemCount: getPages(context).length,
            itemBuilder: (context, index) {
              final page = getPages(context)[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: page.gradientColors,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.2),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            size: 72,
                            color: page.iconColor,
                          )
                              .animate(delay: 200.ms)
                              .scale(
                                curve: Curves.easeOutBack,
                                duration: 600.ms,
                              ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.5),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.5),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip button
                    TextButton(
                      onPressed: () =>
                          _controller.jumpToPage(getPages(context).length - 1),
                      child: Text(
                        AppLocalizations.of(context).tr('skip'),
                        style: TextStyle(
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Indicator
                    SmoothPageIndicator(
                      controller: _controller,
                      count: getPages(context).length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: isDark
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        dotColor: isDark
                            ? Colors.black26
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    // Next/Done button
                    isLastPage
                        ? ElevatedButton(
                            onPressed: _completeOnboarding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                              foregroundColor: isDark
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              AppLocalizations.of(context).tr('start'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ).animate().scale()
                        : Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.white)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: IconButton.styleFrom(
                                foregroundColor: isDark
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.primary,
                                padding: const EdgeInsets.all(12),
                              ),
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
