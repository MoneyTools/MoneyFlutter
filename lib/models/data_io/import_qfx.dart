import 'dart:convert';
import 'dart:io';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_entities/accounts/account.dart';
import 'package:money/models/money_entities/accounts/accounts.dart';
import 'package:money/models/money_entities/aliases/aliases.dart';
import 'package:money/models/money_entities/categories/categories.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_entities/payees/payee.dart';
import 'package:money/models/money_entities/payees/payees.dart';
import 'package:money/models/money_entities/transactions/transaction.dart';
import 'package:money/models/money_entities/transactions/transactions.dart';

void importQFX(
  final String filePath,
  final Data data,
) {
  final File file = File(filePath);

  final String text = file.readAsStringSync();
  final String ofx = getStringDelimitedStartEndTokens(text, '<OFX>', '</OFX>');

  final OfxBankInfo bankInfo = OfxBankInfo.fromOfx(ofx);
  final Account? account = Accounts.findByIdAndType(
    bankInfo.accountId,
    Account.getTypeFromText(bankInfo.accountType),
  );

  if (account != null) {
    final List<QFXTransaction> list = getTransactionFromOFX(ofx);

    for (final QFXTransaction item in list) {
      debugLog(item.toString());

      // find by fuzzy match
      Payee? payee = Aliases.findByMatch(item.name);

      // ignore: prefer_conditional_assignment
      if (payee == null) {
        // if null find match or add
        payee = Payees.findOrAddPayee(item.name);
      }

      Transactions.add(Transaction(
        -1,
        '',
        accountId: account.id,
        dateTime: item.date,
        payeeId: payee.id,
        categoryId: getCategoryFromOfxType(item),
        amount: item.amount,
        balance: 0,
        fitid: item.fitid,
        memo: item.memo,
      ));
    }
  }
}

class OfxBankInfo {
  String id = '';
  String accountId = '';
  String accountType = '';

  static OfxBankInfo fromOfx(final String ofx) {
    final String bankInfoText = getStringContentBetweenTwoTokens(
      ofx,
      '<BANKACCTFROM>',
      '</BANKACCTFROM>',
    );

    final List<String> bankInfoLines = LineSplitter.split(bankInfoText).toList();
    final OfxBankInfo bankInfo = OfxBankInfo();

    for (final String line in bankInfoLines) {
      if (line.startsWith('<BANKID>')) {
        bankInfo.id = getTokenValue(line);
      }
      if (line.startsWith('<ACCTID>')) {
        bankInfo.accountId = getTokenValue(line);
      }
      if (line.startsWith('<ACCTTYPE>')) {
        bankInfo.accountType = getTokenValue(line);
      }
    }
    return bankInfo;
  }
}

int getCategoryFromOfxType(final QFXTransaction ofxTransaction) {
  int categoryId = -1;
  switch (ofxTransaction.type) {
    case "CREDIT":
      categoryId = Categories.investmentCredit.id;
      break;
    case "DEBIT":
      categoryId = Categories.investmentDebit.id;
      break;
    case "INT":
      categoryId = Categories.investmentInterest.id;
      break;
    case "DIV":
      categoryId = Categories.investmentDividends.id;
      break;
    case "FEE":
    case "SRVCHG": // service charge
      categoryId = Categories.investmentFees.id;
      break;
    case "DEP": // deposit
    case "ATM": // automatic teller machine
    case "POS": // Point of sale
    case "PAYMENT": // Electronic payment
    case "CASH": // Cash withdrawal
    case "DIRECTDEP": // Direct deposit
    case "DIRECTDEBIT": // Direct debit;
    case "REPEATPMT": // Repeating payment
    case "CHECK": // check
    case "OTHER":
      if (ofxTransaction.amount > 0) {
        categoryId = Categories.investmentCredit.id;
      } else {
        categoryId = Categories.investmentDebit.id;
      }
      break;
    case "XFER":
      categoryId = Categories.investmentTransfer.id;
      break;
  }
  return categoryId;
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
  late String fitid;
  late String memo;

  QFXTransaction({
    required this.type,
    required this.date,
    required this.amount,
    required this.name,
    required this.fitid,
    this.memo = '',
  });
}

List<QFXTransaction> parseQFXTransactions(final List<String> lines) {
  final List<QFXTransaction> transactions = <QFXTransaction>[];
  QFXTransaction? currentTransaction;

  for (String line in lines) {
    line = getNormalizedValue(line);

    if (line.startsWith('<STMTTRN>')) {
      currentTransaction = QFXTransaction(type: '', date: DateTime.now(), amount: 0.0, name: '', fitid: '');
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
        } else if (line.startsWith('<FITID>')) {
          currentTransaction.fitid = getTokenValue(line);
        } else if (line.startsWith('<MEMO>')) {
          currentTransaction.memo = getTokenValue(line);
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
  return getNormalizedValue(lineContent);
}
