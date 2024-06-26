import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/helpers/value_parser.dart';
import 'package:money/app/core/widgets/confirmation_dialog.dart';
import 'package:money/app/core/widgets/dialog/dialog.dart';
import 'package:money/app/core/widgets/import_transactions_list.dart';
import 'package:money/app/core/widgets/picker_panel.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/data/storage/import/import_transactions_from_text.dart';
import 'package:money/app/modules/home/sub_views/view_accounts/picker_account.dart';

Future<bool> importQFX(
  final BuildContext context,
  final String filePath,
  final Data data,
) async {
  final File file = File(filePath);

  final String text = file.readAsStringSync();
  final String ofx = getStringDelimitedStartEndTokens(text, '<OFX>', '</OFX>');

  final OfxBankInfo bankInfo = OfxBankInfo.fromOfx(ofx);

  final AccountType? accountType = getAccountTypeFromText(bankInfo.accountType);
  Account? account = data.accounts.findByIdAndType(bankInfo.accountId, accountType);

  if (account == null) {
    final List<String> activeAccountNames =
        Data().accounts.getListSorted().map((element) => element.name.value).toList();

    showPopupSelection(
      title: 'Pick account to import to',
      context: context,
      items: activeAccountNames,
      selectedItem: bankInfo.accountId,
      onSelected: (final String text) {
        final Account? accountSelected = Data().accounts.getByName(text);
        if (accountSelected != null) {
          _showAndConfirmTransactionToImport(context, ofx, accountSelected);
        } else {
          SnackBarService.displayWarning(
            autoDismiss: false,
            message: 'QFX Import - No matching "${bankInfo.accountType}" accounts with ID "${bankInfo.accountId}"',
          );
          return false;
        }
      },
    );
  } else {
    _showAndConfirmTransactionToImport(context, ofx, account);
  }

  return true;
}

void _showAndConfirmTransactionToImport(
  final BuildContext context,
  final String ofx,
  final Account account,
) {
  final List<QFXTransaction> list = getTransactionFromOFX(ofx);

  final List<ValuesQuality> valuesQuality = [];

  // attempt to find or add new transactions
  for (final QFXTransaction item in list) {
    // when there's no 'name' then fallback to 'memo'
    final payeeText = item.name.isEmpty ? item.memo : item.name;
    valuesQuality.add(
      ValuesQuality(
        date: ValueQuality(item.date.toIso8601String()),
        // final int payeeIdMatchingPayeeText = Data().aliases.getPayeeIdFromTextMatchingOrAdd(payeeText, fireNotification: false);
        description: ValueQuality(payeeText),
        amount: ValueQuality(item.amount.toString()),
      ),
    );
  }

  String messageToUser = '${list.length} transactions found in QFX file, to be imported into "${account.name.value}"';

  Widget questionContent = SizedBox(
    height: 400,
    width: 500,
    child: ImportTransactionsList(
      values: valuesQuality,
    ),
  );

  showConfirmationDialog(
    context: context,
    title: 'Import QFX',
    question: messageToUser,
    content: questionContent,
    buttonText: 'Import',
    onConfirmation: () {
      final List<Transaction> transactionsToAdd = [];
      for (final ValuesQuality singleTransactionInput in valuesQuality) {
        if (!singleTransactionInput.exist) {
          final t = createNewTransactionFromDateDescriptionAmount(
            account,
            singleTransactionInput.date.asDate(),
            singleTransactionInput.description.asString(),
            singleTransactionInput.amount.asAmount(),
          );
          transactionsToAdd.add(t);
        }
      }
      addNewTransactions(
        transactionsToAdd,
        'QFX Imported - ${transactionsToAdd.length} transactions into "${account.name.value}"',
      );
    },
  );
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
  QFXTransaction({
    required this.type,
    required this.date,
    required this.amount,
    required this.name,
    required this.fitid,
    this.memo = '',
    this.number = '',
  });
  late String type;
  late DateTime date;
  late double amount;
  late String name;
  late String fitid;
  late String memo;
  late String number;
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
