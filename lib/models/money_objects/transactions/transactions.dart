import 'dart:math';

import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/splits/split.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/money_objects/transfers/transfer.dart';
import 'package:money/storage/data/data.dart';

export 'package:money/models/money_objects/transactions/transaction.dart';

part 'transactions_csv.dart';

part 'transactions_demo.dart';

class Transactions extends MoneyObjects<Transaction> {
  Transactions() {
    collectionName = 'Transactions';
  }

  double runningBalance = 0.00;

  @override
  void loadDemoData() {
    _loadDemoData();
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }

  @override
  List<Transaction> loadFromJson(final List<MyJson> rows) {
    clear();

    runningBalance = 0.00;

    for (final MyJson row in rows) {
      final Transaction t = Transaction.fromJSon(row, runningBalance);
      runningBalance += t.balance.value;
      appendMoneyObject(t);
    }
    return iterableList().toList();
  }

  @override
  void onAllDataLoaded() {
    for (final Transaction t in iterableList()) {
      t.postDeserializeFixup(false);
    }

    // Now that everything is loaded, lets resolve the Transfers
    for (final Transaction transactionSource in iterableList().where((element) => element.transfer.value != -1)) {
      final int transferId = transactionSource.transfer.value!;
      final Transaction? transactionRelated = get(transferId);
      if (transactionRelated == null) {
        debugLog('Transaction.transferID of ${transactionSource.uniqueId} missing related transaction id $transferId');
      } else {
        if (transactionSource.transferSplit.value == -1) {
          // Normal direct transfer
          transactionSource.transferInstance = Transfer(id: transferId, source: transactionSource, related: transactionRelated);
        } else {
          // Split transfer
          final Split? s = Data().splits.get(transactionSource.transferSplit.value);
          if (s == null) {
            debugLog('Transaction contains a split marked as a transfer, but other side of transfer was not found');
          } else {
            if (transactionSource.transferInstance == null) {
              transactionSource.transferInstance = Transfer(id: transferId, source: transactionSource, related: transactionRelated, relatedSplit: s);
            } else {
              debugLog('Already have a transfer for this split');
            }
          }
        }
      }
    }
  }

  int getNextTransactionId() {
    int maxIdFound = -1;
    for (final item in iterableList(true)) {
      maxIdFound = max(maxIdFound, item.id.value);
    }
    return maxIdFound + 1;
  }

  Transaction? findExistingTransaction({
    required final DateTime dateTime,
    required final String payeeAsText,
    required final String memo,
    required final double amount,
  }) {
    // TODO make this more precises, at the moment we only match amount and date YYYY,MM,DD
    return iterableList(true).firstWhereOrNull((transaction) {
      if (transaction.amount.value == amount) {
        if (transaction.dateTime.value?.year == dateTime.year &&
            transaction.dateTime.value?.month == dateTime.month &&
            transaction.dateTime.value?.day == dateTime.day) {
          return true;
        }
      }
      return false;
    });
  }
}
