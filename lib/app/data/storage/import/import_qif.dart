import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/app/data/storage/import/import_data.dart';

///
/// schema https://www.w3.org/2000/10/swap/pim/qif-doc/QIF-doc.htm
///
void importQIF(
  final BuildContext context,
  final String filePath,
) {
  final File file = File(filePath);

  file.readAsLines().then((final List<String> lines) {
    final ImportData importData = loadQIF(lines);
    importData.fileType = 'QIF';
    showAndConfirmTransactionToImport(context, importData);
  }).catchError((final dynamic e) {
    debugLog('Error reading file: $e');
    SnackBarService.displayError(message: e.toString(), autoDismiss: false);
  });
}

ImportData loadQIF(final List<String> lines) {
  ImportData importData = ImportData();

  ImporEntry currentEntry = ImporEntry.blank();

  for (final String line in lines) {
    if (line == '^') {
      // Indicates the end of a transaction
      // add this entry
      importData.entries.add(currentEntry);
      // started new transaction object
      currentEntry = ImporEntry.blank();
      continue;
    }
    if (line.length >= 2) {
      String fieldLetter = line[0];
      String fieldData = line.substring(1);
      switch (fieldLetter) {
        case '!':
          switch (fieldData) {
            case 'Type:Invst':
              importData.accountType = AccountType.investment;
          }

        case 'D':
          // In some cases the QIF will
          // have the date in the following format 01/30'2000
          // so before processing the date we replace the "'" with "/"
          String dateAsString = getNormalizedValue(fieldData);
          dateAsString = dateAsString.replaceAll("'", '/');
          currentEntry.date = DateFormat('MM/dd/yyyy').parse(dateAsString);

        case 'T':
        case 'U':
          // Amount
          currentEntry.amount = parseUSDAmount(fieldData) ?? 0.00;

        case 'M':
          // Memo
          currentEntry.name = getNormalizedValue(fieldData);

        case 'N':
          // Stock Action
          currentEntry.stockAction = getNormalizedValue(fieldData);

        case 'Q':
          // Quantity - We use Amount parser because quanity can have fraction
          currentEntry.stockQuantity = parseUSDAmount(fieldData) ?? 0.0;

        case 'Y':
          // Security
          currentEntry.stockSymbol = getNormalizedValue(fieldData);

        case 'P':
        case 'I':
          currentEntry.stockPrice = parseUSDAmount(fieldData) ?? 0.00;
      }
    }
  }

  return importData;
}
