// ignore_for_file: unnecessary_this

import 'package:money/helpers/list_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/investments/investment_types.dart';
import 'package:money/models/money_objects/investments/stock_cumulative.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';

class Investment extends MoneyObject {
  static final Fields<Investment> _fields = Fields<Investment>();

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
        tmp.amount,
        tmp.runningBalance,
      ]);
    }

    return _fields;
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    return security.value.toString();
  }

  /// Id
  //// 0    Id              bigint  0                    1
  FieldId id = FieldId(
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).uniqueId,
  );

  /// 1    Security        INT     1                    0
  FieldInt security = FieldInt(
    importance: 1,
    name: 'Security',
    serializeName: 'Security',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).security.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).security.value,
  );

  /// 2    UnitPrice       money   1                    0
  FieldMoney unitPrice = FieldMoney(
    importance: 3,
    name: 'Price',
    serializeName: 'UnitPrice',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).unitPrice.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).unitPrice.value,
  );

  /// 3    Units           money   0                    0
  FieldQuantity units = FieldQuantity(
    importance: 2,
    name: 'Units',
    serializeName: 'Units',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).units.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).units.value,
  );

  /// 4    Commission      money   0                    0
  FieldMoney commission = FieldMoney(
    name: 'Commission',
    serializeName: 'Commission',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).commission.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).commission.value,
  );

  /// 5    MarkUpDown      money   0                    0
  FieldMoney markUpDown = FieldMoney(
    name: 'MarkUpDown',
    serializeName: 'MarkUpDown',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).markUpDown.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).markUpDown.value,
  );

  /// 6    Taxes           money   0                    0
  FieldMoney taxes = FieldMoney(
    name: 'Taxes',
    serializeName: 'Taxes',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).taxes.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).taxes.value,
  );

  /// 7    Fees            money   0                    0
  FieldMoney fees = FieldMoney(
    name: 'Fees',
    serializeName: 'Fees',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).fees.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).fees.value,
  );

  /// 8    Load            money   0                    0
  FieldMoney load = FieldMoney(
    name: 'Load',
    serializeName: 'Load',
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).load.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).load.value,
  );

  /// 9    InvestmentType  INT     1                    0
  FieldInt investmentType = FieldInt(
    name: 'Action',
    serializeName: 'InvestmentType',
    align: TextAlign.center,
    columnWidth: ColumnWidth.tiny,
    type: FieldType.text,
    valueFromInstance: (final MoneyObject instance) =>
        getInvestmentTypeTextFromValue((instance as Investment).investmentType.value),
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).investmentType.value,
  );

  /// 10   TradeType       INT     0                    0
  FieldInt tradeType = FieldInt(
    name: 'TradeType',
    serializeName: 'TradeType',
    type: FieldType.text,
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) =>
        InvestmentTradeType.values[(instance as Investment).tradeType.value].name.toUpperCase(),
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).tradeType.value,
  );

  /// 11   TaxExempt       bit     0                    0
  FieldInt taxExempt = FieldInt(
    name: 'Taxable',
    serializeName: 'TaxExempt',
    columnWidth: ColumnWidth.nano,
    align: TextAlign.center,
    useAsColumn: false,
    type: FieldType.text,
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).taxExempt.value == 1 ? 'No' : 'Yes',
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).taxExempt.value,
  );

  /// 12   Withholding     money   0                    0
  FieldMoney withholding = FieldMoney(
    name: 'Withholding',
    serializeName: 'Withholding',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).withholding.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Investment).withholding.value,
  );

  /// --------------------------------------------
  /// Not Persisted
  ///

  /// The actual transaction date.
  Transaction? transactionInstance;

  DateTime get date => this.transactionInstance!.dateTime.value!;

  double get originalCostBasis {
    // looking for the original un-split cost basis at the date of this transaction.
    double proceeds = this.unitPrice.value.amount * this.units.value;

    if (this.transactionInstance!.amount.value.amount != 0) {
      // We may have paid more for the stock than "price" in a buy transaction because of brokerage fees and
      // this can be included in the cost basis.  We may have also received less than "price" in a sale
      // transaction, and that can also reduce our capital gain, so we use the transaction amount if we
      // have one.
      return this.transactionInstance!.amount.value.amount.abs();
    }

    // But if the sale proceeds were not recorded for some reason, then we fall back on the proceeds.
    return proceeds;
  }

  FieldDate transactionDate = FieldDate(
    name: 'Date',
    importance: 0,
    useAsColumn: true,
    columnWidth: ColumnWidth.small,
    valueFromInstance: (final MoneyObject instance) => (instance as Investment).date,
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) =>
        sortByDateAndInvestmentType(a as Investment, b as Investment, ascending, false),
  );

  FieldString securitySymbol = FieldString(
    name: 'Symbol',
    useAsColumn: true,
    columnWidth: ColumnWidth.small,
    valueFromInstance: (final MoneyObject instance) =>
        Data().securities.getSymbolFromId((instance as Investment).security.value),
  );

  FieldString transactionAccountName = FieldString(
      name: 'Account',
      useAsColumn: true,
      columnWidth: ColumnWidth.largest,
      valueFromInstance: (final MoneyObject instance) {
        final investment = instance as Investment;
        final Transaction? transaction = Data().transactions.get(investment.uniqueId);
        if (transaction != null) {
          return Data().accounts.getNameFromId(transaction.accountId.value);
        }
        return '?not found?';
      });

  FieldMoney amount = FieldMoney(
      name: 'Amount',
      valueFromInstance: (final MoneyObject instance) {
        return MoneyModel(amount: (instance as Investment).finalAmount.amount);
      });

  StockCumulative get finalAmount {
    StockCumulative cumulative = StockCumulative();
    switch (InvestmentType.values[this.investmentType.value]) {
      // case InvestmentType.add:
      case InvestmentType.buy:
        // Commission adds to the cost
        cumulative.quantity += this.units.value;
        cumulative.amount = this.units.value * this.unitPrice.value.amount;
        cumulative.amount += this.commission.value.amount;

      // case InvestmentType.remove:
      case InvestmentType.sell:
        // commission reduce the revenue
        cumulative.quantity -= this.units.value;
        cumulative.amount = this.units.value * this.unitPrice.value.amount;
        cumulative.amount -= this.commission.value.amount;

      default:
      //
    }
    return cumulative;
  }

  FieldMoney runningBalance = FieldMoney(
      name: 'Balance',
      valueFromInstance: (final MoneyObject instance) {
        return (instance as Investment).runningBalance.value;
      });

  Investment({
    required final int id, // 1
    required final int security, // 1
    required final double unitPrice, // 2
    required final double units, // 3
    required final double commission, // 4
    required final double markUpDown, // 5
    required final double taxes, // 6
    required final double fees, // 7
    required final double load, // 8
    required final int investmentType, // 9
    required final int tradeType, // 10
    required final int taxExempt, // 11
    required final double withholding, // 12
  }) {
    this.id.value = id;
    this.security.value = security;
    this.unitPrice.value.amount = unitPrice;
    this.units.value = units;
    this.commission.value.amount = commission;
    this.markUpDown.value.amount = markUpDown;
    this.taxes.value.amount = taxes;
    this.fees.value.amount = fees;
    this.load.value.amount = load;
    this.investmentType.value = investmentType;
    this.tradeType.value = tradeType;
    this.taxExempt.value = taxExempt;
    this.withholding.value.amount = withholding;
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

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

  static int sortByDateAndInvestmentType(final Investment a, final Investment b, final bool ascending, bool ta) {
    int result = sortByDate(a.date, b.date, ascending);

    if (result == 0) {
      // If on the same date sort so that "Buy" is before "Sell"
      result = sortByValue(a.investmentType.value, b.investmentType.value, ascending);
    }

    if (result == 0) {
      // If on the same date sort so that "Buy" is before "Sell"
      result = sortByValue(a.finalAmount.amount.abs(), b.finalAmount.amount.abs(), !ascending);
    }
    return result;
  }
}
