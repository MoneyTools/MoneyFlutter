import 'package:flutter/material.dart';
import 'package:money/core/widgets/picker_edit_box.dart';
import 'package:money/data/models/money_objects/accounts/account.dart';
import 'package:money/data/storage/data/data.dart';

Widget pickerAccount({
  required final Account? selected,
  required final void Function(Account?) onSelected,
}) {
  final List<String> options = Data().accounts.getListSorted().map((element) => element.fieldName.value).toList();

  String selectedName = selected == null ? '' : selected.fieldName.value;

  return PickerEditBox(
    key: Constants.keyAccountPicker,
    title: 'Account',
    items: options,
    initialValue: selectedName,
    onChanged: (String newSelection) {
      final Account? found = Data().accounts.getByName(newSelection);
      if (found != null) {
        onSelected(found);
      }
    },
  );
}
