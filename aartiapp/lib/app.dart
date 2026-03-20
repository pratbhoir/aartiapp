import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'navigation/home_shell.dart';

class AartiSangrahApp extends StatelessWidget {
  const AartiSangrahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aarti Sangrah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.stone,
        colorScheme: const ColorScheme.light(
          primary: AppColors.saffron,
          surface: AppColors.white,
        ),
        fontFamily: 'Georgia',
        splashColor: AppColors.saffronGlow,
        highlightColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeShell(),
    );
  }
}
