import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations_delegate.dart';

/// Service for managing app locale and language preferences
class LocaleService {
  static const String _localeKey = 'app_locale';

  /// Get the currently saved locale from preferences
  Future<Locale?> getSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      
      if (localeCode != null) {
        // Parse locale code (e.g., 'en_US' or just 'en')
        final parts = localeCode.split('_');
        if (parts.length >= 2) {
          return Locale(parts[0], parts[1]);
        } else {
          return Locale(parts[0]);
        }
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
    }
    
    return null;
  }

  /// Save locale to preferences
  Future<void> saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = locale.countryCode != null 
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      
      await prefs.setString(_localeKey, localeCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Get the best locale to use based on saved preferences and device settings
  Future<Locale> getBestLocale(List<Locale> deviceLocales) async {
    // First, check for saved preference
    final savedLocale = await getSavedLocale();
    if (savedLocale != null && SupportedLocales.isSupported(savedLocale)) {
      return savedLocale;
    }

    // Fall back to device locale matching
    return SupportedLocales.getBestMatch(deviceLocales);
  }

  /// Clear saved locale (will use device locale)
  Future<void> clearSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localeKey);
    } catch (e) {
      debugPrint('Error clearing saved locale: $e');
    }
  }

  /// Check if right-to-left layout should be used
  bool isRTL(Locale locale) {
    // Add RTL languages here when supported
    const rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(locale.languageCode);
  }

  /// Get text direction for a locale
  TextDirection getTextDirection(Locale locale) {
    return isRTL(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Format numbers according to locale
  String formatNumber(int number, Locale locale) {
    // In a real app, use NumberFormat from intl package
    return number.toString();
  }

  /// Format currency according to locale
  String formatCurrency(double amount, Locale locale) {
    // In a real app, use NumberFormat.currency from intl package
    switch (locale.languageCode) {
      case 'en':
        return '\$${amount.toStringAsFixed(2)}';
      case 'es':
        return '€${amount.toStringAsFixed(2)}';
      case 'fr':
        return '${amount.toStringAsFixed(2)} €';
      case 'de':
        return '${amount.toStringAsFixed(2).replaceAll('.', ',')} €';
      default:
        return amount.toStringAsFixed(2);
    }
  }

  /// Get locale-specific date format pattern
  String getDateFormatPattern(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'MM/dd/yyyy';
      case 'es':
      case 'fr':
      case 'de':
        return 'dd/MM/yyyy';
      default:
        return 'yyyy-MM-dd';
    }
  }

  /// Get locale-specific time format pattern
  String getTimeFormatPattern(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'h:mm a'; // 12-hour format
      case 'es':
      case 'fr':
      case 'de':
        return 'HH:mm'; // 24-hour format
      default:
        return 'HH:mm';
    }
  }

  /// Get week start day for locale (0 = Sunday, 1 = Monday)
  int getWeekStartDay(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 0; // Sunday
      case 'es':
      case 'fr':
      case 'de':
        return 1; // Monday
      default:
        return 1; // Monday as default
    }
  }

  /// Get calendar type for locale
  String getCalendarType(Locale locale) {
    // Most supported locales use Gregorian calendar
    return 'gregorian';
  }

  /// Get measurement units for locale
  String getMeasurementUnit(String type, Locale locale) {
    switch (type) {
      case 'distance':
        return locale.languageCode == 'en' ? 'miles' : 'kilometers';
      case 'temperature':
        return locale.languageCode == 'en' ? 'fahrenheit' : 'celsius';
      case 'weight':
        return locale.languageCode == 'en' ? 'pounds' : 'kilograms';
      default:
        return 'metric';
    }
  }
}

/// Locale state notifier for managing app locale
class LocaleNotifier extends StateNotifier<Locale> {
  final LocaleService _localeService;

  LocaleNotifier(this._localeService) : super(SupportedLocales.defaultLocale) {
    _loadSavedLocale();
  }

  /// Load saved locale from preferences
  Future<void> _loadSavedLocale() async {
    final savedLocale = await _localeService.getSavedLocale();
    if (savedLocale != null && mounted) {
      state = savedLocale;
    }
  }

  /// Change the app locale
  Future<void> setLocale(Locale locale) async {
    if (!SupportedLocales.isSupported(locale)) {
      throw ArgumentError('Locale ${locale.languageCode} is not supported');
    }

    await _localeService.saveLocale(locale);
    state = locale;
  }

  /// Reset to system locale
  Future<void> resetToSystemLocale() async {
    await _localeService.clearSavedLocale();
    
    // Get device locales (this would come from the framework in a real scenario)
    const deviceLocales = [SupportedLocales.defaultLocale];
    final bestLocale = SupportedLocales.getBestMatch(deviceLocales);
    
    state = bestLocale;
  }

  /// Check if current locale is RTL
  bool get isRTL => _localeService.isRTL(state);

  /// Get text direction for current locale
  TextDirection get textDirection => _localeService.getTextDirection(state);

  /// Get available locales for selection
  List<Locale> get availableLocales => SupportedLocales.all;

  /// Format number according to current locale
  String formatNumber(int number) => _localeService.formatNumber(number, state);

  /// Format currency according to current locale
  String formatCurrency(double amount) => _localeService.formatCurrency(amount, state);
}

/// Providers for locale management
final localeServiceProvider = Provider<LocaleService>((ref) {
  return LocaleService();
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final localeService = ref.read(localeServiceProvider);
  return LocaleNotifier(localeService);
});

/// Helper extension for easy locale access
extension LocaleContext on BuildContext {
  /// Get current locale from provider
  Locale get locale => ProviderScope.containerOf(this).read(localeProvider);
  
  /// Get locale notifier
  LocaleNotifier get localeNotifier => 
      ProviderScope.containerOf(this).read(localeProvider.notifier);
  
  /// Check if current locale is RTL
  bool get isRTL => localeNotifier.isRTL;
  
  /// Get text direction for current locale
  TextDirection get textDirection => localeNotifier.textDirection;
}

/// Locale selection widget for settings
class LocaleSelector extends ConsumerWidget {
  final bool showFlags;
  final bool showNativeNames;

  const LocaleSelector({
    super.key,
    this.showFlags = true,
    this.showNativeNames = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    return Column(
      children: SupportedLocales.all.map((locale) {
        final isSelected = currentLocale.languageCode == locale.languageCode;
        
        return ListTile(
          leading: showFlags ? Text(
            SupportedLocales.getFlag(locale),
            style: const TextStyle(fontSize: 24),
          ) : null,
          title: Text(
            showNativeNames 
                ? SupportedLocales.getNativeName(locale)
                : SupportedLocales.getDisplayName(locale),
          ),
          subtitle: showNativeNames ? Text(
            SupportedLocales.getDisplayName(locale),
            style: Theme.of(context).textTheme.bodySmall,
          ) : null,
          trailing: isSelected ? Icon(
            Icons.check,
            color: Theme.of(context).colorScheme.primary,
          ) : null,
          selected: isSelected,
          onTap: () => localeNotifier.setLocale(locale),
        );
      }).toList(),
    );
  }
}

/// Animated locale transition widget
class LocaleTransition extends ConsumerWidget {
  final Widget child;
  final Duration duration;

  const LocaleTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(locale.languageCode),
        child: child,
      ),
    );
  }
}