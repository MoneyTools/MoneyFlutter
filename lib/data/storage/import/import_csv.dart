import 'dart:io'; // For File operations
import 'package:flutter/material.dart'; // For BuildContext and other UI elements
import 'package:money/data/storage/import/import_data.dart';
import 'package:money/core/widgets/csv_column_mapper_dialog.dart'; // Import the dialog
// We might need a logging utility, for now, print will do for errors/info.

Future<void> importCSV(BuildContext context, String filePath) async {
  print('importCSV called with filePath: $filePath');
  try {
    final file = File(filePath);
    final lines = await file.readAsLines();

    if (lines.isEmpty) {
      print('CSV file is empty.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV file is empty.')),
      );
      return;
    }

    // Basic CSV parsing: extract headers and data rows
    // This assumes the first line is headers.
    // More robust CSV parsing might be needed for complex cases (e.g., quotes, escaped commas).
    final headers = lines.first.split(',');
    final dataRows = lines.skip(1).map((line) => line.split(',')).toList();

    // For the dialog preview, take at most 5 rows.
    final previewRows = dataRows.length > 5 ? dataRows.sublist(0, 5) : dataRows;

    // Show the column mapper dialog
    // Ensure that the context passed to showCsvColumnMapperDialog is valid and mounted.
    if (!context.mounted) {
      print("Context is not mounted, cannot show dialog.");
      return;
    }

    final Map<String, String>? columnMapping = await showCsvColumnMapperDialog(
      context: context,
      headers: headers,
      dataRows: previewRows, // Pass only a few rows for preview
    );

    if (columnMapping != null) {
      // User confirmed the mapping
      print('Column mapping received: $columnMapping');
      final importData = loadCSV(headers, dataRows, columnMapping);

      if (importData.entries.isNotEmpty) {
        // Call the existing function to show preview and confirm import
        showAndConfirmTransactionToImport(context, importData);
      } else {
        // If no entries were parsed (e.g., all rows had errors, or file was empty after headers)
        print('No entries to import after processing CSV.');
        if (context.mounted) { // Check context before showing SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No valid entries found in CSV to import.')),
          );
        }
      }
    } else {
      // User cancelled the dialog
      print('CSV import cancelled by user.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV import cancelled.')),
      );
    }
  } catch (e) {
    print('Error importing CSV: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing CSV: $e')),
      );
    }
  }
}

ImportData loadCSV(
  List<String> headers,
  List<List<String>> dataRows,
  Map<String, String> columnMapping,
) {
  final importData = ImportData();
  importData.fileType = 'CSV';

  // Get column indices from mapping
  final String dateColumnName = columnMapping['date']!;
  final String descriptionColumnName = columnMapping['description']!;
  final String amountColumnName = columnMapping['amount']!;

  final int dateIndex = headers.indexOf(dateColumnName);
  final int descriptionIndex = headers.indexOf(descriptionColumnName);
  final int amountIndex = headers.indexOf(amountColumnName);

  if (dateIndex == -1 || descriptionIndex == -1 || amountIndex == -1) {
    print('Error: One or more mapped column names not found in CSV headers.');
    // Potentially throw an error or return an empty ImportData with an error message.
    return importData; // Return empty data for now
  }

  for (int i = 0; i < dataRows.length; i++) {
    final row = dataRows[i];

    // Check if row has enough columns based on the maximum index we'll access
    final maxIndex = [dateIndex, descriptionIndex, amountIndex].reduce((a, b) => a > b ? a : b);
    if (row.length <= maxIndex) {
      print('Skipping row ${i + 1}: Not enough columns for mapped fields. Row: "${row.join(",")}"');
      continue;
    }

    DateTime? date;
    try {
      // Assuming YYYY-MM-DD format. Consider making date format also configurable.
      date = DateTime.parse(row[dateIndex].trim());
    } catch (e) {
      print('Skipping row ${i + 1}: Invalid date format for "${row[dateIndex].trim()}". Error: $e. Row: "${row.join(",")}"');
      continue;
    }

    final description = row[descriptionIndex].trim();
    if (description.isEmpty) {
      print('Skipping row ${i + 1}: Description is empty. Row: "${row.join(",")}"');
      continue;
    }

    double? amount;
    try {
      amount = double.tryParse(row[amountIndex].trim());
      if (amount == null) {
        print('Skipping row ${i + 1}: Amount "${row[amountIndex].trim()}" is not a valid number. Row: "${row.join(",")}"');
        continue;
      }
    } catch (e) {
      print('Skipping row ${i + 1}: Error parsing amount for "${row[amountIndex].trim()}". Error: $e. Row: "${row.join(",")}"');
      continue;
    }

    importData.entries.add(
      ImportEntry(
        date: date,
        name: description,
        amount: amount,
        type: 'CSVImport',
        fitid: 'csv_row_${i + 1}_${date.millisecondsSinceEpoch}',
        memo: '',
        number: '',
        stockAction: '',
        stockSymbol: '',
        stockQuantity: 0.0,
        stockPrice: 0.0,
        stockCommission: 0.0,
      ),
    );
  }
  print('loadCSV processed ${dataRows.length} data rows, successfully created ${importData.entries.length} entries.');
  return importData;
}
