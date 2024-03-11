import 'package:flutter/material.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/storage/data/data.dart';

Widget buildAccountSelection(
  Account? accountSelected,
  final Function(Account?) onAccountSelected,
) {
  final accounts = Data().accounts.getOpenRealAccounts();
  bool accountSelectedIsPartOfTheList = false;
  final dropDownItems = accounts.map<DropdownMenuItem<Account>>((Account account) {
    if (accountSelected?.name.value == account.name.value) {
      accountSelectedIsPartOfTheList = true;
    }
    return DropdownMenuItem<Account>(
      value: account,
      child: Text(Account.getName(account)),
    );
  }).toList();

  if (!accountSelectedIsPartOfTheList) {
    accountSelected = accounts.first;
  }

  return DropdownButton<Account>(
    value: accountSelected,
    onChanged: onAccountSelected,
    items: dropDownItems,
  );
}
