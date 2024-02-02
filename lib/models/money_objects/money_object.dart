// Exports
import 'package:flutter/material.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/models/fields/fields.dart';

export 'dart:ui';
export 'package:money/helpers/misc_helpers.dart';
export 'package:money/models/fields/field.dart';

class MoneyObject<C> {
  /// All object must have a unique identified
  int get uniqueId => -1;

  /// State of any and all object instances
  /// to indicated any alteration to the data set of the users
  /// to reflect on the customer CRUD actions [Create|Rename|Update|Delete]
  MutationType mutation = MutationType.none;

  MoneyObject<C> fromJson(final MyJson row) {
    return MoneyObject<C>();
  }

  ///
  /// Column 1 | Column 2 | Column 3
  ///
  Widget Function(Fields<C>, C)? buildListWidgetForLargeScreen = (final Fields<C> fields, final C instance) {
    return fields.getRowOfColumns(instance);
  };

  ///
  /// Title       |
  /// ------------+ Right
  /// SubTitle    |
  ///
  Widget Function()? buildListWidgetForSmallScreen = () => const Text('Small screen content goes here');

  MyJson getPersistableJSon() {
    final MyJson json = {};

    final List<Field<C, dynamic>> declarations = getFieldsForClass<C>();
    for (final Field<C, dynamic> field in declarations) {
      if (field.serializeName != '' && field.serializeName != 'Id') {
        json[field.serializeName] = field.valueForSerialization(this as C);
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
