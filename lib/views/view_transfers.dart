import 'package:flutter/material.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/models/money_objects/transfers/transfer.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view.dart';

class ViewTransfers extends ViewWidget<Transfer> {
  const ViewTransfers({
    super.key,
  });

  @override
  State<ViewWidget<Transfer>> createState() => ViewTransfersState();
}

class ViewTransfersState extends ViewWidgetState<Transfer> {
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
    final List<Transaction> list = Data()
        .transactions
        .iterableList(includeDeleted)
        .where((final Transaction transaction) => transaction.transfer.value != -1)
        .toList();

    final List<Transfer> listOfTransfers = [];
    for (final t in list) {
      final Transfer transfer = Transfer(
        id: 0,
        source: t,
        related: Data().transactions.get(t.transfer.value),
      );
      // transfer.transactionAmount.value = t.amount.value;
      listOfTransfers.add(transfer);
    }
    return listOfTransfers;
  }
}
