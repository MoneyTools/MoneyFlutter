import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/widgets/details_panel/details_panel_header.dart';

enum SubViews {
  details,
  chart,
  transactions,
}

class DetailsPanel extends StatelessWidget {
  final bool isExpanded;
  final Function onExpanded;
  final ValueNotifier<List<int>> selectedItems;

  // SubViews [Details] [Chart] [Transactions]
  final SubViews subPanelSelected;
  final Function(SubViews) subPanelSelectionChanged;
  final Widget Function(SubViews, List<int>) subPanelContent;

  // Currency selection
  final int currencySelected;
  final List<String> Function(SubViews, List<int>) getCurrencyChoices;
  final Function(int) currencySelectionChanged;

  // Actions
  final Function? onActionAddTransaction;
  final Function? onActionEdit;
  final Function? onActionDelete;

  /// Constructor
  const DetailsPanel({
    super.key,
    required this.isExpanded,
    required this.onExpanded,
    required this.selectedItems,

    // sub-views
    required this.subPanelSelected,
    required this.subPanelSelectionChanged,
    required this.subPanelContent,

    // Currency
    required this.getCurrencyChoices,
    required this.currencySelected,
    required this.currencySelectionChanged,

    // Actions
    required this.onActionAddTransaction,
    required this.onActionEdit,
    required this.onActionDelete,
  });

  @override
  Widget build(final BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: getColorTheme(context).surfaceVariant,
          border: Border(
            left: BorderSide(color: getColorTheme(context).outline),
            top: BorderSide(color: getColorTheme(context).outline),
            right: BorderSide(color: getColorTheme(context).outline),
          ),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
      child: ValueListenableBuilder<List<int>>(
        valueListenable: selectedItems,
        builder: (final BuildContext context, final List<int> listOfSelectedItemIndex, final _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              DetailsPanelHeader(
                isExpanded: isExpanded,
                onExpanded: onExpanded,

                // SubPanel
                subViewSelected: subPanelSelected,
                subViewSelectionChanged: subPanelSelectionChanged,

                // Currency
                currencyChoices: getCurrencyChoices(subPanelSelected, listOfSelectedItemIndex),
                currencySelected: currencySelected,
                currentSelectionChanged: currencySelectionChanged,

                // Actions
                onActionAddTransaction:
                    (subPanelSelected == SubViews.transactions) && isExpanded ? onActionAddTransaction : null,
                onActionEdit:
                    subPanelSelected == SubViews.details && listOfSelectedItemIndex.isNotEmpty ? onActionEdit : null,
                onActionDelete:
                    subPanelSelected == SubViews.details && listOfSelectedItemIndex.isNotEmpty ? onActionDelete : null,
              ),
              if (isExpanded) Expanded(child: subPanelContent(subPanelSelected, listOfSelectedItemIndex)),
            ],
          );
        },
      ),
    );
  }
}
