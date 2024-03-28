import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/models/money_objects/transfers/transfer.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view.dart';
import 'package:money/widgets/box.dart';
import 'package:money/widgets/center_message.dart';

class ViewTransfers extends ViewWidget<Transfer> {
  const ViewTransfers({
    super.key,
  });

  @override
  State<ViewWidget<Transfer>> createState() => ViewTransfersState();
}

class ViewTransfersState extends ViewWidgetState<Transfer> {
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
  List<Transfer> getList([bool includeDeleted = false]) {
    final List<Transaction> listOfTransactions = Data()
        .transactions
        .iterableList(includeDeleted)
        .where((final Transaction transaction) => transaction.transfer.value != -1)
        .toList();

    // Add the Senders
    for (final transaction in listOfTransactions) {
      final Transaction? transactionReceiver = Data().transactions.get(transaction.transfer.value);
      if (transaction.amount.value <= 0) {
        // Display only the Sender/From Transaction you know that its the sender because the amount id negative (deducted)
        keepThisTransfer(transactionSender: transaction, transactionReceiver: transactionReceiver, isOrphan: false);
      }
    }

    // Add the Receivers only it they are not already part of the Senders
    for (final transaction in listOfTransactions) {
      final Transaction? transactionReceiver = Data().transactions.get(transaction.transfer.value);
      if (transaction.amount.value > 0) {
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
  Widget getPanelForDetails({required final List<int> indexOfItems, required final bool isReadOnly}) {
    if (indexOfItems.isNotEmpty) {
      final int index = indexOfItems.first;
      if (isBetweenOrEqual(index, 0, list.length - 1)) {
        final Transfer transfer = list[index];
        return SingleChildScrollView(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 30,
              spacing: 30,
              children: [
                IntrinsicWidth(child: getParticipantTransaction('Sender', transfer.getSenderTransaction())),
                IntrinsicWidth(child: getParticipantTransaction('Receiver', transfer.getReceiverTransaction())),
              ],
            ),
          ),
        );
      }
    }
    return const CenterMessage(message: 'No item selected.');
  }

  Widget getParticipantTransaction(final String title, final Transaction? transaction) {
    List<Widget> widgets = [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          title,
          style: getTextTheme(context).headlineSmall,
        ),
      )
    ];
    if (transaction == null) {
      widgets.add(const Text('- not found -'));
    } else {
      widgets.addAll(
        transaction.buildWidgets<Transaction>(onEdit: null, compact: true),
      );
    }

    return Box(
      color: getColorTheme(context).background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
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
