import 'package:flutter/material.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/models/money_objects/splits/money_split.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_view.dart';

// Export
export 'package:money/app/data/models/money_objects/splits/splits.dart';

class ListViewTransactionSplits extends StatefulWidget {
  final List<MoneySplit> Function() getList;
  final int defaultSortingField;

  const ListViewTransactionSplits({
    super.key,
    required this.getList,
    this.defaultSortingField = 0,
  });

  @override
  State<ListViewTransactionSplits> createState() => _ListViewTransactionSplitsState();
}

class _ListViewTransactionSplitsState extends State<ListViewTransactionSplits> {
  List<MoneySplit> rows = [];
  late int _sortBy = widget.defaultSortingField;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    rows = widget.getList();
    onSort();
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
              onSort();
            });
          },
        ),
        // Table list of rows
        Expanded(
          child: MyListView<MoneySplit>(
            fields: MoneySplit.fields,
            list: rows,
            selectedItemIds: ValueNotifier<List<int>>([]),
            onSelectionChanged: (int _) {},
          ),
        ),
      ],
    );
  }

  void onSort() {
    // final FieldDefinition<Split> fieldDefinition = _tableFields.definitions[_sortBy];
    // if (fieldDefinition.sort != null) {
    //   rows.sort(
    //     (final Split a, final Split b) {
    //       return fieldDefinition.sort!(a, b, _sortAscending);
    //     },
    //   );
    // }
  }
}

typedef FilterFunction = bool Function(Split);

bool defaultFilter(final Split element) {
  return true; // filter nothing
}
