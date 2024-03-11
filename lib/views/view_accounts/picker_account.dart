import 'package:flutter/material.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/storage/data/data.dart';

Widget pickerAccount(
  Account? selected,
  final Function(Account?) onSelected,
) {
  final list = Data().accounts.getOpenRealAccounts();
  bool selectionFound = false;
  final dropDownItems = list.map<DropdownMenuItem<Account>>((Account account) {
    if (selected?.name.value == account.name.value) {
      selectionFound = true;
    }
    return DropdownMenuItem<Account>(
      value: account,
      child: Text(Account.getName(account)),
    );
  }).toList();

  if (!selectionFound) {
    selected = list.first;
  }

  return DropdownButton<Account>(
    value: selected,
    onChanged: onSelected,
    items: dropDownItems,
  );
}
