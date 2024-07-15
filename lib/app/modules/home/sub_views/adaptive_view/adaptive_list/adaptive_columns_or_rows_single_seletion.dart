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

  final Widget? Function(Field field)? getColumnFooterWidget;
  final Function(int uniqueId)? onSelectionChanged;
  final Function(int columnHeaderIndex)? onColumnHeaderTap;
  final Function(Field field)? onColumnHeaderLongPress;
  final Function(BuildContext context, int itemId)? onItemTap;
  final Function(BuildContext context, int itemId)? onItemLongPress;
  final Color? backgoundColorForHeaderFooter;
  final FieldDefinitions fieldDefinitions;
  final FieldFilters filters;
  final List<MoneyObject> list;
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
  final AccumulatorList<Field, String> accumaltorListOfText = AccumulatorList<Field, String>();
  final AccumulatorDateRange<Field> accumulatorDateRange = AccumulatorDateRange<Field>();
  final AccumulatorAverage<Field> accumulatorForAverage = AccumulatorAverage<Field>();
  final AccumulatorSum<Field, double> accumulatorSumAmount = AccumulatorSum<Field, double>();
  final AccumulatorSum<Field, double> accumulatorSumNumber = AccumulatorSum<Field, double>();
  late final selectionCollectionOfOnlyOneItem = ValueNotifier<List<int>>([widget.selectedId]);

  @override
  Widget build(BuildContext context) {
    footerAccumulators();

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

  void footerAccumulators() {
    accumulatorSumAmount.clear();
    accumulatorSumNumber.clear();
    accumulatorForAverage.clear();
    accumulatorDateRange.clear();
    accumaltorListOfText.clear();

    for (final item in widget.list) {
      for (final field in widget.fieldDefinitions) {
        switch (field.type) {
          case FieldType.text:
            accumaltorListOfText.cumulate(field, field.getValueForDisplay(item));

          case FieldType.date:
            accumulatorDateRange.cumulate(field, field.getValueForDisplay(item));

          case FieldType.amount:
            final value = field.getValueForDisplay(item).toDouble();
            accumulatorSumAmount.cumulate(field, value);
            if (field.footer == FooterType.average) {
              accumulatorForAverage.cumulate(field, value);
            }

          case FieldType.widget:
            if (field.getValueForReading != null) {
              accumaltorListOfText.cumulate(field, field.getValueForReading?.call(item)!.toString() ?? '');
            }

          case FieldType.numeric:
          case FieldType.amountShorthand:
          case FieldType.numericShorthand:
          case FieldType.quantity:
            final value = field.getValueForDisplay(item);
            accumulatorSumNumber.cumulate(field, value);
            if (field.footer == FooterType.average) {
              accumulatorForAverage.cumulate(field, value);
            }
          default:
            break;
        }
      }
    }
  }

  /// Use the field FooterType to decide how to render the bottom button of each columns
  Widget getColumnFooterWidget(final Field field) {
    switch (field.footer) {
      case FooterType.range:
        if (accumulatorDateRange.containsKey(field)) {
          return getFooterForDateRange(accumulatorDateRange.getValue(field)!);
        }
      case FooterType.count:
        List<String> list = [];

        if (accumaltorListOfText.containsKey(field)) {
          list = accumaltorListOfText.getList(field);
        } else {
          if (accumulatorSumNumber.containsKey(field)) {
            list = accumulatorSumNumber.getValue(field);
          }
        }

        final int count = list.length;
        if (count > 0) {
          String samples = '';
          if (count > 10) {
            samples = '${list.take(10).join('\n')}\n...';
          } else {
            samples = list.join('\n');
          }
          return Tooltip(
            message: '$count items\n$samples',
            child: getFooterForInt(count, applyColorBasedOnValue: false),
          );
        }

      case FooterType.sum:
        Widget? widget;
        if (accumulatorSumAmount.containsKey(field)) {
          widget = getFooterForAmount(accumulatorSumAmount.getValue(field));
        } else {
          if (accumulatorSumNumber.containsKey(field)) {
            widget = getFooterForInt(accumulatorSumNumber.getValue(field));
          }
        }
        return Tooltip(
          message: 'Sum.',
          child: widget,
        );

      case FooterType.average:
        if (accumulatorForAverage.containsKey(field)) {
          final RunningAverage range = accumulatorForAverage.getValue(field)!;
          final double value = range.getAverage();
          Widget widget = field.type == FieldType.amount
              ? getFooterForAmount(value, prefix: 'Av ')
              : getFooterForInt(value, prefix: 'Av ');
          return Tooltip(
            message: field.type == FieldType.amount ? range.descriptionAsMoney : range.descriptionAsInt,
            child: widget,
          );
        }

      case FooterType.none:
      default:
        return const SizedBox();
    }
    return const SizedBox();
  }
}
