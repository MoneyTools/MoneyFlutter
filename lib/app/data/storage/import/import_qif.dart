import 'dart:io';

import 'package:intl/intl.dart';
import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/string_helper.dart';

void importQIF(final String filePath) {
  final File file = File(filePath);

  file.readAsLines().then((final List<String> lines) {
    final List<MyJson> transactions = loadQIF(lines);
    // Process transactions list
    for (final MyJson transaction in transactions) {
      // TODO
      debugLog(transaction.toString());
    }
  }).catchError((final dynamic e) {
    debugLog('Error reading file: $e');
  });
}

List<MyJson> loadQIF(final List<String> lines) {
  final List<MyJson> transactions = <MyJson>[];
  MyJson? currentTransaction;

  for (final String line in lines) {
    if (line.startsWith('^')) {
      // Indicates the end of a transaction
      if (currentTransaction != null) {
        // stash this
        transactions.add(currentTransaction);
        // started new transaction object
        currentTransaction = null;
      }
    } else if (line.startsWith('D')) {
      currentTransaction ??= <String, dynamic>{};
      // In some cases the QIF will
      // have the date in the following format 01/30'2000
      // so before processing the date we replace the "'" with "/"
      currentTransaction['date'] = DateFormat('MM/dd/yyyy').parse(getNormalizedValue(line.substring(1)));
    } else if (line.startsWith('T') || line.startsWith('U')) {
      // Amount
      currentTransaction ??= <String, dynamic>{};
      final NumberFormat format = NumberFormat.simpleCurrency();
      // Parsing the currency string into a double
      final String currencyRawText = line.substring(1);
      final num parsedCurrency = format.parse(currencyRawText);
      currentTransaction['amount'] = parsedCurrency;
    } else if (line.startsWith('P')) {
      // Amount
      currentTransaction ??= <String, dynamic>{};
      currentTransaction['payee'] = getNormalizedValue(line.substring(1));
    } else if (line.startsWith('M')) {
      // Amount
      currentTransaction ??= <String, dynamic>{};
      currentTransaction['memo'] = getNormalizedValue(line.substring(1));
    }
  }

  return transactions;
}
