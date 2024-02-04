// Imports
import 'package:money/helpers/string_helper.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transaction_types.dart';
import 'package:money/widgets/list_view/list_item_card.dart';

// Exports
export 'package:money/models/money_objects/transactions/transaction_types.dart';

/// Main source of information for this App
/// All transactions are loaded in this class [Transaction] and [Split]
class Transaction extends MoneyObject {
  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  /// ID
  /// SQLite  0|Id|bigint|0||1
  FieldId<Transaction> id = FieldId<Transaction>(
    importance: 0,
    valueFromInstance: (final Transaction instance) => instance.id.value,
    valueForSerialization: (final Transaction instance) => instance.id.value,
  );

  /// Account Id
  /// SQLite  1|Account|INT|1||0
  Field<Transaction, int> accountId = Field<Transaction, int>(
    importance: 1,
    type: FieldType.text,
    name: 'Account',
    serializeName: 'Account',
    defaultValue: -1,
    // useAsColumn: false,
    // useAsDetailPanels: false,
    valueFromInstance: (final Transaction instance) => Data().accounts.getNameFromId(instance.accountId.value),
    valueForSerialization: (final Transaction instance) => instance.accountId.value,
  );

  /// Date
  /// SQLite 2|Date|datetime|1||0
  FieldDate<Transaction> dateTime = FieldDate<Transaction>(
    importance: 2,
    name: 'Date',
    serializeName: 'Date',
    valueFromInstance: (final Transaction instance) => instance.dateTimeAsText,
    valueForSerialization: (final Transaction instance) => dateAsIso8601OrDefault(instance.dateTime.value),
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByDate(a.dateTime.value, b.dateTime.value, ascending),
  );

  /// Status N | E | C | R
  /// SQLite 3|Status|INT|0||0
  Field<Transaction, TransactionStatus> status = Field<Transaction, TransactionStatus>(
    importance: 20,
    type: FieldType.text,
    align: TextAlign.center,
    columnWidth: ColumnWidth.small,
    defaultValue: TransactionStatus.none,
    name: 'Status',
    serializeName: 'Status',
    valueFromInstance: (final Transaction instance) => transactionStatusToLetter(instance.status.value),
    valueForSerialization: (final Transaction instance) => instance.status.value.index,
    sort: (final Transaction a, final Transaction b, final bool ascending) => sortByString(
      transactionStatusToLetter(a.status.value),
      transactionStatusToLetter(b.status.value),
      ascending,
    ),
  );

  /// Payee Id
  /// Payee Id
  /// SQLite 4|Payee|INT|0||0
  FieldInt<Transaction> payeeId = FieldInt<Transaction>(
    importance: 4,
    serializeName: 'Payee',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueFromInstance: (final Transaction instance) => instance.payeeId.value,
    valueForSerialization: (final Transaction instance) => instance.payeeId.value,
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByString(Payee.getName(a.payeeInstance), Payee.getName(b.payeeInstance), ascending),
  );

  /// Payee Name
  FieldString<Transaction> payeeName = FieldString<Transaction>(
    importance: 4,
    name: 'Payee',
    valueFromInstance: (final Transaction instance) => Payee.getName(instance.payeeInstance),
  );

  /// OriginalPayee
  /// before auto-aliasing, helps with future merging.
  /// SQLite 5|OriginalPayee|nvarchar(255)|0||0
  FieldString<Transaction> originalPayee = FieldString<Transaction>(
    importance: 10,
    name: 'Original Payee',
    serializeName: 'OriginalPayee',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => instance.originalPayee.value,
    valueForSerialization: (final Transaction instance) => instance.originalPayee.value,
  );

  /// Category Id
  /// SQLite 6|Category|INT|0||0
  Field<Transaction, int> categoryId = Field<Transaction, int>(
    importance: 10,
    type: FieldType.text,
    name: 'Category',
    serializeName: 'Category',
    defaultValue: -1,
    valueFromInstance: (final Transaction instance) => Data().categories.getNameFromId(instance.categoryId.value),
    valueForSerialization: (final Transaction instance) => instance.categoryId.value,
  );

  /// Memo
  /// 7|Memo|nvarchar(255)|0||0
  FieldString<Transaction> memo = FieldString<Transaction>(
    importance: 80,
    name: 'Memo',
    serializeName: 'Memo',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => instance.memo.value,
    valueForSerialization: (final Transaction instance) => instance.memo.value,
  );

  /// Number
  /// 8|Number|nchar(10)|0||0
  FieldString<Transaction> number = FieldString<Transaction>(
    importance: 10,
    name: 'Number',
    serializeName: 'Number',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => instance.number.value,
    valueForSerialization: (final Transaction instance) => instance.number.value,
  );

  /// Reconciled Date
  /// 9|ReconciledDate|datetime|0||0
  FieldDate<Transaction> reconciledDate = FieldDate<Transaction>(
    importance: 10,
    name: 'ReconciledDate',
    serializeName: 'ReconciledDate',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => dateAsIso8601OrDefault(instance.reconciledDate.value),
    valueForSerialization: (final Transaction instance) => dateAsIso8601OrDefault(instance.reconciledDate.value),
  );

  /// Budget Balance Date
  /// 10|BudgetBalanceDate|datetime|0||0
  FieldDate<Transaction> budgetBalanceDate = FieldDate<Transaction>(
    importance: 10,
    name: 'ReconciledDate',
    serializeName: 'ReconciledDate',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => dateAsIso8601OrDefault(instance.budgetBalanceDate.value),
    valueForSerialization: (final Transaction instance) => dateAsIso8601OrDefault(instance.budgetBalanceDate.value),
  );

  /// Transfer
  /// 11|Transfer|bigint|0||0
  FieldInt<Transaction> transfer = FieldInt<Transaction>(
    importance: 10,
    name: 'Transfer',
    serializeName: 'Transfer',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => instance.transfer.value,
    valueForSerialization: (final Transaction instance) => instance.transfer.value,
  );

  /// FITID
  /// 12|FITID|nchar(40)|0||0
  FieldString<Transaction> fitid = FieldString<Transaction>(
    importance: 20,
    name: 'FITID',
    serializeName: 'FITID',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => instance.fitid.value,
    valueForSerialization: (final Transaction instance) => instance.fitid.value,
  );

  /// Flags
  /// 13|Flags|INT|1||0
  FieldInt<Transaction> flags = FieldInt<Transaction>(
    importance: 20,
    name: 'Flags',
    serializeName: 'Flags',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => instance.flags.value,
    valueForSerialization: (final Transaction instance) => instance.flags.value,
  );

  /// Amount
  /// 14|Amount|money|1||0
  FieldAmount<Transaction> amount = FieldAmount<Transaction>(
    importance: 98,
    name: 'Amount',
    serializeName: 'Amount',
    valueFromInstance: (final Transaction instance) => instance.amount.value,
    valueForSerialization: (final Transaction instance) => instance.amount.value,
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByValue(a.amount.value, b.amount.value, ascending),
  );

  /// Sales Tax
  /// 15|SalesTax|money|0||0
  FieldAmount<Transaction> salesTax = FieldAmount<Transaction>(
    importance: 98,
    name: 'Sales Tax',
    serializeName: 'SalesTax',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => instance.salesTax.value,
    valueForSerialization: (final Transaction instance) => instance.salesTax.value,
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByValue(a.salesTax.value, b.salesTax.value, ascending),
  );

  /// Transfer Split
  /// 16|TransferSplit|INT|0||0
  FieldInt<Transaction> transferSplit = FieldInt<Transaction>(
    importance: 10,
    name: 'TransferSplit',
    serializeName: 'TransferSplit',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => instance.transferSplit.value,
    valueForSerialization: (final Transaction instance) => instance.transferSplit.value,
  );

  /// MergeDate
  /// 17|MergeDate|datetime|0||0
  FieldDate<Transaction> mergeDate = FieldDate<Transaction>(
    importance: 10,
    name: 'Merge Date',
    serializeName: 'MergeDate',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => dateAsIso8601OrDefault(instance.mergeDate.value),
    valueForSerialization: (final Transaction instance) => dateAsIso8601OrDefault(instance.mergeDate.value),
  );

  //------------------------------------------------------------------------
  // Not serialized
  // derived property used for display

  /// Balance
  FieldAmount<Transaction> balance = FieldAmount<Transaction>(
    importance: 99,
    name: 'Balance',
    useAsColumn: true,
    useAsDetailPanels: false,
    valueFromInstance: (final Transaction instance) => instance.balance.value,
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByValue(a.balance.value, b.balance.value, ascending),
  );

  Account? accountInstance;
  Payee? payeeInstance;

  String get dateTimeAsText => getDateAsText(dateTime.value);

  Transaction({
    final TransactionStatus status = TransactionStatus.none,
  }) {
    this.status.value = status;
    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: Payee.getName(payeeInstance),
          leftBottomAsString: '${Data().categories.getNameFromId(categoryId.value)}\n${memo.value}',
          rightTopAsString: Currency.getCurrencyText(amount.value),
          rightBottomAsString: '$dateTimeAsText\n${Account.getName(accountInstance)}',
        );
  }

  factory Transaction.fromJSon(final MyJson json, final double runningBalance) {
    final Transaction t = Transaction();
    // 0 ID
    t.id.value = json.getInt('Id');
    // 1 Account ID
    t.accountId.value = json.getInt('Account');
    t.accountInstance = Data().accounts.get(t.accountId.value);
    // 2 Date Time
    t.dateTime.value = json.getDate('Date');
    // 3 Status
    t.status.value = TransactionStatus.values[json.getInt('Status')];
    // 4 Payee ID
    t.payeeId.value = json.getInt('Payee');
    t.payeeInstance = Data().payees.get(t.payeeId.value);
    // 5 Original Payee
    t.originalPayee.value = json.getString('OriginalPayee');
    // 6 Category Id
    t.categoryId.value = json.getInt('Category');
    // 7 Memo
    t.memo.value = json.getString('Memo');
    // 8 Number
    t.number.value = json.getString('Number');
    // 9 Reconciled Date
    t.reconciledDate.value = json.getDate('ReconciledDate');
    // 10 BudgetBalanceDate
    t.budgetBalanceDate.value = json.getDate('BudgetBalanceDate');
    // 11 Transfer
    t.transfer.value = json.getInt('Transfer');
    // 12 FITID
    t.fitid.value = json.getString('FITID');
    // 13 Flags
    t.flags.value = json.getInt('Flags');
    // 14 Amount
    t.amount.value = json.getDouble('Amount');
    // 15 Sales Tax
    t.salesTax.value = json.getDouble('SalesTax');
    // 16 Transfer Split
    t.transferSplit.value = json.getInt('TransferSplit');
    // 17 Merge Date
    t.mergeDate.value = json.getDate('MergeDate');

    // not serialized
    t.balance.value = runningBalance;

    return t;
  }

  double getNormalizedAmount() {
    // Convert the value to USD
    if (accountInstance == null || accountInstance?.getCurrencyRatio() == 0) {
      return amount.value;
    }
    return amount.value * accountInstance!.getCurrencyRatio();
  }
}
