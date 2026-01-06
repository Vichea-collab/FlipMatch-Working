// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_pair_game/main.dart';
import 'package:memory_pair_game/ui/screens/how_to_play_screen.dart';
import 'package:memory_pair_game/ui/screens/name_entry_screen.dart';
import 'package:memory_pair_game/ui/screens/welcome_screen.dart';

void _configureTestDisplay(WidgetTester tester) {
  final view = tester.view;
  view.physicalSize = const Size(1080, 1920);
  view.devicePixelRatio = 1.0;
  addTearDown(() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });
}

void main() {
  testWidgets('renders splash then navigates to welcome screen',
      (WidgetTester tester) async {
    _configureTestDisplay(tester);

    await tester.pumpWidget(const MemoryPairGameApp());

    expect(find.text('FlipMatch'), findsOneWidget);
    expect(find.text('Welcome to'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('FlipMatch'), findsWidgets);
  });

  testWidgets('welcome screen shows actions and opens name entry',
      (WidgetTester tester) async {
    _configureTestDisplay(tester);
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    expect(find.text('Let\'s Play'), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);

    await tester.tap(find.text('Let\'s Play'));
    await tester.pumpAndSettle();

    expect(find.byType(NameEntryScreen), findsOneWidget);
  });

  testWidgets('welcome screen opens how to play instructions',
      (WidgetTester tester) async {
    _configureTestDisplay(tester);
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    await tester.tap(find.text('How to Play'));
    await tester.pumpAndSettle();

    expect(find.byType(HowToPlayScreen), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Use fewer moves for higher scores'), findsOneWidget);
  });
}
