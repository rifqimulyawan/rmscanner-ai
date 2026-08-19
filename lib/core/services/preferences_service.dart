import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _autoEnhanceKey = 'auto_enhance';
  static const String _scanQualityKey = 'scan_quality';
  static const String _ocrLanguageKey = 'ocr_language';
  static const String _defaultPageSizeKey = 'default_page_size';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _useSystemFontKey = 'use_system_font';
  Future<bool> getHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, value);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'light';
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'id';
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<bool> getAutoEnhance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoEnhanceKey) ?? true;
  }

  Future<void> setAutoEnhance(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoEnhanceKey, value);
  }

  Future<String> getScanQuality() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_scanQualityKey) ?? 'High';
  }

  Future<void> setScanQuality(String quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scanQualityKey, quality);
  }

  Future<String> getOcrLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ocrLanguageKey) ?? 'Indonesian';
  }

  Future<void> setOcrLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ocrLanguageKey, language);
  }

  Future<String> getDefaultPageSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultPageSizeKey) ?? 'A4';
  }

  Future<void> setDefaultPageSize(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultPageSizeKey, size);
  }

  Future<bool> getUseSystemFont() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useSystemFontKey) ?? false;
  }

  Future<void> setUseSystemFont(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useSystemFontKey, value);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
