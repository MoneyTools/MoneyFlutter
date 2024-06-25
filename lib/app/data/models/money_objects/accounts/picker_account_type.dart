import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/picker_edit_box.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';

Widget pickerAccountType({
  required final AccountType itemSelected,
  required final Function(AccountType) onSelected,
}) {
  String selectedName = getTypeAsText(itemSelected);

  return PickerEditBox(
    title: 'Accounts',
    items: getAccountTypeAsText(),
    initialValue: selectedName,
    onChanged: (String newSelection) {
      onSelected(getAccountTypeFromText(newSelection)!);
    },
  );
}
