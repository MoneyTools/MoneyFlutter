import 'package:flutter/material.dart';
import 'package:money/core/widgets/picker_edit_box.dart';
import 'package:money/data/models/money_objects/categories/category.dart';
import 'package:money/data/storage/data/data.dart';

export 'package:money/data/models/money_objects/categories/category.dart';

Widget pickerCategory({
  Key? key,
  required final Category? itemSelected,
  required final Function(Category?) onSelected,
}) {
  String selectedName = itemSelected == null ? '' : itemSelected.fieldName.value;

  return PickerEditBox(
    key: key,
    title: 'Category',
    items: Data().categories.getCategoriesAsStrings(),
    initialValue: selectedName,
    onChanged: (String newSelection) {
      final Category? found = Data().categories.getByName(newSelection);
      if (found != null) {
        onSelected(found);
      }
    },
  );
}
