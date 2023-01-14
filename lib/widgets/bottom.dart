import 'package:flutter/material.dart';

class BottomPanel extends StatelessWidget {
  final bool isExpanded;
  final Function onExpanded;
  final List<num> selectedItems;
  final Object? subViewSelectedItem;
  final num selectedTabId;
  final Function onTabActivated;
  final Function(num, Object?) getBottomContentToRender;

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
  Widget build(BuildContext context) {
    List<Widget> itemsToRender = [const Divider(thickness: 1, height: 1)];

    itemsToRender.add(Row(children: [
      Expanded(child: getRowOfTabs()),
      IconButton(
          onPressed: () {
            onExpanded(!isExpanded);
          },
          icon: Icon(isExpanded ? Icons.expand_more : Icons.expand_less))
    ]));

    if (isExpanded) {
      Widget widgetToRender = getBottomContentToRender(selectedTabId, selectedItems);
      itemsToRender.add(Expanded(child: Padding(padding: const EdgeInsets.all(20), child: widgetToRender)));
    }

    return SizedBox(height: isExpanded ? 400 : 50, child: Column(children: itemsToRender));
  }

  getRowOfTabs() {
    return Row(
      children: [
        getTabButton(0, "Details"),
        getTabButton(1, "Chart"),
        getTabButton(2, "Transactions"),
      ],
    );
  }

  getTabButton(num id, String text) {
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
