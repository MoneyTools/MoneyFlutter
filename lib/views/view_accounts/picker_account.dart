import 'package:flutter/material.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/picker_edit_box.dart';

// Widget pickerAccount(
//   Account? selected,
//   final Function(Account?) onSelected,
// ) {
//   final list = Data().accounts.getOpenRealAccounts();
//   bool selectionFound = false;
//   final dropDownItems = list.map<DropdownMenuItem<Account>>((Account account) {
//     if (selected?.name.value == account.name.value) {
//       selectionFound = true;
//     }
//     return DropdownMenuItem<Account>(
//       value: account,
//       child: Text(Account.getName(account)),
//     );
//   }).toList();
//
//   if (!selectionFound) {
//     selected = list.first;
//   }
//
//   return DropdownButton<Account>(
//     value: selected,
//     onChanged: onSelected,
//     items: dropDownItems,
//   );
// }


Widget pickerAccount({
  required final Account? selected,
  required final Function(Account?) onSelected,
}) {
  final List<String> options = Data().accounts.getListSorted().map((element) => element.name.value).toList();

  String selectedName = selected == null ? '' : selected.name.value;

  return PickerEditBox(
    title: 'Account',
    options: options,
    initialValue: selectedName,
    onChanged: (String newSelection) {
      final Account? found = Data().accounts.getByName(newSelection);
      if (found != null) {
        onSelected(found);
      }
    },
  );
}
