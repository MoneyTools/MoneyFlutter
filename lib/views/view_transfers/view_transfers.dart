import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/models/money_objects/transfers/transfer.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_money_objects.dart';
import 'package:money/views/view_transactions/money_object_card.dart';
import 'package:money/widgets/center_message.dart';

class ViewTransfers extends ViewForMoneyObjects {
  const ViewTransfers({
    super.key,
  });

  @override
  State<ViewForMoneyObjects> createState() => ViewTransfersState();
}

class ViewTransfersState extends ViewForMoneyObjectsState {
  List<Transfer> listOfTransfers = [];
  Map<int, Transfer> loadedTransfers = {};

  @override
  String getClassNamePlural() {
    return 'Transfers';
  }

  @override
  String getClassNameSingular() {
    return 'Transfer';
  }

  @override
  String getDescription() {
    return 'Transfers between accounts.';
  }

  @override
  MyJson getViewChoices() {
    return Settings().views['Transfer'] ?? {};
  }

  @override
  Fields<Transfer> getFieldsForTable() {
    return Transfer.fields;
  }

  @override
  List<Transfer> getList({bool includeDeleted = false, bool applyFilter = true}) {
    final List<Transaction> listOfTransactions = Data()
        .transactions
        .iterableList(includeDeleted: includeDeleted)
        .where((final Transaction transaction) => transaction.transfer.value != -1)
        .toList();

    // Add the Senders
    for (final transaction in listOfTransactions) {
      final Transaction? transactionReceiver = Data().transactions.get(transaction.transfer.value);
      if (transaction.amount.value.amount <= 0) {
        // Display only the Sender/From Transaction you know that its the sender because the amount id negative (deducted)
        keepThisTransfer(transactionSender: transaction, transactionReceiver: transactionReceiver, isOrphan: false);
      }
    }

    // Add the Receivers only it they are not already part of the Senders
    for (final transaction in listOfTransactions) {
      final Transaction? transactionReceiver = Data().transactions.get(transaction.transfer.value);
      if (transaction.amount.value.amount > 0) {
        // the amount is positive, so this is the receiver transaction
        if (transactionReceiver == null || loadedTransfers[transactionReceiver.uniqueId] == null) {
          if (transaction.transferSplit.value <= 0) {
            debugLog('This is a split');
          }
          debugLog('related account not found ${transaction.uniqueId} ${transaction.amount.value}');
          keepThisTransfer(transactionSender: transactionReceiver!, transactionReceiver: transaction, isOrphan: true);
        }
      }
    }
    return listOfTransfers;
  }

  @override
  Widget getInfoPanelViewDetails({required final List<int> selectedIds, required final bool isReadOnly}) {
    if (selectedIds.isNotEmpty) {
      final int id = selectedIds.first;
      final Transfer? transfer = list.firstWhereOrNull((element) => element.uniqueId == id) as Transfer?;
      if (transfer != null) {
        return SingleChildScrollView(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 30,
              spacing: 30,
              children: [
                IntrinsicWidth(
                  child: TransactionCard(title: 'Sender', transaction: transfer.getSenderTransaction()),
                ),
                IntrinsicWidth(
                  child: TransactionCard(title: 'Receiver', transaction: transfer.getReceiverTransaction()),
                ),
              ],
            ),
          ),
        );
      }
    }
    return const CenterMessage(message: 'No item selected.');
  }

  void keepThisTransfer({
    required Transaction transactionSender,
    required Transaction? transactionReceiver,
    required bool isOrphan,
  }) {
    final Account? accountSender = transactionSender.getAccount();
    final Account? accountReceiver = transactionReceiver?.getAccount();
    if (accountSender != null && accountReceiver != null) {
      // Are the accounts available?

      // if both accounts are closed skip them if the user does not care
      if (accountSender.isClosed() && accountReceiver.isClosed()) {
        if (!Settings().includeClosedAccounts) {
          // exclude closed account
          return;
        }
      }

      final Transfer transfer = Transfer(
        id: 0,
        source: transactionSender,
        related: transactionReceiver,
        isOrphan: isOrphan,
      );
      // transfer.transactionAmount.value = t.amount.value;
      listOfTransfers.add(transfer);
      if (!isOrphan) {
        loadedTransfers[transactionSender.uniqueId] = transfer;
      }
    }
  }
}
