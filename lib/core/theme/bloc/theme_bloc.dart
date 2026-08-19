import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/preferences_service.dart';

// Events
abstract class ThemeEvent {}

class LoadTheme extends ThemeEvent {}

class ChangeTheme extends ThemeEvent {
  final ThemeMode themeMode;
  ChangeTheme(this.themeMode);
}

// State
class ThemeState {
  final ThemeMode themeMode;
  ThemeState(this.themeMode);
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final PreferencesService _prefsService = PreferencesService();
  ThemeBloc({ThemeMode initialMode = ThemeMode.light})
    : super(ThemeState(initialMode)) {
    on<LoadTheme>((event, emit) async {
      final mode = await _prefsService.getThemeMode();
      emit(ThemeState(_getModeFromString(mode)));
    });
    on<ChangeTheme>((event, emit) async {
      await _prefsService.setThemeMode(event.themeMode.name);
      emit(ThemeState(event.themeMode));
    });
  }
  ThemeMode _getModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }
}
