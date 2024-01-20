import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_object.dart';

/*
   6|OpeningBalance|money|0||0
   7|Currency|nchar(3)|0||0
   8|OnlineAccount|INT|0||0
   9|WebSite|nvarchar(512)|0||0
  10|ReconcileWarning|INT|0||0

  12|SyncGuid|uniqueidentifier|0||0
  13|Flags|INT|0||0

*/
class Account extends MoneyObject<Account> {
  @override
  int get uniqueId => id.value;

  // Id
  // 0|Id|INT|0||1
  Declare<Account, int> id = Declare<Account, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final Account instance) => instance.id.value,
  );

  // Account ID
  // 1|AccountId|nchar(20)|0||0
  Declare<Account, String> accountId = Declare<Account, String>(
    importance: 90,
    name: 'AccountId',
    serializeName: 'AccountId',
    defaultValue: '',
    useAsColumn: false,
    valueForSerialization: (final Account instance) => instance.accountId.value,
  );

  // OFX Account Id
  // 2|OfxAccountId|nvarchar(50)|0||0
  Declare<Account, String> ofxAccountId = Declare<Account, String>(
    importance: 1,
    name: 'OfxAccountId',
    serializeName: 'OfxAccountId',
    defaultValue: '',
    useAsColumn: false,
    valueFromInstance: (final Account instance) => instance.ofxAccountId.value,
    valueForSerialization: (final Account instance) => instance.ofxAccountId.value,
  );

  // Name
  // 3|Name|nvarchar(80)|1||0
  Declare<Account, String> name = Declare<Account, String>(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    defaultValue: '',
    valueFromInstance: (final Account instance) => instance.name.value,
    valueForSerialization: (final Account instance) => instance.name.value,
  );

  // Description
  // 4|Description|nvarchar(255)|0||0
  Declare<Account, String> description = Declare<Account, String>(
    importance: 3,
    name: 'Description',
    serializeName: 'Description',
    defaultValue: '',
    valueFromInstance: (final Account instance) => instance.description.value,
    valueForSerialization: (final Account instance) => instance.description.value,
  );

  // Type of account
  // 5|Type|INT|1||0
  Declare<Account, AccountType> type = Declare<Account, AccountType>(
    importance: 2,
    type: FieldType.text,
    align: TextAlign.center,
    name: 'Type',
    serializeName: 'Type',
    defaultValue: AccountType.checking,
    valueFromInstance: (final Account instance) => instance.getTypeAsText(),
    valueForSerialization: (final Account instance) => instance.type.value.index,
  );

  // 6
  Declare<Account, double> openingBalance = Declare<Account, double>(
    name: 'Opening Balance',
    serializeName: 'OpeningBalance',
    defaultValue: 0,
    useAsColumn: false,
    valueFromInstance: (final Account instance) => instance.openingBalance.value,
    valueForSerialization: (final Account instance) => instance.openingBalance.value,
  );

  // 7
  Declare<Account, String> currency = Declare<Account, String>(
    importance: 4,
    name: 'Currency',
    serializeName: 'Currency',
    align: TextAlign.center,
    defaultValue: '',
    valueFromInstance: (final Account instance) => instance.currency.value,
    valueForSerialization: (final Account instance) => instance.currency.value,
  );

  // 8
  int onlineAccount = -1;

  // 9
  Declare<Account, String> webSite = Declare<Account, String>(
    importance: 4,
    name: 'WebSite',
    serializeName: 'WebSite',
    defaultValue: '',
    useAsColumn: false,
    valueFromInstance: (final Account instance) => instance.webSite.value,
    valueForSerialization: (final Account instance) => instance.webSite.value,
  );

  // 10
  int reconcileWarning = 0;

  /// lastSync
  /// 11|LastSync|datetime|0||0
  Declare<Account, DateTime> lastSync = Declare<Account, DateTime>(
    importance: 90,
    type: FieldType.date,
    serializeName: 'Date',
    useAsColumn: false,
    defaultValue: DateTime.parse('1970-01-01'),
    valueFromInstance: (final Account instance) => instance.lastSync.value.toIso8601String(),
    valueForSerialization: (final Account instance) => instance.lastSync.value.toIso8601String(),
  );

  // 12
  String syncGuid = '';

  // 13
  int flags = 0;

  /// Last Balance date
  /// 14|LastBalance|datetime|0||0
  Declare<Account, DateTime> lastBalance = Declare<Account, DateTime>(
    importance: 98,
    serializeName: 'LastBalance',
    defaultValue: DateTime.parse('1970-01-01'),
    useAsColumn: false,
    valueFromInstance: (final Account instance) => instance.lastBalance.value,
    valueForSerialization: (final Account instance) => instance.lastBalance.value,
  );

  /// categoryIdForPrincipal
  /// 15 | CategoryIdForPrincipal|INT|0||0
  Declare<Account, int> categoryIdForPrincipal = Declare<Account, int>(
    importance: 98,
    serializeName: 'CategoryIdForPrincipal',
    defaultValue: 0,
    useAsColumn: false,
    valueFromInstance: (final Account instance) => instance.categoryIdForPrincipal.value,
    valueForSerialization: (final Account instance) => instance.categoryIdForPrincipal.value,
  );

  /// categoryIdForInterest
  /// 16|CategoryIdForInterest|INT|0||0
  Declare<Account, int> categoryIdForInterest = Declare<Account, int>(
    importance: -1,
    serializeName: 'CategoryIdForInterest',
    defaultValue: 0,
    useAsColumn: false,
    valueFromInstance: (final Account instance) => instance.categoryIdForInterest.value,
    valueForSerialization: (final Account instance) => instance.categoryIdForInterest.value,
  );

  // ------------------------------------------------
  // Properties that are not persisted

  /// Count
  Declare<Account, int> count = Declare<Account, int>(
    importance: 98,
    type: FieldType.numeric,
    align: TextAlign.right,
    name: 'Count',
    useAsDetailPanels: false,
    defaultValue: 0,
    valueFromInstance: (final Account instance) => instance.count.value,
    valueForSerialization: (final Account instance) => instance.count.value,
  );

  /// Balance
  Declare<Account, double> balance = Declare<Account, double>(
    importance: 99,
    type: FieldType.amount,
    align: TextAlign.right,
    name: 'Balance',
    useAsDetailPanels: false,
    defaultValue: 0,
    valueFromInstance: (final Account instance) => instance.balance.value,
    valueForSerialization: (final Account instance) => instance.balance.value,
  );

  /// Constructor
  Account();

  /// Constructor from a SQLite row
  factory Account.fromSqlite(final Json row) {
    return Account()
      ..id.value = jsonGetInt(row, 'Id')
      ..accountId.value = jsonGetString(row, 'AccountId')
      ..ofxAccountId.value = jsonGetString(row, 'OfxAccountId')
      ..name.value = jsonGetString(row, 'Name')
      ..description.value = jsonGetString(row, 'Description')
      ..type.value = AccountType.values[jsonGetInt(row, 'Type')]
      ..openingBalance.value = jsonGetDouble(row, 'OpeningBalance')
      ..currency.value = jsonGetString(row, 'Currency')
      ..onlineAccount = jsonGetInt(row, 'OnlineAccount')
      ..webSite.value = jsonGetString(row, 'WebSite')
      ..reconcileWarning = jsonGetInt(row, 'ReconcileWarning')
      ..lastSync.value = jsonGetDate(row, 'LastSync')
      ..syncGuid = jsonGetString(row, 'SyncGuid')
      ..flags = jsonGetInt(row, 'Flags')
      ..lastBalance.value = jsonGetDate(row, 'LastBalance')
      ..categoryIdForPrincipal.value = jsonGetInt(row, 'CategoryIdForPrincipal')
      ..categoryIdForInterest.value = jsonGetInt(row, 'CategoryIdForInterest');
  }

  static getName(final Account? instance) {
    return instance == null ? '' : instance.name.value;
  }

  bool isBitOn(final int value, final int bitIndex) {
    return (value & bitIndex) == bitIndex;
  }

  bool isClosed() {
    return isBitOn(flags, AccountFlags.closed.index);
  }

  bool isActive() {
    return !isClosed();
  }

  bool matchType(final List<AccountType> types) {
    if (types.isEmpty) {
      // All accounts except these
      return type.value != AccountType._notUsed_7 && type.value != AccountType.categoryFund;
    }
    return types.contains(type.value);
  }

  bool isBankAccount() {
    return type.value == AccountType.savings || type.value == AccountType.checking || type.value == AccountType.cash;
  }

  bool isActiveBankAccount() {
    return isBankAccount() && isActive();
  }

  getTypeAsText() {
    switch (type.value) {
      case AccountType.savings:
        return 'Savings';
      case AccountType.checking:
        return 'Checking';
      case AccountType.moneyMarket:
        return 'MoneyMarket';
      case AccountType.cash:
        return 'Cash';
      case AccountType.credit:
        return 'Credit';
      case AccountType.investment:
        return 'Investment';
      case AccountType.retirement:
        return 'Retirement';
      case AccountType.asset:
        return 'Asset';
      case AccountType.categoryFund:
        return 'CategoryFund';
      case AccountType.loan:
        return 'Loan';
      case AccountType.creditLine:
        return 'CreditLine';
      default:
        break;
    }

    return 'other $type';
  }

  static AccountType getTypeFromText(final String text) {
    switch (text.toLowerCase()) {
      case 'savings':
        return AccountType.savings;
      case 'checking':
        return AccountType.checking;
      case 'moneymarket':
        return AccountType.moneyMarket;
      case 'cash':
        return AccountType.cash;
      case 'credit':
      case 'creditcard': // as seen in OFX <ACCTTYPE>
        return AccountType.credit;
      case 'investment':
        return AccountType.investment;
      case 'retirement':
        return AccountType.retirement;
      case 'asset':
        return AccountType.asset;
      case 'categoryfund':
        return AccountType.categoryFund;
      case 'loan':
        return AccountType.loan;
      case 'creditLine':
        return AccountType.creditLine;
      default:
        return AccountType._notUsed_7;
    }
  }
}

enum AccountType {
  savings, // 0
  checking, // 1
  moneyMarket, // 2
  cash, // 3
  credit, // 4
  investment, // 5
  retirement, // 6
  _notUsed_7, // 7 There is a hole here from deleted type which we can fill when we invent new types, but the types 8-10 have to keep those numbers or else we mess up the existing databases.
  asset, // 8 Used for tracking Assets like "House, Car, Boat, Jewelry, this helps to make NetWorth more accurate
  categoryFund, // 9 a pseudo account for managing category budgets
  loan, // 10
  creditLine, // 11
}

enum AccountFlags {
  none, // 0
  budgeted, // 1
  closed, // 2
  taxDeferred, // 3
}
