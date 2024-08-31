import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/info_panel/info_panel_header.dart';
import 'package:money/app/core/widgets/info_panel/info_panel_views_enum.dart';
import 'package:money/app/data/models/constants.dart';

class InfoPanel extends StatelessWidget {
  /// Constructor
  const InfoPanel({
    required this.isExpanded,
    required this.onExpanded,
    required this.selectedItems, // sub-views
    required this.subPanelSelected,
    required this.subPanelSelectionChanged,
    required this.subPanelContent, // Currency
    required this.getCurrencyChoices,
    required this.currencySelected,
    required this.currencySelectionChanged, // Actions
    required this.getActionButtons,
    super.key,
  });

  final Function(int) currencySelectionChanged;
  final List<String> Function(InfoPanelSubViewEnum, List<int>) getCurrencyChoices;
  final bool isExpanded;
  final Function onExpanded;
  final ValueNotifier<List<int>> selectedItems;
  final Widget Function(InfoPanelSubViewEnum, List<int>) subPanelContent;
  final Function(InfoPanelSubViewEnum) subPanelSelectionChanged;

  // Currency selection
  final int currencySelected;

  // Actions
  final List<Widget> Function(bool) getActionButtons;

  // SubViews [Details] [Chart] [Transactions]
  final InfoPanelSubViewEnum subPanelSelected;

  @override
  Widget build(final BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SizeForPadding.medium),
      decoration: BoxDecoration(
        color: getColorTheme(context).surfaceContainerHighest,
        border: Border(
          left: BorderSide(color: getColorTheme(context).outline),
          top: BorderSide(color: getColorTheme(context).outline),
          right: BorderSide(color: getColorTheme(context).outline),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: ValueListenableBuilder<List<int>>(
        valueListenable: selectedItems,
        builder: (
          final BuildContext context,
          final List<int> listOfSelectedItemIndex,
          final _,
        ) {
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
                currencyChoices: getCurrencyChoices(
                  subPanelSelected,
                  listOfSelectedItemIndex,
                ),
                currencySelected: currencySelected,
                currentSelectionChanged: currencySelectionChanged,

                // Actions
                actionButtons: getActionButtons,
              ),
              if (isExpanded)
                Expanded(
                  child: subPanelContent(
                    subPanelSelected,
                    listOfSelectedItemIndex,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
