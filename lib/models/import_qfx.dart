import 'dart:convert';
import 'dart:io';

import 'package:money/helpers.dart';

void importQFX(final String filePath) {
  final File file = File(filePath);

  final String text = file.readAsStringSync();
  final String ofx = getStringBetweenTwoTokens(text, '<OFX>', '</OFX>');
  final List<QFXTransaction> list = getTransactionFromOFX(ofx);
  for (final QFXTransaction item in list) {
    debugLog(item.toString());
  }
}

List<QFXTransaction> getTransactionFromOFX(final String ofx) {
  if (ofx.isNotEmpty) {
    final String bankTransactionLit = getStringContentBetweenTwoTokens(
      ofx,
      '<BANKTRANLIST>',
      '</BANKTRANLIST>',
    );

    // debugLog(bankTransactionLit);

    final List<String> lines = LineSplitter.split(bankTransactionLit).toList();
    final List<QFXTransaction> qfxTransactions = parseQFXTransactions(lines);
    return qfxTransactions;
  }

  return <QFXTransaction>[];
}

class QFXTransaction {
  late String type;
  late DateTime date;
  late double amount;
  late String name;

  QFXTransaction({
    required this.type,
    required this.date,
    required this.amount,
    required this.name,
  });

  @override
  String toString() {
    return '"$type", "$date", "$amount" "$name"';
  }
}

List<QFXTransaction> parseQFXTransactions(final List<String> lines) {
  final List<QFXTransaction> transactions = <QFXTransaction>[];
  QFXTransaction? currentTransaction;

  for (String line in lines) {
    line = line.trim();

    if (line.startsWith('<STMTTRN>')) {
      currentTransaction = QFXTransaction(type: '', date: DateTime.now(), amount: 0.0, name: '');
    } else if (line.startsWith('</STMTTRN>')) {
      if (currentTransaction != null) {
        transactions.add(currentTransaction);
      }
    } else {
      if (currentTransaction != null) {
        if (line.startsWith('<TRNTYPE>')) {
          currentTransaction.type = getTokenValue(line);
        } else if (line.startsWith('<DTPOSTED>')) {
          final String dateString = getTokenValue(line);
          currentTransaction.date = DateTime.parse(dateString.substring(0, 8));
        } else if (line.startsWith('<TRNAMT>')) {
          final String amountString = getTokenValue(line);
          currentTransaction.amount = double.parse(amountString);
        } else if (line.startsWith('<NAME>')) {
          currentTransaction.name = getTokenValue(line);
        }
      }
    }
  }

  return transactions;
}

String getTokenValue(final String line) {
  String lineContent = line.substring(line.indexOf('>') + 1);

  int end = lineContent.lastIndexOf('<');
  if (end == -1) {
    end = lineContent.lastIndexOf('\n');
  }
  if (end != -1) {
    lineContent = lineContent.substring(0, end);
  }
  return lineContent;
}
