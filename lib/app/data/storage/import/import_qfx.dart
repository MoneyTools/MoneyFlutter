import 'dart:io';

import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/dialog/dialog.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/data/storage/import/import_data.dart';
import 'package:money/app/modules/home/sub_views/view_accounts/picker_account.dart';

Future<bool> importQFX(
  final BuildContext context,
  final String filePath,
) async {
  final File file = File(filePath);

  final String text = file.readAsStringSync();
  final String ofx = getStringDelimitedStartEndTokens(text, '<OFX>', '</OFX>');

  final OfxBankInfo bankInfo = OfxBankInfo.fromOfx(ofx);

  final AccountType? accountType = getAccountTypeFromText(bankInfo.accountType);

  ImportData importData = ImportData();
  importData.account = Data().accounts.findByIdAndType(bankInfo.accountId, accountType);
  importData.entries = getTransactionFromOFX(ofx);
  importData.fileType = 'QFX';
  showAndConfirmTransactionToImport(context, importData);

  return true;
}

class OfxBankInfo {
  String accountId = '';
  String accountType = '';
  String id = '';

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

int getInvestmentCategoryFromOfxType(final ImporEntry ofxTransaction) {
  int categoryId = -1;
  switch (ofxTransaction.type) {
    case 'CREDIT':
      categoryId = Data().categories.investmentCredit.fieldId.value;
      break;
    case 'DEBIT':
      categoryId = Data().categories.investmentDebit.fieldId.value;
      break;
    case 'INT':
      categoryId = Data().categories.investmentInterest.fieldId.value;
      break;
    case 'DIV':
      categoryId = Data().categories.investmentDividends.fieldId.value;
      break;
    case 'FEE':
    case 'SRVCHG': // service charge
      categoryId = Data().categories.investmentFees.fieldId.value;
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
        categoryId = Data().categories.investmentCredit.fieldId.value;
      } else {
        categoryId = Data().categories.investmentDebit.fieldId.value;
      }
      break;
    case 'XFER':
      categoryId = Data().categories.investmentTransfer.fieldId.value;
      break;
  }
  return categoryId;
}

List<ImporEntry> getTransactionFromOFX(final String rawOfx) {
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

    final List<ImporEntry> qfxTransactions = parseQFXTransactions(lines);
    return qfxTransactions;
  }

  return <ImporEntry>[];
}

List<ImporEntry> parseQFXTransactions(final List<String> lines) {
  final List<ImporEntry> transactions = <ImporEntry>[];

  for (String line in lines) {
    line = getNormalizedValue(line);

    final String rawTransactionText = getStringContentBetweenTwoTokens(
      line,
      '<STMTTRN>',
      '</STMTTRN>',
    );

    if (rawTransactionText.isNotEmpty) {
      final ImporEntry currentTransaction = ImporEntry(
        type: findAndGetValueOf(rawTransactionText, '<TRNTYPE>', ''),
        date: parseQfxDataFormat(
              findAndGetValueOf(rawTransactionText, '<DTPOSTED>', ''),
            ) ??
            DateTime.now(),
        amount: double.parse(
          findAndGetValueOf(rawTransactionText, '<TRNAMT>', '0.00'),
        ),
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

String findAndGetValueOf(
  final String line,
  final String tokenTextToFind,
  final String valueIfNotFound,
) {
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

void showPickAccount(
  final BuildContext context,
) {
  adaptiveScreenSizeDialog(
    context: context,
    title: 'Pick Account to import to',
    captionForClose: null, // this will hide the close button
    child: Column(
      children: [
        pickerAccount(
          selected: null,
          onSelected: (Account? account) {
            // widget.onSelected(_choice, widget.payee, account);
          },
        ),
      ],
    ),
  );
}
