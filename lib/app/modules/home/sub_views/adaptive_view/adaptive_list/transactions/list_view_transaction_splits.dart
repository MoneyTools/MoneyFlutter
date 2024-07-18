import 'package:flutter/material.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/models/money_objects/splits/money_split.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_view.dart';

// Export
export 'package:money/app/data/models/money_objects/splits/splits.dart';

class ListViewTransactionSplits extends StatefulWidget {
  const ListViewTransactionSplits({
    required this.getList,
    super.key,
    this.defaultSortingField = 0,
  });

  final int defaultSortingField;
  final List<MoneySplit> Function() getList;

  @override
  State<ListViewTransactionSplits> createState() => _ListViewTransactionSplitsState();
}

class _ListViewTransactionSplitsState extends State<ListViewTransactionSplits> {
  List<MoneySplit> rows = [];

  bool _sortAscending = true;
  late int _sortBy = widget.defaultSortingField;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    rows = widget.getList();

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
            list: rows,
            selectedItemIds: ValueNotifier<List<int>>([]),
            onSelectionChanged: (int _) {},
          ),
        ),
      ],
    );
  }
}

typedef FilterFunction = bool Function(Split);

bool defaultFilter(final Split element) {
  return true; // filter nothing
}
