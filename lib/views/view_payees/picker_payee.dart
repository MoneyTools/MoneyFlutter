import 'package:flutter/material.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/widgets/picker_edit_box.dart';

Widget pickerForPayee({
  required final Payee? itemSelected,
  required final Function(Payee?) onSelected,
}) {
  final List<String> options = Data().payees.getListSorted().map((element) => element.name.value).toList();
  String selectedName = itemSelected == null ? '' : itemSelected.name.value;

  return PickerEditBox(
    options: options,
    initialValue: selectedName,
    onChanged: (String newSelection) {
      final Payee? found = Data().payees.getByName(newSelection);
      if (found != null) {
        onSelected(found);
      }
    },
  );
}
