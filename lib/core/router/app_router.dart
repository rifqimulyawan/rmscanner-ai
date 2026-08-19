import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rmscanner/features/landing/presentation/pages/main_layout_screen.dart';
import 'package:rmscanner/features/home/presentation/pages/home_screen.dart';
import 'package:rmscanner/features/files/presentation/pages/files_screen.dart';
import 'package:rmscanner/features/tools/presentation/pages/tools_screen.dart';
import 'package:rmscanner/core/services/ocr_service.dart';
import 'package:rmscanner/features/ocr/presentation/bloc/ocr_bloc.dart';
import 'package:rmscanner/features/ocr/presentation/pages/ocr_screen.dart';
import 'package:rmscanner/features/ocr/presentation/pages/ocr_result_screen.dart';
import 'package:rmscanner/features/home/presentation/pages/scan_result_screen.dart';
import 'package:rmscanner/features/settings/presentation/pages/menu_screen.dart';
import 'package:rmscanner/features/settings/presentation/pages/about_screen.dart';
import 'package:rmscanner/features/splash/presentation/pages/splash_screen.dart';
import 'package:rmscanner/features/tools/presentation/pages/qr_scanner_screen.dart';
import 'package:rmscanner/features/tools/presentation/pages/ai_prompt_screen.dart';
import 'package:rmscanner/features/onboarding/presentation/pages/onboard_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorFilesKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellFiles');
final GlobalKey<NavigatorState> _shellNavigatorToolsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellTools');
final GlobalKey<NavigatorState> _shellNavigatorOcrKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellOcr');
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellSettings');
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboard',
      name: 'onboard',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/qr-scanner',
      name: 'qr-scanner',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const QrScannerScreen(),
    ),
    GoRoute(
      path: '/ai-prompt',
      name: 'ai-prompt',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final text = state.extra as String? ?? '';
        return AiPromptScreen(documentText: text);
      },
    ),
    GoRoute(
      path: '/scan-result',
      name: 'scan-result',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final imagePaths = state.extra as List<String>? ?? [];
        return ScanResultScreen(scannedImagePaths: imagePaths);
      },
    ),
    GoRoute(
      path: '/ocr-result',
      name: 'ocr-result',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return OcrResultScreen(
          text: extra?['text'] as String? ?? '',
          wordCount: extra?['wordCount'] as int? ?? 0,
          characterCount: extra?['characterCount'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AboutScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayoutScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorFilesKey,
          routes: [
            GoRoute(
              path: '/files',
              builder: (context, state) => const FilesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorToolsKey,
          routes: [
            GoRoute(
              path: '/tools',
              builder: (context, state) => const ToolsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorOcrKey,
          routes: [
            GoRoute(
              path: '/ocr',
              builder: (context, state) => BlocProvider(
                create: (context) => OcrBloc(ocrService: OcrService()),
                child: const OcrScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const MenuScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
