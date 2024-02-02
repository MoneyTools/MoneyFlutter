import 'package:flutter/material.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

import 'package:money/widgets/list_view/list_view.dart';

class ListViewTransactions extends StatefulWidget {
  final List<String> columnsToInclude;
  final List<Transaction> Function() getList;
  final int defaultSortingField;

  const ListViewTransactions({
    super.key,
    required this.columnsToInclude,
    required this.getList,
    this.defaultSortingField = 0,
  });

  @override
  State<ListViewTransactions> createState() => _ListViewTransactionsState();
}

class _ListViewTransactionsState extends State<ListViewTransactions> {
  late int sortBy = widget.defaultSortingField;
  bool sortAscending = true;
  late final Fields<Transaction> columns;

  @override
  void initState() {
    super.initState();
    columns = getFieldsForTable();
    onSort();
  }

  @override
  Widget build(final BuildContext context) {
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
              onSort();
            });
          },
        ),
        // Table list of rows
        Expanded(
          child: MyTableView<Transaction>(
            fields: columns,
            list: widget.getList(),
            selectedItems: ValueNotifier<List<int>>(<int>[]),
          ),
        ),
      ],
    );
  }

  void onSort() {
    if (columns.definitions.isNotEmpty) {
      final Field<Transaction, dynamic> fieldDefinition = columns.definitions[sortBy];
      if (fieldDefinition.sort != null) {
        widget.getList().sort(
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

typedef FilterFunction = bool Function(Transaction);

List<Transaction> getFilteredTransactions(final FilterFunction filter) {
  final List<Transaction> list =
      Data().transactions.getList().where((final Transaction transaction) => filter(transaction)).toList();

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
