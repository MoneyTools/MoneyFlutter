import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/app/core/widgets/picker_panel.dart';

class PickerEditBox extends StatefulWidget {
  const PickerEditBox({
    super.key,
    required this.title,
    required this.items,
    this.initialValue,
    required this.onChanged,
  });

  final String title;
  final List<String> items;
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
    return Container(
      decoration: BoxDecoration(
        color: getColorTheme(context).tertiaryContainer.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: getColorTheme(context).outline)),
        // borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
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
                  title: widget.title,
                  context: context,
                  items: widget.items,
                  selectedItem: _textController.text,
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
      ),
    );
  }
}
