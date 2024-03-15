import 'package:flutter/material.dart';
import 'package:money/widgets/picker_panel.dart';

class PickerEditBox extends StatefulWidget {
  const PickerEditBox({
    super.key,
    required this.options,
    this.initialValue,
    required this.onChanged,
  });

  final List<String> options;
  final String? initialValue;
  final Function(String) onChanged;

  @override
  PickerEditBoxState createState() => PickerEditBoxState();
}

class PickerEditBoxState extends State<PickerEditBox> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialValue ?? "";
  }

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
            onChanged: (final String value) {
              setState(() {
                widget.onChanged(value);
              });
            },
          ),
        ),
        IconButton(
          onPressed: () {
            showPopupSelection(
                context: context,
                options: widget.options,
                onSelected: (final String text) {
                  setState(() {
                    _textController.text = text;
                    widget.onChanged(text);
                  });
                });
          },
          icon: const Icon(Icons.arrow_drop_down),
        )
      ],
    );
  }
}
