// ignore_for_file: unnecessary_this

import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/investments/picker_investment_type.dart';
import 'package:money/app/data/models/money_objects/investments/stock_cumulative.dart';
import 'package:money/app/data/models/money_objects/stock_splits/stock_split.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item_card.dart';

class Investment extends MoneyObject {
  Investment({
    required final int id, // 1
    required final int security, // 1
    required final double unitPrice, // 2
    required final double units, // 3
    final double commission = 0, // 4
    final double markUpDown = 0, // 5
    final double taxes = 0, // 6
    final double fees = 0, // 7
    final double load = 0, // 8
    required final int investmentType, // 9
    required final int tradeType, // 10
    final int taxExempt = 0, // 11
    final double withholding = 0, // 12
  }) {
    this.fieldId.value = id;
    this.fieldSecurity.value = security;
    this.fieldUnitPrice.value.setAmount(unitPrice);
    this.fieldUnits.value = units;
    this.fieldCommission.value.setAmount(commission);
    this.fieldMarkUpDown.value.setAmount(markUpDown);
    this.fieldTaxes.value.setAmount(taxes);
    this.fieldFees.value.setAmount(fees);
    this.fieldLoad.value.setAmount(load);
    this.fieldInvestmentType.value = investmentType;
    this.fieldTradeType.value = tradeType;
    this.fieldTaxExempt.value = taxExempt;
    this.fieldWithholding.value.setAmount(withholding);
  }

  /// Constructor from a SQLite row
  factory Investment.fromJson(final MyJson row) {
    return Investment(
// 1
      id: row.getInt('Id', -1),
// 1
      security: row.getInt('Security'),
// 2
      unitPrice: row.getDouble('UnitPrice'),
// 3
      units: row.getDouble('Units'),
// 4
      commission: row.getDouble('Commission'),
// 5
      markUpDown: row.getDouble('MarkUpDown'),
// 6
      taxes: row.getDouble('Taxes'),
// 7
      fees: row.getDouble('Fees'),
// 8
      load: row.getDouble('Load'),
// 9
      investmentType: row.getInt('InvestmentType'),
// 10
      tradeType: row.getInt('TradeType'),
// 11
      taxExempt: row.getInt('TaxExempt'),
// 12
      withholding: row.getDouble('Withholding'),
    );
  }

  FieldMoney activityDividend = FieldMoney(
    name: 'ActivityDividend',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment)._activityDividend,
  );

  FieldMoney fieldActivityAmount = FieldMoney(
    name: 'ActivityAmount',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).activityAmount,
  );

  /// 4    Commission      money   0                    0
  FieldMoney fieldCommission = FieldMoney(
    name: 'Commission',
    serializeName: 'Commission',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).fieldCommission.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldCommission.value.toDouble(),
  );

  /// 7    Fees            money   0                    0
  FieldMoney fieldFees = FieldMoney(
    name: 'Fees',
    serializeName: 'Fees',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).fieldFees.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldFees.value.toDouble(),
  );

  FieldQuantity fieldHoldingShares = FieldQuantity(
    name: 'Holding',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).fieldHoldingShares.value,
  );

  FieldMoney fieldHoldingSharesValue = FieldMoney(
    name: 'HoldingValue',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) {
      return MoneyModel(
        amount: (instance as Investment).fieldHoldingShares.value * instance._unitPriceAdjusted,
      );
    },
  );

  /// Id
  //// 0    Id              bigint  0                    1
  FieldId fieldId = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).uniqueId,
  );

  /// 9    InvestmentType  INT     1                    0
  FieldInt fieldInvestmentType = FieldInt(
    name: 'Activity',
    serializeName: 'InvestmentType',
    align: TextAlign.center,
    columnWidth: ColumnWidth.tiny,
    type: FieldType.text,
    footer: FooterType.count,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment)._investmentTypeAsString,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldInvestmentType.value,
    getEditWidget: (final MoneyObject instance, Function(bool wasModified) onEdited) {
      return pickerInvestmentType(
        itemSelected: getInvestmentTypeFromValue((instance as Investment).fieldInvestmentType.value),
        onSelected: (final InvestmentType newSelection) {
          instance.fieldInvestmentType.value = newSelection.index;
          onEdited(true); // notify container
        },
      );
    },
    setValue: (final MoneyObject instance, dynamic value) {
      (instance as Investment).stashValueBeforeEditing();
      instance.fieldInvestmentType.value = getInvestmentTypeFromValue(value).index;
    },
  );

  /// 8    Load            money   0                    0
  FieldMoney fieldLoad = FieldMoney(
    name: 'Load',
    serializeName: 'Load',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).fieldLoad.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldLoad.value.toDouble(),
  );

  /// 5    MarkUpDown      money   0                    0
  FieldMoney fieldMarkUpDown = FieldMoney(
    name: 'MarkUpDown',
    serializeName: 'MarkUpDown',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).fieldMarkUpDown.value.toDouble(),
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldMarkUpDown.value.toDouble(),
  );

  FieldMoney fieldNetValueOfEvent = FieldMoney(
    name: 'NetValue',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) {
      return MoneyModel(
        amount: (instance as Investment).transactionNetValue,
      );
    },
  );

  /// 1    Security        INT     1                    0
  FieldInt fieldSecurity = FieldInt(
    name: 'Security',
    serializeName: 'Security',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).fieldSecurity.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldSecurity.value,
  );

  FieldString fieldSecuritySymbol = FieldString(
    name: 'Symbol',
    columnWidth: ColumnWidth.tiny,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).symbol,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldSecuritySymbol.value,
    setValue: (final MoneyObject instance, dynamic value) {
      (instance as Investment).stashValueBeforeEditing();
      instance.fieldSecuritySymbol.value = value as String;
    },
  );

  FieldString fieldSplitRatioAsText = FieldString(
    name: 'Split',
    align: TextAlign.right,
    columnWidth: ColumnWidth.tiny,
    footer: FooterType.none,
    getValueForDisplay: (final MoneyObject instance) =>
        'x ${formatDoubleTrimZeros((instance as Investment)._splitRatio)}',
  );

  /// 11   TaxExempt       bit     0                    0
  FieldInt fieldTaxExempt = FieldInt(
    name: 'Taxable',
    serializeName: 'TaxExempt',
    columnWidth: ColumnWidth.nano,
    align: TextAlign.center,
    type: FieldType.text,
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as Investment).fieldTaxExempt.value == 1 ? 'No' : 'Yes',
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldTaxExempt.value,
  );

  /// 6    Taxes           money   0                    0
  FieldMoney fieldTaxes = FieldMoney(
    name: 'Taxes',
    serializeName: 'Taxes',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).fieldTaxes.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldTaxes.value.toDouble(),
  );

  /// 10   TradeType       INT     0                    0
  FieldInt fieldTradeType = FieldInt(
    name: 'TradeType',
    serializeName: 'TradeType',
    type: FieldType.text,
    getValueForDisplay: (final MoneyObject instance) =>
        InvestmentTradeType.values[(instance as Investment).fieldTradeType.value].name.toUpperCase(),
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldTradeType.value,
  );

  FieldString fieldTransactionAccountName = FieldString(
    name: 'Account',
    columnWidth: ColumnWidth.largest,
    getValueForDisplay: (final MoneyObject instance) {
      return (instance as Investment).transactionInstance?.accountName ?? '<Account?>';
    },
  );

  FieldDate fieldTransactionDate = FieldDate(
    name: 'Date',
    columnWidth: ColumnWidth.small,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).date,
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByDateAndInvestmentType(
      a as Investment,
      b as Investment,
      ascending,
      false,
    ),
  );

  /// --------------------------------------------
  /// Not Persisted
  ///

  /// 2    UnitPrice       money   1
  FieldMoney fieldUnitPrice = FieldMoney(
    name: 'Price',
    serializeName: 'UnitPrice',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).fieldUnitPrice.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldUnitPrice.value.toDouble(),
  );

  FieldMoney fieldUnitPriceAdjusted = FieldMoney(
    name: 'Price A.S.',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment)._unitPriceAdjusted,
  );

  /// 3    Units           money   0                    0
  FieldQuantity fieldUnits = FieldQuantity(
    name: 'Units',
    serializeName: 'Units',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).effectiveUnits,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fieldUnits.value,
  );

  FieldQuantity fieldUnitsAdjusted = FieldQuantity(
    name: 'Units A.S.',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).effectiveUnitsAdjusted,
  );

  /// 12   Withholding     money   0                    0
  FieldMoney fieldWithholding = FieldMoney(
    name: 'Withholding',
    serializeName: 'Withholding',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).fieldWithholding.value,
    getValueForSerialization: (final MoneyObject instance) =>
        (instance as Investment).fieldWithholding.value.toDouble(),
  );

  double _splitRatio = 1;

  /// The actual transaction date.
  Transaction? _transactionInstance;

  @override
  Widget buildFieldsAsWidgetForSmallScreen() {
    return MyListItemAsCard(
      leftTopAsWidget: fieldTransactionDate.getValueAsWidget(this),
      leftBottomAsWidget: fieldTransactionAccountName.getValueAsWidget(this),
      rightTopAsWidget: fieldSecuritySymbol.getValueAsWidget(this),
      rightBottomAsWidget: fieldActivityAmount.getValueAsWidget(this),
    );
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  @override
  String getRepresentation() {
    return fieldSecurity.value.toString();
  }

  @override
  String toString() {
    return '$uniqueId $date ${fieldInvestmentType.getValueForDisplay(this)} ${fieldSecuritySymbol.getValueForDisplay(this)} $effectiveUnits ${fieldUnitPrice.value} ${fieldHoldingShares.value} $activityAmount';
  }

  @override
  int get uniqueId => fieldId.value;

  @override
  set uniqueId(value) => fieldId.value = value;

  static final Fields<Investment> _fields = Fields<Investment>();

  InvestmentType get actionType => getInvestmentTypeFromValue(this.fieldInvestmentType.value);

  double get activityAmount {
    // if (investmentType.value != InvestmentType.dividend.index &&
    //     investmentType.value != InvestmentType.add.index &&
    //     investmentType.value != InvestmentType.remove.index) {
    return transactionInstance?.fieldAmount.value.toDouble() ?? 0.00;
    // }
    // return 0.00;
  }

  void applySplits(List<StockSplit> splits) {
    _splitRatio = 1;
    for (final StockSplit split in splits) {
      this._applySplit(split);
    }
  }

  DateTime get date => this.transactionInstance?.fieldDateTime.value ?? DateTime.now();

  double get effectiveUnits {
    if (this.fieldUnits.value == 0) {
      return 0;
    }

    return this.fieldUnits.value * _signBasedOnActivity;
  }

  // Buy is a positive value
  // Sell is negative value
  double get effectiveUnitsAdjusted {
    if (this.fieldUnits.value == 0) {
      return 0;
    }

    return this.fieldUnits.value * this._splitRatio * _signBasedOnActivity;
  }

  static Fields<Investment> get fields {
    if (_fields.isEmpty) {
      final tmp = Investment.fromJson({});
      _fields.setDefinitions([
        tmp.fieldId,
        tmp.fieldTransactionDate,
        tmp.fieldTransactionAccountName,
        tmp.fieldSecurity,
        tmp.fieldSecuritySymbol,
        tmp.fieldInvestmentType,
        tmp.fieldUnits,
        tmp.fieldSplitRatioAsText,
        tmp.fieldUnitsAdjusted,
        tmp.fieldHoldingShares,
        tmp.fieldUnitPrice,
        tmp.fieldUnitPriceAdjusted,
        tmp.fieldCommission,
        tmp.fieldMarkUpDown,
        tmp.fieldTaxes,
        tmp.fieldFees,
        tmp.fieldLoad,
        tmp.fieldTradeType,
        tmp.fieldTaxExempt,
        tmp.fieldWithholding,
        tmp.fieldActivityAmount,
        tmp.fieldHoldingSharesValue,
      ]);
    }

    return _fields;
  }

  static Fields<Investment> get fieldsForColumnView {
    final tmp = Investment.fromJson({});
    return Fields<Investment>()
      ..setDefinitions([
        tmp.fieldTransactionDate,
        tmp.fieldTransactionAccountName,
        tmp.fieldSecuritySymbol,
        tmp.fieldInvestmentType,
        tmp.fieldTradeType,
        tmp.fieldUnits,
        tmp.fieldSplitRatioAsText,
        tmp.fieldUnitsAdjusted,
        tmp.fieldHoldingShares,
        tmp.fieldUnitPrice,
        tmp.fieldUnitPriceAdjusted,
        tmp.fieldCommission,
        tmp.fieldFees,
        tmp.fieldLoad,
        tmp.fieldActivityAmount,
        tmp.fieldHoldingSharesValue,
        tmp.fieldNetValueOfEvent,
      ]);
  }

  StockCumulative get finalAmount {
    StockCumulative cumulative = StockCumulative();
    cumulative.quantity = -1 * effectiveUnits * this.fieldUnitPrice.value.toDouble();
    cumulative.amount += this.fieldCommission.value.toDouble();
    return cumulative;
  }

  double get originalCostBasis {
    // looking for the original un-split cost basis at the date of this transaction.
    double proceeds = this.fieldUnitPrice.value.toDouble() * this.fieldUnits.value;

    if (this.transactionInstance!.fieldAmount.value.toDouble() != 0) {
      // We may have paid more for the stock than "price" in a buy transaction because of brokerage fees and
      // this can be included in the cost basis.  We may have also received less than "price" in a sale
      // transaction, and that can also reduce our capital gain, so we use the transaction amount if we
      // have one.
      return this.transactionInstance!.fieldAmount.value.toDouble().abs();
    }

    // But if the sale proceeds were not recorded for some reason, then we fall back on the proceeds.
    return proceeds;
  }

  static int sortByDateAndInvestmentType(
    final Investment a,
    final Investment b,
    final bool ascending,
    bool ta,
  ) {
    int result = sortByDate(a.date, b.date, ascending);

    if (result == 0) {
      // If on the same date sort so that "Buy" is before "Sell"
      result = sortByValue(
        a.fieldInvestmentType.value,
        b.fieldInvestmentType.value,
        ascending,
      );
    }

    // if (result == 0) {
    //   // then if needed sort by amount
    //   result = sortByValue(
    //     a.finalAmount.amount.abs(),
    //     b.finalAmount.amount.abs(),
    //     !ascending,
    //   );
    // }
    return result;
  }

  String get symbol => Data().securities.getSymbolFromId(fieldSecurity.value);

  double get transactionHoldingValue => this.fieldHoldingShares.value * this._unitPriceAdjusted;

  /// The actual transaction date.
  Transaction? get transactionInstance {
    _transactionInstance ??= Data().transactions.get(this.uniqueId);
    return _transactionInstance;
  }

  /// The actual transaction date.
  set transactionInstance(Transaction? value) {
    _transactionInstance = value;
  }

  double get transactionNetValue => transactionHoldingValue + this.activityAmount;

  double get _activityDividend {
    if (fieldInvestmentType.value == InvestmentType.dividend.index) {
      return transactionInstance?.fieldAmount.value.toDouble() ?? 0.00;
    }
    return 0.00;
  }

  void _applySplit(final StockSplit s) {
    if (this.date.isBefore(s.fieldDate.value!) && s.fieldDenominator.value != 0 && s.fieldNumerator.value != 0) {
      _splitRatio *= s.fieldNumerator.value / s.fieldDenominator.value;
    }
  }

  String get _investmentTypeAsString => getInvestmentTypeTextFromValue(this.fieldInvestmentType.value);

  int get _signBasedOnActivity =>
      [InvestmentType.buy, InvestmentType.add].contains(getInvestmentTypeFromValue(this.fieldInvestmentType.value))
          ? 1
          : -1;

  double get _unitPriceAdjusted => this.fieldUnitPrice.value.toDouble() / this._splitRatio;
}
