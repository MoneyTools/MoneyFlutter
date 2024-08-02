import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/models/money_objects/money_object.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_list.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/footer_accumulators.dart';

export 'package:flutter/material.dart';

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
  late final selectionCollectionOfOnlyOneItem = ValueNotifier<List<int>>([widget.selectedId]);

  final FooterAccumulators _footerAccumulators = FooterAccumulators();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        if (widget.displayAsColumns) {
          // only collect footer data if we are displaying columns
          footerAccumulators();
        }
        final theList = AdaptiveListColumnsOrRows(
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

        if (widget.displayAsColumns && constraints.maxWidth < 900) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1200,
              child: theList,
            ),
          );
        } else {
          return theList;
        }
      },
    );
  }

  void footerAccumulators() {
    _footerAccumulators.clear();

    for (final item in widget.list) {
      for (final field in widget.fieldDefinitions) {
        switch (field.type) {
          case FieldType.text:
            _footerAccumulators.accumaltorListOfText.cumulate(field, field.getValueForDisplay(item));

          case FieldType.date:
            _footerAccumulators.accumulatorDateRange.cumulate(field, field.getValueForDisplay(item));
          case FieldType.dateRange:
            if (field.value.min != null) {
              _footerAccumulators.accumulatorDateRange.cumulate(field, field.value.min);
            }
            if (field.value.max != null) {
              _footerAccumulators.accumulatorDateRange.cumulate(field, field.value.max);
            }

          case FieldType.amount:
            final value = field.getValueForDisplay(item).toDouble();
            _footerAccumulators.accumulatorSumAmount.cumulate(field, value);
            if (field.footer == FooterType.average) {
              _footerAccumulators.accumulatorForAverage.cumulate(field, value);
            }

          case FieldType.widget:
            if (field.getValueForReading != null) {
              _footerAccumulators.accumaltorListOfText
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
  Widget getColumnFooterWidget(final Field field) {
    return _footerAccumulators.buildWidget(field);
  }
}
