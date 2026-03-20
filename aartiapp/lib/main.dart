import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories/aarti_repository.dart';
import 'data/repositories/bookmark_repository.dart';
import 'data/repositories/puja_repository.dart';
import 'data/repositories/user_aarti_repository.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Load aarti catalog from bundled JSON
  await AartiRepository.instance.load();

  // Initialize repositories
  final prefs = await SharedPreferences.getInstance();
  final pujaRepo = PujaRepository();
  await pujaRepo.init();
  final bookmarkRepo = BookmarkRepository();
  await bookmarkRepo.init();
  final userAartiRepo = UserAartiRepository();
  await userAartiRepo.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        pujaRepoProvider.overrideWithValue(pujaRepo),
        bookmarkRepoProvider.overrideWithValue(bookmarkRepo),
        userAartiRepoProvider.overrideWithValue(userAartiRepo),
      ],
      child: const AartiSangrahApp(),
    ),
  );
}
