// Exports
import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/circle.dart';
import 'package:money/widgets/form_field_switch.dart';
import 'package:money/widgets/form_field_widget.dart';

export 'dart:ui';

export 'package:money/helpers/misc_helpers.dart';
export 'package:money/models/fields/field.dart';

class MoneyObject {
  MoneyObject();

  /// All object must have a unique identified
  int get uniqueId => -1;

  set uniqueId(int value) {}

  FieldDefinitions get fieldDefinitions => [];

  FieldDefinitions getFieldDefinitionsForPanel() {
    return fieldDefinitions.where((element) => element.useAsDetailPanels).toList();
  }

  /// Return the best way to identify this instance, e.g. Name
  String getRepresentation() {
    return 'Id: $uniqueId'; // By default the ID is the best unique way
  }

  String getMutatedChangeAsSingleString<T>() {
    final myJson = getMutatedDiff<T>();
    return myJson.toString();
  }

  /// State of any and all object instances
  /// to indicated any alteration to the data set of the users
  /// to reflect on the customer CRUD actions [Create|Rename|Update|Delete]
  MutationType mutation = MutationType.none;
  MyJson? valueBeforeEdit;

  Color getMutationColor() {
    switch (mutation) {
      case MutationType.inserted:
        return Colors.green;
      case MutationType.changed:
        return Colors.orange;
      case MutationType.deleted:
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  bool get isInserted => mutation == MutationType.inserted;

  bool get isDeleted => mutation == MutationType.deleted;

  bool get isChanged => mutation == MutationType.changed;

  MoneyObject rollup(List<MoneyObject> moneyObjectInstances) {
    return MoneyObject();
  }

  void mutateField(final String fieldName, final dynamic newValue, final bool fireNotification) {
    stashValueBeforeEditing();
    final field = getFieldDefinitionByName(fieldDefinitions, fieldName);
    if (field != null && field.setValue != null) {
      field.setValue!(this, newValue);
      Data()
          .notifyMutationChanged(mutation: MutationType.changed, moneyObject: this, fireNotification: fireNotification);
    }
  }

  ///
  /// Column 1 | Column 2 | Column 3
  ///
  Widget Function(Fields, dynamic)? buildFieldsAsWidgetForLargeScreen = (final Fields fields, final dynamic instance) {
    return fields.getRowOfColumns(instance);
  };

  ///
  /// Title       |
  /// ------------+ Right
  /// SubTitle    |
  ///
  Widget Function()? buildFieldsAsWidgetForSmallScreen = () => const Text('Small screen content goes here');

  ///
  /// Name: Bob
  /// Date: 2020-12-31
  List<Widget> buildWidgets({
    Function? onEdit,
    bool compact = false,
  }) {
    if (fieldDefinitions.isEmpty) {
      return [Text('No fields found for $this')];
    }
    final List<Widget> widgets = <Widget>[];
    final definitions = getFieldDefinitionsForPanel();
    for (final fieldDefinition in definitions) {
      final Widget widget = getBestWidgetForFieldDefinition(
        this,
        fieldDefinition,
        onEdit,
        compact,
        isFirstItem: fieldDefinition == definitions.first,
        isLastItem: fieldDefinition == definitions.last,
      );
      widgets.add(Padding(
        padding: compact ? const EdgeInsets.symmetric(horizontal: 8.0) : const EdgeInsets.all(8.0),
        child: widget,
      ));
    }
    return widgets;
  }

  Widget getBestWidgetForFieldDefinition(
    final MoneyObject objectInstance,
    final Field<dynamic> fieldDefinition,
    final Function? onEdited,
    final bool compact, {
    bool isFirstItem = false,
    bool isLastItem = false,
  }) {
    final isReadOnly = onEdited == null;
    final dynamic fieldValue = fieldDefinition.valueFromInstance(objectInstance);

    if (compact) {
      // simple [Name  Value] pair
      return _buildNameValuePair(fieldDefinition, fieldValue);
    }

    final decoration = getFormFieldDecoration(
      fieldName: fieldDefinition.name,
      isReadOnly: isReadOnly,
    );

    if (!isReadOnly && fieldDefinition.getEditWidget != null) {
      // Editing mode and the MoneyObject has a custom edit widget
      return InputDecorator(
        decoration: InputDecoration(
          labelText: fieldDefinition.name,
          border: const OutlineInputBorder(),
        ),
        child: fieldDefinition.getEditWidget!(objectInstance, onEdited),
      );
    } else {
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
            return Row(
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
            );
        }
      }
    }
  }

  Widget _buildNameValuePair(
    Field<dynamic> fieldDefinition,
    final dynamic fieldValue,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Text(fieldDefinition.name),
          ),
          Expanded(
            child: fieldDefinition.getValueWidgetForDetailView(fieldValue),
          ),
        ],
      ),
    );
  }

  /// Serialize object instance to a JSon format
  MyJson getPersistableJSon() {
    final MyJson json = {};

    for (final Field<dynamic> field in fieldDefinitions) {
      if (field.serializeName != '') {
        json[field.serializeName] = field.valueForSerialization(this);
      }
    }
    return json;
  }

  String toJsonString() {
    return getPersistableJSon().toString();
  }

  bool isMutated<T>() {
    return getMutatedDiff<T>().keys.isNotEmpty;
  }

  MyJson getMutatedDiff<T>() {
    MyJson afterEditing = getPersistableJSon();
    return myJsonDiff(before: valueBeforeEdit ?? {}, after: afterEditing);
  }

  void stashValueBeforeEditing() {
    if (valueBeforeEdit == null) {
      valueBeforeEdit = getPersistableJSon();
    } else {
      // already stashed
    }
  }
}

enum MutationType {
  none,
  changed,
  inserted,
  deleted,
  reloaded,
  rebalanced,
  childChanged,
  transientChanged,
}

class MutationGroup {
  String title = '';
  List<Widget> whatWasMutated = [];
}
