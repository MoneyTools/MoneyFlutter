import 'package:flutter/material.dart';

/// Hybrid widget Text on the left, custom widget on the right
class MyFormFieldForWidget extends StatefulWidget {
  final String title;
  final String valueAsText;
  final Widget child;

  const MyFormFieldForWidget({
    super.key,
    required this.title,
    required this.valueAsText,
    required this.child,
  });

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
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: widget.title,
              border: const OutlineInputBorder(),
            ),
            onChanged: (final String value) {
              setState(() {
                // todo
              });
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}
