import '../../data/models/aarti_item.dart';
import '../../data/models/verse_data.dart';

/// Supported script choices for rendering aarti titles and lyrics.
enum AppScriptLanguage {
  devanagari,
  english,
  gujarati,
}

/// Supported application language choices for translated meaning surfaces.
enum AppLanguage {
  english,
  hindi,
  gujarati,
}

/// Content modes shown in the aarti detail experience.
enum AartiDetailContentMode {
  lyrics,
  transliteration,
  meaning,
}

/// Central resolver for script-driven and language-driven aarti text selection.
class AartiLanguageResolver {
  const AartiLanguageResolver._();

  /// Converts persisted script mode values into a stable enum.
  static AppScriptLanguage scriptFromMode(int mode) {
    switch (mode) {
      case 1:
        return AppScriptLanguage.english;
      case 2:
        return AppScriptLanguage.gujarati;
      case 0:
      default:
        return AppScriptLanguage.devanagari;
    }
  }

  /// Converts persisted language codes into a stable enum.
  static AppLanguage appLanguageFromCode(String code) {
    switch (code) {
      case 'hi':
        return AppLanguage.hindi;
      case 'gu':
        return AppLanguage.gujarati;
      case 'en':
      default:
        return AppLanguage.english;
    }
  }

  /// Returns the script a user most likely reads for their selected app language.
  static AppScriptLanguage preferredScriptForLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return AppScriptLanguage.english;
      case AppLanguage.gujarati:
        return AppScriptLanguage.gujarati;
      case AppLanguage.hindi:
        return AppScriptLanguage.devanagari;
    }
  }

  /// Whether the detail screen should expose a separate transliteration tab.
  static bool shouldShowTransliteration({
    required int scriptMode,
    required String appLanguageCode,
    required List<VerseData> verses,
  }) {
    if (!hasTransliteration(verses)) {
      return false;
    }

    final AppScriptLanguage selectedScript = scriptFromMode(scriptMode);
    final AppLanguage appLanguage = appLanguageFromCode(appLanguageCode);
    return selectedScript != preferredScriptForLanguage(appLanguage);
  }

  /// Whether any verse contains transliteration lines.
  static bool hasTransliteration(List<VerseData> verses) {
    return verses.any((verse) => verse.transliteration.isNotEmpty);
  }

  /// Whether any verse contains meaning content.
  static bool hasMeaning(List<VerseData> verses) {
    return verses.any((verse) => verse.meanings.isNotEmpty);
  }

  /// Resolves the title variant that matches the selected script.
  static String resolveAartiTitle(AartiItem aarti, int scriptMode) {
    switch (scriptFromMode(scriptMode)) {
      case AppScriptLanguage.english:
        return aarti.title;
      case AppScriptLanguage.gujarati:
        return aarti.gujarati.trim().isNotEmpty ? aarti.gujarati : aarti.devanagari;
      case AppScriptLanguage.devanagari:
        return aarti.devanagari;
    }
  }

  /// Resolves lyric lines using the selected script, with graceful fallbacks.
  static List<String> resolveLyricsLines(VerseData verse, int scriptMode) {
    switch (scriptFromMode(scriptMode)) {
      case AppScriptLanguage.english:
        return verse.transliteration.isNotEmpty ? verse.transliteration : verse.lines;
      case AppScriptLanguage.gujarati:
        return verse.gujarati.isNotEmpty ? verse.gujarati : verse.lines;
      case AppScriptLanguage.devanagari:
        return verse.lines;
    }
  }

  /// Resolves transliteration lines independently of the selected lyric script.
  static List<String> resolveTransliterationLines(VerseData verse) {
    return verse.transliteration.isNotEmpty ? verse.transliteration : verse.lines;
  }

  /// Resolves translated meaning lines.
  ///
  /// English meanings are currently used as the fallback for all app languages
  /// until localized meaning datasets exist.
  static List<String> resolveMeaningLines(VerseData verse, String appLanguageCode) {
    final AppLanguage appLanguage = appLanguageFromCode(appLanguageCode);
    switch (appLanguage) {
      case AppLanguage.english:
      case AppLanguage.hindi:
      case AppLanguage.gujarati:
        return verse.meanings;
    }
  }

  /// User-facing label for a script mode.
  static String scriptLabel(int scriptMode) {
    switch (scriptFromMode(scriptMode)) {
      case AppScriptLanguage.english:
        return 'English';
      case AppScriptLanguage.gujarati:
        return 'Gujarati';
      case AppScriptLanguage.devanagari:
        return 'Devanagari';
    }
  }

  /// User-facing label for an application language code.
  static String appLanguageLabel(String code) {
    switch (appLanguageFromCode(code)) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.gujarati:
        return 'Gujarati';
      case AppLanguage.hindi:
        return 'Hindi';
    }
  }
}