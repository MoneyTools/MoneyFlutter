import 'package:flutter/material.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/widgets/picker_edit_box.dart';
import 'package:money/data/models/money_objects/investments/investment_types.dart';

export 'package:flutter/material.dart';
export 'package:money/data/models/money_objects/investments/investment_types.dart';

Widget pickerSecurityType({
  required final SecurityType itemSelected,
  required final void Function(SecurityType?) onSelected,
}) {
  List<String> options = enumToStringList(SecurityType.values);

  return PickerEditBox(
    title: 'Type',
    items: options,
    initialValue: itemSelected.name,
    onChanged: (String newSelection) {
      final SecurityType found = SecurityType.values.byName(newSelection);
      onSelected(found);
    },
  );
}
