// Imports
import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/categories/category_types.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/widgets/circle.dart';
import 'package:money/widgets/list_view/list_item_card.dart';

// Exports
export 'package:money/models/money_objects/categories/category_types.dart';

class Category extends MoneyObject {
  static Fields<Category>? fields;

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    return name.value;
  }

  /// Id
  /// 0|Id|INT|0||1
  FieldId id = FieldId(
    valueForSerialization: (final MoneyObject instance) => (instance as Category).uniqueId,
  );

  /// 1|ParentId|INT|0||0
  FieldInt parentId = FieldInt(
    importance: 1,
    serializeName: 'ParentId',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).parentId.value,
  );

  /// Name
  /// 2|Name|nvarchar(80)|1||0
  Field<String> name = Field<String>(
    importance: 2,
    type: FieldType.text,
    name: 'Name',
    serializeName: 'Name',
    defaultValue: '',
    valueFromInstance: (final MoneyObject instance) => (instance as Category).name.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).name.value,
  );

  /// Description
  /// 3|Description|nvarchar(255)|0||0
  Field<String> description = Field<String>(
    importance: 3,
    type: FieldType.text,
    name: 'Description',
    serializeName: 'Description',
    defaultValue: '',
    valueFromInstance: (final MoneyObject instance) => (instance as Category).description.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).description.value,
  );

  /// Type
  /// 4|Type|INT|1||0
  Field<CategoryType> type = Field<CategoryType>(
    importance: 4,
    type: FieldType.text,
    align: TextAlign.center,
    serializeName: 'Type',
    defaultValue: CategoryType.none,
    valueFromInstance: (final MoneyObject instance) => (instance as Category).getTypeAsText(),
    valueForSerialization: (final MoneyObject instance) => (instance as Category).type.value.index,
  );

  /// Color
  /// 5|Color|nchar(10)|0||0
  Field<String> color = Field<String>(
    importance: 5,
    serializeName: 'Color',
    type: FieldType.widget,
    columnWidth: ColumnWidth.small,
    defaultValue: '',
    valueFromInstance: (final MoneyObject instance) => MyCircle(
      colorFill: getColorFromString((instance as Category).color.value),
      size: 12,
    ),
    valueForSerialization: (final MoneyObject instance) => (instance as Category).color.value,
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) =>
        sortByString((a as Category).color.value, (b as Category).color.value, ascending),
  );

  /// Budget
  /// 6|Budget|money|0||0
  FieldAmount budget = FieldAmount(
    importance: 99,
    name: 'Budget',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Category).budget.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).budget.value,
  );

  /// Budget Balance
  /// 7|Balance|money|0||0
  FieldAmount budgetBalance = FieldAmount(
    importance: 80,
    name: 'BudgetBalance',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Category).budgetBalance.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).budgetBalance.value,
  );

  /// 8|Frequency|INT|0||0
  FieldInt frequency = FieldInt(
    importance: 80,
    serializeName: 'Frequency',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).frequency.value,
  );

  /// 9|TaxRefNum|INT|0||0
  FieldInt taxRefNum = FieldInt(
    importance: 80,
    serializeName: 'TaxRefNum',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).taxRefNum.value,
  );

  //-----------------------------------
  // These properties are not persisted

  /// Count
  FieldInt count = FieldInt(
    importance: 98,
    name: 'Transactions',
    columnWidth: ColumnWidth.small,
    useAsDetailPanels: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Category).count.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).count.value,
  );

  /// Running Balance
  Field<double> runningBalance = Field<double>(
    importance: 99,
    type: FieldType.amount,
    align: TextAlign.right,
    name: 'Balance',
    useAsDetailPanels: false,
    defaultValue: 0,
    valueFromInstance: (final MoneyObject instance) => (instance as Category).runningBalance.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Category).runningBalance.value,
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
    fields ??= Fields<Category>(definitions: [
      this.id,
      this.parentId,
      this.name,
      this.description,
      this.color,
      this.type,
      this.budget,
      this.budgetBalance,
      this.frequency,
      this.taxRefNum,
      // ignore: unnecessary_this
      this.count,
      // ignore: unnecessary_this
      this.runningBalance,
    ]);
    // Also stash the definition in the instance for fast retrieval later
    fieldDefinitions = fields!.definitions;

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

    buildFieldsAsWidgetForSmallScreen = () {
      String top = '';
      String bottom = '';

      if (this.parentId.value == -1) {
        top = this.name.value;
        bottom = '';
      } else {
        top = getName(Data().categories.get(this.parentId.value));
        bottom = this.name.value.substring(top.length);
      }

      return MyListItemAsCard(
        leftTopAsString: top,
        leftBottomAsString: bottom,
        rightTopAsString: Currency.getAmountAsStringUsingCurrency(runningBalance.value),
        rightBottomAsWidget: Row(
          children: <Widget>[
            Text(getTypeAsText()),
            const SizedBox(
              width: 8,
            ),
            MyCircle(colorFill: getColorFromString(this.color.value), size: 12),
          ],
        ),
      );
    };
  }

  factory Category.fromJson(final MyJson row) {
    return Category(
      id: row.getInt('Id', -1),
      parentId: row.getInt('ParentId', -1),
      name: row.getString('Name'),
      description: row.getString('Description'),
      color: row.getString('Color').trim(),
      type: Category.getTypeFromInt(row.getInt('Type')),
      budget: row.getDouble('Budget'),
      budgetBalance: row.getDouble('Balance'),
      frequency: row.getInt('Frequency'),
      taxRefNum: row.getInt('TaxRefNum'),
    );
  }

  static String getName(final Category? instance) {
    return instance == null ? '' : (instance).name.value;
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
