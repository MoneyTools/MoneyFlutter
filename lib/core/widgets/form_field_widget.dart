import 'package:flutter/material.dart';
import 'package:money/core/widgets/form_field_switch.dart';

/// Hybrid widget Text on the left, custom widget on the right
class MyFormFieldForWidget extends StatefulWidget {
  const MyFormFieldForWidget({
    required this.title,
    required this.valueAsText,
    required this.isReadOnly,
    required this.onChanged,
    super.key,
  });

  final bool isReadOnly;
  final Function(String) onChanged;
  final String title;
  final String valueAsText;

  @override
  MyFormFieldForWidgetState createState() => MyFormFieldForWidgetState();
}

class MyFormFieldForWidgetState extends State<MyFormFieldForWidget> {
  TextEditingController controller = TextEditingController();
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    controller.value = TextEditingValue(text: widget.valueAsText);
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.isReadOnly) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.bodySmall),
          Text(widget.valueAsText),
        ],
      );
    }
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: getFormFieldDecoration(
              fieldName: widget.title,
              isReadOnly: widget.isReadOnly,
            ),
            onChanged: (final String value) {
              setState(() {
                widget.onChanged(value);
              });
            },
          ),
        ),
      ],
    );
  }
}
