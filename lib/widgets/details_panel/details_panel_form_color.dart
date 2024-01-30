import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/widgets/circle.dart';

///
class MyFormFieldForColor extends StatefulWidget {
  final String title;
  final Color color;

  const MyFormFieldForColor({super.key, required this.title, required this.color});

  @override
  MyFormFieldForColorState createState() => MyFormFieldForColorState();
}

class MyFormFieldForColorState extends State<MyFormFieldForColor> {
  TextEditingController colorController = TextEditingController();
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.color;
    colorController.value = TextEditingValue(text: colorToHexString(selectedColor).toUpperCase());
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
                selectedColor = getColorFromString(value);
              });
            },
          ),
        ),
        MyCircle(
          colorFill: selectedColor,
          colorBorder: Colors.grey,
          size: 30,
        )
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
