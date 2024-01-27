import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/fields/field.dart';
import 'package:money/widgets/circle.dart';
export 'package:money/models/fields/field.dart';

class Fields<T> {
  final List<Field<T, dynamic>> definitions;

  Fields({required this.definitions}) {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  Widget getRowOfColumns(final T objectInstance) {
    final List<Widget> cells = <Widget>[];

    for (int columnIndex = 0; columnIndex < definitions.length; columnIndex++) {
      final Field<T, dynamic> fieldDefinition = definitions[columnIndex];
      if (fieldDefinition.useAsColumn) {
        final dynamic value = fieldDefinition.valueFromInstance(objectInstance);
        cells.add(
          Expanded(
            flex: fieldDefinition.columnWidth.index,
            child: buildWidgetFromTypeAndValue(
              value,
              fieldDefinition.type,
              fieldDefinition.align,
            ),
          ),
        );
      }
    }

    return Row(children: cells);
  }

  List<Widget> getCellsForDetailsPanel(final T objectInstance) {
    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < definitions.length; i++) {
      final Widget widget = getBestWidgetForFieldDefinition(i, objectInstance);
      cells.add(widget);
    }
    return cells;
  }

  List<String> getListOfFieldValueAsString(final T objectInstance, [final bool includeHiddenFields = false]) {
    final List<String> strings = <String>[];
    for (int fieldIndex = 0; fieldIndex < definitions.length; fieldIndex++) {
      final Field<T, dynamic> fieldDefinition = definitions[fieldIndex];
      if (includeHiddenFields == true || fieldDefinition.useAsColumn == true) {
        final dynamic rawValue = fieldDefinition.valueFromInstance(objectInstance);
        strings.add(fieldDefinition.getString(rawValue));
      }
    }
    return strings;
  }

  Widget getBestWidgetForFieldDefinition(final int columnIndex, final T objectInstance) {
    final Field<T, dynamic> fieldDefinition = definitions[columnIndex];

    final dynamic fieldValue = fieldDefinition.valueFromInstance(objectInstance);

    if (fieldDefinition.isMultiLine) {
      return TextFormField(
        readOnly: fieldDefinition.readOnly,
        initialValue: fieldValue.toString(),
        keyboardType: TextInputType.multiline,
        minLines: 1,
        //Normal textInputField will be displayed
        maxLines: 5,
        // when user presses enter it will adapt to
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: fieldDefinition.name,
        ),
      );
    } else {
      if (fieldDefinition.type == FieldType.widget) {
        final String valueAsString = fieldDefinition.valueForSerialization(objectInstance).toString();
        return MyFormFieldForColor(
          color: getColorFromString(valueAsString),
        );
      }

      return TextFormField(
        readOnly: fieldDefinition.readOnly,
        initialValue: fieldDefinition.getString(fieldValue),
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: fieldDefinition.name,
        ),
      );
    }
  }

  String getCsvRowValues(final T item) {
    final List<dynamic> listOfValues = <dynamic>[];
    for (final Field<T, dynamic> field in definitions) {
      listOfValues.add('"${field.valueForSerialization(item)}"');
    }
    return listOfValues.join(',');
  }
}

///
class MyFormFieldForColor extends StatefulWidget {
  final Color color;

  const MyFormFieldForColor({super.key, required this.color});

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
            decoration: const InputDecoration(labelText: 'Color (e.g., #RRGGBB)'),
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
