import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/models/money_objects/transactions/transactions.dart';
import 'package:money/app/data/models/money_objects/transfers/transfer.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/view_money_objects.dart';
import 'package:money/app/modules/home/sub_views/view_transfers/transfer_sender_receiver.dart';

class ViewTransfers extends ViewForMoneyObjects {
  const ViewTransfers({
    super.key,
  });

  @override
  State<ViewForMoneyObjects> createState() => ViewTransfersState();
}

class ViewTransfersState extends ViewForMoneyObjectsState {
  ViewTransfersState() {
    viewId = ViewId.viewTransfers;
  }

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
  Fields<Transfer> getFieldsForTable() {
    return Transfer.fieldsForColumnView;
  }

  @override
  Widget getInfoPanelViewDetails({
    required final List<int> selectedIds,
    required final bool isReadOnly,
  }) {
    if (selectedIds.isNotEmpty) {
      final int id = selectedIds.first;
      final Transfer? transfer = list.firstWhereOrNull((element) => element.uniqueId == id) as Transfer?;
      if (transfer != null) {
        return TransferSenderReceiver(transfer: transfer);
      }
    }
    return const CenterMessage(message: 'No item selected.');
  }

  @override
  List<Transfer> getList({
    bool includeDeleted = false,
    bool applyFilter = true,
  }) {
    List<Transfer> listOfTransfers = [];

    // get all transaction of type transfer where the money was sent from (debited)
    final List<Transaction> listOfTransactionsUseForTransfer = Data()
        .transactions
        .getListFlattenSplits()
        .where(
          (final Transaction transaction) => transaction.transfer.value != -1,
        )
        .toList();

    // Add the Senders
    for (final transactionOfSender in listOfTransactionsUseForTransfer) {
      // Display only the Sender/From Transaction you know that its the sender because the amount id negative (deducted)
      if (transactionOfSender.amount.value.toDouble() <= 0) {
        final Transaction? transactionOfReceiver = Data().transactions.get(transactionOfSender.transfer.value);
        keepThisTransfer(
          list: listOfTransfers,
          transactionSender: transactionOfSender,
          transactionReceiver: transactionOfReceiver,
          isOrphan: false,
        );
      }
    }

    // Add the Receivers only it they are not already part of the Senders
    for (final transactionOfReceiver in listOfTransactionsUseForTransfer) {
      // the amount is positive, so this is the receiver transaction
      if (transactionOfReceiver.amount.value.toDouble() > 0) {
        final Transaction? transactionOfSender = Data().transactions.get(transactionOfReceiver.transfer.value);
        if (transactionOfSender == null) {
          if (transactionOfReceiver.transferSplit.value != -1) {
            logger.i('This is a split');
          }
          logger.e(
            'related account not found ${transactionOfReceiver.uniqueId} ${transactionOfReceiver.amount.value}',
          );
          keepThisTransfer(
            list: listOfTransfers,
            transactionSender: transactionOfSender!,
            transactionReceiver: transactionOfReceiver,
            isOrphan: true,
          );
        }
      }
    }

    if (applyFilter) {
      listOfTransfers = listOfTransfers.where((final instance) => isMatchingFilters(instance)).toList();
    }

    return listOfTransfers;
  }

  @override
  String getViewId() {
    return 'transfer';
  }

  void keepThisTransfer({
    required final List<Transfer> list,
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
        if (!PreferenceController.to.includeClosedAccounts) {
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
      list.add(transfer);
    }
  }
}
