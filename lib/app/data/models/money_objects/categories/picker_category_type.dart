import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/picker_edit_box.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';

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
