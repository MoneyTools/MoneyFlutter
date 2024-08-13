import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapOnText(final WidgetTester tester, final String textToFind) async {
  final firstMatchingElement = find.text(textToFind).first;
  expect(firstMatchingElement, findsOneWidget);
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.myPump();
}

Future<void> tapOnKeyString(final WidgetTester tester, final String keyString) async {
  final firstMatchingElement = find.byKey(Key(keyString)).first;
  expect(firstMatchingElement, findsOneWidget);
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.myPump();
}

Future<void> tapOnKey(final WidgetTester tester, final Key key) async {
  final firstMatchingElement = find.byKey(key).first;
  expect(firstMatchingElement, findsOneWidget, reason: key.toString());
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.myPump();
}

Future<void> tapOnWidgetType(final WidgetTester tester, final Type type) async {
  final firstMatchingElement = find.byElementType(type).first;
  expect(firstMatchingElement, findsOneWidget);
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.myPump();
}

Future<void> tapOnTextFromParentType(final WidgetTester tester, final Type type, final String textToFind) async {
  Finder firstMatchingElement = find.descendant(
    of: find.byType(type),
    matching: find.text(textToFind),
  );
  expect(
    firstMatchingElement,
    findsAny,
    reason: 'tapOnTextFromParentType "$textToFind"',
  );

  firstMatchingElement = firstMatchingElement.first;

  expect(firstMatchingElement, findsOneWidget);
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.myPump();
}

Future<void> tapOnFirstRowOfListView(final WidgetTester tester) async {
  Finder firstMatchingElement = find.descendant(
    of: find.byType(ListView),
    matching: find.byType(Row),
  );
  expect(
    firstMatchingElement,
    findsAny,
  );

  firstMatchingElement = firstMatchingElement.first;

  expect(firstMatchingElement, findsOneWidget);
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.myPump();
}

Future<void> tapBackButton(WidgetTester tester) async {
  final backButton = find.byTooltip('Back');
  await tester.tap(backButton);
  await tester.myPump();
}

Future<void> pump(final WidgetTester tester, [int milliseconds = 300]) async {
  await tester.pumpAndSettle(Duration(milliseconds: milliseconds));
}

extension WidgetTesterExtension on WidgetTester {
  Future<void> myPump([int milliseconds = 50]) async {
    await pump(this, milliseconds);
  }
}
