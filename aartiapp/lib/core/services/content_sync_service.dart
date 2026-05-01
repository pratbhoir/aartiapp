import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/repositories/aarti_repository.dart';
import '../../data/repositories/festival_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../constants/app_sync_config.dart';
import 'activity_log_service.dart';
import 'content_cache_service.dart';

/// Refreshes bundled devotional content from n8n-backed JSON endpoints.
class ContentSyncService {
  ContentSyncService({
    required SettingsRepository settingsRepository,
    required ContentCacheService cacheService,
    AartiRepository? aartiRepository,
    FestivalRepository? festivalRepository,
    http.Client? client,
    DateTime Function()? now,
    Duration refreshInterval = AppSyncConfig.contentRefreshInterval,
    Duration requestTimeout = AppSyncConfig.contentSyncRequestTimeout,
    String festivalWebhookUrl = AppSyncConfig.festivalContentWebhookUrl,
    String aartiWebhookUrl = AppSyncConfig.aartiContentWebhookUrl,
  }) : _settingsRepository = settingsRepository,
       _cacheService = cacheService,
       _aartiRepository = aartiRepository ?? AartiRepository.instance,
       _festivalRepository = festivalRepository ?? FestivalRepository.instance,
       _client = client ?? http.Client(),
       _ownsClient = client == null,
       _now = now ?? DateTime.now,
       _refreshInterval = refreshInterval,
       _requestTimeout = requestTimeout,
       _festivalWebhookUrl = festivalWebhookUrl,
       _aartiWebhookUrl = aartiWebhookUrl;

  final SettingsRepository _settingsRepository;
  final ContentCacheService _cacheService;
  final AartiRepository _aartiRepository;
  final FestivalRepository _festivalRepository;
  final http.Client _client;
  final bool _ownsClient;
  final DateTime Function() _now;
  final Duration _refreshInterval;
  final Duration _requestTimeout;
  final String _festivalWebhookUrl;
  final String _aartiWebhookUrl;

  Future<ContentRefreshResult>? _activeRefresh;

  /// Releases the underlying HTTP client when owned by this service.
  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  /// Refreshes both datasets immediately.
  Future<ContentRefreshResult> refreshNow() {
    return _enqueueRefresh(
      () => _refresh(
        refreshFestival: true,
        refreshAarti: true,
        skipIfFresh: false,
      ),
    );
  }

  /// Refreshes only stale datasets based on the persisted 24-hour window.
  Future<ContentRefreshResult> refreshIfStale() {
    return _enqueueRefresh(() {
      final now = _now().toUtc();
      final shouldRefreshFestival = _isStale(
        _settingsRepository.getFestivalContentLastSync(),
        now,
      );
      final shouldRefreshAarti = _isStale(
        _settingsRepository.getAartiContentLastSync(),
        now,
      );

      if (!shouldRefreshFestival && !shouldRefreshAarti) {
        return Future<ContentRefreshResult>.value(
          const ContentRefreshResult(
            festivalUpdated: false,
            aartiUpdated: false,
            festivalChecked: false,
            aartiChecked: false,
            errors: <String>[],
          ),
        );
      }

      return _refresh(
        refreshFestival: shouldRefreshFestival,
        refreshAarti: shouldRefreshAarti,
        skipIfFresh: true,
      );
    });
  }

  Future<ContentRefreshResult> _enqueueRefresh(
    Future<ContentRefreshResult> Function() action,
  ) {
    final activeRefresh = _activeRefresh;
    if (activeRefresh != null) {
      return activeRefresh;
    }

    final refresh = action();
    _activeRefresh = refresh;
    return refresh.whenComplete(() {
      if (identical(_activeRefresh, refresh)) {
        _activeRefresh = null;
      }
    });
  }

  Future<ContentRefreshResult> _refresh({
    required bool refreshFestival,
    required bool refreshAarti,
    required bool skipIfFresh,
  }) async {
    final futures = <Future<_DatasetRefreshOutcome>>[];

    if (refreshFestival) {
      futures.add(_refreshFestivalContent(skipIfFresh: skipIfFresh));
    }

    if (refreshAarti) {
      futures.add(_refreshAartiContent(skipIfFresh: skipIfFresh));
    }

    final outcomes = await Future.wait(futures);
    _DatasetRefreshOutcome? festivalOutcome;
    _DatasetRefreshOutcome? aartiOutcome;

    for (final outcome in outcomes) {
      if (outcome.dataset == _ContentDataset.festival) {
        festivalOutcome = outcome;
      } else {
        aartiOutcome = outcome;
      }
    }

    return ContentRefreshResult(
      festivalUpdated: festivalOutcome?.updated ?? false,
      aartiUpdated: aartiOutcome?.updated ?? false,
      festivalChecked: refreshFestival,
      aartiChecked: refreshAarti,
      errors: <String>[
        if (festivalOutcome?.error != null) festivalOutcome!.error!,
        if (aartiOutcome?.error != null) aartiOutcome!.error!,
      ],
    );
  }

  Future<_DatasetRefreshOutcome> _refreshFestivalContent({
    required bool skipIfFresh,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(_festivalWebhookUrl))
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message =
            'Festival content refresh failed with status ${response.statusCode}: ${response.body}';
        ActivityLogService.error('ContentSync', message);
        return _DatasetRefreshOutcome.failure(
          _ContentDataset.festival,
          message,
        );
      }

      final payload = _decodeRootObject(response.body);
      if (!payload.containsKey('festivals')) {
        throw const FormatException(
          'Festival content payload is missing the festivals list.',
        );
      }

      _festivalRepository.loadFromJsonString(response.body, source: 'remote');
      await _cacheService.writeFestivalContent(response.body);

      final now = _now().toUtc();
      await _settingsRepository.setFestivalContentLastSync(now);
      final version =
          (payload['version'] as int?) ?? _festivalRepository.version;
      await _settingsRepository.setFestivalContentVersion(version);
      ActivityLogService.info(
        'ContentSync',
        'Festival content refreshed with ${_festivalRepository.festivals.length} items.',
      );

      return const _DatasetRefreshOutcome.success(_ContentDataset.festival);
    } on TimeoutException catch (error, stack) {
      final message =
          'Festival content refresh timed out after ${_requestTimeout.inSeconds}s: $error';
      ActivityLogService.error('ContentSync', message, stack);
      return _DatasetRefreshOutcome.failure(_ContentDataset.festival, message);
    } catch (error, stack) {
      final message = 'Festival content refresh failed: $error';
      ActivityLogService.error('ContentSync', message, stack);
      return _DatasetRefreshOutcome.failure(_ContentDataset.festival, message);
    }
  }

  Future<_DatasetRefreshOutcome> _refreshAartiContent({
    required bool skipIfFresh,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(_aartiWebhookUrl))
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message =
            'Aarti content refresh failed with status ${response.statusCode}: ${response.body}';
        ActivityLogService.error('ContentSync', message);
        return _DatasetRefreshOutcome.failure(_ContentDataset.aarti, message);
      }

      final payload = _decodeRootObject(response.body);
      if (!payload.containsKey('aartis') || !payload.containsKey('deities')) {
        throw const FormatException(
          'Aarti content payload is missing required keys.',
        );
      }

      _aartiRepository.loadFromJsonString(response.body, source: 'remote');
      await _cacheService.writeAartiContent(response.body);

      final now = _now().toUtc();
      await _settingsRepository.setAartiContentLastSync(now);
      final version = (payload['version'] as int?) ?? _aartiRepository.version;
      await _settingsRepository.setAartiContentVersion(version);
      ActivityLogService.info(
        'ContentSync',
        'Aarti content refreshed with ${_aartiRepository.aartis.length} items.',
      );

      return const _DatasetRefreshOutcome.success(_ContentDataset.aarti);
    } on TimeoutException catch (error, stack) {
      final message =
          'Aarti content refresh timed out after ${_requestTimeout.inSeconds}s: $error';
      ActivityLogService.error('ContentSync', message, stack);
      return _DatasetRefreshOutcome.failure(_ContentDataset.aarti, message);
    } catch (error, stack) {
      final message = 'Aarti content refresh failed: $error';
      ActivityLogService.error('ContentSync', message, stack);
      return _DatasetRefreshOutcome.failure(_ContentDataset.aarti, message);
    }
  }

  bool _isStale(DateTime? lastSync, DateTime now) {
    if (lastSync == null) {
      return true;
    }

    return now.difference(lastSync.toUtc()) >= _refreshInterval;
  }

  Map<String, dynamic> _decodeRootObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }

    throw const FormatException('Content response must be a JSON object.');
  }
}

/// Summary of the latest content refresh attempt.
class ContentRefreshResult {
  const ContentRefreshResult({
    required this.festivalUpdated,
    required this.aartiUpdated,
    required this.festivalChecked,
    required this.aartiChecked,
    required this.errors,
  });

  final bool festivalUpdated;
  final bool aartiUpdated;
  final bool festivalChecked;
  final bool aartiChecked;
  final List<String> errors;

  bool get didChange => festivalUpdated || aartiUpdated;

  bool get skipped => !festivalChecked && !aartiChecked;

  bool get hasErrors => errors.isNotEmpty;
}

enum _ContentDataset { festival, aarti }

class _DatasetRefreshOutcome {
  const _DatasetRefreshOutcome._({
    required this.dataset,
    required this.updated,
    this.error,
  });

  const _DatasetRefreshOutcome.success(_ContentDataset dataset)
    : this._(dataset: dataset, updated: true);

  const _DatasetRefreshOutcome.failure(_ContentDataset dataset, String error)
    : this._(dataset: dataset, updated: false, error: error);

  final _ContentDataset dataset;
  final bool updated;
  final String? error;
}
