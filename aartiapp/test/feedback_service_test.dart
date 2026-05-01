import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/core/services/feedback_service.dart';
import 'package:aartiapp/core/utils/device_info_helper.dart';
import 'package:aartiapp/data/repositories/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedbackService', () {
    test('submit posts the expected payload', () async {
      final SettingsRepository repository =
          await _buildRepository(const <String, Object>{
            'onboarding_completed': true,
            'user_id': 'user-123',
            'user_name': 'Seva Bhakt',
            'registration_date': '2026-04-20T10:00:00.000Z',
            'onboarding_date': '2026-04-22T08:00:00.000Z',
          });

      Map<String, dynamic>? payload;
      final FeedbackService service = FeedbackService(
        settingsRepository: repository,
        webhookUrl: 'https://example.com/feedback',
        feedbackIdGenerator: () => 'feedback-123',
        now: () => DateTime.utc(2026, 5, 1, 12),
        appVersionLoader: () async => '2.0.0',
        deviceInfoLoader: () async => const DeviceSnapshot(
          model: 'Pixel 8',
          osVersion: 'Android 16',
          platform: 'android',
        ),
        client: MockClient((http.Request request) async {
          payload = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{"ok":true}', 200);
        }),
      );

      await service.submit(
        feedbackType: 'Bug Report',
        message: 'The reader freezes after opening Focus Mode.',
        email: 'bhakt@example.com',
      );

      expect(payload, isNotNull);
      expect(payload!['feedback_id'], 'feedback-123');
      expect(payload!['user_id'], 'user-123');
      expect(payload!['user_name'], 'Seva Bhakt');
      expect(payload!['email'], 'bhakt@example.com');
      expect(payload!['registration_date'], '2026-04-20T10:00:00.000Z');
      expect(payload!['onboarding_date'], '2026-04-22T08:00:00.000Z');
      expect(payload!['device_model'], 'Pixel 8');
      expect(payload!['os_version'], 'Android 16');
      expect(payload!['platform'], 'android');
      expect(payload!['app_version'], '2.0.0');
      expect(payload!['feedback_type'], 'Bug Report');
      expect(
        payload!['message'],
        'The reader freezes after opening Focus Mode.',
      );
      expect(payload!['submitted_at'], '2026-05-01T12:00:00.000Z');
    });

    test('submit backfills identity for a legacy install', () async {
      final SettingsRepository repository = await _buildRepository(
        const <String, Object>{'user_name': 'Bhakt'},
      );

      Map<String, dynamic>? payload;
      final FeedbackService service = FeedbackService(
        settingsRepository: repository,
        webhookUrl: 'https://example.com/feedback',
        feedbackIdGenerator: () => 'feedback-legacy',
        now: () => DateTime.utc(2026, 5, 1, 12),
        appVersionLoader: () async => '2.0.0',
        deviceInfoLoader: () async => const DeviceSnapshot(
          model: 'Windows PC',
          osVersion: 'Windows 11',
          platform: 'windows',
        ),
        client: MockClient((http.Request request) async {
          payload = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{"ok":true}', 200);
        }),
      );

      await service.submit(
        feedbackType: 'General Feedback',
        message: 'The app feels peaceful to use.',
      );

      expect((payload!['user_id'] as String), isNotEmpty);
      expect((payload!['registration_date'] as String), isNotEmpty);
      expect(repository.getUserId(), isNotNull);
      expect(repository.getRegistrationDate(), isNotNull);
      expect(payload!['email'], '');
    });

    test('submit throws on non-2xx responses', () async {
      final SettingsRepository repository = await _buildRepository(
        const <String, Object>{
          'user_id': 'user-123',
          'registration_date': '2026-04-20T10:00:00.000Z',
        },
      );

      final FeedbackService service = FeedbackService(
        settingsRepository: repository,
        webhookUrl: 'https://example.com/feedback',
        appVersionLoader: () async => '2.0.0',
        deviceInfoLoader: () async => const DeviceSnapshot(
          model: 'Pixel 8',
          osVersion: 'Android 16',
          platform: 'android',
        ),
        client: MockClient((http.Request request) async {
          return http.Response('{"ok":false}', 500);
        }),
      );

      await expectLater(
        service.submit(
          feedbackType: 'Bug Report',
          message: 'The settings screen does not open.',
        ),
        throwsA(isA<FeedbackSubmissionException>()),
      );
    });
  });
}

Future<SettingsRepository> _buildRepository(
  Map<String, Object> initialValues,
) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return SettingsRepository(prefs);
}
