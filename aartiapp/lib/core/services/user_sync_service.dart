import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/repositories/settings_repository.dart';
import '../constants/app_sync_config.dart';
import '../utils/device_info_helper.dart';
import 'activity_log_service.dart';
import 'user_profile_snapshot.dart';

/// Best-effort sync of lightweight user profile and app settings to n8n.
class UserSyncService {
  /// Creates a sync service using the app's persisted settings as source of truth.
  UserSyncService({
    required SettingsRepository settingsRepository,
    http.Client? client,
    Future<DeviceSnapshot> Function()? deviceInfoLoader,
    Future<String> Function()? appVersionLoader,
    DateTime Function()? now,
    Duration debounceDelay = AppSyncConfig.userSyncDebounceDelay,
    Duration requestTimeout = AppSyncConfig.userSyncRequestTimeout,
    String webhookUrl = AppSyncConfig.userSyncWebhookUrl,
  }) : _settingsRepository = settingsRepository,
       _client = client ?? http.Client(),
       _ownsClient = client == null,
       _deviceInfoLoader =
           deviceInfoLoader ?? DeviceInfoHelper.getDeviceSnapshot,
       _appVersionLoader = appVersionLoader ?? _defaultAppVersionLoader,
       _now = now ?? DateTime.now,
       _debounceDelay = debounceDelay,
       _requestTimeout = requestTimeout,
       _webhookUrl = webhookUrl;

  final SettingsRepository _settingsRepository;
  final http.Client _client;
  final bool _ownsClient;
  final Future<DeviceSnapshot> Function() _deviceInfoLoader;
  final Future<String> Function() _appVersionLoader;
  final DateTime Function() _now;
  final Duration _debounceDelay;
  final Duration _requestTimeout;
  final String _webhookUrl;

  Timer? _debounceTimer;
  Future<void>? _activeSync;
  bool _syncQueued = false;
  bool _didLogMissingWebhook = false;

  /// Schedules a sync, optionally bypassing debounce for startup or onboarding completion.
  Future<void> sync({bool force = false}) async {
    if (!_settingsRepository.getOnboardingCompleted()) {
      return;
    }

    if (_webhookUrl.trim().isEmpty) {
      _logMissingWebhook();
      return;
    }

    if (force) {
      _debounceTimer?.cancel();
      _debounceTimer = null;
      await _performSync();
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      _debounceTimer = null;
      unawaited(_performSync());
    });
  }

  /// Releases resources owned by the service.
  void dispose() {
    _debounceTimer?.cancel();
    if (_ownsClient) {
      _client.close();
    }
  }

  Future<void> _performSync() async {
    if (_activeSync != null) {
      _syncQueued = true;
      await _activeSync;
      return;
    }

    do {
      _syncQueued = false;
      final currentSync = _doSync();
      _activeSync = currentSync;

      try {
        await currentSync;
      } finally {
        _activeSync = null;
      }
    } while (_syncQueued);
  }

  Future<void> _doSync() async {
    try {
      final snapshot = await UserProfileSnapshot.load(
        settingsRepository: _settingsRepository,
        deviceInfoLoader: _deviceInfoLoader,
        appVersionLoader: _appVersionLoader,
        now: _now,
      );

      final response = await _client
          .post(
            Uri.parse(_webhookUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(snapshot.toUserSyncPayload()),
          )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        ActivityLogService.error(
          'UserSync',
          'User sync failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } on TimeoutException catch (error, stack) {
      ActivityLogService.error(
        'UserSync',
        'User sync timed out after ${_requestTimeout.inSeconds}s: $error',
        stack,
      );
    } catch (error, stack) {
      ActivityLogService.error(
        'UserSync',
        'User sync request failed: $error',
        stack,
      );
    }
  }

  void _logMissingWebhook() {
    if (_didLogMissingWebhook) {
      return;
    }

    _didLogMissingWebhook = true;
    ActivityLogService.warn(
      'UserSync',
      'Skipping user sync because AARTI_USER_SYNC_WEBHOOK_URL is not configured.',
    );
  }

  static Future<String> _defaultAppVersionLoader() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
