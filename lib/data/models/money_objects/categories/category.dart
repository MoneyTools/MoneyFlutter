// Imports
// ignore_for_file: unnecessary_this

import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/circle.dart';
import 'package:money/core/widgets/color_picker.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/money_widget.dart';
import 'package:money/core/widgets/my_text_input.dart';
import 'package:money/core/widgets/rectangle.dart';
import 'package:money/core/widgets/token_text.dart';
import 'package:money/data/models/money_objects/categories/category_types.dart';
import 'package:money/data/models/money_objects/categories/picker_category_type.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/list_item_card.dart';

// Exports
export 'package:money/data/models/money_objects/categories/category_types.dart';

class Category extends MoneyObject {
  Category({
    required final int id,
    required final String name,
    required final CategoryType type,
    final int parentId = -1,
    final String description = '',
    final String color = '',
    final double budget = 0,
    final double budgetBalance = 0,
    final int frequency = 0,
    final int taxRefNum = 0,
  }) {
    this.fieldId.value = id;
    this.fieldParentId.value = parentId;
    this.fieldName.value = name;
    this.fieldDescription.value = description;
    this.fieldColor.value = color;
    this.fieldType.value = type;
    this.fieldBudget.value.setAmount(budget);
    this.fieldBudgetBalance.value.setAmount(budgetBalance);
    this.fieldFrequency.value = frequency;
    this.fieldTaxRefNum.value = taxRefNum;
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

  /// Budget
  /// 6|Budget|money|0||0
  FieldMoney fieldBudget = FieldMoney(
    name: 'Budget',
    getValueForDisplay: (final MoneyObject instance) => (instance as Category).fieldBudget.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Category).fieldBudget.value.toDouble(),
  );

  /// Budget Balance
  /// 7|Balance|money|0||0
  FieldMoney fieldBudgetBalance = FieldMoney(
    name: 'BudgetBalance',
    getValueForDisplay: (final MoneyObject instance) => (instance as Category).fieldBudgetBalance.value,
    getValueForSerialization: (final MoneyObject instance) =>
        (instance as Category).fieldBudgetBalance.value.toDouble(),
  );

  /// Color
  /// 5|Color|nchar(10)|0||0
  Field<String> fieldColor = Field<String>(
    serializeName: 'Color',
    type: FieldType.widget,
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    defaultValue: '',
    getValueForDisplay: (final MoneyObject instance) => (instance as Category).getColorWidget(),
    getValueForSerialization: (final MoneyObject instance) => (instance as Category).fieldColor.value,
    setValue: (final MoneyObject instance, final dynamic value) {
      (instance as Category).fieldColor.value = value as String;
    },
    getEditWidget: (final MoneyObject instance, Function(bool wasModified) onEdited) {
      return MutateFieldColor(
        colorAsHex: (instance as Category).fieldColor.value,
        onEdited: (String newValue) {
          instance.fieldColor.value = newValue;
          Data().notifyMutationChanged(
            mutation: MutationType.changed,
            moneyObject: instance,
            recalculateBalances: false,
          );
          onEdited(true);
        },
      );
    },
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByValue(
      (a as Category).getColorOrAncestorsColor().computeLuminance(),
      (b as Category).getColorOrAncestorsColor().computeLuminance(),
      ascending,
    ),
  );

  /// Description
  /// 3|Description|nvarchar(255)|0||0
  FieldString fieldDescription = FieldString(
    columnWidth: ColumnWidth.large,
    name: 'Description',
    serializeName: 'Description',
    getValueForDisplay: (final MoneyObject instance) => (instance as Category).fieldDescription.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Category).fieldDescription.value,
    setValue: (final MoneyObject instance, dynamic value) => (instance as Category).fieldDescription.value = value,
  );

  /// 8|Frequency|INT|0||0
  FieldInt fieldFrequency = FieldInt(
    serializeName: 'Frequency',
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForSerialization: (final MoneyObject instance) => (instance as Category).fieldFrequency.value,
  );

  /// Id
  /// 0|Id|INT|0||1
  FieldId fieldId = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as Category).uniqueId,
  );

  //-----------------------------------
  // These properties are not persisted

  /// Level
  FieldInt fieldLevel = FieldInt(
    align: TextAlign.center,
    name: 'Level',
    columnWidth: ColumnWidth.nano,
    type: FieldType.text,
    footer: FooterType.count,
    getValueForDisplay: (final MoneyObject instance) =>
        (countOccurrences((instance as Category).fieldName.value, ':') + 1).toString(),
  );

  /// Name
  /// 2|Name|nvarchar(80)|1||0
  FieldString fieldName = FieldString(
    columnWidth: ColumnWidth.largest,
    name: 'Name',
    serializeName: 'Name',
    type: FieldType.widget,
    getValueForDisplay: (final MoneyObject instance) => TokenText((instance as Category).fieldName.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as Category).fieldName.value,
    setValue: (final MoneyObject instance, dynamic value) => (instance as Category).fieldName.value = value,
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByString(
      (a as Category).fieldName.value,
      (b as Category).fieldName.value,
      ascending,
    ),
  );

  /// 1|ParentId|INT|0||0
  FieldInt fieldParentId = FieldInt(
    name: 'ParentId',
    serializeName: 'ParentId',
    getValueForDisplay: (final MoneyObject instance) => (instance as Category).fieldParentId.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Category).fieldParentId.value,
  );

  /// Running Balance
  FieldMoney fieldSum = FieldMoney(
    name: 'Sum',
    getValueForDisplay: (final MoneyObject instance) => (instance as Category).fieldSum.value,
  );

  /// Running Balance
  FieldMoney fieldSumRollup = FieldMoney(
    name: 'Sum~',
    getValueForDisplay: (final MoneyObject instance) => (instance as Category).fieldSumRollup.value,
  );

  /// 9|TaxRefNum|INT|0||0
  FieldInt fieldTaxRefNum = FieldInt(
    serializeName: 'TaxRefNum',
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForSerialization: (final MoneyObject instance) => (instance as Category).fieldTaxRefNum.value,
  );

  /// Count
  FieldInt fieldTransactionCount = FieldInt(
    name: '#T',
    columnWidth: ColumnWidth.tiny,
    getValueForDisplay: (final MoneyObject instance) => (instance as Category).fieldTransactionCount.value,
  );

  /// Count
  FieldInt fieldTransactionCountRollup = FieldInt(
    name: '#T~',
    columnWidth: ColumnWidth.tiny,
    getValueForDisplay: (final MoneyObject instance) => (instance as Category).fieldTransactionCountRollup.value,
  );

  /// Type
  /// 4|Type|INT|1||0
  Field<CategoryType> fieldType = Field<CategoryType>(
    type: FieldType.text,
    align: TextAlign.center,
    serializeName: 'Type',
    defaultValue: CategoryType.none,
    footer: FooterType.count,
    getValueForDisplay: (final MoneyObject instance) => (instance as Category).getTypeAsText(),
    getValueForSerialization: (final MoneyObject instance) => (instance as Category).fieldType.value.index,
    setValue: (final MoneyObject instance, final dynamic value) {
      (instance as Category).fieldType.value = CategoryType.values[value as int];
    },
    getEditWidget: (final MoneyObject instance, Function(bool wasModified) onEdited) {
      final i = instance as Category;
      return pickerCategoryType(
        itemSelected: i.fieldType.value,
        onSelected: (CategoryType selectedType) {
          i.fieldType.value = selectedType;
          onEdited(true);
        },
      );
    },
  );

  @override
  Widget buildFieldsAsWidgetForSmallScreen() {
    String top = '';
    String bottom = '';

    if (this.fieldParentId.value == -1) {
      top = this.fieldName.value;
      bottom = '';
    } else {
      top = this.leafName;
      bottom = getName(parentCategory);
    }

    return MyListItemAsCard(
      leftTopAsString: top,
      leftBottomAsString: bottom,
      rightTopAsWidget: MoneyWidget(amountModel: fieldSum.value, asTile: true),
      rightBottomAsWidget: Row(
        children: <Widget>[
          Text(getTypeAsText()),
          gapMedium(),
          getColorWidget(),
        ],
      ),
    );
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  @override
  String getRepresentation() {
    return fieldName.value;
  }

  @override
  int get uniqueId => fieldId.value;

  @override
  set uniqueId(value) => fieldId.value = value;

  static final _fields = Fields<Category>();

  static Fields<Category> get fields {
    if (_fields.isEmpty) {
      final tmp = Category.fromJson({});
      _fields.setDefinitions([
        tmp.fieldId,
        tmp.fieldParentId,
        tmp.fieldLevel,
        tmp.fieldColor,
        tmp.fieldName,
        tmp.fieldDescription,
        tmp.fieldType,
        tmp.fieldBudget,
        tmp.fieldBudgetBalance,
        tmp.fieldFrequency,
        tmp.fieldTaxRefNum,
        tmp.fieldTransactionCount,
        tmp.fieldSum,
        tmp.fieldTransactionCountRollup,
        tmp.fieldSumRollup,
      ]);
    }
    return _fields;
  }

  static Fields<Category> get fieldsForColumnView {
    final tmp = Category.fromJson({});
    return Fields<Category>()
      ..setDefinitions([
        tmp.fieldLevel,
        tmp.fieldColor,
        tmp.fieldName,
        tmp.fieldDescription,
        tmp.fieldType,
        tmp.fieldBudgetBalance,
        tmp.fieldTransactionCount,
        tmp.fieldSum,
        tmp.fieldTransactionCountRollup,
        tmp.fieldSumRollup,
      ]);
  }

  void getAncestors(List<Category> list) {
    if (parentCategory != null) {
      list.add(parentCategory!);
      parentCategory!.getAncestors(list);
    }
  }

  static CategoryType getCategoryTypeFromName(final String categoryTypeName) {
    switch (categoryTypeName.toLowerCase()) {
      case 'income':
        return CategoryType.income;
      case 'expense':
        return CategoryType.expense;
      case 'recurringexpense':
      case 'expenserecurring':
        return CategoryType.recurringExpense;
      case 'saving':
        return CategoryType.saving;
      case 'reserved':
        return CategoryType.reserved;
      case 'transfer':
        return CategoryType.transfer;
      case 'investment':
        return CategoryType.investment;
      default:
        return CategoryType.none;
    }
  }

  static List<String> getCategoryTypes() {
    return [
      getTextFromType(CategoryType.income),
      getTextFromType(CategoryType.expense),
      getTextFromType(CategoryType.recurringExpense),
      getTextFromType(CategoryType.saving),
      getTextFromType(CategoryType.reserved),
      getTextFromType(CategoryType.transfer),
      getTextFromType(CategoryType.investment),
      getTextFromType(CategoryType.none),
    ];
  }

  Pair<Color, int> getColorAndLevel(int level) {
    if (this.fieldColor.value.isNotEmpty) {
      return Pair<Color, int>(getColorFromString(this.fieldColor.value), level);
    }

    if (parentCategory != null) {
      return parentCategory!.getColorAndLevel(level + 1);
    }

    // reach the top
    return Pair<Color, int>(Colors.transparent, 0);
  }

  Widget getColorAndNameWidget() {
    return Row(
      children: [
        getColorWidget(),
        gapMedium(),
        Expanded(
          child: getNameAsWidget(),
        ),
      ],
    );
  }

  Color getColorOrAncestorsColor() {
    final pair = getColorAndLevel(0);
    return pair.first;
  }

  Widget getColorWidget() {
    final Color fillColor = getColorOrAncestorsColor();
    final Color textColor = fillColor.a == 0 ? Colors.grey : contrastColor(fillColor);

    return Stack(
      alignment: Alignment.center,
      children: [
        MyCircle(colorFill: fillColor, size: 12),
        if (this.fieldColor.value.isNotEmpty && this.fieldLevel.getValueForDisplay(this) != '1')
          Text('#', style: TextStyle(fontSize: 10, color: textColor)),
      ],
    );
  }

  static String getName(final Category? instance) {
    return instance == null ? '' : (instance).fieldName.value;
  }

  Widget getNameAsWidget() {
    return TokenText(this.fieldName.value);
  }

  Widget getRectangleWidget() {
    return MyRectangle(
      colorFill: getColorFromString(this.fieldColor.value),
      size: 12,
    );
  }

  static String getTextFromType(final CategoryType type) {
    switch (type) {
      case CategoryType.income:
        return 'Income';
      case CategoryType.expense:
        return 'Expense';
      case CategoryType.recurringExpense:
        return 'ExpenseRecurring';
      case CategoryType.saving:
        return 'Saving';
      case CategoryType.reserved:
        return 'Reserved';
      case CategoryType.transfer:
        return 'Transfer';
      case CategoryType.investment:
        return 'Investment';
      case CategoryType.none:
        return 'None';
    }
  }

  String getTypeAsText() {
    return getTextFromType(fieldType.value);
  }

  static CategoryType getTypeFromInt(final int index) {
    if (isBetween(index, -1, CategoryType.values.length)) {
      return CategoryType.values[index];
    }
    return CategoryType.none;
  }

  bool get isExpense => fieldType.value == CategoryType.expense || fieldType.value == CategoryType.recurringExpense;

  bool get isIncome => fieldType.value == CategoryType.income || fieldType.value == CategoryType.investment;

  bool get isRecurring => fieldType.value == CategoryType.recurringExpense;

  ///
  /// The last part of the full name of the Category without the ancestor names
  ///
  String get leafName {
    return name.split(':').last;
  }

  ///
  /// The full name of the Category
  ///
  String get name {
    return fieldName.value;
  }

  Category? get parentCategory {
    return Data().categories.get(this.fieldParentId.value);
  }

  /// Updates the name based on the parent category by appending the leaf name of the category to its current name.
  /// If the parent category is not null, it extracts the leaf name from the current name, and then rebuilds the new full name
  /// by combining the parent's full name with the leaf name.
  void updateNameBaseOnParent() {
    if (parentCategory == null) {
      // No update needed since there is not parent for this category
    } else {
      // rebuild the new full name parent full name + this leaf name
      stashValueBeforeEditing();
      fieldName.value = '${parentCategory!.fieldName.value}:$leafName';
      Data().notifyMutationChanged(
        mutation: MutationType.changed,
        moneyObject: this,
        recalculateBalances: false,
      );
    }
  }
}

class MutateFieldColor extends StatefulWidget {
  const MutateFieldColor({
    required this.colorAsHex,
    required this.onEdited,
    super.key,
  });

  final String colorAsHex;
  final Function(String) onEdited;

  @override
  State<MutateFieldColor> createState() => _MutateFieldColorState();
}

class _MutateFieldColorState extends State<MutateFieldColor> {
  late TextEditingController controllerForText = TextEditingController(text: widget.colorAsHex);

  @override
  Widget build(BuildContext context) {
    late Color color = getColorFromString(controllerForText.text);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: MyTextInput(
            controller: controllerForText,
            onChanged: (String colorText) {
              setState(() {
                color = getColorFromString(colorText);
                widget.onEdited(controllerForText.text);
              });
            },
          ),
        ),
        gapLarge(),
        MyCircle(
          colorFill: color,
          colorBorder: Colors.grey,
          size: 40,
        ),
        gapLarge(),
        Expanded(
          child: ColorPicker(
            color: color,
            onColorChanged: (Color color) {
              setState(() {
                controllerForText.text = colorToHexString(color, includeAlpha: false);
                widget.onEdited(controllerForText.text);
              });
            },
          ),
        ),
      ],
    );
  }
}
