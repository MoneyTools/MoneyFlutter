import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:money/app/core/widgets/info_panel/info_panel_header.dart';
import 'package:money/app/core/widgets/widgets.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

void main() {
  group(
    'App Test',
    () {
      testWidgets(
        'Full app test',
        (WidgetTester tester) async {
          // Use an empty SharedPreferences to get the same results each time
          SharedPreferences.setMockInitialValues(<String, Object>{});

          app.main();
          await tester.pumpAndSettle();

          //*************************************************************************
          await switchToSmall(tester);
          await stepWelcomeSettingAndTheme(tester);

          //*************************************************************************
          await switchToMedium(tester);
          await stepImport(tester);

          //*************************************************************************
          await switchToLarge(tester);
          await stepDemoDataViews(tester);

          //*************************************************************************
          await switchToSmall(tester);
          await stepDemoDataViewInSmallScreen(tester);
        },
      );
    },
  );
}

Future<void> stepWelcomeSettingAndTheme(WidgetTester tester) async {
  //------------------------------------------------------------------------
  // Welcome screen - Policy
  await testWelcomeScreen(tester);

  //------------------------------------------------------------------------
  // Themes
  await testTheme(tester);

  //------------------------------------------------------------------------
  // The Settings dialog
  await testThemeColors(tester);
}

Future<void> stepDemoDataViewInSmallScreen(WidgetTester tester) async {
  await tapOnKeyString(tester, 'key_menu_cashflow');
  await tapOnKeyString(tester, 'key_menu_accounts');
  await testAccountEdit(tester);
}

Future<void> stepDemoDataViews(WidgetTester tester) async {
  //------------------------------------------------------------------------
  // Open a Demo Data
  await tapOnText(tester, 'Use Demo Data');

  //------------------------------------------------------------------------
  // Show the Settings dialog in Larger screen size
  await testSettingsFontsAndRental(tester);

  //------------------------------------------------------------------------
  // Cash Flow
  await testCashFlow(tester);

  //------------------------------------------------------------------------
  // Accounts
  await testAccounts(tester);

  //------------------------------------------------------------------------
  // Categories
  await testCategories(tester);

  //------------------------------------------------------------------------
  // Payees
  await testPayees(tester);

  //------------------------------------------------------------------------
  // Aliases
  await testAliases(tester);

  //------------------------------------------------------------------------
  // Transactions
  await testTransactions(tester);

  //------------------------------------------------------------------------
  // Transfers
  await tapOnText(tester, 'Transfers');
  await infoTabs(tester);

  //------------------------------------------------------------------------
  // Investments
  await tapOnText(tester, 'Investments');
  await tapOnTextFromParentType(tester, ListView, 'Fidelity');
  await infoTabs(tester);

  //------------------------------------------------------------------------
  // Stocks
  await testStocks(tester);

  //------------------------------------------------------------------------
  // Rentals
  await tapOnText(tester, 'Rentals');
  await tapOnTextFromParentType(tester, ListView, 'AirBnB');
  await infoTabs(tester);
  // Go back to Chart where there's a PNL panel
  // we want to test the copy PnL data to clipboard
  await tapOnTextFromParentType(tester, InfoPanelHeader, 'Chart');
  await tapOnKeyString(tester, 'key_card_copy_to_clipboard');

  //------------------------------------------------------------------------
  // Pending Changes
  await testPendingChanges(tester);
}

Future<void> stepImport(WidgetTester tester) async {
  // Import Wizard
  await tapOnKeyString(tester, 'key_menu_button');
  await tapOnText(tester, 'Add transactions...');
  await tester.myPump();

  await tapOnText(tester, 'Manual bulk text input');
  await tester.myPump();

  // Drop down
  await tapOnKeyString(tester, 'key_dropdown');
  await tapOnText(tester, 'New Bank Account');
  await tapOnText(tester, 'Close');

  await tapOnKeyString(tester, 'key_import_tab_free_style');

  final textFieldInput = find.byKey(const Key('key_input_text_field_value')).first;
  await inputTextToElement(
    tester,
    textFieldInput,
    '2001-12-25;Hawaii;123.45\n2002-12-25;Bahamas;-123.45\n2003-01-01;Ibiza;(77.99)',
  );

  await tapOnKeyString(tester, 'key_import_tab_three_columns');
  await tapOnKeyString(tester, 'key_import_tab_free_style');

  // Close ImportDialog
  await tapOnText(tester, 'Cancel');

  //------------------------------------------------------------------------
  // Close the file
  await tapOnKeyString(tester, 'key_menu_button');
  await tapOnText(tester, 'Close file');
}

Future<void> testThemeColors(WidgetTester tester) async {
  // Change Colors, Purple is the default, and we use "Teal" as the last color.
  {
    for (final String themeColorName in ['Blue', 'Green', 'Yellow', 'Orange', 'Pink', 'Teal']) {
      await tapOnKey(tester, Constants.keySettingsButton);
      await tapOnKeyString(tester, 'key_theme_$themeColorName');
    }
  }
}

Future<void> testSettingsFontsAndRental(WidgetTester tester) async {
  await tapOnKey(tester, Constants.keySettingsButton);
  // Test Font Scaling
  {
    await tapOnKey(tester, Constants.keyZoomIncrease);
    await tapOnKey(tester, Constants.keyZoomIncrease);
    await tapOnKey(tester, Constants.keyZoomNormal);
    await tapOnKey(tester, Constants.keyZoomDecrease);
  }

  await tapOnKeyString(tester, 'key_settings');

  // Turn on Rentals
  {
    // Find the SwitchListTile using the text label provided in the Semantics
    final Finder switchTileFinder = find.byWidgetPredicate(
      (Widget widget) => widget is SwitchListTile && widget.title is Text && (widget.title as Text).data == 'Rental',
    );

    // Verify initial state is OFF (false)
    SwitchListTile switchTile = tester.widget(switchTileFinder);
    expect(switchTile.value, isFalse);

    // Toggle the switch to "On"
    await tester.tap(switchTileFinder);
    await tester.myPump(); // Wait for the state to update
    await Future.delayed(const Duration(seconds: 1));
  }
  await tapBackButton(tester);
}

Future<void> testTheme(WidgetTester tester) async {
  // Turn Dark-Mode on
  await tapOnKeyString(tester, 'key_toggle_mode');
}

Future<void> testWelcomeScreen(WidgetTester tester) async {
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
  await tester.myPump();
}

Future<void> testCashFlow(WidgetTester tester) async {
  await tapOnText(tester, 'Cashflow');

  await tapOnText(tester, 'NetWorth');

  await tapOnText(tester, 'Incomes');

  await tapOnText(tester, 'Expenses');
}

Future<void> testAliases(WidgetTester tester) async {
  await tapOnText(tester, 'Aliases');
  await tapOnTextFromParentType(tester, ListView, 'ABC');
  await infoTabs(tester);
}

Future<void> testAccounts(WidgetTester tester) async {
  await tapOnKeyString(tester, 'key_menu_accounts');

  // Iterate over all found ToggleButtons and click on each child button
  await tapAllToggleButtons(tester, [
    'key_toggle_show_bank',
    'key_toggle_show_investment',
    'key_toggle_show_credit',
    'key_toggle_show_assets',
    'key_toggle_show_all',
  ]);

  await tapOnKey(tester, Constants.keyInfoPanelExpando);
  await infoTabs(tester);

  // Select one of the row
  await tapOnTextFromParentType(tester, ListView, 'Savings');
  await infoTabs(tester);

  // await tester.myPump();
  // toggle sorting
  await tapOnText(tester, 'Memo');

  await tapOnTextFromParentType(tester, ListView, 'Investment');
  await infoTabs(tester);
  await tapOnTextFromParentType(tester, ListView, 'Loan');
  await infoTabs(tester);

  // CopyToCLipboard from the Info Panel Header
  await tapOnKey(tester, Constants.keyCopyListToClipboardHeaderInfoPanel);

  // Accounts - Add new
  await tapOnKey(tester, Constants.keyAddNewItem);

  // Accounts - Edit
  await testAccountEdit(tester);

  // Back to Checking Account
  await tapOnTextFromParentType(tester, ListView, 'Checking');

  // CopyToCLipboard from the Main Header
  await tapOnKey(tester, Constants.keyCopyListToClipboardHeaderMain);

  // Select first element of the Info-Panel-Transaction-List
  await selectFirstItemOfInfoPanelTransactionLIst(tester);

  // Bring upt the Mutate Transaction Dialog
  await longPressFirstItemOfInfoPanelTransactionLIst(tester);

  await tapOnText(tester, 'Close');
}

Future<void> testAccountEdit(WidgetTester tester) async {
  await tapOnKey(tester, Constants.keyEditSelectedItems);

  // Drop down on Account Type
  await tapOnKeyString(tester, 'key_dropdown');
  await tapOnText(tester, 'Savings');

  await tapOnKey(tester, Constants.keyEditSelectedItems);
  await tapOnKeyString(tester, 'key_dropdown');
  await tapOnText(tester, 'Checking');

  // Apply Change and close the dialog
  await tapOnText(tester, 'Cancel');
}

Future<void> testCategories(WidgetTester tester) async {
  await tapOnText(tester, 'Categories');
  await tapOnFirstRowOfListView(tester);

  // Edit
  {
    await tapOnKey(tester, Constants.keyEditSelectedItems);

    // Drop down
    await tapOnKeyString(tester, 'key_dropdown');
    await tapOnText(tester, 'Close');
    // Close Edit box
    await tapOnText(tester, 'Cancel');
  }

  // Merge
  await tapOnKey(tester, Constants.keyMergeButton);

  // Drop down pretend to pick a category
  await tapOnKeyString(tester, 'key_dropdown');
  await tapOnText(tester, 'Close');

  await tapOnText(tester, 'Cancel');
  await infoTabs(tester);

  // Add New Item
  {
    await tapOnKey(tester, Constants.keyAddNewItem);
    await tapOnText(tester, 'Cancel');
  }
  // trigger sort by Level
  await tester.longPress(find.text('Level').first);
  await tapOnText(tester, 'Close');
}

Future<void> testPayees(WidgetTester tester) async {
  Data().payees.getPayeeIdFromName('NASA');

  await tapOnText(tester, 'Payees');
  await tapOnFirstRowOfListView(tester);
  await tapOnKey(tester, Constants.keyMergeButton);
  await tapOnText(tester, 'Comcast');
  await tapOnText(tester, 'Cancel');
  await infoTabs(tester);
}

Future<void> testStocks(WidgetTester tester) async {
  await tapOnText(tester, 'Stocks');
  await tapOnTextFromParentType(tester, ListView, 'AAPL');

  // Edit
  {
    await tapOnKey(tester, Constants.keyEditSelectedItems);

    // Drop down
    await tapOnKeyString(tester, 'key_dropdown');

    // Make a change
    await tapOnText(tester, 'private');

    // Apply will close the dialog
    await tapOnText(tester, 'Apply');
  }

  await infoTabs(tester);

  await tapOnTextFromParentType(tester, InfoPanelHeader, 'Chart');
  await tapOnText(tester, 'Set API Key');
  await tapOnText(tester, 'Cancel');
}

Future<void> testTransactions(WidgetTester tester) async {
  await tapOnText(tester, 'Transactions');

  // Toggle Multi-Selection on and off
  await tapOnKey(tester, Constants.keyMultiSelectionToggle);

  // Select All
  await tapOnKey(tester, Constants.keyCheckboxToggleSelectAll);

  // Edit
  await tapOnKey(tester, Constants.keyEditSelectedItems);
  await tapOnText(tester, 'Transfer');
  await tapOnText(tester, 'Cancel');

  // Unselect All
  await tapOnKey(tester, Constants.keyCheckboxToggleSelectAll);

  // out of multi-selection mode
  await tapOnKey(tester, Constants.keyMultiSelectionToggle);

  // Select one of the rows
  await tapOnTextFromParentType(tester, ListView, 'Bank Of America');

  // Single Transaction Edit
  {
    await tapOnKey(tester, Constants.keyEditSelectedItems);

    // Edit  the Date
    {
      await inputTextToElement(tester, find.byKey(Constants.keyDatePicker), '2021-01-01');
    }

    // Edit the Category of a single transaction
    {
      await inputTextToElement(tester, findByKeyString('key_pick_category'), 'Food');
    }
    // Edit  the Amount
    {
      final textFieldFinder = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == 'Amount',
      );
      await inputTextToElement(tester, textFieldFinder, '66.99');
    }
    await tapOnText(tester, 'Apply');
  }
  await infoTabs(tester);

  // Delete selected item
  await tapOnKey(tester, Constants.keyDeleteSelectedItems);
  await tapOnText(tester, 'Delete');

  // trigger sort by Date
  await tapOnText(tester, 'Date');
  await tapOnText(tester, 'Date'); // Descending

  // trigger sort by  Account
  await tapOnText(tester, 'Account');
  await tapOnText(tester, 'Account'); // Descending

  // trigger sort by  Account
  await tapOnText(tester, 'Payee/Transfer');
  await tapOnText(tester, 'Payee/Transfer'); // Descending

  // trigger sort by  Category
  await tapOnText(tester, 'Category');
  await tapOnText(tester, 'Category'); // Descending

  // trigger sort by  Status
  await tapOnText(tester, 'Status');
  await tapOnText(tester, 'Status'); // Descending

  // trigger sort by  Currency
  await tapOnText(tester, 'Currency');
  await tapOnText(tester, 'Currency'); // Descending

  // trigger sort by  Amount
  await tapOnText(tester, 'Amount');
  await tapOnText(tester, 'Amount'); // Descending

  // trigger sort by  Amount(USD)
  await tapOnText(tester, 'Amount(USD)');
  await tapOnText(tester, 'Amount(USD)'); // Descending

  // trigger sort by  Balance(USD)
  await tapOnText(tester, 'Balance(USD)');
  await tapOnText(tester, 'Balance(USD)'); // Descending

  // input a filter text that will return no match
  await inputText(tester, 'some text that will not return any match');

  // Not expecting to fnd any match, look for and tap the "reset the filters" button
  await tapOnText(tester, 'Clear Filters');

  await inputText(tester, '12');

  // Flitter by Category "Split"
  {
    await tester.longPress(find.text('Category').first);
    await tapOnKeyString(tester, 'key_select_unselect_all');
    await inputTextToElement(tester, findByKeyString('key_picker_input_filter'), 'Split');
    await tapOnKeyString(tester, 'key_select_unselect_all');
    await tapOnText(tester, 'Apply');
  }
  // By selecting the first Transaction in the list that is a s 'split' we end up showing on the info-panel the sub-transactions of that Split
  await tapOnFirstRowOfListView(tester);
}

Future<void> infoTabs(WidgetTester tester) async {
  await tapOnTextFromParentType(tester, InfoPanelHeader, 'Details');
  await tapOnTextFromParentType(tester, InfoPanelHeader, 'Chart');
  await tapOnTextFromParentType(tester, InfoPanelHeader, 'Transactions');
}

Future<void> testPendingChanges(WidgetTester tester) async {
  await tapOnKey(tester, Constants.keyPendingChanges);

  await tapOnTextFromParentType(tester, Wrap, 'Aliases');
  await tapOnTextFromParentType(tester, Wrap, 'Categories');
  await tapOnTextFromParentType(tester, Wrap, 'Currencies');
  await tapOnTextFromParentType(tester, Wrap, 'LoanPayments');
  await tapOnTextFromParentType(tester, Wrap, 'Payees');
  await tapOnTextFromParentType(tester, Wrap, 'Transactions');
  await tapOnTextFromParentType(tester, Wrap, 'Splits');
  await tapOnTextFromParentType(tester, Wrap, 'Stock Splits');
  await tapOnTextFromParentType(tester, Wrap, 'Accounts');

  await tapOnText(tester, '1 modified');

  await tapOnText(tester, '1 deleted');

  // close the panel
  await tapOnText(tester, 'Save to CSV');

  // Save and Load to SQL
  await Data().saveToSql(
    filePath: './test_output_sqlite.db',
    onSaveCompleted: (_, __) {
      // save completed
    },
  );

  await Data().loadFromSql(
    filePath: './test_output_sqlite.db',
    fileBytes: Uint8List(0),
  );
}

Future<void> tapAllToggleButtons(final WidgetTester tester, final List<String> keys) async {
  for (final key in keys) {
    await tapOnKeyString(tester, key);
  }
}
