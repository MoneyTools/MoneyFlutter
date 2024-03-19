import 'dart:convert';
import 'dart:io';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/widgets/snack_bar.dart';

void importQFX(
  final String filePath,
  final Data data,
) {
  final File file = File(filePath);

  final String text = file.readAsStringSync();
  final String ofx = getStringDelimitedStartEndTokens(text, '<OFX>', '</OFX>');

  final OfxBankInfo bankInfo = OfxBankInfo.fromOfx(ofx);
  final Account? account = data.accounts.findByIdAndType(
    bankInfo.accountId,
    getAccountTypeFromText(bankInfo.accountType),
  );

  if (account == null) {
    SnackBarService.showSnackBar(
        autoDismiss: false,
        message: 'QFX Import - No matching "${bankInfo.accountType}" accounts with ID "${bankInfo.accountId}"');
    return;
  }

  final List<QFXTransaction> list = getTransactionFromOFX(ofx);

  for (final QFXTransaction item in list) {
    // find by fuzzy match
    Payee? payee = Data().aliases.findByMatch(item.name);

    final Transaction t = Transaction()
      ..id.value = Data().transactions.getNextTransactionId()
      ..accountId.value = account.id.value
      ..dateTime.value = item.date
      ..payee.value = payee == null ? -1 : payee.id.value
      ..categoryId.value = getCategoryFromOfxType(item)
      ..amount.value = item.amount
      ..fitid.value = item.fitid
      ..memo.value = item.memo;

    Data().transactions.addEntry(moneyObject: t, isNewEntry: true);
  }
}

class OfxBankInfo {
  String id = '';
  String accountId = '';
  String accountType = '';

  static OfxBankInfo fromOfx(final String ofx) {
    // start with this
    // <BANKACCTFROM><BANKID>123456<ACCTID>00001 99-55555<ACCTTYPE>SAVINGS</BANKACCTFROM>
    final String bankInfoText = getStringContentBetweenTwoTokens(
      ofx,
      '<BANKACCTFROM>',
      '</BANKACCTFROM>',
    );

    // Now we should have just this
    // <BANKID>123456<ACCTID>00001 99-55555<ACCTTYPE>SAVINGS
    final OfxBankInfo bankInfo = OfxBankInfo();
    bankInfo.id = findAndGetValueOf(bankInfoText, '<BANKID>', bankInfo.id);
    bankInfo.accountId = findAndGetValueOf(bankInfoText, '<ACCTID>', bankInfo.accountId);
    bankInfo.accountType = findAndGetValueOf(bankInfoText, '<ACCTTYPE>', bankInfo.accountType);
    return bankInfo;
  }
}

int getCategoryFromOfxType(final QFXTransaction ofxTransaction) {
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
        date: DateTime.parse(findAndGetValueOf(rawTransactionText, '<DTPOSTED>', '').substring(0, 8)),
        amount: double.parse(findAndGetValueOf(rawTransactionText, '<TRNAMT>', '0.00')),
        name: findAndGetValueOf(rawTransactionText, '<NAME>', ''),
        fitid: findAndGetValueOf(rawTransactionText, '<FITID>', ''),
        memo: findAndGetValueOf(rawTransactionText, '<MEMO>', ''),
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
