import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/money_widget.dart';
import 'package:money/data/models/fields/field_filter.dart';
import 'package:money/data/models/money_objects/splits/money_split.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/list_view.dart';
import 'package:money/views/home/sub_views/view_transactions/dialog_mutate_split.dart';

// Export
export 'package:money/data/models/money_objects/splits/splits.dart';

class ListViewTransactionSplits extends StatefulWidget {
  const ListViewTransactionSplits({
    super.key,
    this.defaultSortingField = 0,
    required this.transaction,
  });

  final int defaultSortingField;
  final Transaction transaction;

  @override
  State<ListViewTransactionSplits> createState() => _ListViewTransactionSplitsState();
}

class _ListViewTransactionSplitsState extends State<ListViewTransactionSplits> {
  bool _sortAscending = true;
  late int _sortBy = widget.defaultSortingField;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: <Widget>[
        // Table Header
        MyListItemHeader<MoneySplit>(
          columns: MoneySplit.fields.definitions,
          filterOn: FieldFilters(),
          sortByColumn: _sortBy,
          sortAscending: _sortAscending,
          onTap: (final int index) {
            setState(() {
              if (_sortBy == index) {
                // same column tap/click again, change the sort order
                _sortAscending = !_sortAscending;
              } else {
                _sortBy = index;
              }
            });
          },
        ),
        // Table list of rows
        Expanded(
          child: MyListView<MoneySplit>(
            fields: MoneySplit.fields.definitions,
            list: widget.transaction.splits,
            selectedItemIds: ValueNotifier<List<int>>([]),
            onSelectionChanged: (int _) {},
            onLongPress: (context2, index) {
              final MoneySplit instance = widget.transaction.splits[index];
              showSplitAndActions(
                context: context2,
                split: instance,
              );
            },
            scrollController: ScrollController(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // update
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Refresh list'),
                ],
              ),
            ),
            _buildTally(),
          ],
        ),
      ],
    );
  }

  double get amountDelta {
    return sumOfSplits - widget.transaction.fieldAmount.value.toDouble();
  }

  bool get isTotalMatching => amountDelta == 0;

  double get sumOfSplits {
    return widget.transaction.splits.fold(0.0, (sum, split) => sum + split.fieldAmount.value.toDouble());
  }

  Widget _buildTally() {
    if (isTotalMatching) {
      return Row(
        children: [
          Text('Amount is matching'),
          gapSmall(),
          MoneyWidget.fromDouble(sumOfSplits),
        ],
      );
    } else {
      return Row(
        children: [
          Text('Amount is off by'),
          gapSmall(),
          MoneyWidget.fromDouble(amountDelta),
        ],
      );
    }
  }
}

typedef FilterFunction = bool Function(Split);

bool defaultFilter(final Split element) {
  return true; // filter nothing
}
