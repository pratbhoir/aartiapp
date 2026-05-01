import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/activity_log_service.dart';
import 'core/services/content_cache_service.dart';
import 'core/services/notification_service.dart';
import 'data/repositories/aarti_repository.dart';
import 'data/repositories/bookmark_repository.dart';
import 'data/repositories/festival_repository.dart';
import 'data/repositories/puja_repository.dart';
import 'data/repositories/user_aarti_repository.dart';
import 'data/repositories/recently_played_repository.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    ActivityLogService.error(
      'Flutter',
      details.exceptionAsString(),
      details.stack,
    );
  };

  await runZonedGuarded<Future<void>>(
    () async {
      await ActivityLogService.init();

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );

      // Initialize Hive for local storage
      await Hive.initFlutter();

      // Initialize repositories
      final prefs = await SharedPreferences.getInstance();
      final contentCacheService = ContentCacheService();
      await _loadCachedOrBundledContent(contentCacheService);

      // Initialize notification service (v1.5)
      await NotificationService.instance.init();

      final pujaRepo = PujaRepository();
      await pujaRepo.init();
      final bookmarkRepo = BookmarkRepository();
      await bookmarkRepo.init();
      final userAartiRepo = UserAartiRepository();
      await userAartiRepo.init();
      final recentlyPlayedRepo = RecentlyPlayedRepository();
      await recentlyPlayedRepo.init();

      // Restore scheduled notification if enabled (v1.5)
      final settingsNotifEnabled =
          prefs.getBool('notification_enabled') ?? false;
      if (settingsNotifEnabled) {
        final hour = prefs.getInt('notification_hour') ?? 6;
        final minute = prefs.getInt('notification_minute') ?? 0;
        await NotificationService.instance.scheduleDailyReminder(
          time: TimeOfDay(hour: hour, minute: minute),
        );
      }

      ActivityLogService.info('Bootstrap', 'App initialization completed');

      runApp(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            pujaRepoProvider.overrideWithValue(pujaRepo),
            bookmarkRepoProvider.overrideWithValue(bookmarkRepo),
            userAartiRepoProvider.overrideWithValue(userAartiRepo),
            recentlyPlayedRepoProvider.overrideWithValue(recentlyPlayedRepo),
          ],
          child: const AartiSangrahApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      ActivityLogService.error('Zone', error.toString(), stack);
    },
  );
}

Future<void> _loadCachedOrBundledContent(
  ContentCacheService contentCacheService,
) async {
  await _loadAartiCatalog(contentCacheService);
  await _loadFestivalCalendar(contentCacheService);
}

Future<void> _loadAartiCatalog(ContentCacheService contentCacheService) async {
  try {
    final cachedJson = await contentCacheService.readAartiContent();
    if (cachedJson != null) {
      AartiRepository.instance.loadFromJsonString(cachedJson, source: 'cache');
      ActivityLogService.info('Bootstrap', 'Loaded aarti catalog from cache');
      return;
    }
  } catch (error, stack) {
    ActivityLogService.warn(
      'Bootstrap',
      'Falling back to bundled aarti catalog after cache read failure: $error',
      stack,
    );
  }

  await AartiRepository.instance.load();
}

Future<void> _loadFestivalCalendar(
  ContentCacheService contentCacheService,
) async {
  try {
    final cachedJson = await contentCacheService.readFestivalContent();
    if (cachedJson != null) {
      FestivalRepository.instance.loadFromJsonString(
        cachedJson,
        source: 'cache',
      );
      ActivityLogService.info(
        'Bootstrap',
        'Loaded festival calendar from cache',
      );
      return;
    }
  } catch (error, stack) {
    ActivityLogService.warn(
      'Bootstrap',
      'Falling back to bundled festival calendar after cache read failure: $error',
      stack,
    );
  }

  await FestivalRepository.instance.load();
}
