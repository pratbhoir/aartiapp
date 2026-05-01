import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/core/services/analytics_service.dart';
import 'package:aartiapp/core/utils/device_info_helper.dart';
import 'package:aartiapp/data/repositories/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(AnalyticsService.resetForTesting);
  tearDown(AnalyticsService.resetForTesting);

  group('AnalyticsService', () {
    test('trackEvent posts the expected Umami event payload', () async {
      final SettingsRepository repository =
          await _buildRepository(const <String, Object>{
            'analytics_enabled': true,
            'analytics_session_id': 'session-123',
            'user_id': 'user-123',
            'user_name': 'Seva Bhakt',
            'preferred_language': 'gu',
            'onboarding_completed': true,
          });

      Map<String, dynamic>? payload;
      AnalyticsService.configure(
        settingsRepository: repository,
        analyticsEnabled: true,
        sessionId: repository.getAnalyticsSessionId() ?? 'session-123',
        locale: repository.getPreferredLanguage(),
        name: repository.getUserName(),
        userId: repository.getUserId(),
        endpoint: 'https://example.com/api/send',
        websiteId: 'site-123',
        hostname: 'aartisangrah-test',
        client: MockClient((http.Request request) async {
          payload = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{"ok":true}', 200);
        }),
      );

      AnalyticsService.trackEvent(
        'discover_search_performed',
        data: const <String, Object>{'query': 'shiv'},
        path: '/discover',
      );
      await _flushAnalytics();

      expect(payload, isNotNull);
      expect(payload!['type'], 'event');
      final Map<String, dynamic> eventPayload =
          payload!['payload'] as Map<String, dynamic>;
      expect(eventPayload['website'], 'site-123');
      expect(eventPayload['url'], '/discover');
      expect(eventPayload['hostname'], 'aartisangrah-test');
      expect(eventPayload['language'], 'Gujarati');
      expect(eventPayload['id'], 'SevaBhakt-user-123');
      expect(eventPayload['name'], 'discover_search_performed');
      expect(eventPayload['data'], <String, dynamic>{'query': 'shiv'});
    });

    test('trackScreen dedupes repeated path notifications', () async {
      final SettingsRepository repository =
          await _buildRepository(const <String, Object>{
            'analytics_enabled': true,
            'analytics_session_id': 'session-123',
            'user_id': 'user-123',
            'onboarding_completed': true,
          });

      var requestCount = 0;
      AnalyticsService.configure(
        settingsRepository: repository,
        analyticsEnabled: true,
        sessionId: repository.getAnalyticsSessionId() ?? 'session-123',
        locale: 'en',
        userId: repository.getUserId(),
        endpoint: 'https://example.com/api/send',
        websiteId: 'site-123',
        client: MockClient((http.Request request) async {
          requestCount += 1;
          return http.Response('{"ok":true}', 200);
        }),
      );

      AnalyticsService.trackScreen('/discover', title: 'Discover');
      AnalyticsService.trackScreen('/discover', title: 'Discover');
      await _flushAnalytics();

      expect(requestCount, 1);
    });

    test('identifySession posts the expected session properties', () async {
      final SettingsRepository repository =
          await _buildRepository(const <String, Object>{
            'analytics_enabled': true,
            'analytics_session_id': 'session-123',
            'user_id': 'user-123',
            'user_name': 'Bhakt Pranav',
            'registration_date': '2026-04-20T10:00:00.000Z',
            'onboarding_date': '2026-04-22T08:00:00.000Z',
            'theme_mode': 'dark',
            'text_scale': 1.2,
            'script_mode': 2,
            'preferred_language': 'hi',
            'notification_enabled': true,
            'notification_hour': 7,
            'notification_minute': 30,
            'auto_play': false,
            'repeat_current': true,
            'crossfade_duration': 3,
            'onboarding_completed': true,
          });

      Map<String, dynamic>? payload;
      AnalyticsService.configure(
        settingsRepository: repository,
        analyticsEnabled: true,
        sessionId: repository.getAnalyticsSessionId() ?? 'session-123',
        locale: repository.getPreferredLanguage(),
        name: repository.getUserName(),
        userId: repository.getUserId(),
        endpoint: 'https://example.com/api/send',
        websiteId: 'site-123',
        hostname: 'aartisangrah-test',
        appVersionLoader: () async => '2.0.0',
        deviceInfoLoader: () async => const DeviceSnapshot(
          model: 'Pixel 8',
          osVersion: 'Android 16',
          platform: 'android',
        ),
        now: () => DateTime.utc(2026, 5, 1, 12),
        client: MockClient((http.Request request) async {
          payload = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{"ok":true}', 200);
        }),
      );

      await AnalyticsService.identifySession(path: '/settings');

      expect(payload, isNotNull);
      expect(payload!['type'], 'identify');
      final Map<String, dynamic> identifyPayload =
          payload!['payload'] as Map<String, dynamic>;
      expect(identifyPayload['url'], '/settings');
      expect(identifyPayload['language'], 'Hindi');
      expect(identifyPayload['id'], 'BhaktPranav-user-123');
      final Map<String, dynamic> data =
          identifyPayload['data'] as Map<String, dynamic>;
      expect(data['name'], 'Bhakt Pranav');
      expect(data['device_model'], 'Pixel 8');
      expect(data['app_version'], '2.0.0');
      expect(data['theme'], 'dark');
      expect(data['text_scale'], 1.2);
      expect(data['script_mode'], 'gujarati');
      expect(data['app_language'], 'hi');
      expect(data['notification_enabled'], isTrue);
      expect(data['notification_time'], '07:30');
      expect(data['auto_play_enabled'], isFalse);
      expect(data['repeat_current_enabled'], isTrue);
      expect(data['crossfade_duration_seconds'], 3);
      expect(data['onboarding_completed'], isTrue);
      expect(data['profile_complete'], isTrue);
      expect(data['registration_date'], '2026-04-20T10:00:00.000Z');
      expect(data['onboarding_date'], '2026-04-22T08:00:00.000Z');
    });

    test('identifySession skips unchanged session properties', () async {
      final SettingsRepository repository =
          await _buildRepository(const <String, Object>{
            'analytics_enabled': true,
            'analytics_session_id': 'session-123',
            'user_id': 'user-123',
            'user_name': 'Bhakt Pranav',
            'registration_date': '2026-04-20T10:00:00.000Z',
            'onboarding_date': '2026-04-22T08:00:00.000Z',
            'theme_mode': 'dark',
            'text_scale': 1.2,
            'script_mode': 2,
            'preferred_language': 'hi',
            'notification_enabled': true,
            'notification_hour': 7,
            'notification_minute': 30,
            'auto_play': false,
            'repeat_current': true,
            'crossfade_duration': 3,
            'onboarding_completed': true,
          });

      var requestCount = 0;
      AnalyticsService.configure(
        settingsRepository: repository,
        analyticsEnabled: true,
        sessionId: repository.getAnalyticsSessionId() ?? 'session-123',
        locale: repository.getPreferredLanguage(),
        name: repository.getUserName(),
        userId: repository.getUserId(),
        endpoint: 'https://example.com/api/send',
        websiteId: 'site-123',
        hostname: 'aartisangrah-test',
        appVersionLoader: () async => '2.0.0',
        deviceInfoLoader: () async => const DeviceSnapshot(
          model: 'Pixel 8',
          osVersion: 'Android 16',
          platform: 'android',
        ),
        now: () => DateTime.utc(2026, 5, 1, 12),
        client: MockClient((http.Request request) async {
          requestCount += 1;
          return http.Response('{"ok":true}', 200);
        }),
      );

      await AnalyticsService.identifySession(path: '/settings');
      await AnalyticsService.identifySession(path: '/home');

      expect(requestCount, 1);
    });

    test('trackEvent does not send when analytics are disabled', () async {
      final SettingsRepository repository =
          await _buildRepository(const <String, Object>{
            'analytics_enabled': false,
            'analytics_session_id': 'session-123',
            'user_id': 'user-123',
          });

      var requestCount = 0;
      AnalyticsService.configure(
        settingsRepository: repository,
        analyticsEnabled: false,
        sessionId: repository.getAnalyticsSessionId() ?? 'session-123',
        locale: 'en',
        endpoint: 'https://example.com/api/send',
        websiteId: 'site-123',
        client: MockClient((http.Request request) async {
          requestCount += 1;
          return http.Response('{"ok":true}', 200);
        }),
      );

      AnalyticsService.trackEvent('discover_screen_viewed', path: '/discover');
      await _flushAnalytics();

      expect(requestCount, 0);
    });

    test('trackEvent does not send before onboarding is completed', () async {
      final SettingsRepository repository =
          await _buildRepository(const <String, Object>{
            'analytics_enabled': true,
            'analytics_session_id': 'session-123',
            'user_id': 'user-123',
          });

      var requestCount = 0;
      AnalyticsService.configure(
        settingsRepository: repository,
        analyticsEnabled: true,
        sessionId: repository.getAnalyticsSessionId() ?? 'session-123',
        locale: 'en',
        endpoint: 'https://example.com/api/send',
        websiteId: 'site-123',
        client: MockClient((http.Request request) async {
          requestCount += 1;
          return http.Response('{"ok":true}', 200);
        }),
      );

      AnalyticsService.trackEvent('discover_screen_viewed', path: '/discover');
      AnalyticsService.trackScreen('/discover', title: 'Discover');
      await _flushAnalytics();

      expect(requestCount, 0);
    });

    test('identifySession does not send before onboarding is completed', () async {
      final SettingsRepository repository =
          await _buildRepository(const <String, Object>{
            'analytics_enabled': true,
            'analytics_session_id': 'session-123',
            'user_id': 'user-123',
            'user_name': 'Seva Bhakt',
          });

      var requestCount = 0;
      AnalyticsService.configure(
        settingsRepository: repository,
        analyticsEnabled: true,
        sessionId: repository.getAnalyticsSessionId() ?? 'session-123',
        locale: 'en',
        name: repository.getUserName(),
        userId: repository.getUserId(),
        endpoint: 'https://example.com/api/send',
        websiteId: 'site-123',
        client: MockClient((http.Request request) async {
          requestCount += 1;
          return http.Response('{"ok":true}', 200);
        }),
      );

      await AnalyticsService.identifySession(path: '/settings');

      expect(requestCount, 0);
    });

    test(
      'trackEvent retries 5xx responses with exponential attempts',
      () async {
        final SettingsRepository repository =
            await _buildRepository(const <String, Object>{
              'analytics_enabled': true,
              'analytics_session_id': 'session-123',
              'user_id': 'user-123',
              'onboarding_completed': true,
            });

        var requestCount = 0;
        AnalyticsService.configure(
          settingsRepository: repository,
          analyticsEnabled: true,
          sessionId: repository.getAnalyticsSessionId() ?? 'session-123',
          locale: 'en',
          endpoint: 'https://example.com/api/send',
          websiteId: 'site-123',
          client: MockClient((http.Request request) async {
            requestCount += 1;
            return http.Response('{"ok":false}', 500);
          }),
        );
        AnalyticsService.setRetryDelaysForTesting(const <Duration>[
          Duration.zero,
          Duration.zero,
        ]);

        AnalyticsService.trackEvent(
          'discover_screen_viewed',
          path: '/discover',
        );
        await _flushAnalytics();

        expect(requestCount, 3);
      },
    );

    test('trackEvent does not retry 4xx responses', () async {
      final SettingsRepository repository =
          await _buildRepository(const <String, Object>{
            'analytics_enabled': true,
            'analytics_session_id': 'session-123',
            'user_id': 'user-123',
            'onboarding_completed': true,
          });

      var requestCount = 0;
      AnalyticsService.configure(
        settingsRepository: repository,
        analyticsEnabled: true,
        sessionId: repository.getAnalyticsSessionId() ?? 'session-123',
        locale: 'en',
        endpoint: 'https://example.com/api/send',
        websiteId: 'site-123',
        client: MockClient((http.Request request) async {
          requestCount += 1;
          return http.Response('{"ok":false}', 400);
        }),
      );

      AnalyticsService.trackEvent('discover_screen_viewed', path: '/discover');
      await _flushAnalytics();

      expect(requestCount, 1);
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

Future<void> _flushAnalytics() async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
}
