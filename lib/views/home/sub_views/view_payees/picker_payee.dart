import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/widgets/picker_edit_box.dart';
import 'package:money/data/models/money_objects/payees/payee.dart';
import 'package:money/data/storage/data/data.dart';

Widget pickerPayee({
  required final Payee? itemSelected,
  required final void Function(Payee?) onSelected,
}) {
  final List<String> options =
      Data().payees
          .getListSorted()
          .map((Payee element) => element.fieldName.value)
          .toList();
  options.sort((String a, String b) => sortByString(a, b, true));

  final String selectedName =
      itemSelected == null ? '' : itemSelected.fieldName.value;

  return PickerEditBox(
    title: 'Payee',
    items: options,
    initialValue: selectedName,
    onChanged: (String newSelection) {
      final Payee? found = Data().payees.getByName(newSelection);
      if (found != null) {
        onSelected(found);
      }
    },
    onAddNew: (String newPayeeText) {
      final Payee found = Data().payees.getOrCreate(newPayeeText);
      onSelected(found);
    },
  );
}
