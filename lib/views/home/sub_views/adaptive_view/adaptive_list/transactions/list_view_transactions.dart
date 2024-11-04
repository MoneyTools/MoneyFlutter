import 'dart:math';

import 'package:money/core/controller/list_controller.dart';
import 'package:money/core/controller/selection_controller.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/date_range_time_line.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/mini_timeline_daily.dart';
import 'package:money/data/models/fields/field_filter.dart';
import 'package:money/data/models/money_objects/transactions/transactions.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_single_selection.dart';
import 'package:money/views/home/sub_views/view_transactions/dialog_mutate_transaction.dart';

class ListViewTransactions extends StatefulWidget {
  const ListViewTransactions({
    super.key,
    required this.columnsToInclude,
    required this.getList,
    required this.listController,
    required this.selectionController,
    this.sortFieldIndex = 0,
    this.sortAscending = true,
    this.onUserChoiceChanged,
  });

  final Function(int sortingField, bool sortAscending, int selectedItemIndex)? onUserChoiceChanged;
  final List<Field> columnsToInclude;
  final List<Transaction> Function() getList;
  final ListController listController;
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
      listController: widget.listController,

      // Field & Columns
      displayAsColumns: true,
      backgroundColorForHeaderFooter: Colors.transparent,
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

List<Transaction> getTransactions({bool Function(Transaction)? filter, bool flattenSplits = false}) {
  filter ??= (Transaction transaction) => true;

  List<Transaction> list = [];

  if (flattenSplits) {
    // Flatten the splits
    list = Transactions.flatTransactions(Data().transactions.iterableList())
        .where((final Transaction transaction) => filter!(transaction))
        .toList();
  } else {
    // No flattening of splits
    list = Data().transactions.iterableList().where((final Transaction transaction) => filter!(transaction)).toList();
  }

  list.sort((a, b) => Transaction.sortByDateTime(a, b, true));

  double runningBalance = 0.0;
  for (Transaction transaction in list) {
    runningBalance += transaction.fieldAmount.value.toDouble();
    transaction.balance = runningBalance;
  }
  return list;
}

/// Widget to display a timeline chart of transactions.
///
/// This widget visualizes the sum of transactions over time, providing a graphical
/// representation of spending patterns. It uses a [MiniTimelineDaily] to display
/// daily sums and a [DateRangeTimeline] to show the overall date range.
///
/// [flatTransactions: A list of transactions, potentially with splits flattened.
Widget timeLineChartOfTransactionsWidget(final BuildContext context, final List<Transaction> flatTransactions) {
  // Handle empty transaction list
  if (flatTransactions.isEmpty) {
    return const Center(child: Text('No transactions'));
  }

  // Calculate the date range of all transactions
  final DateRange dateRange = DateRange();
  for (final t in flatTransactions) {
    dateRange.inflate(t.fieldDateTime.value);
  }

  // Calculate the maximum absolute transaction value for scaling the graph
  double maxValue = 0;
  final List<Pair<int, double>> sumByDays = Transactions.transactionSumByTime(flatTransactions);
  for (final pair in sumByDays) {
    maxValue = max(maxValue, pair.second.abs());
  }

  // Extract start and end years for the timeline
  final int yearStart = dateRange.min!.year;
  final int yearEnd = dateRange.max!.year;

  // Define styling for the graph
  final borderColor = getColorTheme(context).onSecondaryContainer.withOpacity(0.3);
  final TextStyle textStyle = getTextTheme(context).labelSmall!;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical axis labels
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(getAmountAsShorthandText(maxValue), style: textStyle),
                Text(
                  getAmountAsShorthandText(maxValue / 2),
                  style: textStyle,
                ),
                Text('0.00', style: textStyle),
              ],
            ),
          ),
          // Timeline chart and date range
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Daily transaction sum timeline
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: borderColor,
                          width: 1.0,
                        ),
                        bottom: BorderSide(
                          color: borderColor,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: MiniTimelineDaily(
                      offsetStartingDay: sumByDays.first.first,
                      yearStart: yearStart,
                      yearEnd: yearEnd,
                      values: sumByDays,
                      lineWidth: 3,
                    ),
                  ),
                ),
                gapMedium(),
                // Overall date range timeline
                DateRangeTimeline(
                  startDate: dateRange.min!,
                  endDate: dateRange.max!,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
