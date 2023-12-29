import 'package:flutter/material.dart';

class BottomPanel extends StatelessWidget {
  final bool isExpanded;
  final Function onExpanded;
  final List<int> selectedItems;
  final Object? subViewSelectedItem;
  final num selectedTabId;
  final Function onTabActivated;
  final Widget Function(num, List<int>) getBottomContentToRender;

  const BottomPanel({
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
    final List<Widget> itemsToRender = <Widget>[const Divider(thickness: 1, height: 1)];

    itemsToRender.add(Row(children: <Widget>[
      Expanded(child: getRowOfTabs()),
      IconButton(
          onPressed: () {
            onExpanded(!isExpanded);
          },
          icon: Icon(isExpanded ? Icons.expand_more : Icons.expand_less))
    ]));

    if (isExpanded) {
      final Widget widgetToRender = getBottomContentToRender(selectedTabId, selectedItems);
      itemsToRender.add(Expanded(child: Padding(padding: const EdgeInsets.all(20), child: widgetToRender)));
    }

    return SizedBox(height: isExpanded ? 400 : 50, child: Column(children: itemsToRender));
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
