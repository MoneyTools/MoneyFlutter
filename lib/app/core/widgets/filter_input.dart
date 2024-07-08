import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';

class FilterInput extends StatelessWidget {
  FilterInput({
    super.key,
    required this.hintText,
    required this.initialValue,
    required this.onChanged,
    required this.autoSubmitAfterSeconds,
  });
  final String hintText;
  final String initialValue;
  final int autoSubmitAfterSeconds;
  final Function(String) onChanged;
  late final Debouncer _debouncerForFilterText = Debouncer(Duration(seconds: autoSubmitAfterSeconds));

  @override
  Widget build(final BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        prefixIcon: const Icon(Icons.search),
        labelText: hintText,
        border: const OutlineInputBorder(),
      ),
      onFieldSubmitted: (String text) {
        onChanged(text);
      },
      onChanged: (final String text) {
        // optional auto submit
        if (autoSubmitAfterSeconds != -1) {
          _debouncerForFilterText.run(() {
            onChanged(text);
          });
        }
      },
    );
  }
}
