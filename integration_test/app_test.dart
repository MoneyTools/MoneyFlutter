import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money/app/controller/theme_controller.dart';
import 'package:money/app/core/widgets/info_panel/info_panel_header.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('App Test', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Full app test', (WidgetTester tester) async {
      // Use an empty SharedPreferences to get the same results each time
      SharedPreferences.setMockInitialValues(<String, Object>{});

      app.main();
      await tester.pumpAndSettle();

      ThemeController.to.setAppSizeToLarge();
      await tester.pumpAndSettle();

      //------------------------------------------------------------------------
      // Welcome screen - Policy
      await tapOnText(tester, 'Privacy Policy');
      await tapBackButton(tester);

      //------------------------------------------------------------------------
      // Welcome screen - Licenses
      await tapOnText(tester, 'Licenses');
      await tapBackButton(tester);

      //------------------------------------------------------------------------
      // Welcome screen - MRU
      await tapOnKey(tester, Constants.keyMruButton);
      await tapOnText(tester, 'Close');

      //------------------------------------------------------------------------
      // Tap the "New File"
      await tapOnText(tester, 'New File ...');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      //------------------------------------------------------------------------
      // Toggle Theme Mode
      {
        // Turn Dark-Mode on
        await tapOnKeyString(tester, 'key_toggle_mode');
        await Future.delayed(const Duration(seconds: 1));

        // Turn back Light-Mode
        await tapOnKeyString(tester, 'key_toggle_mode');
        await Future.delayed(const Duration(seconds: 1));
      }

      //------------------------------------------------------------------------
      // Close the file
      await tapOnKeyString(tester, 'key_menu_button');
      await tapOnText(tester, 'Close file');

      //------------------------------------------------------------------------
      // Open a Demo Data
      await tapOnText(tester, 'Use Demo Data');

      //------------------------------------------------------------------------
      // Bring up the Settings dialog
      await tapOnKey(tester, Constants.keySettingsButton);
      await tapOnKeyString(tester, 'key_settings');

      // Turn on Rentals
      {
        // Find the SwitchListTile using the text label provided in the Semantics
        final Finder switchTileFinder = find.byWidgetPredicate(
          (Widget widget) =>
              widget is SwitchListTile && widget.title is Text && (widget.title as Text).data == 'Rental',
        );

        // Verify initial state is OFF (false)
        SwitchListTile switchTile = tester.widget(switchTileFinder);
        expect(switchTile.value, isFalse);

        // Toggle the switch to "On"
        await tester.tap(switchTileFinder);
        await tester.pumpAndSettle(); // Wait for the state to update
        await Future.delayed(const Duration(seconds: 1));
      }
      await tapBackButton(tester);

      //------------------------------------------------------------------------
      // Cash Flow
      {
        await tapOnText(tester, 'Cashflow');
        await Future.delayed(const Duration(seconds: 1));

        await tapOnText(tester, 'NetWorth');
        await Future.delayed(const Duration(seconds: 1));

        await tapOnText(tester, 'Incomes');
        await Future.delayed(const Duration(seconds: 1));

        await tapOnText(tester, 'Expenses');
        await Future.delayed(const Duration(seconds: 1));
      }

      //------------------------------------------------------------------------
      // Accounts
      {
        await tapOnText(tester, 'Accounts');

        // Accounts - Add new
        await tapOnKey(tester, Constants.keyAddNewAccount);

        // Accounts - Edit
        await tapOnKey(tester, Constants.keyEditSelectedItems);
        await tapOnText(tester, 'Cancel');

        // Delete selected item
        await tapOnKey(tester, Constants.keyDeleteSelectedItems);
        await tapOnText(tester, 'Delete');

        await tapOnKey(tester, Constants.keyInfoPanelExpando);
        await tapOnTextFromParentType(tester, InfoPanelHeader, 'Details');
        await tapOnTextFromParentType(tester, InfoPanelHeader, 'Chart');
        await tapOnTextFromParentType(tester, InfoPanelHeader, 'Transactions');
      }

      // Categories
      await tapOnText(tester, 'Categories');

      // Payees
      await tapOnText(tester, 'Payees');

      // Aliases
      await tapOnText(tester, 'Aliases');

      // // Transactions
      await tapOnText(tester, 'Transactions');

      // trigger sort by Date
      await tapOnText(tester, 'Date');

      // trigger sort by  Account
      await tapOnText(tester, 'Account');

      // trigger sort by  Account
      await tapOnText(tester, 'Payee/Transfer');

      // trigger sort by  Category
      await tapOnText(tester, 'Category');

      // trigger sort by  Status
      await tapOnText(tester, 'Status');

      // trigger sort by  Currency
      await tapOnText(tester, 'Currency');

      // trigger sort by  Amount
      await tapOnText(tester, 'Amount');

      // trigger sort by  Amount(USD)
      await tapOnText(tester, 'Amount(USD)');

      // trigger sort by  Balance(USD)
      await tapOnText(tester, 'Balance(USD)');

      // input a filter text that will return no match
      await filterBy(tester, 'some text that will not return any match');

      // Not expecting to fnd any match, look for and tap the "reset the filters" button
      await tapOnText(tester, 'Clear Filters');

      await filterBy(tester, '12');

      // Transfers
      await tapOnText(tester, 'Transfers');
      await tester.pumpAndSettle();

      // Investments
      await tapOnText(tester, 'Investments');

      // Stocks
      await tapOnText(tester, 'Stocks');

      // Rentals
      await tapOnText(tester, 'Rentals');

      // Pending Changes
      {
        await tapOnKey(tester, Constants.keyPendingChanges);

        await tapOnTextFromParentType(tester, Wrap, 'Aliases');
        await tapOnTextFromParentType(tester, Wrap, 'Categories');
        await tapOnTextFromParentType(tester, Wrap, 'Currencies');
        await tapOnTextFromParentType(tester, Wrap, 'LoanPayments');
        await tapOnTextFromParentType(tester, Wrap, 'Payees');
        await tapOnTextFromParentType(tester, Wrap, 'Transactions');
        await tapOnTextFromParentType(tester, Wrap, 'Splits');
        await tapOnTextFromParentType(tester, Wrap, 'Accounts');

        await tapOnText(tester, 'None modified');

        await tapOnText(tester, '1 deleted');

        // close the panel
        await tapOnText(tester, 'Close');
      }
    });
  });
}

Future<void> tapOnTextFromParentType(final WidgetTester tester, final Type type, final String textToFind) async {
  Finder firstMatchingElement = find.descendant(
    of: find.byType(type),
    matching: find.text(textToFind),
  );
  expect(
    firstMatchingElement,
    findsOneWidget,
    reason: 'tapOnTextFromParentType "$textToFind"',
  );

  firstMatchingElement = firstMatchingElement.first;

  expect(firstMatchingElement, findsOneWidget);
  await tester.tap(firstMatchingElement, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> tapBackButton(WidgetTester tester) async {
  final backButton = find.byTooltip('Back');
  await tester.tap(backButton);
  await tester.pumpAndSettle();
}

Future<void> filterBy(WidgetTester tester, final String textToFilterBy) async {
  final filterInput = find.byType(TextField).first;
  await tester.enterText(filterInput, textToFilterBy);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle(Durations.long4);
}

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