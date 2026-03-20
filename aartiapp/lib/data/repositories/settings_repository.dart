import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting user settings via SharedPreferences.
class SettingsRepository {
  static const _keyThemeMode = 'theme_mode';
  static const _keyTextScale = 'text_scale';
  static const _keyScriptMode = 'script_mode'; // 0=devanagari, 1=roman
  static const _keyUserName = 'user_name';

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
}
