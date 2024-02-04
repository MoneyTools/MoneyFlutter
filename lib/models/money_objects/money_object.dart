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

  /// Serialize object instance to a JSon format
  MyJson getPersistableJSon() {
    final MyJson json = {};

    final List<Field<Object, dynamic>> declarations = getFieldsForClass<Object>();
    for (final Field<Object, dynamic> field in declarations) {
      if (field.serializeName != '' && field.serializeName != 'Id') {
        json[field.serializeName] = field.valueForSerialization(this);
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
