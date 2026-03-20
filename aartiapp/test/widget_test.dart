import 'package:flutter_test/flutter_test.dart';

import 'package:aartiapp/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AartiSangrahApp());

    // Verify that the Discover screen greeting is visible
    expect(find.textContaining('Shri Krishna'), findsOneWidget);
  });
}
