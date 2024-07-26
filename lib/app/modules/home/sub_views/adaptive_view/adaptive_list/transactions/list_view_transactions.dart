import 'package:money/app/controller/selection_controller.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_single_seletion.dart';
import 'package:money/app/modules/home/sub_views/view_transactions/dialog_mutate_transaction.dart';

class ListViewTransactions extends StatefulWidget {
  const ListViewTransactions({
    super.key,
    required this.columnsToInclude,
    required this.getList,
    required this.selectionController,
    this.sortFieldIndex = 0,
    this.sortAscending = true,
    this.onUserChoiceChanged,
  });

  final Function(int sortingField, bool sortAscending, int selectedItemIndex)? onUserChoiceChanged;
  final List<Field> columnsToInclude;
  final List<Transaction> Function() getList;
  final SelectionController selectionController;
  final bool sortAscending;
  final int sortFieldIndex;

  @override
  State<ListViewTransactions> createState() => _ListViewTransactionsState();
}

class _ListViewTransactionsState extends State<ListViewTransactions> {
  late bool _sortAscending = widget.sortAscending;
  late int _sortBy = widget.sortFieldIndex;

  @override
  Widget build(final BuildContext context) {
    // get the list sorted
    final List<Transaction> transactions = widget.getList();
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions'));
    }

    MoneyObjects.sortList(
      transactions,
      widget.columnsToInclude,
      _sortBy,
      _sortAscending,
    );

    return AdaptiveListColumnsOrRowsSingleSelection(
      list: transactions,
      fieldDefinitions: widget.columnsToInclude,
      filters: FieldFilters(),
      sortByFieldIndex: _sortBy,
      sortAscending: _sortAscending,
      selectedId: widget.selectionController.firstSelectedId,
      // Field & Columns
      displayAsColumns: true,
      backgoundColorForHeaderFooter: Colors.transparent,
      onSelectionChanged: (int uniqueId) {
        widget.onUserChoiceChanged?.call(_sortBy, _sortAscending, uniqueId);
        widget.selectionController.select(uniqueId);
      },
      onColumnHeaderTap: (final int index) {
        setState(() {
          if (_sortBy == index) {
            // same column tap/click again, change the sort order
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = index;
          }
          widget.onUserChoiceChanged?.call(_sortBy, _sortAscending, widget.selectionController.firstSelectedId);
        });
      },
      onItemLongPress: (final BuildContext context2, final int uniqueId) {
        final Transaction instance = findObjectById(uniqueId, transactions) as Transaction;
        showTransactionAndActions(
          context: context2,
          transaction: instance,
        ).then((value) {
          widget.selectionController.select(uniqueId);
          widget.onUserChoiceChanged?.call(_sortBy, _sortAscending, widget.selectionController.firstSelectedId);
        });
      },
    );
  }
}

List<Transaction> getTransactions({bool Function(Transaction)? filter}) {
  filter ??= (Transaction transaction) => true;

  final List<Transaction> list =
      Data().transactions.iterableList().where((final Transaction transaction) => filter!(transaction)).toList();

  list.sort((a, b) => Transaction.sortByDateTime(a, b, true));

  double runningBalance = 0.0;
  for (Transaction transaction in list) {
    runningBalance += transaction.amount.value.toDouble();
    transaction.balance = runningBalance;
  }
  return list;
}
