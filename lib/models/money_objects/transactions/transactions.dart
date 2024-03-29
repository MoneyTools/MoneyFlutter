import 'dart:math';

import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
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
    // for (final Transaction t in iterableList()) {
    //   t.postDeserializeFixup(false);
    // }

    // Now that everything is loaded, lets resolve the Transfers
    for (final Transaction transactionSource in iterableList()) {
      final int transferId = transactionSource.transfer.value;
      transactionSource.transferInstance = null;

      if (transactionSource.transferSplit.value > 0) {
        // deal with transfer of split
        // Split transfer
        // if (transactionSource.transferSplit.value != -1) {
        //   final Split? s = Data().splits.get(transactionSource.transferSplit.value);
        //   if (s == null) {
        //     debugLog('Transaction contains a split marked as a transfer, but other side of transfer was not found');
        //     continue;
        //   }
        //
        //   if (transactionSource.transferInstance == null) {
        //     transactionSource.transferInstance =
        //         Transfer(id: transferId, source: transactionSource, related: transactionRelated, relatedSplit: s);
        //     continue;
        //   }
        // debugLog('Already have a transfer for this split');
        // }
        continue;
      }

      // Simple Transfer
      if (transferId == -1) {
        if (transactionSource.transferInstance == null) {
          // this is correct
        } else {
          // this needs to be cleared
          // TODO should the other side transaction be cleared too?
          transactionSource.transferInstance = null;
        }
      } else {
        // hook up the transfer relation
        final Transaction? transactionRelated = get(transferId);

        // check for error
        if (transactionRelated == null) {
          debugLog(
              'Transaction.transferID of ${transactionSource.uniqueId} missing related transaction id $transferId');
          continue;
        }

        // hydrate the Transfer
        if (transactionSource.transferSplit.value == -1) {
          // Normal direct transfer
          // ignore: prefer_conditional_assignment
          if (transactionSource.transferInstance == null) {
            // cache the transfer
            transactionSource.transferInstance =
                Transfer(id: 0, source: transactionSource, related: transactionRelated, isOrphan: false);
          }
          // ignore: prefer_conditional_assignment
          if (transactionRelated.transferInstance == null) {
            // cache the transfer
            transactionRelated.transferInstance =
                Transfer(id: 0, source: transactionRelated, related: transactionSource, isOrphan: false);
          }
          continue;
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

  Transaction? findExistingTransactionForAccount({
    required final int accountId,
    required final DateTime dateTime,
    required final double amount,
  }) {
    // TODO make this more precises, at the moment we only match amount and date YYYY,MM,DD
    return iterableList(true).firstWhereOrNull((transaction) {
      if (transaction.accountId.value == accountId && transaction.amount.value == amount) {
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
