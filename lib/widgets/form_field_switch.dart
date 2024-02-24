import 'package:flutter/material.dart';

class SwitchFormField extends FormField<bool> {
  SwitchFormField({
    required String title,
    required bool super.initialValue,
    required super.validator,
    required super.onSaved,
  }) : super(
          key: UniqueKey(),
          builder: (FormFieldState<bool> state) {
            return Column(
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
