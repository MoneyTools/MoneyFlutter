// Exports
import 'package:flutter/material.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/models/fields/fields.dart';

export 'dart:ui';
export 'package:money/helpers/misc_helpers.dart';
export 'package:money/models/fields/field.dart';

abstract class MoneyObject {
  /// All object must have a unique identified
  int get uniqueId => -1;

  set uniqueId(int value) {}

  /// State of any and all object instances
  /// to indicated any alteration to the data set of the users
  /// to reflect on the customer CRUD actions [Create|Rename|Update|Delete]
  MutationType mutation = MutationType.none;

  // factory MoneyObject.fromJson(final MyJson row) {
  //   return MoneyObject();
  // }

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
  // List<Widget> Function(Function? onEdit, bool compact)? buildFieldsAsWidgetForDetailsPanel =
  //     (Function? onEdit, bool compact) {
  //   return [];
  // };

  List<Widget> buildWidgets<T>({
    Function? onEdit,
    bool compact = false,
  }) {
    final Fields<T> fields =
        Fields<T>(definitions: getFieldsForClass<T>().where((element) => element.useAsDetailPanels).toList());
    return fields.getFieldsAsWidgets(this as T, onEdit, compact);
  }

  /// Serialize object instance to a JSon format
  MyJson getPersistableJSon<T>() {
    final MyJson json = {};

    final List<Field<T, dynamic>> declarations = getFieldsForClass<T>();
    for (final Field<T, dynamic> field in declarations) {
      if (field.serializeName != '') {
        json[field.serializeName] = field.valueForSerialization(this as T);
      }
    }
    return json;
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
