import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/adaptive_view/adaptive_list/adaptive_columns_or_rows_single_seletion.dart';
import 'package:money/views/view_transactions/dialog_mutate_transaction.dart';

class ListViewTransactions extends StatefulWidget {
  final List<Field> columnsToInclude;
  final List<Transaction> Function() getList;
  final int sortFieldIndex;
  final bool sortAscending;
  final int selectedItemIndex;
  final Function(int sortingField, bool sortAscending, int selectedItemIndex)? onUserChoiceChanged;

  const ListViewTransactions({
    super.key,
    required this.columnsToInclude,
    required this.getList,
    this.sortFieldIndex = 0,
    this.sortAscending = true,
    this.onUserChoiceChanged,
    this.selectedItemIndex = 0,
  });

  @override
  State<ListViewTransactions> createState() => _ListViewTransactionsState();
}

class _ListViewTransactionsState extends State<ListViewTransactions> {
  late int sortBy = widget.sortFieldIndex;
  late bool sortAscending = widget.sortAscending;
  late int selectedItemIndex = widget.selectedItemIndex;

  @override
  Widget build(final BuildContext context) {
    // get the list sorted
    final List<Transaction> transactions = widget.getList();
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions'));
    }

    MoneyObjects.sortList(transactions, widget.columnsToInclude, sortBy, sortAscending);

    return AdaptiveListColumnsOrRowsSingleSelection(
      list: transactions,
      fieldDefinitions: widget.columnsToInclude,
      filters: FieldFilters(),
      sortByFieldIndex: sortBy,
      sortAscending: sortAscending,
      selectedId: -1,
      // Field & Columns
      displayAsColumns: true,
      backgoundColorForHeaderFooter: Colors.transparent,
      onColumnHeaderTap: (final int index) {
        setState(() {
          if (sortBy == index) {
            // same column tap/click again, change the sort order
            sortAscending = !sortAscending;
          } else {
            sortBy = index;
          }
          widget.onUserChoiceChanged?.call(sortBy, sortAscending, selectedItemIndex);
        });
      },
      onItemLongPress: (final BuildContext context2, final int uniqueId) {
        final Transaction instance = findObjectById(uniqueId, transactions) as Transaction;
        showTransactionAndActions(
          context: context2,
          transaction: instance,
        ).then((value) {
          selectedItemIndex = uniqueId;
          widget.onUserChoiceChanged?.call(sortBy, sortAscending, selectedItemIndex);
        });
      },
    );
  }
}

List<Transaction> getTransactions({bool Function(Transaction)? filter}) {
  // default to 'accept all'
  filter ??= (Transaction transaction) => true;

  final List<Transaction> list =
      Data().transactions.iterableList().where((final Transaction transaction) => filter!(transaction)).toList();

  list.sort(
    (final Transaction a, final Transaction b) => sortByDate(a.dateTime.value, b.dateTime.value),
  );

  double runningBalance = 0.0;
  for (Transaction transaction in list) {
    runningBalance += transaction.amount.value.toDouble();
    transaction.balance = runningBalance;
  }
  return list;
}
