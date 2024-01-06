import 'package:flutter/material.dart';

class DetailsPanel extends StatelessWidget {
  final bool isExpanded;
  final Function onExpanded;
  final ValueNotifier<List<int>> selectedItems;
  final Object? subViewSelectedItem;
  final int selectedTabId;
  final Function onTabActivated;
  final Widget Function(int, List<int>) getBottomContentToRender;

  const DetailsPanel({
    super.key,
    required this.selectedItems,
    required this.selectedTabId,
    required this.isExpanded,
    required this.onExpanded,
    required this.subViewSelectedItem,
    required this.onTabActivated,
    required this.getBottomContentToRender,
  });

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(builder: (
      final BuildContext context,
      final BoxConstraints constraints,
    ) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Divider(thickness: 1, height: 1),
          _buildHeaderWithTabsAndExpando(context, constraints),
          if (isExpanded) _buildContent(),
        ],
      );
    });
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

    return Row(children: <Widget>[
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
          selected: <int>{
            selectedTabId
          },
          onSelectionChanged: (final Set<int> newSelection) {
            if (!isExpanded) {
              onExpanded(true);
            }
            onTabActivated(newSelection.first);
          }),
      const Spacer(),
      // Expando
      expando,
    ]);
  }

  Widget _buildContent() {
    return Expanded(
      child: ValueListenableBuilder<List<int>>(
        valueListenable: selectedItems,
        builder: (final BuildContext context, final List<int> list, final _) {
          return getBottomContentToRender(selectedTabId, list);
        },
      ),
    );
  }
}
