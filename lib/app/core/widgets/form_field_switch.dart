import 'package:flutter/material.dart';

InputDecoration getFormFieldDecoration({
  required final fieldName,
  required final bool isReadOnly,
}) {
  return InputDecoration(
    labelText: fieldName,
    contentPadding: isReadOnly ? const EdgeInsets.symmetric(horizontal: 12) : null,
    // some padding to match the Editable fields that have a border and padding
    border: isReadOnly ? null : const OutlineInputBorder(),
  );
}

class SwitchFormField extends FormField<bool> {
  SwitchFormField({
    required String title,
    required bool super.initialValue,
    required bool isReadOnly,
    required super.validator,
    required super.onSaved,
  }) : super(
          key: UniqueKey(),
          builder: (FormFieldState<bool> state) {
            return Switch(
              value: state.value!,
              onChanged: (value) {
                state.didChange(value);
                onSaved?.call(value);
              },
            );
          },
        );
}
