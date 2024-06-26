import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/accumulator.dart';
import 'package:money/app/core/widgets/columns/footer_widgets.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_list.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_view.dart';

class AdaptiveListColumnsOrRowsSingleSelection extends StatefulWidget {
  const AdaptiveListColumnsOrRowsSingleSelection({
    super.key,
    required this.list,
    required this.fieldDefinitions,
    required this.filters,
    required this.selectedId,
    required this.displayAsColumns,
    this.sortByFieldIndex = 0,
    this.sortAscending = true,
    this.onSelectionChanged,
    this.onContextMenu,
    this.onColumnHeaderTap,
    this.onColumnHeaderLongPress,
    this.onItemTap,
    this.onItemLongPress,
    this.getColumnFooterWidget,
    this.backgoundColorForHeaderFooter,
  });

  final List<MoneyObject> list;
  final FieldDefinitions fieldDefinitions;
  final FieldFilters filters;
  final int sortByFieldIndex;
  final bool sortAscending;
  final Widget? Function(Field field)? getColumnFooterWidget;

  // Selections
  final int selectedId;
  final Function(int uniqueId)? onSelectionChanged;
  final Function? onContextMenu;

  // Display as Card vs Columns
  final bool displayAsColumns;
  final Function(int columnHeaderIndex)? onColumnHeaderTap;
  final Function(Field field)? onColumnHeaderLongPress;
  final Function(BuildContext context, int itemId)? onItemTap;
  final Function(BuildContext context, int itemId)? onItemLongPress;
  final Color? backgoundColorForHeaderFooter;

  @override
  State<AdaptiveListColumnsOrRowsSingleSelection> createState() => _AdaptiveListColumnsOrRowsSingleSelectionState();
}

class _AdaptiveListColumnsOrRowsSingleSelectionState extends State<AdaptiveListColumnsOrRowsSingleSelection> {
  late final selectionCollectionOfOnlyOneItem = ValueNotifier<List<int>>([widget.selectedId]);
  final AccumulatorSum<Field, double> fieldsForAmounts = AccumulatorSum<Field, double>();
  final AccumulatorList<Field, String> fieldsForTexts = AccumulatorList<Field, String>();
  final AccumulatorDateRange<Field> fieldsForDates = AccumulatorDateRange<Field>();

  @override
  Widget build(BuildContext context) {
    cumulateSums();

    return AdaptiveListColumnsOrRows(
      list: widget.list,
      fieldDefinitions: widget.fieldDefinitions,
      filters: widget.filters,
      sortByFieldIndex: widget.sortByFieldIndex,
      sortAscending: widget.sortAscending,
      isMultiSelectionOn: false,
      selectedItemsByUniqueId: selectionCollectionOfOnlyOneItem,
      onSelectionChanged: (final int selectedId) {
        setState(() {
          selectionCollectionOfOnlyOneItem.value = [selectedId];
          widget.onSelectionChanged?.call(selectedId);
        });
      },
      onContextMenu: widget.onContextMenu,
      displayAsColumns: widget.displayAsColumns,
      onColumnHeaderTap: widget.onColumnHeaderTap,
      onColumnHeaderLongPress: widget.onColumnHeaderLongPress,
      onItemTap: widget.onItemTap,
      onItemLongPress: widget.onItemLongPress,
      getColumnFooterWidget: getColumnFooterWidget,
      backgoundColorForHeaderFooter: widget.backgoundColorForHeaderFooter,
    );
  }

  Widget getColumnFooterWidget(final Field field) {
    // field considered Balance are excluded from Tallies since they are themself a running tally
    if (field.name != 'Balance') {
      if (fieldsForTexts.containsKey(field)) {
        return getFooterForInt(fieldsForTexts.getList(field).length);
      }

      if (fieldsForAmounts.containsKey(field)) {
        return getFooterForAmount(fieldsForAmounts.getValue(field));
      }

      if (fieldsForDates.containsKey(field)) {
        return getFooterForDateRange(fieldsForDates.getValue(field)!);
      }
    }

    return const SizedBox();
  }

  void cumulateSums() {
    fieldsForTexts.clear();
    fieldsForAmounts.clear();
    fieldsForDates.clear();

    for (final item in widget.list) {
      for (final field in widget.fieldDefinitions) {
        final value = field.getValueForDisplay(item);

        switch (field.type) {
          case FieldType.text:
            fieldsForTexts.cumulate(field, value);

          case FieldType.date:
            fieldsForDates.cumulate(field, value);

          case FieldType.amount:
            fieldsForAmounts.cumulate(field, value.toDouble());
          case FieldType.numeric:
          case FieldType.amountShorthand:
          case FieldType.numericShorthand:
            fieldsForAmounts.cumulate(field, value);
          default:
            break;
        }
      }
    }
  }
}
