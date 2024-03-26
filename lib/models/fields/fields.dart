// Imports
import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/fields/field_filter.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/widgets/circle.dart';
import 'package:money/widgets/details_panel/details_panel_form_widget.dart';
import 'package:money/widgets/form_field_switch.dart';

// Exports
export 'package:money/models/fields/field.dart';

class Fields<T> {
  final List<Field<T, dynamic>> definitions;

  /// Constructor
  Fields({required this.definitions}) {
    assert(T != dynamic, 'Type T cannot be dynamic');
  }

  /// Used in table view
  Widget getRowOfColumns(final T objectInstance) {
    final List<Widget> cells = <Widget>[];

    for (int columnIndex = 0; columnIndex < definitions.length; columnIndex++) {
      final Field<T, dynamic> fieldDefinition = definitions[columnIndex];
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

    return Row(children: cells);
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

  List<Widget> getFieldsAsWidgets(final T objectInstance, Function? onEdited, bool compact) {
    final List<Widget> widgets = <Widget>[];
    for (int i = 0; i < definitions.length; i++) {
      if (definitions[i].useAsDetailPanels) {
        final Widget widget = getBestWidgetForFieldDefinition(i, objectInstance, onEdited, compact);
        widgets.add(widget);
      }
    }
    return widgets;
  }

  bool applyFilters(
    final T objectInstance,
    final String lowerCaseTextToFind,
    final List<FieldFilter> filterByFieldsValue,
  ) {
    bool atLeastOneFieldMatchText = false;

    for (int fieldIndex = 0; fieldIndex < definitions.length; fieldIndex++) {
      // Field Definition
      final Field<T, dynamic> fieldDefinition = definitions[fieldIndex];

      // Only Field that are being displayed
      if (fieldDefinition.useAsColumn == true) {
        // Value of this field
        final dynamic rawValue = fieldDefinition.valueFromInstance(objectInstance);

        // field specific filters
        if (!isMatchingFieldValues(
          fieldDefinition,
          rawValue,
          filterByFieldsValue,
        )) {
          return false;
        }

        // check to see if at least one field contains the free style filter text
        if (atLeastOneFieldMatchText == false) {
          if (lowerCaseTextToFind.isEmpty ||
              fieldDefinition.getString(rawValue).toLowerCase().contains(lowerCaseTextToFind)) {
            if (filterByFieldsValue.isEmpty) {
              // we can stop, we have one match and there's not field specific filters
              return true;
            }
            atLeastOneFieldMatchText = true;
          }
        }
      }
    }

    if (lowerCaseTextToFind.isEmpty) {
      // this instance is valid
      return true;
    }
    return atLeastOneFieldMatchText;
  }

  bool isMatchingFieldValues(
    final Field<T, dynamic> fieldDefinition,
    dynamic rawValue,
    List<FieldFilter> filterByFieldsValue,
  ) {
    for (final filter in filterByFieldsValue) {
      if (!isMatchingFieldValue(fieldDefinition, rawValue, filter)) {
        return false;
      }
    }
    return true;
  }

  bool isMatchingFieldValue(
    final Field<T, dynamic> fieldDefinition,
    dynamic rawValue,
    FieldFilter filter,
  ) {
    if (fieldDefinition.name == filter.fieldName) {
      return rawValue.toString().toLowerCase() == filter.filterTextInLowerCase;
    }
    return true;
  }

  Widget getBestWidgetForFieldDefinition(
    final int fieldIndex,
    final T objectInstance,
    final Function? onEdited,
    final bool compact,
  ) {
    final isReadOnly = onEdited == null;

    final Field<T, dynamic> fieldDefinition = definitions[fieldIndex];
    final dynamic fieldValue = fieldDefinition.valueFromInstance(objectInstance);

    if (compact) {
      // simple [Name  Value]
      return Container(
        decoration: BoxDecoration(
          border: fieldIndex != 0 ? Border(top: BorderSide(color: Colors.grey.withAlpha(0xaa))) : null,
        ),
        child: Row(
          children: [
            Text(fieldDefinition.name),
            const Spacer(),
            fieldDefinition.getAsCompactWidget(fieldValue),
          ],
        ),
      );
    }
    if (!isReadOnly && fieldDefinition.getEditWidget != null) {
      // Editing mode and the MoneyObject has a custom edit widget
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: fieldDefinition.name,
            border: const OutlineInputBorder(),
          ),
          child: fieldDefinition.getEditWidget!(objectInstance, onEdited),
        ),
      );
    } else {
      final decoration = getFormFieldDecoration(
        fieldName: fieldDefinition.name,
        isReadOnly: isReadOnly,
      );

      if (fieldDefinition.isMultiLine) {
        return TextFormField(
          readOnly: isReadOnly,
          initialValue: fieldValue.toString(),
          keyboardType: TextInputType.multiline,
          minLines: 1,
          //Normal textInputField will be displayed
          maxLines: 5,
          // when user presses enter it will adapt to
          decoration: decoration,
        );
      } else {
        switch (fieldDefinition.type) {
          case FieldType.toggle:
            if (isReadOnly) {
              return MyFormFieldForWidget(
                title: fieldDefinition.name,
                valueAsText: fieldDefinition.valueFromInstance(objectInstance).toString(),
                isReadOnly: true,
              );
            }
            return SwitchFormField(
              title: fieldDefinition.name,
              initialValue: fieldDefinition.valueFromInstance(objectInstance),
              isReadOnly: isReadOnly,
              validator: (bool? value) {
                /// Todo
                return null;
              },
              onSaved: (value) {
                /// Todo
                fieldDefinition.setValue?.call(objectInstance, value);
              },
            );

          case FieldType.widget:
            final String valueAsString = fieldDefinition.valueForSerialization(objectInstance).toString();
            return MyFormFieldForWidget(
              title: fieldDefinition.name,
              valueAsText: valueAsString,
              isReadOnly: isReadOnly,
              child: fieldDefinition.name == 'Color'
                  ? MyCircle(
                      colorFill: getColorFromString(valueAsString),
                      colorBorder: Colors.grey,
                      size: 30,
                    )
                  : fieldDefinition.valueFromInstance(objectInstance),
            );

          // all others will be a normal text input
          default:
            String value = fieldDefinition.getString(fieldValue);
            if (value.isEmpty && isReadOnly) {
              value = '. . . ';
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      initialValue: value,
                      decoration: decoration,
                      // allow mutation of the value
                      readOnly: isReadOnly || fieldDefinition.setValue == null,
                      onFieldSubmitted: (String value) {
                        onEdited?.call();
                      },
                      onEditingComplete: () {
                        onEdited?.call();
                      },
                      onChanged: (String newValue) {
                        fieldDefinition.setValue!(objectInstance, newValue);
                        // onEdited?.call();
                      },
                    ),
                  ),
                ],
              ),
            );
        }
      }
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
