import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/screens/profile/settings_screen.dart';

/// Provider that manages the app's locale based on user preferences
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// State notifier for managing the app locale
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  /// Load the saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language') ?? 'en';
      state = Locale(languageCode);
    } catch (e) {
      // Keep default locale if loading fails
      state = const Locale('en');
    }
  }

  /// Set the app locale and save to SharedPreferences
  Future<void> setLocale(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      state = Locale(languageCode);
    } catch (e) {
      // Keep current locale if saving fails
    }
  }

  /// Get the current language code
  String get currentLanguageCode => state.languageCode;

  /// Check if the current locale is Norwegian
  bool get isNorwegian => state.languageCode == 'no';

  /// Check if the current locale is English
  bool get isEnglish => state.languageCode == 'en';
}
