import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/core/widgets/csv_column_mapper_dialog.dart';

void main() {
  // Sample data for testing
  const List<String> sampleHeaders = ['Date', 'Description', 'Amount', 'Category'];
  const List<List<String>> sampleDataRows = [ // Make this const
    ['2023-01-01', 'Groceries', '50.00', 'Food'], // Inner lists also become effectively const
    ['2023-01-02', 'Gas', '30.00', 'Transport'],
    ['2023-01-03', 'Rent', '500.00', 'Housing'],
  ];

  Future<void> pumpDialog(WidgetTester tester, {
    List<String> headers = sampleHeaders,
    List<List<String>> dataRows = sampleDataRows,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                child: const Text('Show Dialog'),
                onPressed: () {
                  showCsvColumnMapperDialog(
                    context: context,
                    headers: headers,
                    dataRows: dataRows,
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle(); // Wait for dialog to appear and animations to finish
  }

  testWidgets('Dialog displays correctly with CSV data and headers', (WidgetTester tester) async {
    await pumpDialog(tester);

    // Verify dialog title
    expect(find.text('Map CSV Columns'), findsOneWidget);

    // Verify presence of mapping dropdowns (identified by their labels for now)
    expect(find.text('Date Column:'), findsOneWidget);
    expect(find.text('Description Column:'), findsOneWidget);
    expect(find.text('Amount Column:'), findsOneWidget);

    // Verify presence of preview table title
    expect(find.text('CSV Data Preview (First 5 rows):'), findsOneWidget);

    // Verify presence of action buttons
    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Confirm'), findsOneWidget);
  });

  testWidgets('Dropdown menus are populated with header names', (WidgetTester tester) async {
    await pumpDialog(tester);

    final dateDropdownFinder = find.byType(DropdownButtonFormField<String>).at(0);
    final descriptionDropdownFinder = find.byType(DropdownButtonFormField<String>).at(1);
    final amountDropdownFinder = find.byType(DropdownButtonFormField<String>).at(2);

    // Helper function to test a single dropdown
    Future<void> testDropdown(Finder dropdownFinder, String initialHeaderToSelect) async {
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle(); // Wait for dropdown items to appear

      // Check if all headers are present as dropdown items
      for (final header in sampleHeaders) {
        // .last is important as items might appear in multiple open dropdowns if not careful
        expect(find.widgetWithText(DropdownMenuItem<String>, header).last, findsOneWidget);
      }
      // Close the dropdown by tapping one item
      await tester.tap(find.widgetWithText(DropdownMenuItem<String>, initialHeaderToSelect).last);
      await tester.pumpAndSettle();
    }

    // Test each dropdown
    await testDropdown(dateDropdownFinder, sampleHeaders.first);
    await testDropdown(descriptionDropdownFinder, sampleHeaders.first);
    await testDropdown(amountDropdownFinder, sampleHeaders.first);
    await tester.pumpAndSettle();
  });

  testWidgets('User can select columns for Date, Description, and Amount', (WidgetTester tester) async {
    await pumpDialog(tester);

    final dateDropdownFinder = find.byType(DropdownButtonFormField<String>).at(0);
    final descriptionDropdownFinder = find.byType(DropdownButtonFormField<String>).at(1);
    final amountDropdownFinder = find.byType(DropdownButtonFormField<String>).at(2);

    // Select 'Date' for Date Column
    await tester.tap(dateDropdownFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'Date').last);
    await tester.pumpAndSettle();
    expect(find.descendant(of: dateDropdownFinder, matching: find.text('Date')), findsOneWidget);

    // Select 'Description' for Description Column
    await tester.tap(descriptionDropdownFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'Description').last);
    await tester.pumpAndSettle();
    expect(find.descendant(of: descriptionDropdownFinder, matching: find.text('Description')), findsOneWidget);

    // Select 'Amount' for Amount Column
    await tester.tap(amountDropdownFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'Amount').last);
    await tester.pumpAndSettle();
    expect(find.descendant(of: amountDropdownFinder, matching: find.text('Amount')), findsOneWidget);
  });

  testWidgets('Confirm button shows SnackBar if not all fields are mapped', (WidgetTester tester) async {
    await pumpDialog(tester);

    final dateDropdownFinder = find.byType(DropdownButtonFormField<String>).at(0);

    // Tap Confirm button without selecting anything
    await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
    await tester.pumpAndSettle(); // Allow time for SnackBar to appear

    expect(find.text('Please map all fields (Date, Description, Amount).'), findsOneWidget);

    // Select only Date
    await tester.tap(dateDropdownFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'Date').last);
    await tester.pumpAndSettle();

    // Tap Confirm button again
    await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Please map all fields (Date, Description, Amount).'), findsOneWidget);
  });

  testWidgets('Confirm button returns mapping when all fields are mapped', (WidgetTester tester) async {
    dynamic result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                child: const Text('Show Dialog'),
                onPressed: () async {
                  result = await showCsvColumnMapperDialog(
                    context: context,
                    headers: sampleHeaders,
                    dataRows: sampleDataRows,
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    final dateDropdownFinder = find.byType(DropdownButtonFormField<String>).at(0);
    final descriptionDropdownFinder = find.byType(DropdownButtonFormField<String>).at(1);
    final amountDropdownFinder = find.byType(DropdownButtonFormField<String>).at(2);

    // Select 'Date' for Date Column
    await tester.tap(dateDropdownFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'Date').last);
    await tester.pumpAndSettle();

    // Select 'Description' for Description Column
    await tester.tap(descriptionDropdownFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'Description').last);
    await tester.pumpAndSettle();

    // Select 'Amount' for Amount Column
    await tester.tap(amountDropdownFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'Amount').last);
    await tester.pumpAndSettle();

    // Tap Confirm button
    await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
    await tester.pumpAndSettle(); // Allow dialog to close and result to be processed

    expect(result, isA<Map<String, String>>());
    expect(result['date'], 'Date');
    expect(result['description'], 'Description');
    expect(result['amount'], 'Amount');
  });

  testWidgets('Cancel button closes the dialog and returns null', (WidgetTester tester) async {
    dynamic result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                child: const Text('Show Dialog'),
                onPressed: () async {
                  result = await showCsvColumnMapperDialog(
                    context: context,
                    headers: sampleHeaders,
                    dataRows: sampleDataRows,
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Tap Cancel button
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle(); // Allow dialog to close

    expect(result, isNull);
  });

  testWidgets('Preview table displays CSV data correctly', (WidgetTester tester) async {
    await pumpDialog(tester);

    // Check for headers in the DataTable
    // Ensure header text is found within the context of the DataTable
    for (final header in sampleHeaders) {
      expect(find.descendant(of: find.byType(DataTable), matching: find.text(header)), findsOneWidget);
    }

    // Check for data cells in the DataTable
    // sampleDataRows has 3 rows, all should be displayed as preview can take up to 5
    for (int i = 0; i < sampleDataRows.length; i++) {
      for (int j = 0; j < sampleHeaders.length; j++) { // Iterate through headers to ensure all cells in a row are checked
        // Ensure cell text is found within the context of the DataTable
        expect(find.descendant(of: find.byType(DataTable), matching: find.text(sampleDataRows[i][j])), findsOneWidget);
      }
    }
  });

   testWidgets('Dialog shows error message when headers are empty', (WidgetTester tester) async {
    await pumpDialog(tester, headers: [], dataRows: []);

    expect(find.text('Error'), findsOneWidget);
    expect(find.text('CSV headers are missing or empty.'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'OK'), findsOneWidget);

    // Close the error dialog
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();

    expect(find.text('Error'), findsNothing);
  });
}

// Note: The test 'Confirm button becomes enabled when all fields are mapped'
// is implicitly covered by 'Confirm button returns mapping when all fields are mapped'.
// The dialog's current behavior is to show a SnackBar if fields are missing,
// rather than disabling the button. So, we test that the SnackBar *doesn't* appear
// when fields *are* mapped (which is what happens before successful pop).
// If the button were to be disabled, the test would be different, e.g.,
// expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Confirm')).enabled, isTrue);
// For now, the successful pop is the indicator.

// Also, the test 'User can select columns for Date, Description, and Amount'
// already verifies that the selected value is displayed in the dropdown.
// The actual state update is confirmed by the 'Confirm button returns mapping' test.

// The test 'Preview table displays the CSV data correctly' checks for the first 3 rows.
// The dialog itself limits preview to 5 rows. If sampleDataRows had more than 5,
// we'd need to adjust the test to only check for the first 5.
// Currently, sampleDataRows has 3, so all are checked.

// Added a test for the error dialog when headers are empty.
// This covers the `if (widget.headers.isEmpty)` block in the dialog.
