import 'package:flutter/material.dart';

class FilterInput extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;

  const FilterInput({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(final BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        prefixIcon: const Icon(Icons.search),
        labelText: hintText,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
