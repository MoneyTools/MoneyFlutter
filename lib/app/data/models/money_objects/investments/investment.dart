// ignore_for_file: unnecessary_this

import 'dart:ui';

import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/investments/stock_cumulative.dart';
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

  FieldMoney activityAmount = FieldMoney(
    name: 'ActivityAmount',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).amount,
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

  FieldQuantity holdingShares = FieldQuantity(
    name: 'Holding',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) {
      return (instance as Investment).holdingShares.value;
    },
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
    getValueForDisplay: (final MoneyObject instance) => getInvestmentTypeTextFromValue(
      (instance as Investment).investmentType.value,
    ),
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).investmentType.value,
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
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).markUpDown.value.toDouble(),
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).markUpDown.value.toDouble(),
  );

  FieldMoney runningBalance = FieldMoney(
    name: 'Balance',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) {
      return (instance as Investment).runningBalance.value;
    },
  );

  /// 1    Security        INT     1                    0
  FieldInt security = FieldInt(
    importance: 1,
    name: 'Security',
    serializeName: 'Security',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).security.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).security.value,
  );

  FieldString securitySymbol = FieldString(
    name: 'Symbol',
    useAsColumn: true,
    columnWidth: ColumnWidth.tiny,
    getValueForDisplay: (final MoneyObject instance) =>
        Data().securities.getSymbolFromId((instance as Investment).security.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).securitySymbol.value,
    setValue: (final MoneyObject instance, dynamic value) {
      (instance as Investment).stashValueBeforeEditing();
      instance.securitySymbol.value = value as String;
    },
  );

  /// 11   TaxExempt       bit     0                    0
  FieldInt taxExempt = FieldInt(
    name: 'Taxable',
    serializeName: 'TaxExempt',
    columnWidth: ColumnWidth.nano,
    align: TextAlign.center,
    useAsColumn: false,
    type: FieldType.text,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).taxExempt.value == 1 ? 'No' : 'Yes',
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).taxExempt.value,
  );

  /// 6    Taxes           money   0                    0
  FieldMoney taxes = FieldMoney(
    name: 'Taxes',
    serializeName: 'Taxes',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).taxes.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).taxes.value.toDouble(),
  );

  /// 10   TradeType       INT     0                    0
  FieldInt tradeType = FieldInt(
    name: 'TradeType',
    serializeName: 'TradeType',
    type: FieldType.text,
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        InvestmentTradeType.values[(instance as Investment).tradeType.value].name.toUpperCase(),
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).tradeType.value,
  );

  FieldString transactionAccountName = FieldString(
    name: 'Account',
    useAsColumn: true,
    columnWidth: ColumnWidth.largest,
    getValueForDisplay: (final MoneyObject instance) {
      return (instance as Investment).transactionInstance?.getAccountName() ?? '<Account?>';
    },
  );

  FieldDate transactionDate = FieldDate(
    name: 'Date',
    importance: 0,
    useAsColumn: true,
    columnWidth: ColumnWidth.small,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).date,
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByDateAndInvestmentType(
      a as Investment,
      b as Investment,
      ascending,
      false,
    ),
  );

  /// The actual transaction date.
  Transaction? transactionInstance;

  /// --------------------------------------------
  /// Not Persisted
  ///

  /// 2    UnitPrice       money   1                    0
  FieldMoney unitPrice = FieldMoney(
    importance: 3,
    name: 'Price',
    serializeName: 'UnitPrice',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).unitPrice.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).unitPrice.value.toDouble(),
  );

  /// 3    Units           money   0                    0
  FieldQuantity units = FieldQuantity(
    importance: 2,
    name: 'Units',
    serializeName: 'Units',
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).effectiveUnits,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).units.value,
  );

  FieldMoney valueOfHoldingShares = FieldMoney(
    name: 'HoldingValue',
    footer: FooterType.average,
    getValueForDisplay: (final MoneyObject instance) {
      return MoneyModel(amount: (instance as Investment).holdingShares.value);
    },
  );

  /// 12   Withholding     money   0                    0
  FieldMoney withholding = FieldMoney(
    name: 'Withholding',
    serializeName: 'Withholding',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as Investment).withholding.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Investment).withholding.value.toDouble(),
  );

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  @override
  String getRepresentation() {
    return security.value.toString();
  }

  @override
  String toString() {
    return '$uniqueId $date ${investmentType.getValueForDisplay(this)} ${securitySymbol.getValueForDisplay(this)} $effectiveUnits ${unitPrice.value} ${holdingShares.value}';
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  static final Fields<Investment> _fields = Fields<Investment>();

  double get amount => this.transactionInstance?.amount.value.toDouble() ?? 0.00;

  DateTime get date => this.transactionInstance?.dateTime.value ?? DateTime.now();

  double get effectiveUnits {
    if (this.units.value == 0) {
      return 0;
    }

    if (getInvestmentTypeFromValue(this.investmentType.value) != InvestmentType.buy) {
      return this.units.value * -1;
    }
    return this.units.value;
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
        tmp.unitPrice,
        tmp.commission,
        tmp.markUpDown,
        tmp.taxes,
        tmp.fees,
        tmp.load,
        tmp.tradeType,
        tmp.taxExempt,
        tmp.withholding,
        tmp.activityAmount,
        tmp.holdingShares,
        tmp.valueOfHoldingShares,
        tmp.runningBalance,
      ]);
    }

    return _fields;
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
}
