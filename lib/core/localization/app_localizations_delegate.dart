import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'app_localizations.dart';

/// Delegate for loading app localizations
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Support English, Spanish, French, and German
    return ['en', 'es', 'fr', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Return a SynchronousFuture here for synchronous initialization
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Supported locales for the app
class SupportedLocales {
  static const List<Locale> all = [
    Locale('en', 'US'), // English (United States)
    Locale('es', 'ES'), // Spanish (Spain)
    Locale('fr', 'FR'), // French (France)
    Locale('de', 'DE'), // German (Germany)
  ];

  static const Map<String, String> names = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
  };

  static const Map<String, String> nativeNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
  };

  static const Map<String, String> flags = {
    'en': '[EMOJI][EMOJI]',
    'es': '[EMOJI][EMOJI]',
    'fr': '[EMOJI][EMOJI]',
    'de': '[EMOJI][EMOJI]',
  };

  /// Get the display name for a locale
  static String getDisplayName(Locale locale) {
    return names[locale.languageCode] ?? locale.languageCode;
  }

  /// Get the native name for a locale
  static String getNativeName(Locale locale) {
    return nativeNames[locale.languageCode] ?? locale.languageCode;
  }

  /// Get the flag emoji for a locale
  static String getFlag(Locale locale) {
    return flags[locale.languageCode] ?? '';
  }

  /// Check if a locale is supported
  static bool isSupported(Locale locale) {
    return all.any((l) => l.languageCode == locale.languageCode);
  }

  /// Get the default locale (fallback)
  static const Locale defaultLocale = Locale('en', 'US');

  /// Get the best matching locale from device locales
  static Locale getBestMatch(List<Locale> deviceLocales) {
    for (final deviceLocale in deviceLocales) {
      for (final supportedLocale in all) {
        if (deviceLocale.languageCode == supportedLocale.languageCode) {
          return supportedLocale;
        }
      }
    }
    return defaultLocale;
  }
}