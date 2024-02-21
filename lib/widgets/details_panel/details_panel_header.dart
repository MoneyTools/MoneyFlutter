import 'package:flutter/material.dart';
import 'package:money/models/money_objects/currencies/currency.dart';

class DetailsPanelHeader extends StatelessWidget {
  final bool isExpanded;
  final Function onExpanded;

  final String currency;

  final Function? onActionAdd;
  final Function? onActionDelete;

  final int selectedTabId;
  final Function onTabActivated;

  /// Constructor
  const DetailsPanelHeader({
    super.key,
    required this.isExpanded,
    required this.onExpanded,
    required this.selectedTabId,
    required this.onTabActivated,
    required this.currency,
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
            // List of tab buttons
            SegmentedButton<int>(
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
                selected: <int>{selectedTabId},
                onSelectionChanged: (final Set<int> newSelection) {
                  if (!isExpanded) {
                    onExpanded(true);
                  }
                  onTabActivated(newSelection.first);
                }),

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
        Currency.buildCurrencyWidget(currency),
        const Spacer(),
        _buildExpando(),
      ],
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
