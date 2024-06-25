// Exports
import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/form_field_switch.dart';
import 'package:money/app/core/widgets/form_field_widget.dart';
import 'package:money/app/data/models/fields/fields.dart';
import 'package:money/app/data/storage/data/data.dart';

export 'dart:ui';

export 'package:money/app/core/helpers/misc_helpers.dart';
export 'package:money/app/data/models/fields/field.dart';

class MoneyObject {

  factory MoneyObject.fromJSon(final MyJson json, final double runningBalance) {
    return MoneyObject();
  }
  MoneyObject();

  /// All object must have a unique identified
  int get uniqueId => -1;

  set uniqueId(int value) {}

  FieldDefinitions get fieldDefinitions => [];

  FieldDefinitions getFieldDefinitionsForPanel() {
    return fieldDefinitions.where((element) => element.useAsDetailPanels(this)).toList();
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
        return getColorFromState(ColorState.success);
      case MutationType.changed:
        return getColorFromState(ColorState.warning);
      case MutationType.deleted:
        return getColorFromState(ColorState.error);
      default:
        return Colors.transparent;
    }
  }

  bool get isInserted => mutation == MutationType.inserted;

  bool get isDeleted => mutation == MutationType.deleted;

  bool get isChanged => mutation == MutationType.changed;

  MoneyObject rollup(List<MoneyObject> moneyObjectInstances) {
    if (moneyObjectInstances.isEmpty) {
      return MoneyObject();
    }
    if (moneyObjectInstances.length == 1) {
      return moneyObjectInstances.first;
    }

    MyJson commonJson = moneyObjectInstances.first.getPersistableJSon();

    for (var t in moneyObjectInstances.skip(1)) {
      commonJson = compareAndGenerateCommonJson(commonJson, t.getPersistableJSon());
    }
    return MoneyObject.fromJSon(commonJson, 0);
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
      return [Center(child: Text('No fields found for $this'))];
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
    final isReadOnly = onEdited == null || fieldDefinition.setValue == null;
    final dynamic fieldValue = fieldDefinition.getValueForDisplay(objectInstance);

    if (compact) {
      // simple [Name  Value] pair
      return _buildNameValuePair(fieldDefinition, fieldValue);
    }

    final InputDecoration decoration = getFormFieldDecoration(
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
    }

    switch (fieldDefinition.type) {
      case FieldType.toggle:
        if (isReadOnly) {
          return MyFormFieldForWidget(
              title: fieldDefinition.name,
              valueAsText: fieldDefinition.getValueForDisplay(objectInstance).toString(),
              isReadOnly: true,
              onChanged: (final String value) {});
        }
        return InputDecorator(
          decoration: InputDecoration(
            labelText: fieldDefinition.name,
            border: const OutlineInputBorder(),
          ),
          child: SwitchFormField(
            title: fieldDefinition.name,
            initialValue: fieldDefinition.getValueForDisplay(objectInstance),
            isReadOnly: isReadOnly,
            validator: (bool? value) {
              /// Todo
              return null;
            },
            onSaved: (value) {
              fieldDefinition.setValue?.call(objectInstance, value);
              onEdited();
            },
          ),
        );

      case FieldType.widget:
        final String valueAsString = fieldDefinition.getValueForSerialization(objectInstance).toString();
        return MyFormFieldForWidget(
          title: fieldDefinition.name,
          valueAsText: valueAsString,
          isReadOnly: isReadOnly,
          onChanged: (final String value) {
            fieldDefinition.setValue?.call(objectInstance, value);
            onEdited?.call();
          },
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
              child: Opacity(
                opacity: isReadOnly ? 0.6 : 1.0,
                child: TextFormField(
                  initialValue: value,
                  decoration: decoration,
                  // allow mutation of the value
                  readOnly: isReadOnly,

                  onFieldSubmitted: (String value) {
                    onEdited?.call();
                  },
                  onEditingComplete: () {
                    onEdited?.call();
                  },
                  onChanged: (String newValue) {
                    fieldDefinition.setValue!(objectInstance, newValue);
                    onEdited?.call();
                  },
                ),
              ),
            ),
          ],
        );
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
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Text(fieldDefinition.name),
            ),
          ),
          IntrinsicWidth(
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
        json[field.serializeName] = field.getValueForSerialization(this);
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
    return myJsonDiff(
      before: valueBeforeEdit ?? {},
      after: afterEditing,
    );
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
