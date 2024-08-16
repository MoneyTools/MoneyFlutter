import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/app/controller/theme_controller.dart';
import 'package:money/app/core/widgets/snack_bar.dart';

Future<void> tapOnText(final WidgetTester tester, final String textToFind) async {
  final firstMatchingElement = find.text(textToFind).first;
  expect(firstMatchingElement, findsOneWidget);
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.myPump();
}

Finder finByKeyString(final String keyString) {
  final Finder firstMatchingElement = find.byKey(Key(keyString)).first;
  return firstMatchingElement;
}

Future<void> tapOnKeyString(final WidgetTester tester, final String keyString) async {
  final firstMatchingElement = finByKeyString(keyString);
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
  final firstMatchingElement = find.byTooltip('Back');
  expect(firstMatchingElement, findsOneWidget, reason: 'No Back button found');
  await tester.tap(firstMatchingElement);
  await tester.myPump();
}

Future<void> pump(final WidgetTester tester, [int milliseconds = 300]) async {
  await tester.pumpAndSettle(Duration(milliseconds: milliseconds));
}

extension WidgetTesterExtension on WidgetTester {
  Future<void> myPump([int milliseconds = 100]) async {
    await pump(this, milliseconds);
  }
}

Future<void> switchToSmall(tester) async {
  ThemeController.to.setAppSizeToSmall();
  await tester.pumpAndSettle();
  await showInstruction(tester, 'Small Screen - Phone');
}

Future<void> switchToMedium(tester) async {
  ThemeController.to.setAppSizeToMedium();
  await tester.pumpAndSettle();
  await showInstruction(tester, 'Medium Screen - iPad');
}

Future<void> switchToLarge(tester) async {
  ThemeController.to.setAppSizeToLarge();
  await tester.pumpAndSettle();
  await showInstruction(tester, 'Medium Screen - Desktop');
}

Future<void> showInstruction(tester, text) async {
  SnackBarService.display(message: text, autoDismiss: true, title: 'MyMoney flutter integration test', duration: 5);
  await tester.pumpAndSettle();

  // Keep the message on screen for a few seconds
  // await Future.delayed(const Duration(milliseconds: 000));
  await tapOnKeyString(tester, 'key_snackbar_close_button');
  // await tester.pumpAndSettle(Durations.long1);
}
