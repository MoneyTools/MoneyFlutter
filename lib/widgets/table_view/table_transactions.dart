import 'package:flutter/material.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/transactions/transaction.dart';
import 'package:money/models/transactions/transactions.dart';

import 'package:money/widgets/table_view/table_header.dart';
import 'package:money/widgets/table_view/table_transactions_fields.dart';
import 'package:money/widgets/table_view/table_view.dart';

class TableTransactions extends StatefulWidget {
  final List<String> columnsToInclude;
  final List<Transaction> Function() getList;
  final int defaultSortingField;

  const TableTransactions({
    super.key,
    required this.columnsToInclude,
    required this.getList,
    this.defaultSortingField = 0,
  });

  @override
  State<TableTransactions> createState() => _TableTransactionsState();
}

class _TableTransactionsState extends State<TableTransactions> {
  late int sortBy = widget.defaultSortingField;
  bool sortAscending = true;
  late final FieldDefinitions<Transaction> columns;

  @override
  void initState() {
    super.initState();
    columns = getFieldDefinitionsForTable();
    onSort();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: <Widget>[
        // Table Header
        MyTableHeader<Transaction>(
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
          onLongPress: () {
            // todo - for example add filtering
          },
        ),
        // Table list of rows
        Expanded(
          child: MyTableView<Transaction>(
            columns: columns,
            list: widget.getList(),
            selectedItems: ValueNotifier<List<int>>(<int>[]),
          ),
        ),
      ],
    );
  }

  void onSort() {
    final FieldDefinition<Transaction> fieldDefinition = columns.definitions[sortBy];
    if (fieldDefinition.sort != null) {
      widget.getList().sort(
        (final Transaction a, final Transaction b) {
          return fieldDefinition.sort!(a, b, sortAscending);
        },
      );
    }
  }

  SortIndicator getSortIndicated(final int columnNumber) {
    if (columnNumber == sortBy) {
      return sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }

  FieldDefinitions<Transaction> getFieldDefinitionsForTable() {
    final List<FieldDefinition<Transaction>> listOfColumns = <FieldDefinition<Transaction>>[];

    for (String columnId in widget.columnsToInclude) {
      listOfColumns.add(getFieldDefinitionFromId(columnId, widget.getList)!);
    }

    return FieldDefinitions<Transaction>(definitions: listOfColumns);
  }
}

typedef FilterFunction = bool Function(Transaction);

bool defaultFilter(final Transaction element) {
  return true; // filter nothing
}

List<Transaction> getFilteredTransactions(final FilterFunction filter) {
  final List<Transaction> list =
      Transactions.list.where((final Transaction transaction) => filter(transaction)).toList();

  list.sort(
    (final Transaction a, final Transaction b) => a.dateTime.compareTo(b.dateTime),
  );

  double runningBalance = 0.0;
  for (Transaction transaction in list) {
    runningBalance += transaction.amount;
    transaction.balance = runningBalance;
  }
  return list;
}
