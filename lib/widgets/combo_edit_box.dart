import 'package:flutter/material.dart';

class ComboEditBox extends StatefulWidget {
  final List<String> options;
  final String? initialValue;
  final Function(String) onChanged;

  const ComboEditBox({
    super.key,
    required this.options,
    this.initialValue,
    required this.onChanged,
  });

  @override
  ComboEditBoxState createState() => ComboEditBoxState();
}

class ComboEditBoxState extends State<ComboEditBox> {
  String? _selectedValue;
  String _searchText = "";
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _textController.text = _selectedValue ?? "";
  }

  List<String> get filteredOptions =>
      widget.options.where((option) => option.toLowerCase().contains(_searchText.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
            onChanged: (value) {
              _searchText = value;
              setState(() {});
              widget.onChanged(value);
            },
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.arrow_drop_down),
          onSelected: (value) {
            setState(() {
              _selectedValue = value;
              _textController.text = value;
            });
            widget.onChanged(value);
          },
          itemBuilder: (context) => filteredOptions
              .map((String option) => PopupMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
