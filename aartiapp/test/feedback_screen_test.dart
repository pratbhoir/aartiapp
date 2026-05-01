import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/core/services/feedback_service.dart';
import 'package:aartiapp/core/theme/app_theme.dart';
import 'package:aartiapp/core/utils/device_info_helper.dart';
import 'package:aartiapp/data/repositories/settings_repository.dart';
import 'package:aartiapp/features/settings/feedback_screen.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedbackScreen', () {
    testWidgets('validates message and email before submit', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      int submitCount = 0;
      final FeedbackService service = await _buildService(
        onRequest: (Map<String, dynamic> payload) async {
          submitCount += 1;
          return http.Response('{"ok":true}', 200);
        },
      );

      await tester.pumpWidget(_buildTestApp(service: service));

      final Finder submitButton = find.widgetWithText(
        ElevatedButton,
        'Send Feedback',
      );

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your feedback.'), findsOneWidget);
      expect(submitCount, 0);

      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'A verse is missing on the Hanuman page.',
      );
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(submitCount, 0);
    });

    testWidgets('shows success state after a valid submission', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      int submitCount = 0;
      Map<String, dynamic>? lastPayload;
      final FeedbackService service = await _buildService(
        onRequest: (Map<String, dynamic> payload) async {
          submitCount += 1;
          lastPayload = payload;
          return http.Response('{"ok":true}', 200);
        },
      );

      await tester.pumpWidget(_buildTestApp(service: service));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'bhakt@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Please add a bookmark filter for festival aartis.',
      );
      final Finder submitButton = find.widgetWithText(
        ElevatedButton,
        'Send Feedback',
      );
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(submitCount, 1);
      expect(lastPayload?['feedback_type'], 'Incorrect Lyrics');
      expect(
        lastPayload?['message'],
        'Please add a bookmark filter for festival aartis.',
      );
      expect(lastPayload?['email'], 'bhakt@example.com');
      expect(find.text('Feedback received'), findsOneWidget);
      expect(find.text('Send Another Response'), findsOneWidget);
    });
  });
}

Widget _buildTestApp({required FeedbackService service}) {
  return ProviderScope(
    overrides: <Override>[
      feedbackServiceProvider.overrideWith((Ref ref) => service),
    ],
    child: MaterialApp(theme: AppTheme.light(), home: const FeedbackScreen()),
  );
}

Future<FeedbackService> _buildService({
  required Future<http.Response> Function(Map<String, dynamic> payload)
  onRequest,
}) async {
  SharedPreferences.setMockInitialValues(const <String, Object>{
    'user_id': 'user-123',
    'user_name': 'Bhakt',
    'registration_date': '2026-04-20T10:00:00.000Z',
    'onboarding_date': '2026-04-22T08:00:00.000Z',
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final SettingsRepository repository = SettingsRepository(prefs);

  return FeedbackService(
    settingsRepository: repository,
    webhookUrl: 'https://example.com/feedback',
    feedbackIdGenerator: () => 'feedback-123',
    now: () => DateTime.utc(2026, 5, 1, 12),
    appVersionLoader: () async => '2.0.0',
    deviceInfoLoader: () async => const _TestDeviceSnapshot(),
    client: MockClient((http.Request request) async {
      return onRequest(
        request.body.isEmpty
            ? <String, dynamic>{}
            : (jsonDecode(request.body) as Map<String, dynamic>),
      );
    }),
  );
}

class _TestDeviceSnapshot extends DeviceSnapshot {
  const _TestDeviceSnapshot()
    : super(model: 'Pixel 8', osVersion: 'Android 16', platform: 'android');
}
