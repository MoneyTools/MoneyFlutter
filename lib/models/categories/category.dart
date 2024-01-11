import 'dart:ui';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_entity.dart';

class Category extends MoneyEntity {
  int parentId = -1;
  CategoryType type = CategoryType.none;
  int count = 0;
  double balance = 0.00;

  Category(final int id, this.type, final String name) : super(id, name) {
    //
  }

  getTypeAsText() {
    switch (type) {
      case CategoryType.income:
        return 'Income';
      case CategoryType.expense:
        return 'Expense';
      case CategoryType.saving:
        return 'Saving';
      case CategoryType.reserved:
        return 'Reserved';
      case CategoryType.transfer:
        return 'Transfer';
      case CategoryType.investment:
        return 'Investment';
      case CategoryType.none:
      default:
        return 'None';
    }
  }

  static CategoryType getTypeFromText(final String text) {
    switch (text) {
      case '1':
        return CategoryType.income;
      case '2':
        return CategoryType.expense;
      case '3':
        return CategoryType.saving;
      case '4':
        return CategoryType.reserved;
      case '5':
        return CategoryType.transfer;
      case '6':
        return CategoryType.investment;
      case '0':
      default:
        return CategoryType.none;
    }
  }

  static FieldDefinition<Category> getFieldForType() {
    return FieldDefinition<Category>(
      name: 'Type',
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final Category item) {
        return item.type.toString();
      },
      sort: (final Category a, final Category b, final bool sortAscending) {
        return sortByString(a.type.toString(), b.type.toString(), sortAscending);
      },
    );
  }

  static FieldDefinitions<Category> getFieldDefinitions() {
    final FieldDefinitions<Category> fields = FieldDefinitions<Category>(definitions: <FieldDefinition<Category>>[
      FieldDefinition<Category>(
        name: 'Id',
        serializeName: 'id',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromList: (final int index) => '',
        valueFromInstance: (final Category entity) => entity.id,
        sort: (final Category a, final Category b, final bool sortAscending) {
          return sortByValue(a.id, b.id, sortAscending);
        },
      ),
      FieldDefinition<Category>(
        name: 'Name',
        serializeName: 'name',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromInstance: (final Category entity) => entity.name,
        sort: (final Category a, final Category b, final bool sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      getFieldForType(),
      FieldDefinition<Category>(
        serializeName: 'parentId',
        valueFromInstance: (final Category entity) => entity.parentId,
      ),
    ]);
    return fields;
  }

  static getCsvHeader() {
    final List<String> headerList = <String>[];
    getFieldDefinitions().definitions.forEach((final FieldDefinition<Category> field) {
      if (field.serializeName != null) {
        headerList.add(field.serializeName!);
      }
    });
    return headerList.join(',');
  }
}

enum CategoryType {
  none, // 0
  income, // 1
  expense, // 2
  saving, // 3
  reserved, // 4
  transfer, // 5
  investment, // 6
}
