import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aartiapp/core/theme/app_colors.dart';
import 'package:aartiapp/core/theme/app_theme.dart';
import 'package:aartiapp/core/utils/snackbar_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SnackBarHelper', () {
    testWidgets('uses themed floating snackbar defaults for success', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestHarness());

      await tester.tap(find.text('Show Success'));
      await tester.pump();

      expect(find.text('Saved to your collection'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.theme?.snackBarTheme.behavior, SnackBarBehavior.floating);

      final SnackBar snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.duration, const Duration(milliseconds: 1500));
      expect(snackBar.backgroundColor, AppColors.snackBarSuccess);
    });

    testWidgets('renders info actions with high-contrast label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestHarness());

      await tester.tap(find.text('Show Info'));
      await tester.pump();

      expect(find.text('Sync available'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.info_rounded), findsOneWidget);

      final SnackBar snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.action, isNotNull);
      expect(snackBar.backgroundColor, AppColors.snackBarInfo);
    });

    testWidgets('replaces the current snackbar instead of queueing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _TestHarness());

      await tester.tap(find.text('Show Error'));
      await tester.pump();
      expect(find.text('Please check the form'), findsOneWidget);

      await tester.tap(find.text('Show Warning'));
      await tester.pump();

      expect(find.text('Please check the form'), findsNothing);
      expect(find.text('Removed from your list'), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });
  });
}

class _TestHarness extends StatelessWidget {
  const _TestHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return Column(
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(
                      context,
                      'Saved to your collection',
                    );
                  },
                  child: const Text('Show Success'),
                ),
                TextButton(
                  onPressed: () {
                    SnackBarHelper.showError(context, 'Please check the form');
                  },
                  child: const Text('Show Error'),
                ),
                TextButton(
                  onPressed: () {
                    SnackBarHelper.showWarning(
                      context,
                      'Removed from your list',
                    );
                  },
                  child: const Text('Show Warning'),
                ),
                TextButton(
                  onPressed: () {
                    SnackBarHelper.showInfo(
                      context,
                      'Sync available',
                      action: SnackBarAction(label: 'Retry', onPressed: () {}),
                    );
                  },
                  child: const Text('Show Info'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
