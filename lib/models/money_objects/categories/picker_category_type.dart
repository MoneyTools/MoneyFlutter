import 'package:flutter/material.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/widgets/picker_edit_box.dart';

Widget pickerCategoryType({
  required final CategoryType itemSelected,
  required final Function(CategoryType) onSelected,
}) {
  return PickerEditBox(
    title: 'Category',
    items: Category.getCategoryTypes(),
    initialValue: Category.getTextFromType(itemSelected),
    onChanged: (String newSelection) {
      onSelected(Category.getCategoryTypeFromName(newSelection));
    },
  );
}
