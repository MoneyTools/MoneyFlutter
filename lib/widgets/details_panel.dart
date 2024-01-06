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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const Divider(thickness: 1, height: 1),
        _buildTabs(context),
        if (isExpanded) _buildContent(),
      ],
    );
  }

  Widget getTabButton(final BuildContext context, final num id, final String text) {
    final bool isSelected = selectedTabId == id;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.secondaryContainer : null,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(50),
          right: Radius.circular(50),
        ),
      ),
      child: TextButton(
          onPressed: () {
            // is use tap directly on one of the tabs
            if (!isExpanded) {
              onExpanded(true);
            }
            onTabActivated(id);
          },
          style: TextButton.styleFrom(
            textStyle: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
          child: Text(text)),
    );
  }

  Widget getRowOfTabs(final BuildContext context) {
    return Row(
      children: <Widget>[
        getTabButton(context, 0, 'Details'),
        getTabButton(context, 1, 'Chart'),
        getTabButton(context, 2, 'Transactions'),
      ],
    );
  }

  Widget _buildTabs(final BuildContext context) {
    return Row(children: <Widget>[
      // List of tab buttons
      Expanded(child: getRowOfTabs(context)),

      // Expando
      IconButton(
          onPressed: () {
            onExpanded(!isExpanded);
          },
          icon: Icon(isExpanded ? Icons.expand_more : Icons.expand_less))
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
