import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/core/services/content_cache_service.dart';
import 'package:aartiapp/core/services/content_sync_service.dart';
import 'package:aartiapp/data/repositories/aarti_repository.dart';
import 'package:aartiapp/data/repositories/festival_repository.dart';
import 'package:aartiapp/data/repositories/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentSyncService', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('aartiapp_content_sync');
      AartiRepository.instance.loadFromJsonString(
        _baselineAartiFixture,
        source: 'bundled',
      );
      FestivalRepository.instance.loadFromJsonString(
        _baselineFestivalFixture,
        source: 'bundled',
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'refreshNow fetches, caches, and applies both content payloads',
      () async {
        final repository = await _buildRepository(const <String, Object>{});
        final cacheService = ContentCacheService(
          documentsDirectoryLoader: () async => tempDir,
        );
        final requests = <Uri>[];
        final timestamp = DateTime.utc(2026, 5, 1, 9, 30);

        final service = ContentSyncService(
          settingsRepository: repository,
          cacheService: cacheService,
          festivalWebhookUrl: 'https://example.com/festival-content',
          aartiWebhookUrl: 'https://example.com/aarti-content',
          now: () => timestamp,
          client: MockClient((request) async {
            requests.add(request.url);
            if (request.url.path.contains('festival-content')) {
              return http.Response.bytes(
                utf8.encode(_updatedFestivalFixture),
                200,
                headers: const <String, String>{
                  'content-type': 'application/json; charset=utf-8',
                },
              );
            }
            return http.Response.bytes(
              utf8.encode(_updatedAartiFixture),
              200,
              headers: const <String, String>{
                'content-type': 'application/json; charset=utf-8',
              },
            );
          }),
        );

        final result = await service.refreshNow();

        expect(result.didChange, isTrue);
        expect(result.hasErrors, isFalse);
        expect(requests, hasLength(2));
        expect(AartiRepository.instance.aartis, hasLength(1));
        expect(AartiRepository.instance.version, 7);
        expect(AartiRepository.instance.dataSource, 'remote');
        expect(FestivalRepository.instance.festivals, hasLength(1));
        expect(FestivalRepository.instance.version, 3);
        expect(FestivalRepository.instance.dataSource, 'remote');
        expect(await cacheService.readAartiContent(), _updatedAartiFixture);
        expect(
          await cacheService.readFestivalContent(),
          _updatedFestivalFixture,
        );
        expect(repository.getAartiContentLastSync(), timestamp);
        expect(repository.getFestivalContentLastSync(), timestamp);
        expect(repository.getAartiContentVersion(), 7);
        expect(repository.getFestivalContentVersion(), 3);
      },
    );

    test(
      'refreshIfStale skips network calls when both datasets are fresh',
      () async {
        final now = DateTime.utc(2026, 5, 1, 12);
        final repository = await _buildRepository(<String, Object>{
          'festival_content_last_sync': now
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          'aarti_content_last_sync': now
              .subtract(const Duration(hours: 1))
              .toIso8601String(),
        });
        var requestCount = 0;

        final service = ContentSyncService(
          settingsRepository: repository,
          cacheService: ContentCacheService(
            documentsDirectoryLoader: () async => tempDir,
          ),
          now: () => now,
          refreshInterval: const Duration(hours: 24),
          client: MockClient((request) async {
            requestCount += 1;
            return http.Response('{}', 200);
          }),
        );

        final result = await service.refreshIfStale();

        expect(result.skipped, isTrue);
        expect(requestCount, 0);
      },
    );

    test(
      'refreshNow preserves successful dataset when the other one fails',
      () async {
        final repository = await _buildRepository(const <String, Object>{});
        final cacheService = ContentCacheService(
          documentsDirectoryLoader: () async => tempDir,
        );

        final service = ContentSyncService(
          settingsRepository: repository,
          cacheService: cacheService,
          festivalWebhookUrl: 'https://example.com/festival-content',
          aartiWebhookUrl: 'https://example.com/aarti-content',
          now: () => DateTime.utc(2026, 5, 1, 14),
          client: MockClient((request) async {
            if (request.url.path.contains('festival-content')) {
              return http.Response('server error', 500);
            }
            return http.Response.bytes(
              utf8.encode(_updatedAartiFixture),
              200,
              headers: const <String, String>{
                'content-type': 'application/json; charset=utf-8',
              },
            );
          }),
        );

        final result = await service.refreshNow();

        expect(result.aartiUpdated, isTrue);
        expect(result.festivalUpdated, isFalse);
        expect(result.hasErrors, isTrue);
        expect(AartiRepository.instance.version, 7);
        expect(AartiRepository.instance.dataSource, 'remote');
        expect(FestivalRepository.instance.version, 1);
        expect(FestivalRepository.instance.dataSource, 'bundled');
        expect(await cacheService.readAartiContent(), _updatedAartiFixture);
        expect(await cacheService.readFestivalContent(), isNull);
        expect(
          repository.getAartiContentLastSync(),
          DateTime.utc(2026, 5, 1, 14),
        );
        expect(repository.getFestivalContentLastSync(), isNull);
      },
    );
  });
}

Future<SettingsRepository> _buildRepository(
  Map<String, Object> initialValues,
) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final prefs = await SharedPreferences.getInstance();
  return SettingsRepository(prefs);
}

const String _baselineAartiFixture = '''
{
  "version": 1,
  "deities": [
    {"emoji": "🕉️", "label": "All"},
    {"emoji": "🌙", "label": "Shiva"}
  ],
  "aartis": [
    {
      "id": "baseline_shiva",
      "title": "Baseline Shiva Aarti",
      "devanagari": "बेसलाइन शिव आरती",
      "deity": "Shiva",
      "duration": "1:00",
      "tags": ["Somvar"],
      "festivalTags": ["Maha Shivaratri"],
      "verses": [
        {
          "label": "Verse 1",
          "lines": ["शिव शम्भो"],
          "transliteration": ["Shiv Shambho"],
          "meanings": ["Praise to Shiva"],
          "gujarati": ["શિવ શંભો"]
        }
      ],
      "gujarati": "બેસલાઇન શિવ આરતી"
    }
  ]
}
''';

const String _updatedAartiFixture = '''
{
  "version": 7,
  "deities": [
    {"emoji": "🕉️", "label": "All"},
    {"emoji": "🐘", "label": "Ganesha"}
  ],
  "aartis": [
    {
      "id": "remote_ganesh",
      "title": "Remote Ganesh Aarti",
      "devanagari": "रिमोट गणेश आरती",
      "deity": "Ganesha",
      "duration": "2:00",
      "tags": ["Ganesh Chaturthi"],
      "festivalTags": ["Ganesh Chaturthi"],
      "verses": [
        {
          "label": "Verse 1",
          "lines": ["जय गणेशा"],
          "transliteration": ["Jai Ganesha"],
          "meanings": ["Victory to Ganesha"],
          "gujarati": ["જય ગણેશા"]
        }
      ],
      "gujarati": "રિમોટ ગણેશ આરતી"
    }
  ]
}
''';

const String _baselineFestivalFixture = '''
{
  "version": 1,
  "festivals": [
    {
      "id": "baseline_festival",
      "name": "Baseline Festival",
      "nameDevanagari": "बेसलाइन पर्व",
      "date": "2026-01-01",
      "deity": "Shiva",
      "description": "Bundled data",
      "aartiTag": "Maha Shivaratri",
      "emoji": "🌙"
    }
  ]
}
''';

const String _updatedFestivalFixture = '''
{
  "version": 3,
  "festivals": [
    {
      "id": "remote_festival",
      "name": "Remote Festival",
      "nameDevanagari": "रिमोट पर्व",
      "date": "2026-02-14",
      "deity": "Ganesha",
      "description": "Remote data",
      "aartiTag": "Ganesh Chaturthi",
      "emoji": "🐘"
    }
  ]
}
''';
