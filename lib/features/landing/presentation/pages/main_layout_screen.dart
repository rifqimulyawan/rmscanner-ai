import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/constants/app_colors.dart';

class MainLayoutScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainLayoutScreen({super.key, required this.navigationShell});
  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      drawer: const NavigationDrawerWidget(),
      body: navigationShell,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isDark
              ? Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.25),
                  width: 1.0,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTap,
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 60,
              indicatorColor: Colors.transparent,
              indicatorShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.zero),
              ),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                );
              }),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, size: 24, color: colorScheme.onSurface.withValues(alpha: 0.45)),
                  selectedIcon: Icon(Icons.home_rounded, color: colorScheme.primary, size: 24),
                  label: loc.tr('home'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_open_outlined, size: 24, color: colorScheme.onSurface.withValues(alpha: 0.45)),
                  selectedIcon: Icon(Icons.folder_open_rounded, color: colorScheme.primary, size: 24),
                  label: loc.tr('files'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.construction_outlined, size: 24, color: colorScheme.onSurface.withValues(alpha: 0.45)),
                  selectedIcon: Icon(Icons.construction_rounded, color: colorScheme.primary, size: 24),
                  label: loc.tr('tools'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.text_fields_outlined, size: 24, color: colorScheme.onSurface.withValues(alpha: 0.45)),
                  selectedIcon: Icon(Icons.text_fields_rounded, color: colorScheme.primary, size: 24),
                  label: loc.tr('ocr'),
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_outlined, size: 24, color: colorScheme.onSurface.withValues(alpha: 0.45)),
                  selectedIcon: Icon(Icons.menu_rounded, color: colorScheme.primary, size: 24),
                  label: loc.tr('menu'),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return NavigationDrawer(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: AppColors.primary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.qr_code_scanner, color: AppColors.white, size: 48),
              SizedBox(height: 12),
              Text(
                'RMScanner AI',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Total Free Premium Pro Scanner App',
                style: TextStyle(color: AppColors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.home_outlined),
          label: Text(loc.tr('home')),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.folder_outlined),
          label: Text(loc.tr('files')),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.grid_view),
          label: Text(loc.tr('tools')),
        ),
        const Divider(),
        NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          label: Text(loc.tr('settings')),
        ),
      ],
      onDestinationSelected: (index) {
        Navigator.pop(context);
        // Close drawer
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/files');
            break;
          case 2:
            context.go('/tools');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },
    );
  }
}
