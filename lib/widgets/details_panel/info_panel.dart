import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/widgets/details_panel/info_panel_header.dart';
import 'package:money/widgets/details_panel/info_panel_views_enum.dart';

class InfoPanel extends StatelessWidget {
  final bool isExpanded;
  final Function onExpanded;
  final ValueNotifier<List<int>> selectedItems;

  // SubViews [Details] [Chart] [Transactions]
  final InfoPanelSubViewEnum subPanelSelected;
  final Function(InfoPanelSubViewEnum) subPanelSelectionChanged;
  final Widget Function(InfoPanelSubViewEnum, List<int>) subPanelContent;

  // Currency selection
  final int currencySelected;
  final List<String> Function(InfoPanelSubViewEnum, List<int>) getCurrencyChoices;
  final Function(int) currencySelectionChanged;

  // Actions
  final List<Widget> actionButtons;

  /// Constructor
  const InfoPanel({
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
    required this.actionButtons,
  });

  @override
  Widget build(final BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: getColorTheme(context).surfaceContainerHighest,
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
              InfoPanelHeader(
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
                actionButtons: actionButtons,
              ),
              if (isExpanded) Expanded(child: subPanelContent(subPanelSelected, listOfSelectedItemIndex)),
            ],
          );
        },
      ),
    );
  }
}
