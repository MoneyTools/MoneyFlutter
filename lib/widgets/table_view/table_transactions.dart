import 'package:flutter/material.dart';
import 'package:money/helpers.dart';
import 'package:money/models/accounts.dart';
import 'package:money/models/categories.dart';
import 'package:money/models/payees.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/columns.dart';
import 'package:money/widgets/table_view/table_header.dart';
import 'package:money/widgets/table_view/table_view.dart';

const String columnIdAccount = 'Accounts';
const String columnIdDate = 'Date';
const String columnIdPayee = 'Payee';
const String columnIdCategory = 'Category';
const String columnIdAmount = 'Amount';
const String columnIdBalance = 'Balance';

class TableTransactions extends StatefulWidget {
  final List<String> columnsToInclude;
  final List<Transaction> Function() getList;

  const TableTransactions({
    super.key,
    required this.columnsToInclude,
    required this.getList,
  });

  @override
  State<TableTransactions> createState() => _TableTransactionsState();
}

class _TableTransactionsState extends State<TableTransactions> {
  int sortBy = 0;
  bool sortAscending = true;
  late final ColumnDefinitions<Transaction> columns;

  @override
  void initState() {
    super.initState();
    columns = getColumnDefinitionsForTable();
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
          ),
        ),
      ],
    );
  }

  void onSort() {
    final ColumnDefinition<Transaction> columnDefinition = columns.list[sortBy];
    final int Function(
      Transaction p1,
      Transaction p2,
      bool p3,
    ) sortFunction = columnDefinition.sort;

    widget.getList().sort((final Transaction a, final Transaction b) {
      return sortFunction(a, b, sortAscending);
    });
  }

  SortIndicator getSortIndicated(final int columnNumber) {
    if (columnNumber == sortBy) {
      return sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }

  ColumnDefinitions<Transaction> getColumnDefinitionsForTable() {
    final List<ColumnDefinition<Transaction>> listOfColumns = <ColumnDefinition<Transaction>>[];

    for (String columnId in widget.columnsToInclude) {
      listOfColumns.add(getColumnDefinitionFromId(columnId, widget.getList)!);
    }

    return ColumnDefinitions<Transaction>(list: listOfColumns);
  }
}

typedef FilterFunction = bool Function(Transaction);

bool defaultFilter(final Transaction element) {
  return true; // filter nothing
}

List<Transaction> getFilteredTransactions(final FilterFunction filter) {
  final List<Transaction> list =
      Transactions.list.where((final Transaction transaction) => filter(transaction)).toList();

  list.sort((final Transaction a, final Transaction b) =>
      sortByStringIgnoreCase2(getDateAsText(a.dateTime), getDateAsText(b.dateTime)));

  double runningBalance = 0.0;
  for (Transaction transaction in list) {
    runningBalance += transaction.amount;
    transaction.balance = runningBalance;
  }
  return list;
}

ColumnDefinition<Transaction>? getColumnDefinitionFromId(
  final String id,
  final List<Transaction> Function() getList,
) {
  switch (id) {
    case columnIdAccount:
      return ColumnDefinition<Transaction>(
        name: columnIdAccount,
        type: ColumnType.text,
        align: TextAlign.left,
        value: (final int index) {
          return Accounts.getNameFromId((getList()[index]).accountId);
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByString(Accounts.getNameFromId(a.accountId), Accounts.getNameFromId(b.accountId), ascending);
        },
      );
    case columnIdDate:
      return ColumnDefinition<Transaction>(
          name: columnIdDate,
          type: ColumnType.date,
          align: TextAlign.left,
          value: (final int index) {
            return getDateAsText((getList()[index]).dateTime);
          },
          sort: (final Transaction a, final Transaction b, final bool ascending) {
            return sortByString(getDateAsText(a.dateTime), getDateAsText(b.dateTime), ascending);
          });

    case columnIdPayee:
      return ColumnDefinition<Transaction>(
        name: columnIdPayee,
        type: ColumnType.text,
        align: TextAlign.left,
        value: (final int index) {
          return Payees.getNameFromId((getList()[index]).payeeId);
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByString(Payees.getNameFromId(a.payeeId), Payees.getNameFromId(b.payeeId), ascending);
        },
      );

    case columnIdCategory:
      return ColumnDefinition<Transaction>(
        name: columnIdCategory,
        type: ColumnType.text,
        align: TextAlign.left,
        value: (final int index) {
          return Categories.getNameFromId((getList()[index]).categoryId);
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByString(
              Categories.getNameFromId(a.categoryId), Categories.getNameFromId(b.categoryId), ascending);
        },
      );

    case columnIdAmount:
      return ColumnDefinition<Transaction>(
        name: columnIdAmount,
        type: ColumnType.amount,
        align: TextAlign.right,
        value: (final int index) {
          return (getList()[index]).amount;
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByValue(a.amount, b.amount, ascending);
        },
      );

    case columnIdBalance:
      return ColumnDefinition<Transaction>(
        name: columnIdBalance,
        type: ColumnType.amount,
        align: TextAlign.right,
        value: (final int index) {
          return (getList()[index]).balance;
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByValue(a.balance, b.balance, ascending);
        },
      );
  }
  return null;
}
