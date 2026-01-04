// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:memory_pair_game/main.dart';

void main() {
  testWidgets('renders splash then navigates to welcome screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MemoryPairGameApp());

    expect(find.text('FlipMatch'), findsOneWidget);
    expect(find.text('Welcome to'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('FlipMatch'), findsWidgets);
  });
}
