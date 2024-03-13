import 'package:flutter/material.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/widgets/combo_edit_box.dart';

Widget pickerCategory(
  Category? selected,
  final Function(Category?) onSelected,
) {
  final List<String> options = Data().categories.getListSorted().map((element) => element.name.value).toList();
  String selectedName = selected == null ? '' : selected.name.value;

  return ComboEditBox(
    options: options,
    initialValue: selectedName,
    onChanged: (String newSelection) {
      final Category? found = Data().categories.getByName(newSelection);
      if (found != null) {
        onSelected(found);
      }
    },
  );
}
