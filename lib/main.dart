import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rmscanner/core/router/app_router.dart';
import 'package:rmscanner/core/theme/app_theme.dart';
import 'package:rmscanner/core/theme/bloc/theme_bloc.dart';
import 'package:rmscanner/core/localization/bloc/language_bloc.dart';
import 'package:rmscanner/core/localization/app_localizations.dart';
import 'package:rmscanner/core/utils/app_strings.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_bloc.dart';
import 'package:rmscanner/features/files/presentation/bloc/files_event.dart';
import 'package:rmscanner/core/services/file_service.dart';
import 'package:rmscanner/core/services/ad_service.dart';
import 'package:rmscanner/core/widgets/global_snackbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService().init();
  final prefs = await SharedPreferences.getInstance();
  final themeStr = prefs.getString('theme_mode') ?? 'light';
  final initialThemeMode = themeStr == 'dark'
      ? ThemeMode.dark
      : ThemeMode.light;
  AppTheme.useSystemFont = prefs.getBool('use_system_font') ?? false;
  Bloc.observer = const AppBlocObserver();
  runApp(RmscannerApp(initialThemeMode: initialThemeMode));
}

class RmscannerApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  const RmscannerApp({super.key, required this.initialThemeMode});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ThemeBloc(initialMode: initialThemeMode)..add(LoadTheme()),
        ),
        BlocProvider(create: (context) => LanguageBloc()..add(LoadLanguage())),
        BlocProvider(
          create: (context) =>
              FilesBloc(fileService: FileService())..add(LoadFiles()),
        ),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, langState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp.router(
                scaffoldMessengerKey: GlobalSnackBar.key,
                title: AppStrings.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,
                routerConfig: appRouter,
                locale: langState.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('id'),
                  Locale('bn'),
                  Locale('hi'),
                  Locale('fr'),
                  Locale('de'),
                  Locale('ar'),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }
}
