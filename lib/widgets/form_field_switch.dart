import 'package:flutter/material.dart';

getFormFieldDecoration({required final fieldName, required final bool isReadOnly}) {
  return InputDecoration(
    labelText: fieldName,
    border: isReadOnly ? InputBorder.none : null,
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
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Switch(
                  value: state.value!,
                  onChanged: (value) {
                    state.didChange(value);
                    onSaved?.call(value);
                  },
                ),
                const Divider(
                  color: Colors.grey,
                ),
              ],
            );
          },
        );
}
