import 'package:flutter/material.dart';

class DetailsPanel extends StatelessWidget {
  final bool isExpanded;
  final Function onExpanded;
  final ValueNotifier<List<int>> selectedItems;
  final int selectedTabId;
  final Function onTabActivated;
  final Widget Function(int, List<int>) getDetailPanelContent;

  const DetailsPanel({
    super.key,
    required this.selectedItems,
    required this.selectedTabId,
    required this.isExpanded,
    required this.onExpanded,
    required this.onTabActivated,
    required this.getDetailPanelContent,
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
      child: LayoutBuilder(builder: (
        final BuildContext context,
        final BoxConstraints constraints,
      ) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildHeaderWithTabsAndExpando(context, constraints),
            if (isExpanded) _buildContent(),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderWithTabsAndExpando(
    final BuildContext context,
    final BoxConstraints constraints,
  ) {
    final Widget expando = IconButton(
        onPressed: () {
          onExpanded(!isExpanded);
        },
        icon: Icon(isExpanded ? Icons.expand_more : Icons.expand_less));

    return InkWell(
      onTap: () {
        if (isExpanded == false) {
          onExpanded(true);
        }
      },
      child: Row(children: <Widget>[
        expando,
        const Spacer(),
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
        const Spacer(),
        // Expando
        expando,
      ]),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: ValueListenableBuilder<List<int>>(
        valueListenable: selectedItems,
        builder: (final BuildContext context, final List<int> list, final _) {
          return getDetailPanelContent(selectedTabId, list);
        },
      ),
    );
  }
}
