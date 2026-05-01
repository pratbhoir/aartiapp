import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'navigation/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers/app_providers.dart';

class AartiSangrahApp extends ConsumerStatefulWidget {
  const AartiSangrahApp({super.key});

  @override
  ConsumerState<AartiSangrahApp> createState() => _AartiSangrahAppState();
}

class _AartiSangrahAppState extends ConsumerState<AartiSangrahApp> {
  bool _didQueueStartupSync = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final onboardingDone = ref.watch(onboardingCompletedProvider);

    _queueStartupSyncIfNeeded(onboardingDone);

    return MaterialApp(
      title: 'Aarti Sangrah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
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
}
