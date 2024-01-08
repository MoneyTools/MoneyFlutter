import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/accounts.dart';
import 'package:money/models/categories.dart';
import 'package:money/models/payees.dart';
import 'package:money/models/transactions.dart';
import 'package:money/widgets/fields/field.dart';
import 'package:money/widgets/fields/fields.dart';
import 'package:money/widgets/table_view/table_header.dart';
import 'package:money/widgets/table_view/table_view.dart';

const String columnIdAccount = 'Accounts';
const String columnIdDate = 'Date';
const String columnIdPayee = 'Payee';
const String columnIdCategory = 'Category';
const String columnIdMemo = 'Memo';
const String columnIdAmount = 'Amount';
const String columnIdBalance = 'Balance';

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
          ),
        ),
      ],
    );
  }

  void onSort() {
    final FieldDefinition<Transaction> fieldDefinition = columns.list[sortBy];
    final int Function(
      Transaction p1,
      Transaction p2,
      bool p3,
    ) sortFunction = fieldDefinition.sort;

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

  FieldDefinitions<Transaction> getFieldDefinitionsForTable() {
    final List<FieldDefinition<Transaction>> listOfColumns = <FieldDefinition<Transaction>>[];

    for (String columnId in widget.columnsToInclude) {
      listOfColumns.add(getFieldDefinitionFromId(columnId, widget.getList)!);
    }

    return FieldDefinitions<Transaction>(list: listOfColumns);
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
      stringCompareIgnoreCasing2(getDateAsText(a.dateTime), getDateAsText(b.dateTime)));

  double runningBalance = 0.0;
  for (Transaction transaction in list) {
    runningBalance += transaction.amount;
    transaction.balance = runningBalance;
  }
  return list;
}

FieldDefinition<Transaction>? getFieldDefinitionFromId(
  final String id,
  final List<Transaction> Function() getList,
) {
  switch (id) {
    case columnIdAccount:
      return FieldDefinition<Transaction>(
        name: columnIdAccount,
        type: FieldType.text,
        align: TextAlign.left,
        value: (final int index) {
          return Accounts.getNameFromId((getList()[index]).accountId);
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByString(Accounts.getNameFromId(a.accountId), Accounts.getNameFromId(b.accountId), ascending);
        },
      );
    case columnIdDate:
      return FieldDefinition<Transaction>(
          name: columnIdDate,
          type: FieldType.date,
          align: TextAlign.left,
          value: (final int index) {
            return getDateAsText((getList()[index]).dateTime);
          },
          sort: (final Transaction a, final Transaction b, final bool ascending) {
            return sortByString(getDateAsText(a.dateTime), getDateAsText(b.dateTime), ascending);
          });

    case columnIdPayee:
      return FieldDefinition<Transaction>(
        name: columnIdPayee,
        type: FieldType.text,
        align: TextAlign.left,
        value: (final int index) {
          return Payees.getNameFromId((getList()[index]).payeeId);
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByString(Payees.getNameFromId(a.payeeId), Payees.getNameFromId(b.payeeId), ascending);
        },
      );

    case columnIdCategory:
      return FieldDefinition<Transaction>(
        name: columnIdCategory,
        type: FieldType.text,
        align: TextAlign.left,
        value: (final int index) {
          return Categories.getNameFromId((getList()[index]).categoryId);
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByString(
              Categories.getNameFromId(a.categoryId), Categories.getNameFromId(b.categoryId), ascending);
        },
      );

    case columnIdMemo:
      return FieldDefinition<Transaction>(
        name: columnIdMemo,
        type: FieldType.text,
        align: TextAlign.left,
        value: (final int index) {
          return getList()[index].memo;
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByString(a.memo, b.memo, ascending);
        },
      );

    case columnIdAmount:
      return FieldDefinition<Transaction>(
        name: columnIdAmount,
        type: FieldType.amount,
        align: TextAlign.right,
        value: (final int index) {
          return (getList()[index]).amount;
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByValue(a.amount, b.amount, ascending);
        },
      );

    case columnIdBalance:
      return FieldDefinition<Transaction>(
        name: columnIdBalance,
        type: FieldType.amount,
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
