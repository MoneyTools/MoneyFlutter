import 'package:money/core/widgets/widgets.dart';
import 'package:money/data/models/fields/field_filters.dart';
import 'package:money/data/models/money_objects/money_objects.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/adaptive_columns_or_rows_list.dart';
import 'package:money/views/home/sub_views/app_scaffold.dart';
import 'package:multi_split_view/multi_split_view.dart';

export 'package:flutter/material.dart';
export 'package:money/data/models/money_objects/money_objects.dart';

class AdaptiveViewWithList extends StatefulWidget {
  const AdaptiveViewWithList({
    super.key,
    required this.top,
    required this.list,
    required this.bottom,
    required this.fieldDefinitions,
    required this.filters,
    required this.selectedItemsByUniqueId,
    required this.onSelectionChanged,
    required this.isMultiSelectionOn,
    required this.listController,
    this.flexBottom = 1,
    this.sortByFieldIndex = 0,
    this.sortAscending = true,
    this.applySorting = true,
    this.onItemTap,
    this.onColumnHeaderTap,
    this.onColumnHeaderLongPress,
    this.getColumnFooterWidget,
  });

  final void Function(BuildContext, int)? onItemTap;
  final void Function(int columnHeaderIndex)? onColumnHeaderTap;
  final void Function(Field<dynamic> field)? onColumnHeaderLongPress;
  final Widget? Function(Field<dynamic> field)? getColumnFooterWidget;
  final bool applySorting;
  final Widget bottom;
  final FieldDefinitions fieldDefinitions;
  final FieldFilters filters;
  final int flexBottom;
  final bool isMultiSelectionOn;
  final List<MoneyObject> list;
  final ListController listController;
  final void Function(int) onSelectionChanged;
  final bool sortAscending;
  final int sortByFieldIndex;
  final Widget top;

  // Selection
  final ValueNotifier<List<int>> selectedItemsByUniqueId;

  @override
  State<AdaptiveViewWithList> createState() => _AdaptiveViewWithListState();
}

class _AdaptiveViewWithListState extends State<AdaptiveViewWithList> {
  final MultiSplitViewController _splitController = MultiSplitViewController();

  @override
  void initState() {
    super.initState();

    // final double hightOfTopPanel = widget.preferences.sidePanelDistance;
    _splitController.areas = <Area>[
      Area(flex: 1),
      Area(
        size: PreferenceController.to.sidePanelHeight.toDouble(),
        min: Constants.sidePanelHeightWhenCollapsed.toDouble(),
      ),
    ];
    // start listening to user change
    _splitController.addListener(_rebuild);
  }

  @override
  void dispose() {
    super.dispose();
    _splitController.removeListener(_rebuild);
  }

  void _rebuild() async {
    if (PreferenceController.to.isSidePanelExpanded) {
      // save the height of the side panel
      PreferenceController.to.sidePanelHeight =
          _splitController.areas[1].size!.toInt();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.applySorting) {
      MoneyObjects.sortList(
        widget.list,
        widget.fieldDefinitions,
        widget.sortByFieldIndex,
        widget.sortAscending,
      );
    }

    /// Adjusts the size and minimum height of the side panel based on whether it is expanded or collapsed.
    if (PreferenceController.to.isSidePanelExpanded) {
      _splitController.areas[1].min =
          Constants.sidePanelHeightWhenCollapsed + 100.0;
      _splitController.areas[1].size =
          PreferenceController.to.sidePanelHeight.toDouble();
    } else {
      _splitController.areas[1].min =
          Constants.sidePanelHeightWhenCollapsed + 0.0;
      _splitController.areas[1].size =
          Constants.sidePanelHeightWhenCollapsed.toDouble();
    }

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        // display as column for Medium & Large devices
        final bool displayAsColumns = context.isWidthSmall == false;

        return ValueListenableBuilder<List<int>>(
          valueListenable: widget.selectedItemsByUniqueId,
          builder: (
            final BuildContext context,
            final List<int> listOfSelectedItemIndex,
            final _,
          ) {
            return MultiSplitView(
              controller: _splitController,
              axis: Axis.vertical,
              dividerBuilder: (
                Axis axis,
                int index,
                bool resizable,
                bool dragging,
                bool highlighted,
                MultiSplitViewThemeData themeData,
              ) {
                return Center(
                  key: const Key('SidePanelSplitter'),
                  child: Container(color: Colors.grey, width: 40, height: 4),
                );
              },
              builder: (BuildContext context, Area area) {
                if (area.index == 0) {
                  return topSection(displayAsColumns);
                }
                return widget.bottom;
              },
            );
          },
        );
      },
    );
  }

  Widget topSection(final bool displayAsColumns) {
    return Column(
      children: <Widget>[
        // Top - Title area
        widget.top,

        // Middle
        Expanded(
          child: AdaptiveListColumnsOrRows(
            // List of Money Object instances
            list: widget.list,
            fieldDefinitions: widget.fieldDefinitions,
            filters: widget.filters,
            sortByFieldIndex: widget.sortByFieldIndex,
            sortAscending: widget.sortAscending,
            listController: widget.listController,

            // Display as Cards or Columns
            // On small device you can display rows a Cards instead of Columns
            displayAsColumns: displayAsColumns,
            onColumnHeaderTap: widget.onColumnHeaderTap,
            onColumnHeaderLongPress: widget.onColumnHeaderLongPress,
            getColumnFooterWidget: widget.getColumnFooterWidget,

            // Selection
            onItemTap: widget.onItemTap,
            selectedItemsByUniqueId: widget.selectedItemsByUniqueId,
            isMultiSelectionOn: widget.isMultiSelectionOn,
            onSelectionChanged: widget.onSelectionChanged,
            onContextMenu: () {},
          ),
        ),
      ],
    );
  }
}
