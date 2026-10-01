import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise_ai/main.dart';

void main() {
  testWidgets('SpendWiseApp smoke test - verifies initial login screen loads', (WidgetTester tester) async {
    // Build the SpendWiseApp
    await tester.pumpWidget(const SpendWiseApp());
    await tester.pumpAndSettle();

    // Verify that the login screen title and fields load
    expect(find.text('SpendWise AI'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
