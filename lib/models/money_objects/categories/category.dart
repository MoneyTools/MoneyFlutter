import 'package:flutter/material.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';

/*
  0|Id|INT|0||1
  1|ParentId|INT|0||0
  2|Name|nvarchar(80)|1||0
  3|Description|nvarchar(255)|0||0
  4|Type|INT|1||0
  5|Color|nchar(10)|0||0
  6|Budget|money|0||0
  7|Balance|money|0||0
  8|Frequency|INT|0||0
  9|TaxRefNum|INT|0||0
 */
class Category extends MoneyObject {
  // 0
  // int MoneyEntity.id

  // 1
  int parentId = -1;

  // 2
  String name;

  // 3
  String description;

  // 4
  CategoryType type = CategoryType.none;

  // 5
  String color;

  // 6
  double budget;

  // 7
  double balance = 0.00;

  // 8
  int frequency = 0;

  // 9
  int taxRefNum = 0;

  // Not serialized
  int count = 0;

  Category({
    required super.id,
    this.parentId = -1,
    required this.name,
    this.description = '',
    required this.type,
    this.color = '',
    this.budget = 0,
    this.balance = 0,
    this.frequency = 0,
    this.taxRefNum = 0,
  });

  factory Category.fromSqlite(final Json row) {
    return Category(
      id: jsonGetInt(row, 'Id'),
      name: jsonGetString(row, 'Name'),
      parentId: jsonGetInt(row, 'ParentId'),
      description: jsonGetString(row, 'Description'),
      type: Category.getTypeFromInt(jsonGetInt(row, 'Type')),
      color: jsonGetString(row, 'Color').trim(),
      budget: jsonGetDouble(row, 'Budget'),
      balance: jsonGetDouble(row, 'Balance'),
      frequency: jsonGetInt(row, 'Frequency'),
      taxRefNum: jsonGetInt(row, 'TaxRefNum'),
    );
  }

  static FieldDefinitions<Category> getFieldDefinitions() {
    final FieldDefinitions<Category> fields = FieldDefinitions<Category>(definitions: <FieldDefinition<Category>>[
      FieldDefinition<Category>(
        name: 'Id',
        serializeName: 'id',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromInstance: (final Category entity) => entity.id,
        sort: (final Category a, final Category b, final bool sortAscending) {
          return sortByValue(a.id, b.id, sortAscending);
        },
      ),
      FieldDefinition<Category>(
        type: FieldType.text,
        name: 'Name',
        serializeName: 'name',
        align: TextAlign.left,
        valueFromInstance: (final Category entity) => entity.name,
        sort: (final Category a, final Category b, final bool sortAscending) {
          return sortByString(a.name, b.name, sortAscending);
        },
      ),
      getFieldForType(),
      getFieldForDescription(),
      FieldDefinition<Category>(
        name: 'ParentId',
        serializeName: 'parentId',
        valueFromInstance: (final Category entity) => entity.parentId,
      ),
      getFieldForColor(),
    ]);
    return fields;
  }

  static CategoryType getTypeFromInt(final int index) {
    if (isBetween(index, -1, CategoryType.values.length)) {
      return CategoryType.values[index];
    }
    return CategoryType.none;
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

  static FieldDefinition<Category> getFieldForDescription() {
    return FieldDefinition<Category>(
      type: FieldType.text,
      name: 'Description',
      serializeName: 'description',
      align: TextAlign.left,
      valueFromInstance: (final Category entity) => entity.description,
      sort: (final Category a, final Category b, final bool sortAscending) {
        return sortByString(a.description, b.description, sortAscending);
      },
    );
  }

  static FieldDefinition<Category> getFieldForColor() {
    return FieldDefinition<Category>(
      type: FieldType.widget,
      name: 'Color',
      serializeName: 'color',
      align: TextAlign.center,
      valueFromInstance: (final Category item) {
        return Container(
          color: getColorFromHex(item.color),
          width: 10,
          height: 10,
        );
      },
      valueForSerialization: (final Category item) {
        return item.color;
      },
      sort: (final Category a, final Category b, final bool sortAscending) {
        return sortByString(a.color, b.color, sortAscending);
      },
    );
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
