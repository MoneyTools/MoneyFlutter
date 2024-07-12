import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/info_panel/info_panel_views_enum.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';

class InfoPanelHeader extends StatelessWidget {
  /// Constructor
  const InfoPanelHeader({
    required this.isExpanded,
    required this.onExpanded, // SubView
    required this.subViewSelected,
    required this.subViewSelectionChanged, // Currency
    required this.currencyChoices,
    required this.currencySelected,
    required this.currentSelectionChanged, // Actions
    required this.actionButtons,
    super.key,
  });

  final int currencySelected;
  final Function currentSelectionChanged;
  final bool isExpanded;
  final Function onExpanded;
  final Function(InfoPanelSubViewEnum) subViewSelectionChanged;

  // Actions
  final List<Widget> Function(bool) actionButtons;

  // Currency
  final List<String> currencyChoices;

  // SubView
  final InfoPanelSubViewEnum subViewSelected;

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(
      builder: (
        final BuildContext context,
        final BoxConstraints constraints,
      ) {
        return InkWell(
          onTap: () {
            onExpanded(!isExpanded);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildExpando(),
                _buildViewSelections(constraints),
                const Spacer(),
                IntrinsicWidth(child: Row(children: actionButtons(true))),
                gapMedium(),
                _buildCurrencySelections(constraints),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencySelections(final BoxConstraints constraints) {
    final bool smallDevice = constraints.maxWidth < 500;

    // this feature is only valid for SubView [Chart|Transaction]
    if (currencyChoices.isEmpty) {
      return const SizedBox();
    }

    if (currencyChoices.length == 1) {
      return Currency.buildCurrencyWidget(currencyChoices[0]);
    }

    return SegmentedButton<int>(
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      ),
      showSelectedIcon: !smallDevice,
      segments: <ButtonSegment<int>>[
        ButtonSegment<int>(
          value: 0,
          label: smallDevice ? Text(currencyChoices[0]) : Currency.buildCurrencyWidget(currencyChoices[0]),
        ),
        ButtonSegment<int>(
          value: 1,
          label: smallDevice ? Text(currencyChoices[1]) : Currency.buildCurrencyWidget(currencyChoices[1]),
        ),
      ],
      selected: <int>{currencySelected},
      onSelectionChanged: (final Set<int> newSelection) {
        currentSelectionChanged(newSelection.first);
      },
    );
  }

  Widget _buildExpando() {
    return IconButton(
      onPressed: () {
        onExpanded(!isExpanded);
      },
      icon: Icon(isExpanded ? Icons.expand_more : Icons.expand_less),
      tooltip: 'Expand/Collapse panel',
    );
  }

  Widget _buildViewSelections(final BoxConstraints constraints) {
    final bool smallDevice = constraints.maxWidth < 700;

    return SegmentedButton<int>(
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      ),
      showSelectedIcon: constraints.maxWidth > 1000,
      segments: <ButtonSegment<int>>[
        ButtonSegment<int>(
          value: 0,
          label: smallDevice ? null : const Text('Details'),
          icon: const Icon(Icons.info_outline),
        ),
        ButtonSegment<int>(
          value: 1,
          label: smallDevice ? null : const Text('Chart'),
          icon: const Icon(Icons.bar_chart),
        ),
        ButtonSegment<int>(
          value: 2,
          label: smallDevice ? null : const Text('Transactions'),
          icon: const Icon(Icons.calendar_view_day),
        ),
      ],
      selected: <int>{subViewSelected.index},
      onSelectionChanged: (final Set<int> newSelection) {
        if (!isExpanded) {
          onExpanded(true);
        }
        subViewSelectionChanged(
          InfoPanelSubViewEnum.values[newSelection.first],
        );
      },
    );
  }
}
