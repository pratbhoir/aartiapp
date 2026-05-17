import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Repository for persisting user settings via SharedPreferences.
class SettingsRepository {
  static const Uuid _uuid = Uuid();
  static const Set<String> _supportedLanguageCodes = <String>{
    'en',
    'hi',
    'gu',
  };

  static const _keyThemeMode = 'theme_mode';
  static const _keyTextScale = 'text_scale';
  static const _keyScriptMode =
      'script_mode'; // 0=devanagari, 1=english, 2=gujarati
  static const _keyUserName = 'user_name';
  static const _keyUserId = 'user_id';
  static const _keyRegistrationDate = 'registration_date';
  static const _keyOnboardingDate = 'onboarding_date';
  static const _keyAnalyticsEnabled = 'analytics_enabled';
  static const _keyAnalyticsSessionId = 'analytics_session_id';
  static const _keyCrossfadeDuration = 'crossfade_duration'; // 0–3 seconds
  static const _keyAutoPlay = 'auto_play'; // puja session auto-play
  static const _keyRepeatCurrent = 'repeat_current'; // repeat current aarti
  static const _keyNotificationHour = 'notification_hour';
  static const _keyNotificationMinute = 'notification_minute';
  static const _keyNotificationEnabled = 'notification_enabled';
  static const _keyOnboardingCompleted = 'onboarding_completed';
  static const _keyPreferredLanguage =
      'preferred_language'; // e.g. 'hi', 'gu', 'en'
  static const _keyFestivalContentLastSync = 'festival_content_last_sync';
  static const _keyAartiContentLastSync = 'aarti_content_last_sync';
  static const _keyFestivalContentVersion = 'festival_content_version';
  static const _keyAartiContentVersion = 'aarti_content_version';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  // --- Theme Mode ---
  ThemeMode getThemeMode() {
    final val = _prefs.getString(_keyThemeMode) ?? 'system';
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final val = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
        ? 'dark'
        : 'system';
    await _prefs.setString(_keyThemeMode, val);
  }

  // --- Text Scale ---
  double getTextScale() => _prefs.getDouble(_keyTextScale) ?? 1.0;

  Future<void> setTextScale(double scale) =>
      _prefs.setDouble(_keyTextScale, scale);

  // --- Script Mode ---
  int getScriptMode() => _prefs.getInt(_keyScriptMode) ?? 0;

  Future<void> setScriptMode(int mode) => _prefs.setInt(_keyScriptMode, mode);

  // --- User Name ---
  String getUserName() => _prefs.getString(_keyUserName) ?? 'Bhakt';

  Future<void> setUserName(String name) => _prefs.setString(_keyUserName, name);

  /// Returns the stable local installation identity used by user sync.
  String? getUserId() => _prefs.getString(_keyUserId);

  /// Returns the first-known registration timestamp for this install.
  String? getRegistrationDate() => _prefs.getString(_keyRegistrationDate);

  /// Returns the latest onboarding completion timestamp.
  String? getOnboardingDate() => _prefs.getString(_keyOnboardingDate);

  /// Ensures the install has a stable sync identity and durable registration date.
  Future<void> ensureUserIdentity() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final existingUserId = getUserId();
    if (existingUserId == null || existingUserId.trim().isEmpty) {
      await _prefs.setString(_keyUserId, _uuid.v4());
    }

    final existingRegistrationDate = getRegistrationDate();
    if (existingRegistrationDate == null ||
        existingRegistrationDate.trim().isEmpty) {
      await _prefs.setString(
        _keyRegistrationDate,
        getOnboardingDate() ?? nowIso,
      );
    }
  }

  /// Returns whether analytics sending is enabled for this install.
  bool getAnalyticsEnabled() => _prefs.getBool(_keyAnalyticsEnabled) ?? true;

  /// Persists analytics enablement.
  Future<void> setAnalyticsEnabled(bool value) =>
      _prefs.setBool(_keyAnalyticsEnabled, value);

  /// Returns the persisted analytics readiness identifier.
  String? getAnalyticsSessionId() => _prefs.getString(_keyAnalyticsSessionId);

  /// Ensures a stable analytics session/install identifier exists.
  Future<String> ensureAnalyticsSessionId() async {
    final existingSessionId = getAnalyticsSessionId();
    if (existingSessionId != null && existingSessionId.trim().isNotEmpty) {
      return existingSessionId;
    }

    final sessionId = _uuid.v4();
    await _prefs.setString(_keyAnalyticsSessionId, sessionId);
    return sessionId;
  }

  // --- Crossfade Duration (v1.5) ---
  int getCrossfadeDuration() => _prefs.getInt(_keyCrossfadeDuration) ?? 1;

  Future<void> setCrossfadeDuration(int seconds) =>
      _prefs.setInt(_keyCrossfadeDuration, seconds.clamp(0, 3));

  // --- Auto-play (v1.5) ---
  bool getAutoPlay() => _prefs.getBool(_keyAutoPlay) ?? true;

  Future<void> setAutoPlay(bool value) => _prefs.setBool(_keyAutoPlay, value);

  // --- Repeat Current (v1.5) ---
  bool getRepeatCurrent() => _prefs.getBool(_keyRepeatCurrent) ?? false;

  Future<void> setRepeatCurrent(bool value) =>
      _prefs.setBool(_keyRepeatCurrent, value);

  // --- Notification Time (v1.5) ---
  bool getNotificationEnabled() =>
      _prefs.getBool(_keyNotificationEnabled) ?? false;

  Future<void> setNotificationEnabled(bool value) =>
      _prefs.setBool(_keyNotificationEnabled, value);

  TimeOfDay getNotificationTime() {
    final hour = _prefs.getInt(_keyNotificationHour) ?? 6;
    final minute = _prefs.getInt(_keyNotificationMinute) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    await _prefs.setInt(_keyNotificationHour, time.hour);
    await _prefs.setInt(_keyNotificationMinute, time.minute);
  }

  // --- Onboarding ---
  bool getOnboardingCompleted() =>
      _prefs.getBool(_keyOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool value) {
    if (value) {
      return completeOnboarding();
    }

    return _prefs.setBool(_keyOnboardingCompleted, false);
  }

  /// Marks onboarding complete while maintaining stable identity semantics.
  Future<void> completeOnboarding() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    await ensureUserIdentity();
    await _prefs.setString(_keyOnboardingDate, nowIso);

    final existingRegistrationDate = getRegistrationDate();
    if (existingRegistrationDate == null ||
        existingRegistrationDate.trim().isEmpty) {
      await _prefs.setString(_keyRegistrationDate, nowIso);
    }

    await _prefs.setBool(_keyOnboardingCompleted, true);
  }

  // --- Preferred Language ---
  String getPreferredLanguage() {
    final stored = _prefs.getString(_keyPreferredLanguage);
    if (_supportedLanguageCodes.contains(stored)) {
      return stored!;
    }
    return 'en';
  }

  Future<void> setPreferredLanguage(String lang) =>
      _prefs.setString(_keyPreferredLanguage, _normalizeLanguageCode(lang));

  /// Seeds the preferred language from the first supported device locale.
  ///
  /// This only runs for installs that have not completed onboarding and do not
  /// already have an explicit persisted preferred language choice.
  Future<String> seedPreferredLanguageFromDeviceLocales({
    List<Locale>? deviceLocales,
  }) async {
    if (getOnboardingCompleted() || _prefs.containsKey(_keyPreferredLanguage)) {
      return getPreferredLanguage();
    }

    final String? seededCode = _firstSupportedLanguageCode(
      deviceLocales ?? WidgetsBinding.instance.platformDispatcher.locales,
    );
    if (seededCode == null || seededCode == 'en') {
      return getPreferredLanguage();
    }

    await _prefs.setString(_keyPreferredLanguage, seededCode);
    return seededCode;
  }

  String _normalizeLanguageCode(String code) {
    return _supportedLanguageCodes.contains(code) ? code : 'en';
  }

  String? _firstSupportedLanguageCode(List<Locale> locales) {
    for (final Locale locale in locales) {
      final String normalized = locale.languageCode.toLowerCase();
      if (_supportedLanguageCodes.contains(normalized)) {
        return normalized;
      }
    }
    return null;
  }

  /// Returns the last successful festival content sync time, if any.
  DateTime? getFestivalContentLastSync() =>
      _readDateTime(_keyFestivalContentLastSync);

  /// Returns the last successful aarti content sync time, if any.
  DateTime? getAartiContentLastSync() =>
      _readDateTime(_keyAartiContentLastSync);

  /// Persists the last successful festival content sync time.
  Future<void> setFestivalContentLastSync(DateTime timestamp) =>
      _prefs.setString(
        _keyFestivalContentLastSync,
        timestamp.toUtc().toIso8601String(),
      );

  /// Persists the last successful aarti content sync time.
  Future<void> setAartiContentLastSync(DateTime timestamp) => _prefs.setString(
    _keyAartiContentLastSync,
    timestamp.toUtc().toIso8601String(),
  );

  /// Returns the last synced festival content version, if known.
  int? getFestivalContentVersion() => _prefs.getInt(_keyFestivalContentVersion);

  /// Returns the last synced aarti content version, if known.
  int? getAartiContentVersion() => _prefs.getInt(_keyAartiContentVersion);

  /// Persists the last synced festival content version.
  Future<void> setFestivalContentVersion(int version) =>
      _prefs.setInt(_keyFestivalContentVersion, version);

  /// Persists the last synced aarti content version.
  Future<void> setAartiContentVersion(int version) =>
      _prefs.setInt(_keyAartiContentVersion, version);

  /// Returns the serialized theme label used in sync payloads.
  String getThemeModeLabel() {
    switch (getThemeMode()) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Returns the serialized script label used in sync payloads.
  String getScriptModeLabel() {
    switch (getScriptMode()) {
      case 1:
        return 'english';
      case 2:
        return 'gujarati';
      default:
        return 'devanagari';
    }
  }

  /// Returns the reminder time in HH:mm format for sync payloads.
  String getNotificationTimeLabel() {
    final time = getNotificationTime();
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Returns whether the app has a non-placeholder profile name.
  bool isProfileComplete() {
    final normalizedName = getUserName().trim().toLowerCase();
    return normalizedName.isNotEmpty && normalizedName != 'bhakt';
  }

  DateTime? _readDateTime(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw)?.toUtc();
  }
}
