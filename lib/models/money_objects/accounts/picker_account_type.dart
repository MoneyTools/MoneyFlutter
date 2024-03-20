import 'package:flutter/material.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/widgets/picker_edit_box.dart';

Widget pickerAccountType({
  required final AccountType itemSelected,
  required final Function(AccountType) onSelected,
}) {
  String selectedName = getTypeAsText(itemSelected);

  return PickerEditBox(
    options: getAccountTypeAsText(),
    initialValue: selectedName,
    onChanged: (String newSelection) {
      onSelected(getAccountTypeFromText(newSelection));
    },
  );
}
