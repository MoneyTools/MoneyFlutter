import 'package:flutter/material.dart';
import 'package:money/models/money_objects/splits/split.dart';
import 'package:money/widgets/list_view/list_item_header.dart';
import 'package:money/widgets/list_view/list_view.dart';

// Export
export 'package:money/models/money_objects/splits/splits.dart';

class ListViewTransactionSplits extends StatefulWidget {
  final List<Split> Function() getList;
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
  final Fields<Split> _tableFields = Fields<Split>(definitions: <Field<Split, dynamic>>[]);
  late final List<Split> rows;
  late int _sortBy = widget.defaultSortingField;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    rows = widget.getList();
    onSort();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: <Widget>[
        // Table Header
        MyListItemHeader<Split>(
          columns: _tableFields,
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
          child: MyTableView<Split>(
            fields: _tableFields,
            list: rows,
            selectedItems: ValueNotifier<List<int>>(<int>[]),
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

  SortIndicator getSortIndicated(final int columnNumber) {
    if (columnNumber == _sortBy) {
      return _sortAscending ? SortIndicator.sortAscending : SortIndicator.sortDescending;
    }
    return SortIndicator.none;
  }
}

typedef FilterFunction = bool Function(Split);

bool defaultFilter(final Split element) {
  return true; // filter nothing
}
