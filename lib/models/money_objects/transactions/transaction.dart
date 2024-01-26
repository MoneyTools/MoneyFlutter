// Imports
import 'package:money/helpers/json_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transaction_types.dart';
import 'package:money/widgets/table_view/list_item_card.dart';

// Exports
export 'package:money/models/money_objects/transactions/transaction_types.dart';

/// Main source of information for this App
/// All transactions are loaded in this class [Transaction] and [Split]
class Transaction extends MoneyObject<Transaction> {
  @override
  int get uniqueId => id.value;

  /// ID
  /// SQLite  0|Id|bigint|0||1
  FieldInt<Transaction> id = FieldInt<Transaction>(
    importance: 0,
    serializeName: 'Id',
    useAsColumn: false,
    useAsDetailPanels: false,
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
    valueForSerialization: (final Transaction instance) => instance.dateTime.value.toIso8601String(),
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
    valueFromInstance: (final Transaction instance) => TransactionStatusToLetter(instance.status.value),
    valueForSerialization: (final Transaction instance) => instance.status.value.index,
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
  FieldInt<Transaction> number = FieldInt<Transaction>(
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
    valueFromInstance: (final Transaction instance) => instance.reconciledDate.value,
    valueForSerialization: (final Transaction instance) => instance.reconciledDate.value,
  );

  /// Budget Balance Date
  /// 10|BudgetBalanceDate|datetime|0||0
  FieldDate<Transaction> budgetBalanceDate = FieldDate<Transaction>(
    importance: 10,
    name: 'ReconciledDate',
    serializeName: 'ReconciledDate',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => instance.budgetBalanceDate.value,
    valueForSerialization: (final Transaction instance) => instance.budgetBalanceDate.value,
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
    serializeName: 'Merge Date',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => instance.mergeDate.value,
    valueForSerialization: (final Transaction instance) => instance.mergeDate.value,
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
  late final String dateTimeAsText;
  Payee? payeeInstance;

  Transaction({
    final TransactionStatus status = TransactionStatus.none,
  }) {
    this.status.value = status;
    this.buildListWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: Payee.getName(payeeInstance),
          leftBottomAsString: '${Data().categories.getNameFromId(this.categoryId.value)}\n${memo.value}',
          rightTopAsString: getCurrencyText(amount.value),
          rightBottomAsString: '$dateTimeAsText\n${Account.getName(accountInstance)}',
        );
  }

  factory Transaction.fromJSon(final MyJson json, final double runningBalance) {
    final Transaction t = Transaction();
    t.id.value = json.getInt('Id'); // 0
    t.accountId.value = json.getInt('Account'); // 1
    t.accountInstance = Data().accounts.get(t.accountId.value); // 2
    t.dateTime.value = json.getDate('Date'); // 3
    t.dateTimeAsText = getDateAsText(t.dateTime.value); // 5
    t.originalPayee.value = json.getString('OriginalPayee'); // 6
    t.categoryId.value = json.getInt('Category');
    t.payeeId.value = json.getInt('Payee');
    t.payeeInstance = Data().payees.get(t.payeeId.value);
    t.amount.value = json.getDouble('Amount');
    t.status.value = TransactionStatus.values[json.getInt('Status')];
    t.memo.value = json.getString('Memo');

    // not serialized
    t.balance.value = runningBalance;

    return t;
  }
}
