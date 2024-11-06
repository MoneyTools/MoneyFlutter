import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/core/controller/theme_controller.dart';
import 'package:money/core/widgets/side_panel/side_panel.dart';
import 'package:money/core/widgets/snack_bar.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/list_item.dart';

Future<void> tapOnText(final WidgetTester tester, final String textToFind) async {
  final firstMatchingElement = find.text(textToFind).first;
  expect(firstMatchingElement, findsOneWidget);
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.myPump();
}

Finder findByKeyString(final String keyString) {
  final Finder firstMatchingElement = find.byKey(Key(keyString)).first;
  expect(firstMatchingElement, findsOneWidget);
  return firstMatchingElement;
}

Future<void> tapOnKeyString(final WidgetTester tester, final String keyString) async {
  final firstMatchingElement = findByKeyString(keyString);
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
  await tapOnKeyString(tester, 'key_snackbar_close_button');
}

// Select first element of the Side-Panel-Transaction-List
Future<void> selectFirstItemOfSidePanelTransactionLIst(WidgetTester tester) async {
  final element = await getFirstRowOfSidePanelTransactionList(tester);
  await tester.tap(element, warnIfMissed: false);
  await tester.myPump();
}

// Long Press first element of the Side-Panel-Transaction-List
Future<void> longPressFirstItemOfSidePanelTransactionLIst(WidgetTester tester) async {
  final element = await getFirstRowOfSidePanelTransactionList(tester);
  await tester.longPress(element, warnIfMissed: false);
  await tester.myPump();
}

Future<Finder> getFirstRowOfSidePanelTransactionList(WidgetTester tester) async {
  // Select first element of the Side-Panel-Transaction-List
  Finder firstMatchingElement = find.descendant(
    of: find.byType(SidePanel),
    matching: find.byType(MyListItem),
  );
  expect(
    firstMatchingElement,
    findsAny,
  );

  firstMatchingElement = firstMatchingElement.first;

  expect(firstMatchingElement, findsOneWidget);
  return firstMatchingElement;
}

Future<void> inputText(WidgetTester tester, final String textToEnter) async {
  final Finder filterInput = find.byType(TextField).first;
  await inputTextToElement(tester, filterInput, textToEnter);
}

Future<void> inputTextToElement(WidgetTester tester, Finder filterInput, String textToEnter) async {
  await tester.enterText(filterInput, textToEnter);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.myPump();
}

Future<void> tapAllToggleButtons(final WidgetTester tester, final List<String> keys) async {
  for (final key in keys) {
    await tapOnKeyString(tester, key);
  }
}

Future<void> inputTextToTextFieldWithThisLabel(
  WidgetTester tester,
  final String labelToFind,
  final String textToInput,
) async {
  Finder textFieldFinder = findTextFieldByLabel(labelToFind).first;
  expect(textFieldFinder, findsOneWidget, reason: 'searching for label $labelToFind');
  await inputTextToElement(tester, textFieldFinder, textToInput);
}

Finder findTextFieldByLabel(final String labelToFind) {
  final textFieldFinder = find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == labelToFind,
  );
  return textFieldFinder;
}
