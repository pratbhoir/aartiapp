import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/settings_repository.dart';
import '../constants/app_sync_config.dart';
import '../utils/device_info_helper.dart';
import 'activity_log_service.dart';

/// Submits user-visible feedback to a configured n8n webhook.
class FeedbackService {
  /// Creates a feedback service using the app's persisted settings as identity context.
  FeedbackService({
    required SettingsRepository settingsRepository,
    http.Client? client,
    Future<DeviceSnapshot> Function()? deviceInfoLoader,
    Future<String> Function()? appVersionLoader,
    DateTime Function()? now,
    String Function()? feedbackIdGenerator,
    Duration requestTimeout = AppSyncConfig.feedbackRequestTimeout,
    String webhookUrl = AppSyncConfig.feedbackWebhookUrl,
  }) : _settingsRepository = settingsRepository,
       _client = client ?? http.Client(),
       _ownsClient = client == null,
       _deviceInfoLoader =
           deviceInfoLoader ?? DeviceInfoHelper.getDeviceSnapshot,
       _appVersionLoader = appVersionLoader ?? _defaultAppVersionLoader,
       _now = now ?? DateTime.now,
       _feedbackIdGenerator = feedbackIdGenerator ?? const Uuid().v4,
       _requestTimeout = requestTimeout,
       _webhookUrl = webhookUrl;

  final SettingsRepository _settingsRepository;
  final http.Client _client;
  final bool _ownsClient;
  final Future<DeviceSnapshot> Function() _deviceInfoLoader;
  final Future<String> Function() _appVersionLoader;
  final DateTime Function() _now;
  final String Function() _feedbackIdGenerator;
  final Duration _requestTimeout;
  final String _webhookUrl;

  /// Releases resources owned by the service.
  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  /// Submits a feedback message and throws if the request fails.
  Future<void> submit({
    required String feedbackType,
    required String message,
    String? email,
  }) async {
    final trimmedType = feedbackType.trim();
    final trimmedMessage = message.trim();
    final trimmedEmail = email?.trim() ?? '';

    if (trimmedType.isEmpty) {
      throw ArgumentError.value(
        feedbackType,
        'feedbackType',
        'Must not be empty.',
      );
    }

    if (trimmedMessage.isEmpty) {
      throw ArgumentError.value(message, 'message', 'Must not be empty.');
    }

    if (_webhookUrl.trim().isEmpty) {
      throw StateError('AARTI_FEEDBACK_WEBHOOK_URL is not configured.');
    }

    try {
      await _settingsRepository.ensureUserIdentity();
      final deviceSnapshot = await _deviceInfoLoader();
      final appVersion = await _appVersionLoader();
      final payload = _buildPayload(
        feedbackType: trimmedType,
        message: trimmedMessage,
        email: trimmedEmail,
        deviceSnapshot: deviceSnapshot,
        appVersion: appVersion,
      );

      final response = await _client
          .post(
            Uri.parse(_webhookUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = FeedbackSubmissionException(
          'Feedback submission failed with status ${response.statusCode}.',
        );
        ActivityLogService.error(
          'FeedbackService',
          'Feedback submission failed with status ${response.statusCode}: ${response.body}',
        );
        throw error;
      }
    } on TimeoutException catch (error, stack) {
      ActivityLogService.error(
        'FeedbackService',
        'Feedback submission timed out after ${_requestTimeout.inSeconds}s: $error',
        stack,
      );
      throw FeedbackSubmissionException(
        'Feedback submission timed out. Please try again.',
      );
    } on FeedbackSubmissionException {
      rethrow;
    } catch (error, stack) {
      ActivityLogService.error(
        'FeedbackService',
        'Feedback submission failed: $error',
        stack,
      );
      throw FeedbackSubmissionException(
        'Unable to send feedback right now. Please try again.',
      );
    }
  }

  Map<String, dynamic> _buildPayload({
    required String feedbackType,
    required String message,
    required String email,
    required DeviceSnapshot deviceSnapshot,
    required String appVersion,
  }) {
    final nowIso = _now().toUtc().toIso8601String();
    final registrationDate =
        _settingsRepository.getRegistrationDate() ??
        _settingsRepository.getOnboardingDate() ??
        nowIso;

    return <String, dynamic>{
      'feedback_id': _feedbackIdGenerator(),
      'user_id': _settingsRepository.getUserId() ?? 'anonymous',
      'user_name': _settingsRepository.getUserName(),
      'email': email,
      'registration_date': registrationDate,
      'onboarding_date': _settingsRepository.getOnboardingDate() ?? '',
      'device_model': deviceSnapshot.model,
      'os_version': deviceSnapshot.osVersion,
      'platform': deviceSnapshot.platform,
      'app_version': appVersion,
      'feedback_type': feedbackType,
      'message': message,
      'submitted_at': nowIso,
    };
  }

  static Future<String> _defaultAppVersionLoader() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}

/// Error surfaced to the UI when feedback submission fails.
class FeedbackSubmissionException implements Exception {
  /// Creates a failure with a user-facing message.
  const FeedbackSubmissionException(this.message);

  /// User-facing failure description.
  final String message;

  @override
  String toString() => message;
}
