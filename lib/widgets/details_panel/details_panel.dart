import 'package:flutter/material.dart';
import 'package:money/widgets/details_panel/details_panel_header.dart';

class DetailsPanel extends StatelessWidget {
  final bool isExpanded;
  final Function onExpanded;
  final ValueNotifier<List<int>> selectedItems;
  final int selectedTabId;
  final Function onTabActivated;
  final Widget Function(int, List<int>) getDetailPanelContent;
  final Function? onActionAdd;
  final Function? onActionDelete;

  /// Constructor
  const DetailsPanel({
    super.key,
    required this.selectedItems,
    required this.selectedTabId,
    required this.isExpanded,
    required this.onExpanded,
    required this.onTabActivated,
    required this.getDetailPanelContent,
    required this.onActionAdd,
    required this.onActionDelete,
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
        child: ValueListenableBuilder<List<int>>(
            valueListenable: selectedItems,
            builder: (final BuildContext context, final List<int> list, final _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  DetailsPanelHeader(
                    isExpanded: isExpanded,
                    onExpanded: onExpanded,
                    selectedTabId: selectedTabId,
                    onTabActivated: onTabActivated,
                    onActionAdd: onActionAdd,
                    onActionDelete: selectedTabId == 0 && list.isNotEmpty ? onActionDelete : null,
                  ),
                  if (isExpanded) Expanded(child: getDetailPanelContent(selectedTabId, list)),
                ],
              );
            }));
  }
}
