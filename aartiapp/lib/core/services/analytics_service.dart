import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/repositories/settings_repository.dart';
import '../constants/app_analytics_config.dart';
import '../utils/device_info_helper.dart';
import 'activity_log_service.dart';
import 'user_profile_snapshot.dart';

/// Centralized Umami analytics transport and event helpers.
abstract final class AnalyticsService {
  static http.Client _client = http.Client();
  static bool _ownsClient = true;
  static Future<DeviceSnapshot> Function() _deviceInfoLoader =
      DeviceInfoHelper.getDeviceSnapshot;
  static Future<String> Function() _appVersionLoader = _defaultAppVersion;
  static DateTime Function() _now = DateTime.now;
  static SettingsRepository? _settingsRepository;

  static String _endpoint = AppAnalyticsConfig.umamiEndpoint;
  static String _websiteId = AppAnalyticsConfig.websiteId;
  static String _hostname = AppAnalyticsConfig.hostname;
  static Duration _requestTimeout = AppAnalyticsConfig.analyticsRequestTimeout;
  static List<Duration> _retryDelays = const <Duration>[
    Duration(seconds: 1),
    Duration(seconds: 2),
  ];

  static bool _enabled = true;
  static String _sessionId = '';
  static String _locale = 'en';
  static String _distinctId = '';
  static String _lastTrackedPath = '';
  static String _lastIdentifySignature = '';
  static bool _didLogMissingConfig = false;

  /// Configures runtime analytics state before any events are sent.
  static void configure({
    required SettingsRepository settingsRepository,
    required bool analyticsEnabled,
    required String sessionId,
    required String locale,
    String? name,
    String? userId,
    http.Client? client,
    Future<DeviceSnapshot> Function()? deviceInfoLoader,
    Future<String> Function()? appVersionLoader,
    DateTime Function()? now,
    String? endpoint,
    String? websiteId,
    String? hostname,
    Duration? requestTimeout,
  }) {
    _settingsRepository = settingsRepository;
    _enabled = analyticsEnabled;
    _sessionId = sessionId;
    _locale = locale;
    _lastIdentifySignature = '';
    updateIdentity(name: name, userId: userId);

    if (client != null) {
      _swapClient(client, ownsClient: false);
    }
    if (deviceInfoLoader != null) {
      _deviceInfoLoader = deviceInfoLoader;
    }
    if (appVersionLoader != null) {
      _appVersionLoader = appVersionLoader;
    }
    if (now != null) {
      _now = now;
    }
    if (endpoint != null) {
      _endpoint = endpoint;
    }
    if (websiteId != null) {
      _websiteId = websiteId;
    }
    if (hostname != null) {
      _hostname = hostname;
    }
    if (requestTimeout != null) {
      _requestTimeout = requestTimeout;
    }
  }

  /// Enables or disables analytics sending.
  static void setEnabled(bool value) {
    if (value && !_enabled) {
      _lastIdentifySignature = '';
    }
    _enabled = value;
  }

  /// Updates the current locale attached to outbound payloads.
  static void updateLocale(String locale) {
    _locale = locale;
  }

  /// Updates the current distinct analytics identity.
  static void updateIdentity({String? name, String? userId}) {
    final trimmedName = (name ?? '').trim();
    final hasPlaceholderName = trimmedName.toLowerCase() == 'bhakt';
    final normalizedName = hasPlaceholderName
        ? ''
        : trimmedName.replaceAll(' ', '');
    final normalizedUserId = (userId ?? '').trim();
    if (normalizedName.isEmpty) {
      _distinctId = normalizedUserId;
      return;
    }
    if (normalizedUserId.isEmpty) {
      _distinctId = normalizedName;
      return;
    }

    _distinctId = '$normalizedName-$normalizedUserId';
  }

  /// Tracks a screen/page view with path-level dedupe.
  static void trackScreen(String path, {String? title}) {
    final normalizedPath = path.trim();
    if (normalizedPath.isEmpty || normalizedPath == _lastTrackedPath) {
      return;
    }

    _lastTrackedPath = normalizedPath;
    _dispatch(<String, Object>{
      'type': 'event',
      'payload': <String, Object>{
        ..._basePayload(url: normalizedPath),
        'title': title ?? normalizedPath,
        'referrer': '',
        'screen': _screenSize(),
      },
    });
  }

  /// Tracks a named analytics event with optional structured data.
  static void trackEvent(
    String name, {
    Map<String, Object?>? data,
    String path = '/',
  }) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      return;
    }

    final normalizedData = _normalizeData(data);
    _dispatch(<String, Object>{
      'type': 'event',
      'payload': <String, Object>{
        ..._basePayload(url: path),
        'name': normalizedName,
        if (normalizedData.isNotEmpty) 'data': normalizedData,
      },
    });
  }

  /// Sends best-effort identify/session properties to Umami.
  static Future<void> identifySession({String path = '/'}) async {
    if (!_shouldSend) {
      return;
    }

    final settingsRepository = _settingsRepository;
    if (settingsRepository == null) {
      return;
    }

    if (!_hasTransportConfig) {
      _logMissingConfig();
      return;
    }

    try {
      final snapshot = await UserProfileSnapshot.load(
        settingsRepository: settingsRepository,
        deviceInfoLoader: _deviceInfoLoader,
        appVersionLoader: _appVersionLoader,
        now: _now,
      );

      updateLocale(snapshot.appLanguage);
      updateIdentity(name: snapshot.analyticsName, userId: snapshot.userId);

      final identifyData = snapshot.toAnalyticsIdentifyData();
      final identifySignature = jsonEncode(<String, Object>{
        'website': _websiteId,
        'session_id': _sessionId,
        if (_distinctId.isNotEmpty) 'id': _distinctId,
        'data': identifyData,
      });

      if (identifySignature == _lastIdentifySignature) {
        return;
      }

      final payload = <String, Object>{
        'type': 'identify',
        'payload': <String, Object>{
          ..._basePayload(url: path),
          'screen': _screenSize(),
          'data': identifyData,
        },
      };

      await _postWithRetry(payload);
      _lastIdentifySignature = identifySignature;
    } catch (error, stack) {
      ActivityLogService.warn(
        'Analytics',
        'Identify request failed: $error',
        stack,
      );
    }
  }

  /// Resets static runtime state for isolated tests.
  @visibleForTesting
  static void resetForTesting() {
    if (_ownsClient) {
      _client.close();
    }
    _client = http.Client();
    _ownsClient = true;
    _deviceInfoLoader = DeviceInfoHelper.getDeviceSnapshot;
    _appVersionLoader = _defaultAppVersion;
    _now = DateTime.now;
    _settingsRepository = null;
    _endpoint = AppAnalyticsConfig.umamiEndpoint;
    _websiteId = AppAnalyticsConfig.websiteId;
    _hostname = AppAnalyticsConfig.hostname;
    _requestTimeout = AppAnalyticsConfig.analyticsRequestTimeout;
    _retryDelays = const <Duration>[Duration(seconds: 1), Duration(seconds: 2)];
    _enabled = true;
    _sessionId = '';
    _locale = 'en';
    _distinctId = '';
    _lastTrackedPath = '';
    _lastIdentifySignature = '';
    _didLogMissingConfig = false;
  }

  /// Overrides retry delays for deterministic unit tests.
  @visibleForTesting
  static void setRetryDelaysForTesting(List<Duration> retryDelays) {
    _retryDelays = retryDelays;
  }

  static Map<String, Object> _basePayload({required String url}) {
    return <String, Object>{
      if (_distinctId.isNotEmpty) 'id': _distinctId,
      'website': _websiteId,
      'url': url,
      'hostname': _hostname,
      'language': _languageLabel(_locale),
    };
  }

  static Map<String, Object> _normalizeData(Map<String, Object?>? data) {
    final normalized = <String, Object>{};
    if (data == null) {
      return normalized;
    }

    data.forEach((key, value) {
      if (value == null) {
        return;
      }
      normalized[key] = value;
    });

    return normalized;
  }

  static void _dispatch(Map<String, Object> payload) {
    if (!_shouldSend) {
      return;
    }
    if (!_hasTransportConfig) {
      _logMissingConfig();
      return;
    }

    unawaited(_postWithRetry(payload));
  }

  static Future<void> _postWithRetry(Map<String, Object> payload) async {
    for (var attempt = 0; attempt < _retryDelays.length + 1; attempt++) {
      try {
        final response = await _client
            .post(
              Uri.parse(_endpoint),
              headers: const <String, String>{
                'Content-Type': 'application/json',
                'User-Agent': AppAnalyticsConfig.userAgent,
              },
              body: jsonEncode(payload),
            )
            .timeout(_requestTimeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return;
        }

        if (response.statusCode >= 500 && attempt < _retryDelays.length) {
          await Future.delayed(_retryDelays[attempt]);
          continue;
        }

        ActivityLogService.warn(
          'Analytics',
          'Analytics request failed with status ${response.statusCode}: ${response.body}',
        );
        return;
      } on TimeoutException catch (error, stack) {
        ActivityLogService.warn(
          'Analytics',
          'Analytics request timed out after ${_requestTimeout.inSeconds}s: $error',
          stack,
        );
        return;
      } catch (error, stack) {
        ActivityLogService.warn(
          'Analytics',
          'Analytics request failed: $error',
          stack,
        );
        return;
      }
    }
  }

  static bool get _shouldSend =>
      _enabled &&
      _sessionId.trim().isNotEmpty &&
      _settingsRepository != null &&
      _settingsRepository!.getOnboardingCompleted();

  static bool get _hasTransportConfig =>
      _endpoint.trim().isNotEmpty && _websiteId.trim().isNotEmpty;

  static void _logMissingConfig() {
    if (_didLogMissingConfig) {
      return;
    }

    _didLogMissingConfig = true;
    ActivityLogService.warn(
      'Analytics',
      'Skipping analytics because AARTI_ANALYTICS_ENDPOINT or AARTI_ANALYTICS_WEBSITE_ID is not configured.',
    );
  }

  static String _screenSize() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) {
      return 'unknown';
    }

    final size = views.first.physicalSize;
    return '${size.width.round()}x${size.height.round()}';
  }

  static void _swapClient(http.Client client, {required bool ownsClient}) {
    if (_ownsClient) {
      _client.close();
    }
    _client = client;
    _ownsClient = ownsClient;
  }

  static Future<String> _defaultAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static String _languageLabel(String locale) {
    switch (locale) {
      case 'hi':
        return 'Hindi';
      case 'gu':
        return 'Gujarati';
      default:
        return 'English';
    }
  }
}
