import 'package:flutter/widgets.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_object.dart';

/*

  1|ParentId|INT|0||0
  2|Name|nvarchar(80)|1||0



  8|Frequency|INT|0||0
  9|TaxRefNum|INT|0||0
 */
class Category extends MoneyObject<Category> {
  @override
  int get uniqueId => id.value;

  /// Id
  /// 0|Id|INT|0||1
  Declare<Category, int> id = Declare<Category, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final Category instance) => instance.id.value,
  );

  // 1
  int parentId = -1;

  // 2
  Declare<Category, String> name = Declare<Category, String>(
    importance: 0,
    type: FieldType.text,
    name: 'Name',
    serializeName: 'Name',
    defaultValue: '',
    valueFromInstance: (final Category instance) => instance.name.value,
    valueForSerialization: (final Category instance) => instance.name.value,
  );

  /// Description
  /// 3|Description|nvarchar(255)|0||0
  Declare<Category, String> description = Declare<Category, String>(
    importance: 1,
    type: FieldType.text,
    name: 'Description',
    serializeName: 'Description',
    defaultValue: '',
    valueFromInstance: (final Category instance) => instance.description.value,
    valueForSerialization: (final Category instance) => instance.description.value,
  );

  /// Type
  /// 4|Type|INT|1||0
  Declare<Category, CategoryType> type = Declare<Category, CategoryType>(
    importance: 3,
    type: FieldType.text,
    align: TextAlign.center,
    serializeName: 'Type',
    defaultValue: CategoryType.none,
    valueFromInstance: (final Category instance) => instance.getTypeAsText(),
    valueForSerialization: (final Category instance) => instance.type.value.index,
  );

  /// Color
  /// 5|Color|nchar(10)|0||0
  Declare<Category, String> color = Declare<Category, String>(
    importance: 4,
    type: FieldType.widget,
    serializeName: 'Color',
    defaultValue: '',
    valueFromInstance: (final Category instance) => Container(
      color: getColorFromHex(instance.color.value),
      width: 10,
      height: 10,
    ),
    valueForSerialization: (final Category instance) => instance.color.value,
  );

  /// Budget
  /// 6|Budget|money|0||0
  double budget;

  /// Budget Balance
  /// 7|Balance|money|0||0
  Declare<Category, double> budgetBalance = Declare<Category, double>(
    importance: 99,
    type: FieldType.amount,
    align: TextAlign.right,
    name: 'BudgetBalance',
    useAsColumn: false,
    defaultValue: 0,
    valueFromInstance: (final Category instance) => instance.budgetBalance.value,
    valueForSerialization: (final Category instance) => instance.budgetBalance.value,
  );

  // 8
  int frequency = 0;

  // 9
  int taxRefNum = 0;

  //-----------------------------------
  // These properties are not persisted

  /// Count
  Declare<Category, int> count = Declare<Category, int>(
    importance: 98,
    type: FieldType.numeric,
    align: TextAlign.right,
    name: 'Count',
    useAsDetailPanels: false,
    defaultValue: 0,
    valueFromInstance: (final Category instance) => instance.count.value,
    valueForSerialization: (final Category instance) => instance.count.value,
  );

  /// Running Balance
  Declare<Category, double> runningBalance = Declare<Category, double>(
    importance: 99,
    type: FieldType.amount,
    align: TextAlign.right,
    name: 'Balance',
    useAsDetailPanels: false,
    defaultValue: 0,
    valueFromInstance: (final Category instance) => instance.runningBalance.value,
    valueForSerialization: (final Category instance) => instance.runningBalance.value,
  );

  Category({
    this.parentId = -1,
    final String description = '',
    final CategoryType type = CategoryType.none,
    this.budget = 0,
    final double budgetBalance = 0,
    this.frequency = 0,
    this.taxRefNum = 0,
    final String name = '',
  }) {
    this.name.value = name;
    this.description.value = description;
    this.type.value = type;
    this.budgetBalance.value = budgetBalance;
  }

  factory Category.fromSqlite(final Json row) {
    return Category(
      parentId: jsonGetInt(row, 'ParentId'),
      description: jsonGetString(row, 'Description'),
      type: Category.getTypeFromInt(jsonGetInt(row, 'Type')),
      budget: jsonGetDouble(row, 'Budget'),
      budgetBalance: jsonGetDouble(row, 'Balance'),
      frequency: jsonGetInt(row, 'Frequency'),
      taxRefNum: jsonGetInt(row, 'TaxRefNum'),
    )
      ..id.value = jsonGetInt(row, 'Id')
      ..name.value = jsonGetString(row, 'Name')
      ..color.value = jsonGetString(row, 'Color').trim();
  }

  static String getName(final Category? instance) {
    return instance == null ? '' : instance.name.value;
  }

  static CategoryType getTypeFromInt(final int index) {
    if (isBetween(index, -1, CategoryType.values.length)) {
      return CategoryType.values[index];
    }
    return CategoryType.none;
  }

  getTypeAsText() {
    switch (type.value) {
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
