import 'package:flutter/material.dart';

///
class MyFormFieldForWidget extends StatefulWidget {
  final String title;
  final String valueAsText;
  final Widget child;

  const MyFormFieldForWidget({super.key, required this.title, required this.valueAsText, required this.child});

  @override
  MyFormFieldForWidgetState createState() => MyFormFieldForWidgetState();
}

class MyFormFieldForWidgetState extends State<MyFormFieldForWidget> {
  TextEditingController colorController = TextEditingController();
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    colorController.value = TextEditingValue(text: widget.valueAsText);
  }

  @override
  Widget build(final BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: colorController,
            decoration: InputDecoration(labelText: widget.title),
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

  Color? parseColor(final String value) {
    try {
      // Parse color from hex string
      return Color(int.parse(value.replaceAll('#', '0x')));
    } catch (e) {
      // Return null for invalid colors
      return null;
    }
  }
}
