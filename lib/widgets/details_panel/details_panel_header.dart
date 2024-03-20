import 'package:flutter/material.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/widgets/details_panel/details_panel.dart';
import 'package:money/widgets/gaps.dart';

class DetailsPanelHeader extends StatelessWidget {
  final bool isExpanded;
  final Function onExpanded;

  // SubView
  final SubViews subViewSelected;
  final Function(SubViews) subViewSelectionChanged;

  // Currency
  final List<String> currencyChoices;
  final int currencySelected;
  final Function currentSelectionChanged;

  // Actions
  final Function? onActionAddTransaction;
  final Function? onActionEdit;
  final Function? onActionDelete;

  /// Constructor
  const DetailsPanelHeader({
    super.key,
    required this.isExpanded,
    required this.onExpanded,

    // SubView
    required this.subViewSelected,
    required this.subViewSelectionChanged,

    // Currency
    required this.currencyChoices,
    required this.currencySelected,
    required this.currentSelectionChanged,

    // Actions
    this.onActionAddTransaction,
    this.onActionEdit,
    this.onActionDelete,
  });

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
                _buildAddButton(),
                const Spacer(),
                _buildDeleteButton(),
                gapMedium(),
                _buildCurrencySelections(constraints),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewSelections(final BoxConstraints constraints) {
    final bool smallDevice = constraints.maxWidth < 700;

    return SegmentedButton<int>(
      style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
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
        subViewSelectionChanged(SubViews.values[newSelection.first]);
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
      style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
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

  Widget _buildAddButton() {
    if (onActionAddTransaction == null) {
      return const SizedBox();
    }

    return IconButton(
      onPressed: () {
        onActionAddTransaction?.call();
      },
      icon: const Icon(Icons.add),
      tooltip: 'Add a new transaction',
    );
  }

  Widget _buildDeleteButton() {
    if (onActionDelete == null) {
      return const SizedBox();
    }

    return IconButton(
      onPressed: () {
        onActionDelete?.call();
      },
      icon: const Icon(Icons.delete),
      tooltip: 'Delete selected item',
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
}
