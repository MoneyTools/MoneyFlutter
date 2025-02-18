import 'package:flutter/material.dart';
import 'package:money/core/controller/theme_controller.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/my_segment.dart';
import 'package:money/core/widgets/side_panel/side_panel.dart';
import 'package:money/core/widgets/side_panel/side_panel_views_enum.dart';
import 'package:money/data/models/constants.dart';
import 'package:money/data/models/money_objects/currencies/currency.dart';

class SidePanelHeader extends StatelessWidget {
  /// Constructor
  const SidePanelHeader({
    required this.isExpanded,
    required this.onExpanded, // SubView
    required this.subViewSelected,
    required this.subViewSelectionChanged, // Currency
    required this.currencyChoices,
    required this.currencySelected,
    required this.currentSelectionChanged,
    required this.sidePanelSupport,
    required this.actionButtons,
    super.key,
  });

  final int currencySelected;
  final void Function(int) currentSelectionChanged;
  final bool isExpanded;
  final void Function(bool) onExpanded;
  final void Function(SidePanelSubViewEnum) subViewSelectionChanged;

  // Actions
  final List<Widget> Function(bool) actionButtons;

  // Currency
  final List<String> currencyChoices;

  // final List<SidePanelSubViewEnum> supportedSubViews;
  final SidePanelSupport sidePanelSupport;

  // SubView
  final SidePanelSubViewEnum subViewSelected;

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

    return mySegmentSelector(
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
      selectedId: currencySelected,
      onSelectionChanged: (final int newSelection) {
        currentSelectionChanged(newSelection);
      },
    );
  }

  Widget _buildExpando() {
    return IconButton(
      key: Constants.keySidePanelExpando,
      onPressed: () {
        onExpanded(!isExpanded);
      },
      icon: Icon(isExpanded ? Icons.expand_more : Icons.expand_less),
      tooltip: 'Expand/Collapse panel',
    );
  }

  Widget _buildViewSelections(final BoxConstraints constraints) {
    if (sidePanelSupport.supportedSubViews.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool smallDevice = ThemeController.to.isDeviceWidthSmall.value;

    return mySegmentSelector(
      segments: <ButtonSegment<int>>[
        if (sidePanelSupport.supportedSubViews.contains(SidePanelSubViewEnum.details))
          ButtonSegment<int>(
            value: 0,
            label: smallDevice ? null : const Text('Details'),
            icon: const Icon(Icons.info_outline),
          ),
        if (sidePanelSupport.supportedSubViews.contains(SidePanelSubViewEnum.chart))
          ButtonSegment<int>(
            value: 1,
            label: smallDevice ? null : const Text('Chart'),
            icon: const Icon(Icons.bar_chart),
          ),
        if (sidePanelSupport.supportedSubViews.contains(SidePanelSubViewEnum.transactions))
          ButtonSegment<int>(
            value: 2,
            label: smallDevice ? null : const Text('Transactions'),
            icon: const Icon(Icons.calendar_view_day),
          ),
        if (sidePanelSupport.supportedSubViews.contains(SidePanelSubViewEnum.pnl))
          ButtonSegment<int>(
            value: 3,
            label: smallDevice ? null : const Text('PnL'),
            icon: const Icon(Icons.calendar_view_day),
          ),
      ],
      selectedId: subViewSelected.index,
      onSelectionChanged: (final int newSelection) {
        if (!isExpanded) {
          onExpanded(true);
        }
        subViewSelectionChanged(
          SidePanelSubViewEnum.values[newSelection],
        );
      },
    );
  }
}
