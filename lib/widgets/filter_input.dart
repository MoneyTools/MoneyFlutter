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
        prefixIcon: const Icon(Icons.search),
        labelText: hintText,
      ),
      onChanged: onChanged,
    );
  }
}
