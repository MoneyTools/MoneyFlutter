// Imports
import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/categories/category_types.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/widgets/circle.dart';
import 'package:money/widgets/table_view/table_row_compact.dart';

// Exports
export 'package:money/models/money_objects/categories/category_types.dart';

class Category extends MoneyObject<Category> {
  @override
  int get uniqueId => id.value;

  /// Id
  /// 0|Id|INT|0||1
  Field<Category, int> id = Field<Category, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final Category instance) => instance.id.value,
  );

  /// 1|ParentId|INT|0||0
  FieldInt<Category> parentId = FieldInt<Category>(
    importance: 1,
    serializeName: 'ParentId',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final Category instance) => instance.parentId.value,
  );

  /// Name
  /// 2|Name|nvarchar(80)|1||0
  Field<Category, String> name = Field<Category, String>(
    importance: 2,
    type: FieldType.text,
    name: 'Name',
    serializeName: 'Name',
    defaultValue: '',
    valueFromInstance: (final Category instance) => instance.name.value,
    valueForSerialization: (final Category instance) => instance.name.value,
  );

  /// Description
  /// 3|Description|nvarchar(255)|0||0
  Field<Category, String> description = Field<Category, String>(
    importance: 3,
    type: FieldType.text,
    name: 'Description',
    serializeName: 'Description',
    defaultValue: '',
    valueFromInstance: (final Category instance) => instance.description.value,
    valueForSerialization: (final Category instance) => instance.description.value,
  );

  /// Type
  /// 4|Type|INT|1||0
  Field<Category, CategoryType> type = Field<Category, CategoryType>(
    importance: 4,
    type: FieldType.text,
    align: TextAlign.center,
    serializeName: 'Type',
    defaultValue: CategoryType.none,
    valueFromInstance: (final Category instance) => instance.getTypeAsText(),
    valueForSerialization: (final Category instance) => instance.type.value.index,
  );

  /// Color
  /// 5|Color|nchar(10)|0||0
  Field<Category, String> color = Field<Category, String>(
    importance: 5,
    serializeName: 'Color',
    type: FieldType.widget,
    defaultValue: '',
    valueFromInstance: (final Category instance) => MyCircle(
      colorFill: getColorFromString(instance.color.value),
      size: 12,
    ),
    valueForSerialization: (final Category instance) => instance.color.value,
    sort: (final Category a, final Category b, final bool ascending) =>
        sortByString(a.color.value, b.color.value, ascending),
  );

  /// Budget
  /// 6|Budget|money|0||0
  FieldAmount<Category> budget = FieldAmount<Category>(
    importance: 99,
    name: 'Budget',
    useAsColumn: false,
    valueFromInstance: (final Category instance) => instance.budget.value,
    valueForSerialization: (final Category instance) => instance.budget.value,
  );

  /// Budget Balance
  /// 7|Balance|money|0||0
  FieldAmount<Category> budgetBalance = FieldAmount<Category>(
    importance: 80,
    name: 'BudgetBalance',
    useAsColumn: false,
    valueFromInstance: (final Category instance) => instance.budgetBalance.value,
    valueForSerialization: (final Category instance) => instance.budgetBalance.value,
  );

  /// 8|Frequency|INT|0||0
  FieldInt<Category> frequency = FieldInt<Category>(
    importance: 80,
    serializeName: 'Frequency',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final Category instance) => instance.frequency.value,
  );

  /// 9|TaxRefNum|INT|0||0
  FieldInt<Category> taxRefNum = FieldInt<Category>(
    importance: 80,
    serializeName: 'TaxRefNum',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final Category instance) => instance.taxRefNum.value,
  );

  //-----------------------------------
  // These properties are not persisted

  /// Count
  Field<Category, int> count = Field<Category, int>(
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
  Field<Category, double> runningBalance = Field<Category, double>(
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
    required final int id,
    final int parentId = -1,
    required final String name,
    final String description = '',
    final String color = '',
    required final CategoryType type,
    final double budget = 0,
    final double budgetBalance = 0,
    final int frequency = 0,
    final int taxRefNum = 0,
  }) {
    this.id.value = id;
    this.parentId.value = parentId;
    this.name.value = name;
    this.description.value = description;
    this.color.value = color;
    this.type.value = type;
    this.budget.value = budget;
    this.budgetBalance.value = budgetBalance;
    this.frequency.value = frequency;
    this.taxRefNum.value = taxRefNum;

    this.buildListWidgetForSmallScreen = () {
      String top = '';
      String bottom = '';

      if (this.parentId.value == -1) {
        top = this.name.value;
        bottom = '';
      } else {
        top = getName(Data().categories.get(this.parentId.value));
        bottom = this.name.value.substring(top.length);
      }

      return TableRowCompact(
        leftTopAsString: top,
        leftBottomAsString: bottom,
        rightTopAsString: getCurrencyText(runningBalance.value),
        rightBottomAsWidget: Row(
          children: <Widget>[
            Text(getTypeAsText()),
            SizedBox(
              width: 8,
            ),
            MyCircle(colorFill: getColorFromString(this.color.value), size: 12),
          ],
        ),
      );
    };
  }

  factory Category.fromSqlite(final Json row) {
    return Category(
      id: jsonGetInt(row, 'Id'),
      parentId: jsonGetInt(row, 'ParentId'),
      name: jsonGetString(row, 'Name'),
      description: jsonGetString(row, 'Description'),
      color: jsonGetString(row, 'Color').trim(),
      type: Category.getTypeFromInt(jsonGetInt(row, 'Type')),
      budget: jsonGetDouble(row, 'Budget'),
      budgetBalance: jsonGetDouble(row, 'Balance'),
      frequency: jsonGetInt(row, 'Frequency'),
      taxRefNum: jsonGetInt(row, 'TaxRefNum'),
    );
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

  String getTypeAsText() {
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
