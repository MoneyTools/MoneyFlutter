import 'package:flutter/material.dart';

class BottomPanel extends StatelessWidget {
  final Widget? details;
  final bool isExpanded;
  final Function onExpanded;

  const BottomPanel({super.key, this.details, required this.isExpanded, required this.onExpanded});

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
      if (details != null) {
        itemsToRender.add(Padding(padding: const EdgeInsets.all(20), child: details!));
      }
    }

    return SizedBox(height: isExpanded ? 400 : 50, child: Column(children: itemsToRender));
  }

  getRowOfTabs() {
    return Row(
      children: [TextButton(onPressed: onClickCharts, child: const Text('Chart')), TextButton(onPressed: onClickDetails, child: const Text('Details'))],
    );
  }

  onClickDetails() {}

  onClickCharts() {}
}
