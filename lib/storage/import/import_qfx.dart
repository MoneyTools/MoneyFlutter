import 'dart:convert';
import 'dart:io';

import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/snack_bar.dart';

Future<bool> importQFX(
  final String filePath,
  final Data data,
) async {
  final File file = File(filePath);

  final String text = file.readAsStringSync();
  final String ofx = getStringDelimitedStartEndTokens(text, '<OFX>', '</OFX>');

  final OfxBankInfo bankInfo = OfxBankInfo.fromOfx(ofx);

  final accountType = getAccountTypeFromText(bankInfo.accountType);

  Account? account = data.accounts.findByIdAndType(bankInfo.accountId, accountType);

  if (account == null && accountType == AccountType.savings) {
    // Alternatively to use the checking account for a match
    account = data.accounts.findByIdAndType(bankInfo.accountId, AccountType.checking);
  }

  if (account == null) {
    SnackBarService.showSnackBar(
        autoDismiss: false,
        message: 'QFX Import - No matching "${bankInfo.accountType}" accounts with ID "${bankInfo.accountId}"');
    return false;
  }

  final List<QFXTransaction> list = getTransactionFromOFX(ofx);

  // attempt to find or add new transactions
  for (final QFXTransaction item in list) {
    // when there's no 'name' then fallback to 'memo'
    final payeeText = item.name.isEmpty ? item.memo : item.name;

    // skip if it already exist
    final Transaction? transactionFound = Data().transactions.findExistingTransaction(
          dateTime: item.date,
          payeeAsText: payeeText,
          memo: item.memo,
          amount: item.amount,
        );

    if (transactionFound == null) {
      final payeeIdMatchingPayeeText =
          Data().aliases.getPayeeIdFromTextMatchingOrAdd(payeeText, fireNotification: false);

      final Transaction t = Transaction(status: TransactionStatus.electronic)
        ..id.value = -1
        ..accountId.value = account.id.value
        ..dateTime.value = item.date
        ..number.value = item.number
        ..amount.value.amount = item.amount
        ..fitid.value = item.fitid
        ..memo.value = item.memo
        ..originalPayee.value = item.name
        ..payee.value = payeeIdMatchingPayeeText;

      // TODO if investment transaction
      // ..categoryId.value = getInvestmentCategoryFromOfxType(item)

      Data().transactions.appendNewMoneyObject(t);
    }
  }
  return true;
}

class OfxBankInfo {
  String id = '';
  String accountId = '';
  String accountType = '';

  static OfxBankInfo fromOfx(final String ofx) {
    // start with this
    // <BANKACCTFROM><BANKID>123456<ACCTID>00001 99-55555<ACCTTYPE>SAVINGS</BANKACCTFROM>
    // final String bankInfoText = getStringContentBetweenTwoTokens(
    //   ofx,
    //   '<BANKACCTFROM>',
    //   '</BANKACCTFROM>',
    // );

    // Now we should have just this
    // <BANKID>123456<ACCTID>00001 99-55555<ACCTTYPE>SAVINGS
    final OfxBankInfo bankInfo = OfxBankInfo();
    bankInfo.id = findAndGetValueOf(ofx, '<BANKID>', bankInfo.id);
    bankInfo.accountId = findAndGetValueOf(ofx, '<ACCTID>', bankInfo.accountId);
    bankInfo.accountType = findAndGetValueOf(ofx, '<ACCTTYPE>', bankInfo.accountType);
    return bankInfo;
  }
}

int getInvestmentCategoryFromOfxType(final QFXTransaction ofxTransaction) {
  int categoryId = -1;
  switch (ofxTransaction.type) {
    case 'CREDIT':
      categoryId = Data().categories.investmentCredit.id.value;
      break;
    case 'DEBIT':
      categoryId = Data().categories.investmentDebit.id.value;
      break;
    case 'INT':
      categoryId = Data().categories.investmentInterest.id.value;
      break;
    case 'DIV':
      categoryId = Data().categories.investmentDividends.id.value;
      break;
    case 'FEE':
    case 'SRVCHG': // service charge
      categoryId = Data().categories.investmentFees.id.value;
      break;
    case 'DEP': // deposit
    case 'ATM': // automatic teller machine
    case 'POS': // Point of sale
    case 'PAYMENT': // Electronic payment
    case 'CASH': // Cash withdrawal
    case 'DIRECTDEP': // Direct deposit
    case 'DIRECTDEBIT': // Direct debit;
    case 'REPEATPMT': // Repeating payment
    case 'CHECK': // check
    case 'OTHER':
      if (ofxTransaction.amount > 0) {
        categoryId = Data().categories.investmentCredit.id.value;
      } else {
        categoryId = Data().categories.investmentDebit.id.value;
      }
      break;
    case 'XFER':
      categoryId = Data().categories.investmentTransfer.id.value;
      break;
  }
  return categoryId;
}

List<QFXTransaction> getTransactionFromOFX(final String rawOfx) {
  if (rawOfx.isNotEmpty) {
    // Remove all LN/CR
    String ofx = getNormalizedValue(rawOfx);

    String bankTransactionLit = getStringContentBetweenTwoTokens(
      ofx,
      '<BANKTRANLIST>',
      '</BANKTRANLIST>',
    );

    bankTransactionLit = bankTransactionLit.replaceAll('</STMTTRN>', '</STMTTRN>\n');
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
  late String number;

  QFXTransaction({
    required this.type,
    required this.date,
    required this.amount,
    required this.name,
    required this.fitid,
    this.memo = '',
    this.number = '',
  });
}

List<QFXTransaction> parseQFXTransactions(final List<String> lines) {
  final List<QFXTransaction> transactions = <QFXTransaction>[];

  for (String line in lines) {
    line = getNormalizedValue(line);

    final String rawTransactionText = getStringContentBetweenTwoTokens(
      line,
      '<STMTTRN>',
      '</STMTTRN>',
    );

    if (rawTransactionText.isNotEmpty) {
      final QFXTransaction currentTransaction = QFXTransaction(
        type: findAndGetValueOf(rawTransactionText, '<TRNTYPE>', ''),
        date: parseQfxDataFormat(findAndGetValueOf(rawTransactionText, '<DTPOSTED>', '')) ?? DateTime.now(),
        amount: double.parse(findAndGetValueOf(rawTransactionText, '<TRNAMT>', '0.00')),
        name: findAndGetValueOf(rawTransactionText, '<NAME>', ''),
        fitid: findAndGetValueOf(rawTransactionText, '<FITID>', ''),
        memo: findAndGetValueOf(rawTransactionText, '<MEMO>', ''),
        number: findAndGetValueOf(rawTransactionText, '<CHECKNUM>', ''),
      );
      transactions.add(currentTransaction);
    }
  }

  return transactions;
}

String findAndGetValueOf(final String line, final String tokenTextToFind, final String valueIfNotFound) {
  int position = line.indexOf(tokenTextToFind);
  if (position != -1) {
    String tokenStartingLine = line.substring(position);
    return getValuePortion(tokenStartingLine);
  }
  return valueIfNotFound;
}

String getValuePortion(final String line) {
  int startIndexOfValue = line.indexOf('>') + 1;
  String lineContent = line.substring(startIndexOfValue);

// Find the end of the value
  int end = lineContent.indexOf('<');
  if (end == -1) {
    end = lineContent.indexOf('\n');
  }
  if (end != -1) {
    lineContent = lineContent.substring(0, end);
  }
  return getNormalizedValue(lineContent);
}
