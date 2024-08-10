import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapOnText(final WidgetTester tester, final String textToFind) async {
  final firstMatchingElement = find.text(textToFind).first;
  expect(firstMatchingElement, findsOneWidget);
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> tapOnKeyString(final WidgetTester tester, final String keyString) async {
  final firstMatchingElement = find.byKey(Key(keyString)).first;
  expect(firstMatchingElement, findsOneWidget);
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> tapOnKey(final WidgetTester tester, final Key key) async {
  final firstMatchingElement = find.byKey(key).first;
  expect(firstMatchingElement, findsOneWidget, reason: key.toString());
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> tapOnWidgetType(final WidgetTester tester, final Type type) async {
  final firstMatchingElement = find.byElementType(type).first;
  expect(firstMatchingElement, findsOneWidget);
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> tapBackButton(WidgetTester tester) async {
  final backButton = find.byTooltip('Back');
  await tester.tap(backButton);
  await tester.pumpAndSettle();
}
