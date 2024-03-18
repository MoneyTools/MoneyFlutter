import 'package:flutter/material.dart';
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
    required this.onActionDelete,
  });

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          border: Border(
            left: BorderSide(color: Theme.of(context).colorScheme.outline),
            top: BorderSide(color: Theme.of(context).colorScheme.outline),
            right: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
      child: ValueListenableBuilder<List<int>>(
        valueListenable: selectedItems,
        builder: (final BuildContext context, final List<int> list, final _) {
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
                currencyChoices: getCurrencyChoices(subPanelSelected, list),
                currencySelected: currencySelected,
                currentSelectionChanged: currencySelectionChanged,

                // Actions
                onActionAddTransaction:
                    (subPanelSelected == SubViews.transactions) && isExpanded ? onActionAddTransaction : null,
                onActionDelete: subPanelSelected == SubViews.details && list.isNotEmpty ? onActionDelete : null,
              ),
              if (isExpanded) Expanded(child: subPanelContent(subPanelSelected, list)),
            ],
          );
        },
      ),
    );
  }
}
