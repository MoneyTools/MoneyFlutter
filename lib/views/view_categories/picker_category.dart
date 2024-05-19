import 'package:flutter/material.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/widgets/picker_edit_box.dart';

export 'package:money/models/money_objects/categories/category.dart';

Widget pickerCategory({
  required final Category? itemSelected,
  required final Function(Category?) onSelected,
}) {
  final List<String> options = Data().categories.getListSorted().map((element) => element.name.value).toList();
  String selectedName = itemSelected == null ? '' : itemSelected.name.value;

  return PickerEditBox(
    title: 'Category',
    items: options,
    initialValue: selectedName,
    onChanged: (String newSelection) {
      final Category? found = Data().categories.getByName(newSelection);
      if (found != null) {
        onSelected(found);
      }
    },
  );
}
