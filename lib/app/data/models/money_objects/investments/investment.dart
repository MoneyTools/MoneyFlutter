// ignore_for_file: unnecessary_this

import 'dart:ui';

import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/investments/picker_investment_type.dart';
import 'package:money/app/data/models/money_objects/investments/stock_cumulative.dart';
import 'package:money/app/data/models/money_objects/stock_splits/stock_split.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';

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
    this.id.value = id;
    this.security.value = security;
    this.unitPrice.value.setAmount(unitPrice);
    this.units.value = units;
    this.commission.value.setAmount(commission);
    this.markUpDown.value.setAmount(markUpDown);
    this.taxes.value.setAmount(taxes);
    this.fees.value.setAmount(fees);
    this.load.value.setAmount(load);
    this.investmentType.value = investmentType;
    this.tradeType.value = tradeType;
    this.taxExempt.value = taxExempt;
    this.withholding.value.setAmount(withholding);
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

  /// 4    Commission      money   0                    0
  FieldMoney commission = FieldMoney(
    name: 'Commission',
    serializeName: 'Commission',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).commission.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).commission.value.toDouble(),
  );

  /// 7    Fees            money   0                    0
  FieldMoney fees = FieldMoney(
    name: 'Fees',
    serializeName: 'Fees',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).fees.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).fees.value.toDouble(),
  );

  FieldMoney fieldActivityAmount = FieldMoney(
    name: 'ActivityAmount',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).activityAmount,
  );

  FieldMoney fieldHoldingSharesValue = FieldMoney(
    name: 'HoldingValue',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) {
      return MoneyModel(
        amount: (instance as Investment).holdingShares.value * instance._unitPriceAdjusted,
      );
    },
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

  FieldQuantity holdingShares = FieldQuantity(
    name: 'Holding',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).holdingShares.value,
  );

  /// Id
  //// 0    Id              bigint  0                    1
  FieldId id = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).uniqueId,
  );

  /// 9    InvestmentType  INT     1                    0
  FieldInt investmentType = FieldInt(
    name: 'Activity',
    serializeName: 'InvestmentType',
    align: TextAlign.center,
    columnWidth: ColumnWidth.tiny,
    type: FieldType.text,
    footer: FooterType.count,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment)._investmentTypeAsString,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).investmentType.value,
    getEditWidget: (final MoneyObject instance, Function(bool wasModified) onEdited) {
      return pickerInvestmentType(
        itemSelected: getInvestmentTypeFromValue((instance as Investment).investmentType.value),
        onSelected: (final InvestmentType newSelection) {
          instance.investmentType.value = newSelection.index;
          onEdited(true); // notify container
        },
      );
    },
    setValue: (final MoneyObject instance, dynamic value) {
      (instance as Investment).stashValueBeforeEditing();
      instance.investmentType.value = getInvestmentTypeFromValue(value).index;
    },
  );

  /// 8    Load            money   0                    0
  FieldMoney load = FieldMoney(
    name: 'Load',
    serializeName: 'Load',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).load.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).load.value.toDouble(),
  );

  /// 5    MarkUpDown      money   0                    0
  FieldMoney markUpDown = FieldMoney(
    name: 'MarkUpDown',
    serializeName: 'MarkUpDown',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).markUpDown.value.toDouble(),
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).markUpDown.value.toDouble(),
  );

  /// 1    Security        INT     1                    0
  FieldInt security = FieldInt(
    name: 'Security',
    serializeName: 'Security',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).security.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).security.value,
  );

  FieldString securitySymbol = FieldString(
    name: 'Symbol',
    columnWidth: ColumnWidth.tiny,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).symbol,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).securitySymbol.value,
    setValue: (final MoneyObject instance, dynamic value) {
      (instance as Investment).stashValueBeforeEditing();
      instance.securitySymbol.value = value as String;
    },
  );

  FieldString splitRatioAsText = FieldString(
    name: 'Split',
    align: TextAlign.right,
    columnWidth: ColumnWidth.tiny,
    footer: FooterType.none,
    getValueForDisplay: (final MoneyObject instance) =>
        'x ${formatDoubleTrimZeros((instance as Investment)._splitRatio)}',
  );

  /// 11   TaxExempt       bit     0                    0
  FieldInt taxExempt = FieldInt(
    name: 'Taxable',
    serializeName: 'TaxExempt',
    columnWidth: ColumnWidth.nano,
    align: TextAlign.center,
    type: FieldType.text,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).taxExempt.value == 1 ? 'No' : 'Yes',
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).taxExempt.value,
  );

  /// 6    Taxes           money   0                    0
  FieldMoney taxes = FieldMoney(
    name: 'Taxes',
    serializeName: 'Taxes',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).taxes.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).taxes.value.toDouble(),
  );

  /// 10   TradeType       INT     0                    0
  FieldInt tradeType = FieldInt(
    name: 'TradeType',
    serializeName: 'TradeType',
    type: FieldType.text,
    getValueForDisplay: (final MoneyObject instance) =>
        InvestmentTradeType.values[(instance as Investment).tradeType.value].name.toUpperCase(),
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).tradeType.value,
  );

  FieldString transactionAccountName = FieldString(
    name: 'Account',
    columnWidth: ColumnWidth.largest,
    getValueForDisplay: (final MoneyObject instance) {
      return (instance as Investment).transactionInstance?.getAccountName() ?? '<Account?>';
    },
  );

  FieldDate transactionDate = FieldDate(
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
  FieldMoney unitPrice = FieldMoney(
    name: 'Price',
    serializeName: 'UnitPrice',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).unitPrice.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).unitPrice.value.toDouble(),
  );

  FieldMoney unitPriceAdjusted = FieldMoney(
    name: 'Price A.S.',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment)._unitPriceAdjusted,
  );

  /// 3    Units           money   0                    0
  FieldQuantity units = FieldQuantity(
    name: 'Units',
    serializeName: 'Units',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).effectiveUnits,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).units.value,
  );

  FieldQuantity unitsAdjusted = FieldQuantity(
    name: 'Units A.S.',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).effectiveUnitsAdjusted,
  );

  /// 12   Withholding     money   0                    0
  FieldMoney withholding = FieldMoney(
    name: 'Withholding',
    serializeName: 'Withholding',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).withholding.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).withholding.value.toDouble(),
  );

  double _splitRatio = 1;

  /// The actual transaction date.
  Transaction? _transactionInstance;

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  @override
  String getRepresentation() {
    return security.value.toString();
  }

  @override
  String toString() {
    return '$uniqueId $date ${investmentType.getValueForDisplay(this)} ${securitySymbol.getValueForDisplay(this)} $effectiveUnits ${unitPrice.value} ${holdingShares.value} $activityAmount';
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  static final Fields<Investment> _fields = Fields<Investment>();

  InvestmentType get actionType => getInvestmentTypeFromValue(this.investmentType.value);

  double get activityAmount {
    // if (investmentType.value != InvestmentType.dividend.index &&
    //     investmentType.value != InvestmentType.add.index &&
    //     investmentType.value != InvestmentType.remove.index) {
    return transactionInstance?.amount.value.toDouble() ?? 0.00;
    // }
    // return 0.00;
  }

  void applySplits(List<StockSplit> splits) {
    _splitRatio = 1;
    for (final StockSplit split in splits) {
      this._applySplit(split);
    }
  }

  DateTime get date => this.transactionInstance?.dateTime.value ?? DateTime.now();

  double get effectiveUnits {
    if (this.units.value == 0) {
      return 0;
    }

    return this.units.value * _signBasedOnActivity;
  }

  // Buy is a positive value
  // Sell is negative value
  double get effectiveUnitsAdjusted {
    if (this.units.value == 0) {
      return 0;
    }

    return this.units.value * this._splitRatio * _signBasedOnActivity;
  }

  static Fields<Investment> get fields {
    if (_fields.isEmpty) {
      final tmp = Investment.fromJson({});
      _fields.setDefinitions([
        tmp.id,
        tmp.transactionDate,
        tmp.transactionAccountName,
        tmp.security,
        tmp.securitySymbol,
        tmp.investmentType,
        tmp.units,
        tmp.splitRatioAsText,
        tmp.unitsAdjusted,
        tmp.holdingShares,
        tmp.unitPrice,
        tmp.unitPriceAdjusted,
        tmp.commission,
        tmp.markUpDown,
        tmp.taxes,
        tmp.fees,
        tmp.load,
        tmp.tradeType,
        tmp.taxExempt,
        tmp.withholding,
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
        tmp.transactionDate,
        tmp.transactionAccountName,
        tmp.securitySymbol,
        tmp.investmentType,
        tmp.tradeType,
        tmp.units,
        tmp.splitRatioAsText,
        tmp.unitsAdjusted,
        tmp.holdingShares,
        tmp.unitPrice,
        tmp.unitPriceAdjusted,
        tmp.commission,
        tmp.fees,
        tmp.load,
        tmp.fieldActivityAmount,
        tmp.fieldHoldingSharesValue,
        tmp.fieldNetValueOfEvent,
      ]);
  }

  StockCumulative get finalAmount {
    StockCumulative cumulative = StockCumulative();
    cumulative.quantity = -1 * effectiveUnits * this.unitPrice.value.toDouble();
    cumulative.amount += this.commission.value.toDouble();
    return cumulative;
  }

  double get originalCostBasis {
    // looking for the original un-split cost basis at the date of this transaction.
    double proceeds = this.unitPrice.value.toDouble() * this.units.value;

    if (this.transactionInstance!.amount.value.toDouble() != 0) {
      // We may have paid more for the stock than "price" in a buy transaction because of brokerage fees and
      // this can be included in the cost basis.  We may have also received less than "price" in a sale
      // transaction, and that can also reduce our capital gain, so we use the transaction amount if we
      // have one.
      return this.transactionInstance!.amount.value.toDouble().abs();
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
        a.investmentType.value,
        b.investmentType.value,
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

  String get symbol => Data().securities.getSymbolFromId(security.value);

  double get transactionHoldingValue => this.holdingShares.value * this._unitPriceAdjusted;

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
    if (investmentType.value == InvestmentType.dividend.index) {
      return transactionInstance?.amount.value.toDouble() ?? 0.00;
    }
    return 0.00;
  }

  void _applySplit(StockSplit s) {
    if (this.date.isBefore(s.date.value!) && s.denominator.value != 0 && s.numerator.value != 0) {
      _splitRatio *= s.numerator.value / s.denominator.value;
    }
  }

  String get _investmentTypeAsString => getInvestmentTypeTextFromValue(this.investmentType.value);

  int get _signBasedOnActivity =>
      [InvestmentType.buy, InvestmentType.add].contains(getInvestmentTypeFromValue(this.investmentType.value)) ? 1 : -1;

  double get _unitPriceAdjusted => this.unitPrice.value.toDouble() / this._splitRatio;
}
