import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/preferences_service.dart';

// Events
abstract class LanguageEvent {}

class LoadLanguage extends LanguageEvent {}

class ChangeLanguage extends LanguageEvent {
  final Locale locale;
  ChangeLanguage(this.locale);
}

// State
class LanguageState {
  final Locale locale;
  LanguageState(this.locale);
}

// Bloc
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final PreferencesService _prefsService = PreferencesService();
  static const _supportedLanguages = ['en', 'id', 'bn', 'hi', 'fr', 'de', 'ar'];

  LanguageBloc() : super(LanguageState(const Locale('id'))) {
    on<LoadLanguage>((event, emit) async {
      final langCode = await _prefsService.getLanguage();
      if (langCode == 'id') {
        // Check if this is a first launch (default value, never explicitly set)
        final prefs = await SharedPreferences.getInstance();
        final hasLangPref = prefs.containsKey('language');
        if (!hasLangPref) {
          // Auto-detect device language on first launch
          final deviceLang = ui.PlatformDispatcher.instance.locale.languageCode;
          final detectedLang = _supportedLanguages.contains(deviceLang)
              ? deviceLang
              : 'id';
          await _prefsService.setLanguage(detectedLang);
          emit(LanguageState(Locale(detectedLang)));
          return;
        }
      }
      emit(LanguageState(Locale(langCode)));
    });
    on<ChangeLanguage>((event, emit) async {
      await _prefsService.setLanguage(event.locale.languageCode);
      emit(LanguageState(event.locale));
    });
  }
}
