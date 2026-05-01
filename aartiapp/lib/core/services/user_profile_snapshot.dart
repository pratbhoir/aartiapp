import 'package:flutter/foundation.dart';

import '../../data/repositories/settings_repository.dart';
import '../utils/device_info_helper.dart';

/// Immutable snapshot of the lightweight user, app, and device context.
@immutable
class UserProfileSnapshot {
  /// Creates a captured user profile snapshot.
  const UserProfileSnapshot({
    required this.userId,
    required this.userName,
    required this.registrationDate,
    required this.onboardingDate,
    required this.deviceModel,
    required this.osVersion,
    required this.platform,
    required this.appVersion,
    required this.themeMode,
    required this.textScale,
    required this.scriptMode,
    required this.appLanguage,
    required this.notificationEnabled,
    required this.notificationTime,
    required this.autoPlayEnabled,
    required this.repeatCurrentEnabled,
    required this.crossfadeDurationSeconds,
    required this.onboardingCompleted,
    required this.profileComplete,
    required this.lastUpdated,
  });

  /// Loads the current profile snapshot from persisted settings plus runtime metadata.
  static Future<UserProfileSnapshot> load({
    required SettingsRepository settingsRepository,
    required Future<DeviceSnapshot> Function() deviceInfoLoader,
    required Future<String> Function() appVersionLoader,
    DateTime Function()? now,
  }) async {
    final currentTime = (now ?? DateTime.now)().toUtc();
    await settingsRepository.ensureUserIdentity();
    final deviceSnapshot = await deviceInfoLoader();
    final appVersion = await appVersionLoader();
    final registrationDate =
        settingsRepository.getRegistrationDate() ??
        settingsRepository.getOnboardingDate() ??
        currentTime.toIso8601String();

    return UserProfileSnapshot(
      userId: settingsRepository.getUserId() ?? 'anonymous',
      userName: settingsRepository.getUserName(),
      registrationDate: registrationDate,
      onboardingDate: settingsRepository.getOnboardingDate() ?? '',
      deviceModel: deviceSnapshot.model,
      osVersion: deviceSnapshot.osVersion,
      platform: deviceSnapshot.platform,
      appVersion: appVersion,
      themeMode: settingsRepository.getThemeModeLabel(),
      textScale: settingsRepository.getTextScale(),
      scriptMode: settingsRepository.getScriptModeLabel(),
      appLanguage: settingsRepository.getPreferredLanguage(),
      notificationEnabled: settingsRepository.getNotificationEnabled(),
      notificationTime: settingsRepository.getNotificationTimeLabel(),
      autoPlayEnabled: settingsRepository.getAutoPlay(),
      repeatCurrentEnabled: settingsRepository.getRepeatCurrent(),
      crossfadeDurationSeconds: settingsRepository.getCrossfadeDuration(),
      onboardingCompleted: settingsRepository.getOnboardingCompleted(),
      profileComplete: settingsRepository.isProfileComplete(),
      lastUpdated: currentTime.toIso8601String(),
    );
  }

  /// Stable local identity generated for sync and analytics.
  final String userId;

  /// User-provided display name.
  final String userName;

  /// Durable install registration timestamp.
  final String registrationDate;

  /// Latest onboarding completion timestamp.
  final String onboardingDate;

  /// Normalized device model.
  final String deviceModel;

  /// Operating system version.
  final String osVersion;

  /// Platform name.
  final String platform;

  /// App semantic version string.
  final String appVersion;

  /// Theme mode label.
  final String themeMode;

  /// User-selected text scale.
  final double textScale;

  /// Script mode label.
  final String scriptMode;

  /// App language code.
  final String appLanguage;

  /// Whether reminders are enabled.
  final bool notificationEnabled;

  /// Reminder time in HH:mm.
  final String notificationTime;

  /// Whether puja auto-play is enabled.
  final bool autoPlayEnabled;

  /// Whether repeat-current is enabled.
  final bool repeatCurrentEnabled;

  /// Configured audio crossfade duration.
  final int crossfadeDurationSeconds;

  /// Whether onboarding is complete.
  final bool onboardingCompleted;

  /// Whether a non-placeholder profile name exists.
  final bool profileComplete;

  /// Snapshot creation timestamp.
  final String lastUpdated;

  /// User name suitable for analytics identity, excluding placeholder values.
  String? get analyticsName {
    final normalized = userName.trim();
    if (normalized.isEmpty || normalized.toLowerCase() == 'bhakt') {
      return null;
    }

    return normalized;
  }

  /// Stable distinct identifier attached to analytics payloads.
  String get distinctId {
    final normalizedName = analyticsName?.replaceAll(' ', '') ?? '';
    if (normalizedName.isEmpty) {
      return userId;
    }
    if (userId.trim().isEmpty) {
      return normalizedName;
    }

    return '$normalizedName-$userId';
  }

  /// Human-readable analytics language label.
  String get analyticsLanguage {
    switch (appLanguage) {
      case 'hi':
        return 'Hindi';
      case 'gu':
        return 'Gujarati';
      default:
        return 'English';
    }
  }

  /// Payload used by the existing best-effort user sync service.
  Map<String, dynamic> toUserSyncPayload() {
    return <String, dynamic>{
      'user_id': userId,
      'user_name': userName,
      'registration_date': registrationDate,
      'onboarding_date': onboardingDate,
      'device_model': deviceModel,
      'os_version': osVersion,
      'platform': platform,
      'app_version': appVersion,
      'theme_mode': themeMode,
      'text_scale': textScale,
      'script_mode': scriptMode,
      'app_language': appLanguage,
      'notification_enabled': notificationEnabled,
      'notification_time': notificationTime,
      'auto_play_enabled': autoPlayEnabled,
      'repeat_current_enabled': repeatCurrentEnabled,
      'crossfade_duration_seconds': crossfadeDurationSeconds,
      'onboarding_completed': onboardingCompleted,
      'profile_complete': profileComplete,
      'last_updated': lastUpdated,
    };
  }

  /// Session properties attached to analytics identify payloads.
  Map<String, Object> toAnalyticsIdentifyData() {
    return <String, Object>{
      if (analyticsName != null) 'name': analyticsName!,
      'aaa_name': analyticsName ?? 'anonymous',
      'device_model': deviceModel,
      'app_version': appVersion,
      'theme': themeMode,
      'text_scale': textScale,
      'script_mode': scriptMode,
      'app_language': appLanguage,
      'notification_enabled': notificationEnabled,
      'notification_time': notificationTime,
      'auto_play_enabled': autoPlayEnabled,
      'repeat_current_enabled': repeatCurrentEnabled,
      'crossfade_duration_seconds': crossfadeDurationSeconds,
      'onboarding_completed': onboardingCompleted,
      'profile_complete': profileComplete,
      'registration_date': registrationDate,
      'onboarding_date': onboardingDate,
    };
  }
}
