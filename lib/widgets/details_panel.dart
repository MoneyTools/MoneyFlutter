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
      children: <Widget>[
        const Divider(thickness: 1, height: 1),
        Row(children: <Widget>[
          Expanded(child: getRowOfTabs()),
          IconButton(
              onPressed: () {
                onExpanded(!isExpanded);
              },
              icon: Icon(isExpanded ? Icons.expand_more : Icons.expand_less))
        ]),
        if (isExpanded)
          ValueListenableBuilder<List<int>>(
            valueListenable: selectedItems,
            builder: (final BuildContext context, final List<int> list, final _) {
              return Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: getBottomContentToRender(selectedTabId, list),
              ));
            },
          ),
      ],
    );
  }

  Widget getRowOfTabs() {
    return Row(
      children: <Widget>[
        getTabButton(0, 'Details'),
        getTabButton(1, 'Chart'),
        getTabButton(2, 'Transactions'),
      ],
    );
  }

  Widget getTabButton(final num id, final String text) {
    return TextButton(
        onPressed: () {
          if (!isExpanded) {
            onExpanded(true);
          }

          onTabActivated(id);
        },
        style: TextButton.styleFrom(
          textStyle: TextStyle(fontWeight: selectedTabId == id ? FontWeight.bold : FontWeight.normal),
        ),
        child: Text(text));
  }
}
