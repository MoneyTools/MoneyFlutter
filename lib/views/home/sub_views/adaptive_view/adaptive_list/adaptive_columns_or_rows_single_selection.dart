import 'package:money/core/controller/list_controller.dart';
import 'package:money/data/models/fields/field_filters.dart';
import 'package:money/data/models/money_objects/money_object.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_list.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/footer_accumulators.dart';

export 'package:flutter/material.dart';

class AdaptiveListColumnsOrRowsSingleSelection extends StatefulWidget {
  const AdaptiveListColumnsOrRowsSingleSelection({
    super.key,
    required this.list,
    required this.fieldDefinitions,
    required this.filters,
    required this.selectedId,
    required this.displayAsColumns,
    required this.listController,
    this.sortByFieldIndex = 0,
    this.sortAscending = true,
    this.onSelectionChanged,
    this.onContextMenu,
    this.onColumnHeaderTap,
    this.onColumnHeaderLongPress,
    this.onItemTap,
    this.onItemLongPress,
    this.getColumnFooterWidget,
    this.backgroundColorForHeaderFooter,
  });

  final Widget? Function(Field<dynamic> field)? getColumnFooterWidget;
  final void Function(int uniqueId)? onSelectionChanged;
  final void Function(int columnHeaderIndex)? onColumnHeaderTap;
  final void Function(Field<dynamic> field)? onColumnHeaderLongPress;
  final void Function(BuildContext context, int itemId)? onItemTap;
  final void Function(BuildContext context, int itemId)? onItemLongPress;
  final Color? backgroundColorForHeaderFooter;
  final FieldDefinitions fieldDefinitions;
  final FieldFilters filters;
  final List<MoneyObject> list;
  final ListController listController;
  final Function? onContextMenu;
  final bool sortAscending;
  final int sortByFieldIndex;

  // Display as Card vs Columns
  final bool displayAsColumns;

  // Selections
  final int selectedId;

  @override
  State<AdaptiveListColumnsOrRowsSingleSelection> createState() => _AdaptiveListColumnsOrRowsSingleSelectionState();
}

class _AdaptiveListColumnsOrRowsSingleSelectionState extends State<AdaptiveListColumnsOrRowsSingleSelection> {
  late final selectionCollectionOfOnlyOneItem = ValueNotifier<List<int>>([widget.selectedId]);

  final FooterAccumulators _footerAccumulators = FooterAccumulators();

  @override
  Widget build(BuildContext context) {
    footerAccumulators();

    return AdaptiveListColumnsOrRows(
      list: widget.list,
      fieldDefinitions: widget.fieldDefinitions,
      filters: widget.filters,
      sortByFieldIndex: widget.sortByFieldIndex,
      sortAscending: widget.sortAscending,
      listController: widget.listController,
      isMultiSelectionOn: false,
      selectedItemsByUniqueId: selectionCollectionOfOnlyOneItem,
      onSelectionChanged: (final int selectedId) {
        widget.listController.bookmark = widget.listController.scrollController.offset;
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
      backgroundColorForHeaderFooter: widget.backgroundColorForHeaderFooter,
    );
  }

  void footerAccumulators() {
    _footerAccumulators.clear();

    for (final item in widget.list) {
      for (final field in widget.fieldDefinitions) {
        switch (field.type) {
          case FieldType.text:
            _footerAccumulators.accumulatorListOfText.cumulate(field, field.getValueForDisplay(item) as String);

          case FieldType.date:
            _footerAccumulators.accumulatorDateRange.cumulate(field, field.getValueForDisplay(item) as DateTime);
            
          case FieldType.dateRange:
            if (field.value.min != null) {
              _footerAccumulators.accumulatorDateRange.cumulate(field, field.value.min as DateTime);
            }
            if (field.value.max != null) {
              _footerAccumulators.accumulatorDateRange.cumulate(field, field.value.max as DateTime);
            }

          case FieldType.amount:
            final value = field.getValueForDisplay(item).toDouble();
            _footerAccumulators.accumulatorSumAmount.cumulate(field, value as double);
            if (field.footer == FooterType.average) {
              _footerAccumulators.accumulatorForAverage.cumulate(field, value as num);
            }

          case FieldType.widget:
            if (field.getValueForReading != null) {
              _footerAccumulators.accumulatorListOfText
                  .cumulate(field, field.getValueForReading?.call(item)!.toString() ?? '');
            }

          case FieldType.numeric:
          case FieldType.amountShorthand:
          case FieldType.numericShorthand:
          case FieldType.quantity:
            final dynamic value = field.getValueForDisplay(item);
            if (value is num) {
              _footerAccumulators.accumulatorSumNumber.cumulate(field, value.toDouble());
              if (field.footer == FooterType.average) {
                _footerAccumulators.accumulatorForAverage.cumulate(field, value);
              }
            }
          default:
            break;
        }
      }
    }
  }

  /// Use the field FooterType to decide how to render the bottom button of each columns
  Widget getColumnFooterWidget(final Field<dynamic> field) {
    return _footerAccumulators.buildWidget(field);
  }
}
