import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ColumnFilterPanel extends StatefulWidget {
  final List<ValueSelection> listOfUniqueInstances;

  const ColumnFilterPanel({
    super.key,
    required this.listOfUniqueInstances,
  });

  @override
  State<ColumnFilterPanel> createState() => _ColumnFilterPanelState();
}

class _ColumnFilterPanelState extends State<ColumnFilterPanel> {
  late List<ValueSelection> list;
  String filterText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Apply filter
    list = widget.listOfUniqueInstances
        .where((element) => filterText.isEmpty || element.name.toLowerCase().contains(filterText.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              filterText = value;
            });
          },
          decoration: const InputDecoration(
            labelText: 'filter',
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              bool setAs = !areAllItemSelected();
              for (final item in list) {
                item.isSelected = setAs;
              }
            });
          },
          child: Text(areAllItemSelected() ? 'Unselect all' : 'Select all'),
        ),
        SizedBox(
          height: 400,
          width: 300,
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (final BuildContext context, final int index) {
              return CheckboxListTile(
                title: Text(list[index].name),
                value: list[index].isSelected,
                onChanged: (final bool? isChecked) {
                  setState(() {
                    list[index].isSelected = isChecked == true;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// true if all items are selected
  bool areAllItemSelected() {
    return list.firstWhereOrNull((element) => element.isSelected == false) == null;
  }
}

class ValueSelection {
  String name;
  bool isSelected;

  ValueSelection({required this.name, required this.isSelected});
}
