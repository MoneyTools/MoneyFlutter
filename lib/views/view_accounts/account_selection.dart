import 'package:flutter/material.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/storage/data/data.dart';

Widget buildAccountSelection(final Account? accountSelected, final Function(Account?) onAccountSelected) {
  final accounts = Data().accounts.getOpenAccounts();

  final dropDownItems = accounts.map<DropdownMenuItem<Account>>((Account account) {
    return DropdownMenuItem<Account>(
      value: account,
      child: Text(Account.getName(account)),
    );
  }).toList();

  return DropdownButton<Account>(
    value: accountSelected,
    onChanged: onAccountSelected,
    items: dropDownItems,
  );
}
