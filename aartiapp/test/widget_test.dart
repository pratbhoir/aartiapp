import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/app.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{
      'onboarding_completed': false,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const AartiSangrahApp(),
      ),
    );

    expect(find.textContaining('Aarti Sangrah'), findsOneWidget);
  });
}
