import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aartiapp/app.dart';
import 'package:aartiapp/providers/app_providers.dart';

void main() {
  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    Map<String, Object> initialValues = const <String, Object>{},
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding_completed': false,
      ...initialValues,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AartiSangrahApp(),
      ),
    );
    await tester.pump();
    return container;
  }

  testWidgets('App starts with persisted English locale', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      initialValues: const <String, Object>{'preferred_language': 'en'},
    );

    final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale?.languageCode, 'en');
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('App updates locale when preferred language changes', (
    WidgetTester tester,
  ) async {
    final container = await pumpApp(
      tester,
      initialValues: const <String, Object>{'preferred_language': 'en'},
    );

    container.read(preferredLanguageProvider.notifier).set('hi');
    await tester.pumpAndSettle();

    final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale?.languageCode, 'hi');
    expect(find.text('जारी रखें'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });
}
