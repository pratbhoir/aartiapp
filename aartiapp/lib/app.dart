import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aartiapp/l10n/app_localizations.dart';
import 'core/services/analytics_service.dart';
import 'core/l10n/app_locale.dart';
import 'core/l10n/app_localizations_ext.dart';
import 'core/theme/app_theme.dart';
import 'navigation/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers/app_providers.dart';

class AartiSangrahApp extends ConsumerStatefulWidget {
  const AartiSangrahApp({super.key});

  @override
  ConsumerState<AartiSangrahApp> createState() => _AartiSangrahAppState();
}

class _AartiSangrahAppState extends ConsumerState<AartiSangrahApp>
    with WidgetsBindingObserver {
  bool _didQueueStartupSync = false;
  bool _didQueueAnalyticsIdentify = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(contentSyncProvider.notifier).refreshIfStale());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(contentSyncProvider.notifier).refreshIfStale());
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final onboardingDone = ref.watch(onboardingCompletedProvider);
    final preferredLanguage = ref.watch(preferredLanguageProvider);

    _queueStartupSyncIfNeeded(onboardingDone);
    _queueAnalyticsIdentifyIfNeeded(onboardingDone);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: AppLocale.fromLanguageCode(preferredLanguage),
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: onboardingDone
          ? const HomeShell()
          : OnboardingScreen(
              onComplete: () {
                // Force rebuild by reading the provider after completion
                ref.invalidate(onboardingCompletedProvider);
              },
            ),
    );
  }

  void _queueStartupSyncIfNeeded(bool onboardingDone) {
    if (!onboardingDone) {
      _didQueueStartupSync = false;
      return;
    }

    if (_didQueueStartupSync) {
      return;
    }

    _didQueueStartupSync = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(userSyncServiceProvider).sync(force: true));
    });
  }

  void _queueAnalyticsIdentifyIfNeeded(bool onboardingDone) {
    if (!onboardingDone) {
      _didQueueAnalyticsIdentify = false;
      return;
    }

    if (_didQueueAnalyticsIdentify) {
      return;
    }

    _didQueueAnalyticsIdentify = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(AnalyticsService.identifySession());
    });
  }
}
