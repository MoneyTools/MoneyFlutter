import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/picker_edit_box.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';
import 'package:money/app/data/storage/data/data.dart';

export 'package:money/app/data/models/money_objects/categories/category.dart';

Widget pickerCategory({
  required final Category? itemSelected,
  required final Function(Category?) onSelected,
}) {
  final List<String> options = Data().categories.getListSorted().map((element) => element.fieldName.value).toList();
  String selectedName = itemSelected == null ? '' : itemSelected.fieldName.value;

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
