import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Limbile in care este disponibila aplicatia.
/// Engleza este limba implicita, prima in lista.
class AppLanguage {
  final String code;
  final String label;   // numele limbii scris in limba respectiva
  final String flag;

  const AppLanguage(this.code, this.label, this.flag);
}

const kSupportedLanguages = <AppLanguage>[
  AppLanguage('en', 'English', '🇬🇧'),
  AppLanguage('ro', 'Română', '🇷🇴'),
  AppLanguage('de', 'Deutsch', '🇩🇪'),
  AppLanguage('hu', 'Magyar', '🇭🇺'),
  AppLanguage('fr', 'Français', '🇫🇷'),
  AppLanguage('es', 'Español', '🇪🇸'),
  AppLanguage('it', 'Italiano', '🇮🇹'),
];

const _prefsKey = 'app_language';
const kDefaultLanguage = 'en';

/// Limba curenta a aplicatiei. Alegerea se pastreaza intre porniri.
final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    // Pornim cu limba implicita si incarcam alegerea salvata in fundal;
    // build() nu poate fi asincron, iar UI-ul se actualizeaza cand soseste.
    _loadSaved();
    return const Locale(kDefaultLanguage);
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null &&
        kSupportedLanguages.any((l) => l.code == saved) &&
        saved != state.languageCode) {
      state = Locale(saved);
    }
  }

  /// Schimba limba si o retine pentru pornirile urmatoare.
  Future<void> setLanguage(String code) async {
    if (!kSupportedLanguages.any((l) => l.code == code)) return;
    state = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }

  AppLanguage get current => kSupportedLanguages.firstWhere(
        (l) => l.code == state.languageCode,
        orElse: () => kSupportedLanguages.first,
      );
}
