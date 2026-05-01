import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/core/services/user_sync_service.dart';
import 'package:aartiapp/core/utils/device_info_helper.dart';
import 'package:aartiapp/data/repositories/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserSyncService', () {
    test(
      'force sync posts the expected payload for a completed user',
      () async {
        final repository = await _buildRepository(const <String, Object>{
          'onboarding_completed': true,
          'user_id': 'user-123',
          'user_name': 'Aarti Bhakt',
          'registration_date': '2026-04-20T10:00:00.000Z',
          'onboarding_date': '2026-04-21T08:00:00.000Z',
          'theme_mode': 'dark',
          'text_scale': 1.2,
          'script_mode': 2,
          'preferred_language': 'gu',
          'notification_enabled': true,
          'notification_hour': 7,
          'notification_minute': 30,
          'auto_play': false,
          'repeat_current': true,
          'crossfade_duration': 3,
        });

        Map<String, dynamic>? payload;
        final service = UserSyncService(
          settingsRepository: repository,
          webhookUrl: 'https://example.com/user-sync',
          now: () => DateTime.utc(2026, 5, 1, 12),
          appVersionLoader: () async => '2.0.0',
          deviceInfoLoader: () async => const DeviceSnapshot(
            model: 'Pixel 8',
            osVersion: 'Android 16',
            platform: 'android',
          ),
          client: MockClient((request) async {
            payload = jsonDecode(request.body) as Map<String, dynamic>;
            return http.Response('{"ok":true}', 200);
          }),
        );

        await service.sync(force: true);

        expect(payload, isNotNull);
        expect(payload!['user_id'], 'user-123');
        expect(payload!['user_name'], 'Aarti Bhakt');
        expect(payload!['registration_date'], '2026-04-20T10:00:00.000Z');
        expect(payload!['onboarding_date'], '2026-04-21T08:00:00.000Z');
        expect(payload!['device_model'], 'Pixel 8');
        expect(payload!['os_version'], 'Android 16');
        expect(payload!['platform'], 'android');
        expect(payload!['app_version'], '2.0.0');
        expect(payload!['theme_mode'], 'dark');
        expect(payload!['text_scale'], 1.2);
        expect(payload!['script_mode'], 'gujarati');
        expect(payload!['app_language'], 'gu');
        expect(payload!['notification_enabled'], isTrue);
        expect(payload!['notification_time'], '07:30');
        expect(payload!['auto_play_enabled'], isFalse);
        expect(payload!['repeat_current_enabled'], isTrue);
        expect(payload!['crossfade_duration_seconds'], 3);
        expect(payload!['onboarding_completed'], isTrue);
        expect(payload!['profile_complete'], isTrue);
        expect(payload!['last_updated'], '2026-05-01T12:00:00.000Z');
      },
    );

    test('sync backfills identity for a completed legacy install', () async {
      final repository = await _buildRepository(const <String, Object>{
        'onboarding_completed': true,
      });

      Map<String, dynamic>? payload;
      final service = UserSyncService(
        settingsRepository: repository,
        webhookUrl: 'https://example.com/user-sync',
        now: () => DateTime.utc(2026, 5, 1, 12),
        appVersionLoader: () async => '2.0.0',
        deviceInfoLoader: () async => const DeviceSnapshot(
          model: 'Windows PC',
          osVersion: 'Windows 11',
          platform: 'windows',
        ),
        client: MockClient((request) async {
          payload = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{"ok":true}', 200);
        }),
      );

      await service.sync(force: true);

      expect(payload, isNotNull);
      expect((payload!['user_id'] as String), isNotEmpty);
      expect((payload!['registration_date'] as String), isNotEmpty);
      expect(repository.getUserId(), isNotNull);
      expect(repository.getRegistrationDate(), isNotNull);
    });

    test('rapid sync requests debounce into one HTTP request', () async {
      final repository = await _buildRepository(const <String, Object>{
        'onboarding_completed': true,
        'user_id': 'user-123',
        'registration_date': '2026-04-20T10:00:00.000Z',
      });

      var requestCount = 0;
      final service = UserSyncService(
        settingsRepository: repository,
        webhookUrl: 'https://example.com/user-sync',
        debounceDelay: const Duration(milliseconds: 20),
        appVersionLoader: () async => '2.0.0',
        deviceInfoLoader: () async => const DeviceSnapshot(
          model: 'Pixel 8',
          osVersion: 'Android 16',
          platform: 'android',
        ),
        client: MockClient((request) async {
          requestCount += 1;
          return http.Response('{"ok":true}', 200);
        }),
      );

      await service.sync();
      await service.sync();
      await service.sync();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(requestCount, 1);
    });

    test(
      'force sync bypasses debounce and cancels the pending timer',
      () async {
        final repository = await _buildRepository(const <String, Object>{
          'onboarding_completed': true,
          'user_id': 'user-123',
          'registration_date': '2026-04-20T10:00:00.000Z',
        });

        var requestCount = 0;
        final service = UserSyncService(
          settingsRepository: repository,
          webhookUrl: 'https://example.com/user-sync',
          debounceDelay: const Duration(milliseconds: 50),
          appVersionLoader: () async => '2.0.0',
          deviceInfoLoader: () async => const DeviceSnapshot(
            model: 'Pixel 8',
            osVersion: 'Android 16',
            platform: 'android',
          ),
          client: MockClient((request) async {
            requestCount += 1;
            return http.Response('{"ok":true}', 200);
          }),
        );

        await service.sync();
        await service.sync(force: true);
        await Future<void>.delayed(const Duration(milliseconds: 80));

        expect(requestCount, 1);
      },
    );

    test('non-2xx responses do not throw to the caller', () async {
      final repository = await _buildRepository(const <String, Object>{
        'onboarding_completed': true,
        'user_id': 'user-123',
        'registration_date': '2026-04-20T10:00:00.000Z',
      });

      final service = UserSyncService(
        settingsRepository: repository,
        webhookUrl: 'https://example.com/user-sync',
        appVersionLoader: () async => '2.0.0',
        deviceInfoLoader: () async => const DeviceSnapshot(
          model: 'Pixel 8',
          osVersion: 'Android 16',
          platform: 'android',
        ),
        client: MockClient((request) async {
          return http.Response('{"ok":false}', 500);
        }),
      );

      await expectLater(service.sync(force: true), completes);
    });

    test('sync does not post before onboarding is complete', () async {
      final repository = await _buildRepository(const <String, Object>{});

      var requestCount = 0;
      final service = UserSyncService(
        settingsRepository: repository,
        webhookUrl: 'https://example.com/user-sync',
        appVersionLoader: () async => '2.0.0',
        deviceInfoLoader: () async => const DeviceSnapshot(
          model: 'Pixel 8',
          osVersion: 'Android 16',
          platform: 'android',
        ),
        client: MockClient((request) async {
          requestCount += 1;
          return http.Response('{"ok":true}', 200);
        }),
      );

      await service.sync(force: true);

      expect(requestCount, 0);
    });
  });
}

Future<SettingsRepository> _buildRepository(
  Map<String, Object> initialValues,
) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final prefs = await SharedPreferences.getInstance();
  return SettingsRepository(prefs);
}
