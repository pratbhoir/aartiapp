import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'navigation/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers/app_providers.dart';

class AartiSangrahApp extends ConsumerWidget {
  const AartiSangrahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final onboardingDone = ref.watch(onboardingCompletedProvider);

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
}
