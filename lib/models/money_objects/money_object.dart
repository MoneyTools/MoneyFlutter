// Imports
import 'dart:ui';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/fields/fields.dart';

// Exports
export 'dart:ui';
export 'package:money/helpers/misc_helpers.dart';
export 'package:money/models/fields/field.dart';

class MoneyObject {
  // All MoneyObject have a unique Id
  int id; // Mandatory

  MoneyObject({required this.id}) {
    // its up to the derived class to build their instance
  }

  static FieldDefinition<T> getFieldId<T>() {
    return FieldDefinition<T>(
      useAsColumn: false,
      name: 'Id',
      serializeName: 'id',
      type: FieldType.numeric,
      align: TextAlign.right,
      valueFromInstance: (final T entity) => (entity as MoneyObject).id,
      sort: (final T a, final T b, final bool sortAscending) {
        return sortByValue((a as MoneyObject).id, (b as MoneyObject).id, sortAscending);
      },
    );
  }

  static FieldDefinitions<T> getFieldDefinitions<T>() {
    return FieldDefinitions<T>(definitions: <FieldDefinition<T>>[
      MoneyObject.getFieldId<T>(),
    ]);
  }
}
