import '../../data/models/aarti_item.dart';
import '../../data/models/verse_data.dart';

/// Supported script choices for rendering aarti titles and lyrics.
enum AppScriptLanguage { devanagari, english, gujarati }

/// Supported application language choices for translated meaning surfaces.
enum AppLanguage { english, hindi, gujarati }

/// Content modes shown in the aarti detail experience.
enum AartiDetailContentMode { lyrics, transliteration, meaning }

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

  /// Converts a stable script enum back into the persisted mode value.
  static int scriptModeFromScript(AppScriptLanguage script) {
    switch (script) {
      case AppScriptLanguage.english:
        return 1;
      case AppScriptLanguage.gujarati:
        return 2;
      case AppScriptLanguage.devanagari:
        return 0;
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

  /// Returns the persisted script mode that best matches the app language.
  static int preferredScriptModeForLanguageCode(String code) {
    return scriptModeFromScript(
      preferredScriptForLanguage(appLanguageFromCode(code)),
    );
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

  /// Resolves the derived secondary script from app language and lyric script.
  ///
  /// When both choices already point to the same reading script, Devanagari is
  /// used as the fallback secondary script.
  static AppScriptLanguage resolveSecondaryScript({
    required int scriptMode,
    required String appLanguageCode,
  }) {
    final AppScriptLanguage selectedScript = scriptFromMode(scriptMode);
    final AppScriptLanguage appLanguageScript = preferredScriptForLanguage(
      appLanguageFromCode(appLanguageCode),
    );
    if (selectedScript == appLanguageScript) {
      return AppScriptLanguage.devanagari;
    }
    return appLanguageScript;
  }

  /// Resolves the persisted mode value for the derived secondary script.
  static int resolveSecondaryScriptMode({
    required int scriptMode,
    required String appLanguageCode,
  }) {
    return scriptModeFromScript(
      resolveSecondaryScript(
        scriptMode: scriptMode,
        appLanguageCode: appLanguageCode,
      ),
    );
  }

  /// Whether a secondary-script surface can be shown for the given verses.
  static bool shouldShowSecondaryScriptMode({required List<VerseData> verses}) {
    return verses.any(
      (verse) =>
          verse.lines.isNotEmpty ||
          verse.transliteration.isNotEmpty ||
          verse.gujarati.isNotEmpty,
    );
  }

  /// Whether any verse contains transliteration lines.
  static bool hasTransliteration(List<VerseData> verses) {
    return verses.any((verse) => verse.transliteration.isNotEmpty);
  }

  /// Whether any verse contains meaning content.
  static bool hasMeaning(List<VerseData> verses) {
    return verses.any((verse) => verse.meanings.isNotEmpty);
  }

  /// Resolves the title variant that matches a specific script.
  static String resolveTitleForScript(
    AartiItem aarti,
    AppScriptLanguage script,
  ) {
    switch (script) {
      case AppScriptLanguage.english:
        return aarti.title;
      case AppScriptLanguage.gujarati:
        return aarti.gujarati.trim().isNotEmpty
            ? aarti.gujarati
            : aarti.devanagari;
      case AppScriptLanguage.devanagari:
        return aarti.devanagari;
    }
  }

  /// Resolves the title variant that matches the selected script.
  static String resolveAartiTitle(AartiItem aarti, int scriptMode) {
    return resolveTitleForScript(aarti, scriptFromMode(scriptMode));
  }

  /// Resolves the title variant for the derived secondary script.
  static String resolveSecondaryAartiTitle(
    AartiItem aarti, {
    required int scriptMode,
    required String appLanguageCode,
  }) {
    return resolveTitleForScript(
      aarti,
      resolveSecondaryScript(
        scriptMode: scriptMode,
        appLanguageCode: appLanguageCode,
      ),
    );
  }

  /// Resolves lyric lines using the selected script, with graceful fallbacks.
  static List<String> resolveLyricsLines(VerseData verse, int scriptMode) {
    return _resolveLinesForScript(verse, scriptFromMode(scriptMode));
  }

  /// Resolves the derived secondary-script lines.
  static List<String> resolveSecondaryScriptLines(
    VerseData verse, {
    required int scriptMode,
    required String appLanguageCode,
  }) {
    return _resolveLinesForScript(
      verse,
      resolveSecondaryScript(
        scriptMode: scriptMode,
        appLanguageCode: appLanguageCode,
      ),
    );
  }

  /// Resolves translated meaning lines.
  ///
  /// English meanings are currently used as the fallback for all app languages
  /// until localized meaning datasets exist.
  static List<String> resolveMeaningLines(
    VerseData verse,
    String appLanguageCode,
  ) {
    final AppLanguage appLanguage = appLanguageFromCode(appLanguageCode);
    switch (appLanguage) {
      case AppLanguage.english:
      case AppLanguage.hindi:
      case AppLanguage.gujarati:
        return verse.meanings;
    }
  }

  /// User-facing label for the derived secondary script.
  static String secondaryScriptLabel({
    required int scriptMode,
    required String appLanguageCode,
  }) {
    return scriptLabel(
      resolveSecondaryScriptMode(
        scriptMode: scriptMode,
        appLanguageCode: appLanguageCode,
      ),
    );
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

  static List<String> _resolveLinesForScript(
    VerseData verse,
    AppScriptLanguage script,
  ) {
    switch (script) {
      case AppScriptLanguage.english:
        return verse.transliteration.isNotEmpty
            ? verse.transliteration
            : verse.lines;
      case AppScriptLanguage.gujarati:
        return verse.gujarati.isNotEmpty ? verse.gujarati : verse.lines;
      case AppScriptLanguage.devanagari:
        return verse.lines;
    }
  }
}
