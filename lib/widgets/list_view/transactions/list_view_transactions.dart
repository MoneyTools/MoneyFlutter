import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/views/view_transactions/dialog_mutate_transaction.dart';
import 'package:money/widgets/list_view/list_view.dart';

class ListViewTransactions extends StatefulWidget {
  final List<String> columnsToInclude;
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
  late final Fields<Transaction> columns;
  late int sortBy = widget.sortFieldIndex;
  late bool sortAscending = widget.sortAscending;
  late int selectedItemIndex = widget.selectedItemIndex;

  @override
  void initState() {
    super.initState();
    columns = getFieldsForTable();
  }

  @override
  Widget build(final BuildContext context) {
    // get the list sorted
    final List<Transaction> transactions = widget.getList();
    if (transactions.isEmpty) {
      return const Center(child: Text('- No transactions -'));
    }
    sortList(transactions);

    return Column(
      children: <Widget>[
        // Table Header
        MyListItemHeader<Transaction>(
          columns: columns,
          sortByColumn: sortBy,
          sortAscending: sortAscending,
          onTap: (final int index) {
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
        ),
        // Table list of rows
        Expanded(
          child: MyListView<Transaction>(
            fields: columns,
            list: transactions,
            selectedItems: ValueNotifier<List<int>>(<int>[selectedItemIndex]),
            unSelectable: false,
            onTap: (final BuildContext context2, final int index) {
              if (isBetweenOrEqual(index, 0, transactions.length - 1)) {
                showTransactionAndActions(
                  context: context2,
                  transaction: transactions[index],
                ).then((value) {
                  selectedItemIndex = index;
                  widget.onUserChoiceChanged?.call(sortBy, sortAscending, selectedItemIndex);
                });
              }
            },
          ),
        ),
      ],
    );
  }

  void sortList(List<Transaction> transactions) {
    if (columns.definitions.isNotEmpty) {
      final Field<Transaction, dynamic> fieldDefinition = columns.definitions[sortBy];
      if (fieldDefinition.sort != null) {
        transactions.sort(
          (final Transaction a, final Transaction b) {
            return fieldDefinition.sort!(a, b, sortAscending);
          },
        );
      }
    }
  }

  SortIndicator getSortIndicated(final int columnNumber) {
    if (columnNumber == sortBy) {
      return sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }

  Fields<Transaction> getFieldsForTable() {
    final List<Field<Transaction, dynamic>> listOfFields = <Field<Transaction, dynamic>>[];

    for (String columnId in widget.columnsToInclude) {
      final Field<Transaction, dynamic>? declared = getFieldByNameForClass<Transaction>(columnId);
      if (declared != null) {
        listOfFields.add(declared);
      }
    }

    return Fields<Transaction>(definitions: listOfFields);
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
    runningBalance += transaction.amount.value;
    transaction.balance.value = runningBalance;
  }
  return list;
}
