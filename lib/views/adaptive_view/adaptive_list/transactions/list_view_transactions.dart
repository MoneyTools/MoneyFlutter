import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/fields/field_filter.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_transactions/dialog_mutate_transaction.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_view.dart';

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
  final bool _isMultiSelectionOn = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    // get the list sorted
    final List<Transaction> transactions = widget.getList();
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions'));
    }
    sortList(transactions);

    return Column(
      children: <Widget>[
        // Table Header
        MyListItemHeader<Transaction>(
          columns: widget.columnsToInclude,
          filterOn: FieldFilters(),
          sortByColumn: sortBy,
          sortAscending: sortAscending,
          onSelectAll: _isMultiSelectionOn
              ? (bool? selectAll) {
                  // selectedItemsByUniqueId.value.clear();
                  // for (final item in list) {
                  //   selectedItemsByUniqueId.value.add(item.uniqueId);
                  //   }
                  // }
                }
              : null,
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
            fields: Fields<Transaction>()..setDefinitions(widget.columnsToInclude),
            list: transactions,
            displayAsColumn: true,
            selectedItemIds: ValueNotifier<List<int>>([selectedItemIndex]),
            isMultiSelectionOn: _isMultiSelectionOn,
            onSelectionChanged: (final int uniqueId) {
              setState(() {
                selectedItemIndex = uniqueId;
                widget.onUserChoiceChanged?.call(sortBy, sortAscending, uniqueId);
              });
            },
            onLongPress: (final BuildContext context2, final int uniqueId) {
              final Transaction instance = findObjectById(uniqueId, transactions) as Transaction;
              showTransactionAndActions(
                context: context2,
                transaction: instance,
              ).then((value) {
                selectedItemIndex = uniqueId;
                widget.onUserChoiceChanged?.call(sortBy, sortAscending, selectedItemIndex);
              });
            },
          ),
        ),
      ],
    );
  }

  void sortList(List<Transaction> transactions) {
    if (isIndexInRange(widget.columnsToInclude, sortBy)) {
      final Field<dynamic> fieldDefinition = widget.columnsToInclude[sortBy];
      if (fieldDefinition.sort == null) {
        // No sorting function found, fallback to String sorting
        transactions.sort((final MoneyObject a, final MoneyObject b) {
          return sortByString(
            fieldDefinition.getValueForDisplay(a).toString(),
            fieldDefinition.getValueForDisplay(b).toString(),
            sortAscending,
          );
        });
      } else {
        transactions.sort(
          (final Transaction a, final Transaction b) {
            return fieldDefinition.sort!(a, b, sortAscending);
          },
        );
      }
    }
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
