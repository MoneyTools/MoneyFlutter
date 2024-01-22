import 'package:money/helpers/json_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/money_objects/transactions/transaction_types.dart';
import 'package:money/widgets/table_view/table_row_compact.dart';

const String columnIdAccount = 'Accounts';
const String columnIdDate = 'Date';
const String columnIdPayee = 'Payee';
const String columnIdCategory = 'Category';
const String columnIdStatus = 'Status';
const String columnIdMemo = 'Memo';
const String columnIdAmount = 'Amount';
const String columnIdBalance = 'Balance';

/// Main source of information for this App
/// All transactions are loaded in this class [Transaction] and [Split]
class Transaction extends MoneyObject<Transaction> {
  @override
  int get uniqueId => id.value;

  // ID
  // SQLite  0|Id|bigint|0||1
  Field<Transaction, int> id = Field<Transaction, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final Transaction instance) => instance.id.value,
  );

  // Account
  // SQLite  1|Account|INT|1||0
  Field<Transaction, int> accountId = Field<Transaction, int>(
    importance: 1,
    name: 'Account',
    serializeName: 'AccountId',
    defaultValue: -1,
    valueFromInstance: (final Transaction instance) => Account.getName(instance.accountInstance),
    valueForSerialization: (final Transaction instance) => instance.accountId.value,
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByString(Account.getName(a.accountInstance), Account.getName(b.accountInstance), ascending),
  );

  // Date
  // SQLite 2|Date|datetime|1||0
  Field<Transaction, DateTime> dateTime = Field<Transaction, DateTime>(
    importance: 2,
    type: FieldType.text,
    align: TextAlign.center,
    name: 'Date',
    serializeName: 'Date',
    defaultValue: DateTime.parse('1970-01-01'),
    valueFromInstance: (final Transaction instance) => instance.dateTimeAsText,
    valueForSerialization: (final Transaction instance) => instance.dateTime.value.toIso8601String(),
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByDate(a.dateTime.value, b.dateTime.value, ascending),
  );

  // SQLite 3|Status|INT|0||0

  // Payee Id
  // SQLite 4|Payee|INT|0||0
  Field<Transaction, int> payeeId = Field<Transaction, int>(
    importance: 1,
    type: FieldType.text,
    serializeName: 'Payee',
    defaultValue: -1,
    valueFromInstance: (final Transaction instance) => Payee.getName(instance.payeeInstance),
    valueForSerialization: (final Transaction instance) => instance.payeeId.value,
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByString(Payee.getName(a.payeeInstance), Payee.getName(b.payeeInstance), ascending),
  );

  // SQLite 5|OriginalPayee|nvarchar(255)|0||0
  String originalPayee = ''; // before auto-aliasing, helps with future merging.

  // Category Id
  // SQLite 6|Category|INT|0||0
  Field<Transaction, int> categoryId = Field<Transaction, int>(
    importance: 1,
    type: FieldType.text,
    name: 'Category',
    serializeName: 'Category',
    defaultValue: -1,
    valueFromInstance: (final Transaction instance) => Category.getName(instance.categoryInstance),
    valueForSerialization: (final Transaction instance) => instance.categoryId.value,
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByString(Category.getName(a.categoryInstance), Category.getName(b.categoryInstance), ascending),
  );

  // Memo
  // 7|Memo|nvarchar(255)|0||0
  Field<Transaction, String> memo = Field<Transaction, String>(
    importance: 80,
    type: FieldType.text,
    name: 'Memo',
    serializeName: 'Memo',
    useAsColumn: false,
    defaultValue: '',
    valueFromInstance: (final Transaction instance) => instance.memo.value,
    valueForSerialization: (final Transaction instance) => instance.memo.value,
  );

  // 8|Number|nchar(10)|0||0

  // 9|ReconciledDate|datetime|0||0

  // 10|BudgetBalanceDate|datetime|0||0

  // 11|Transfer|bigint|0||0

  // 12|FITID|nchar(40)|0||0

  // 13|Flags|INT|1||0

  // Amount
  // 14|Amount|money|1||0
  FieldAmount<Transaction> amount = FieldAmount<Transaction>(
    importance: 98,
    name: 'Amount',
    serializeName: 'Amount',
    valueFromInstance: (final Transaction instance) => instance.amount.value,
    valueForSerialization: (final Transaction instance) => instance.amount.value,
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByValue(a.amount.value, b.amount.value, ascending),
  );

  // 15|SalesTax|money|0||0
  // 16|TransferSplit|INT|0||0
  // 17|MergeDate|datetime|0||0

  // Balance
  FieldAmount<Transaction> balance = FieldAmount<Transaction>(
    importance: 99,
    name: 'Balance',
    useAsColumn: true,
    useAsDetailPanels: false,
    valueFromInstance: (final Transaction instance) => instance.balance.value,
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByValue(a.balance.value, b.balance.value, ascending),
  );

  double salesTax = 0;
  TransactionStatus status = TransactionStatus.none;
  String fitid;

  // derived property used for display
  Account? accountInstance;
  late final String dateTimeAsText;
  Payee? payeeInstance;
  Category? categoryInstance;

  // String number; // requires value.Length < 10
  // // Investment investment;
  // Transfer transfer;
  // double runningUnits;
  // double runningBalance;
  // String routingPath;
  // TransactionFlags flags;
  // DateTime? reconciledDate;
  //
  // //Splits splits;
  // String pendingTransfer;
  // DateTime? budgetBalanceDate;
  //
  // //readonly Transaction related;
  // //readonly Split relatedSplit;
  // DateTime? mergeDate;
  //TransactionViewFlags viewState; // ui transient state only, not persisted.

  Transaction({
    this.status = TransactionStatus.none,
    this.fitid = '',
  }) {
    this.buildListWidgetForSmallScreen = () => TableRowCompact(
          leftTopAsString: Payee.getName(payeeInstance),
          leftBottomAsString: '${Category.getName(categoryInstance)}\n${memo.value}',
          rightTopAsString: getCurrencyText(amount.value),
          rightBottomAsString: '$dateTimeAsText\n${Account.getName(accountInstance)}',
        );
  }

  factory Transaction.fromJSon(final Json json, final double runningBalance) {
    final Transaction t = Transaction(
      // Status
      status: TransactionStatus.values[jsonGetInt(json, 'Status')],
      // Amount
    );
    t.id.value = jsonGetInt(json, 'Id');
    t.accountId.value = jsonGetInt(json, 'Account');
    t.accountInstance = Data().accounts.get(t.accountId.value);
    t.dateTime.value = jsonGetDate(json, 'Date');
    t.dateTimeAsText = getDateAsText(t.dateTime.value);
    t.categoryId.value = jsonGetInt(json, 'Category');
    t.categoryInstance = Data().categories.get(t.categoryId.value);
    t.payeeId.value = jsonGetInt(json, 'Payee');
    t.payeeInstance = Data().payees.get(t.payeeId.value);
    t.amount.value = jsonGetDouble(json, 'Amount');
    t.memo.value = jsonGetString(json, 'Memo');
    t.balance.value = runningBalance;

    return t;
  }
}
