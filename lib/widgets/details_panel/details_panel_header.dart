import 'package:flutter/material.dart';
import 'package:money/models/money_objects/currencies/currency.dart';

class DetailsPanelHeader extends StatelessWidget {
  final bool isExpanded;
  final Function onExpanded;

  // SubView
  final int subViewSelected;
  final Function subViewSelectionChanged;

  // Currency
  final List<String> currencyChoices;
  final int currencySelected;
  final Function currentSelectionChanged;

  // Actions
  final Function? onActionAdd;
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
    this.onActionAdd,
    this.onActionDelete,
  });

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(
      builder: (
        final BuildContext context,
        final BoxConstraints constraints,
      ) {
        return Row(
          children: <Widget>[
            Expanded(child: _buildLeftSide()),
            _buildViewSelections(constraints),
            Expanded(child: _buildRightSide()),
          ],
        );
      },
    );
  }

  Widget _buildLeftSide() {
    final Widget buttonActionDelete = IconButton(
      onPressed: () {
        onActionDelete?.call();
      },
      icon: const Icon(Icons.delete),
      tooltip: 'Delete selected item',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildExpando(),
        const Spacer(),
        if (onActionDelete != null) buttonActionDelete,
        const Spacer(),
      ],
    );
  }

  Widget _buildViewSelections(final BoxConstraints constraints) {
    return SegmentedButton<int>(
      style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
      segments: <ButtonSegment<int>>[
        ButtonSegment<int>(
            value: 0,
            label: constraints.maxWidth < 600 ? null : const Text('Details'),
            icon: const Icon(Icons.info_outline)),
        ButtonSegment<int>(
          value: 1,
          label: constraints.maxWidth < 600 ? null : const Text('Chart'),
          icon: const Icon(Icons.bar_chart),
        ),
        ButtonSegment<int>(
          value: 2,
          label: constraints.maxWidth < 600 ? null : const Text('Transactions'),
          icon: const Icon(Icons.calendar_view_day),
        ),
      ],
      selected: <int>{subViewSelected},
      onSelectionChanged: (final Set<int> newSelection) {
        if (!isExpanded) {
          onExpanded(true);
        }
        subViewSelectionChanged(newSelection.first);
      },
    );
  }

  Widget _buildRightSide() {
    final Widget buttonActionAdd = IconButton(
      onPressed: () {
        onActionAdd?.call();
      },
      icon: const Icon(Icons.add),
      tooltip: 'Add new entry',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Spacer(),
        if (onActionAdd != null) buttonActionAdd,
        const Spacer(),
        _buildCurrencySelections(),
        const Spacer(),
        _buildExpando(),
      ],
    );
  }

  Widget _buildCurrencySelections() {
    // this feature is only valid for SubView [Chart|Transaction]
    if (currencyChoices.isEmpty) {
      return const SizedBox();
    }

    if (currencyChoices.length == 1) {
      return Currency.buildCurrencyWidget(currencyChoices[0]);
    }

    return SegmentedButton<int>(
      style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
      segments: <ButtonSegment<int>>[
        ButtonSegment<int>(
          value: 0,
          label: Currency.buildCurrencyWidget(currencyChoices[0]),
        ),
        ButtonSegment<int>(
          value: 1,
          label: Currency.buildCurrencyWidget(currencyChoices[1]),
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
}
