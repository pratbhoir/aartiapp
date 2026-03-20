import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting user settings via SharedPreferences.
class SettingsRepository {
  static const _keyThemeMode = 'theme_mode';
  static const _keyTextScale = 'text_scale';
  static const _keyScriptMode = 'script_mode'; // 0=devanagari, 1=roman, 2=gujarati
  static const _keyUserName = 'user_name';
  static const _keyCrossfadeDuration = 'crossfade_duration'; // 0–3 seconds
  static const _keyAutoPlay = 'auto_play'; // puja session auto-play
  static const _keyRepeatCurrent = 'repeat_current'; // repeat current aarti
  static const _keyNotificationHour = 'notification_hour';
  static const _keyNotificationMinute = 'notification_minute';
  static const _keyNotificationEnabled = 'notification_enabled';
  static const _keyOnboardingCompleted = 'onboarding_completed';
  static const _keyPreferredLanguage = 'preferred_language'; // e.g. 'hi', 'gu', 'en'

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

  Future<void> setScriptMode(int mode) =>
      _prefs.setInt(_keyScriptMode, mode);

  // --- User Name ---
  String getUserName() => _prefs.getString(_keyUserName) ?? 'Bhakt';

  Future<void> setUserName(String name) =>
      _prefs.setString(_keyUserName, name);

  // --- Crossfade Duration (v1.5) ---
  int getCrossfadeDuration() => _prefs.getInt(_keyCrossfadeDuration) ?? 1;

  Future<void> setCrossfadeDuration(int seconds) =>
      _prefs.setInt(_keyCrossfadeDuration, seconds.clamp(0, 3));

  // --- Auto-play (v1.5) ---
  bool getAutoPlay() => _prefs.getBool(_keyAutoPlay) ?? true;

  Future<void> setAutoPlay(bool value) =>
      _prefs.setBool(_keyAutoPlay, value);

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

  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(_keyOnboardingCompleted, value);

  // --- Preferred Language ---
  String getPreferredLanguage() =>
      _prefs.getString(_keyPreferredLanguage) ?? 'hi';

  Future<void> setPreferredLanguage(String lang) =>
      _prefs.setString(_keyPreferredLanguage, lang);
}
