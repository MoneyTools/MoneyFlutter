import 'package:money/helpers/json_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/settings.dart';

/*
SQLite fields of the [Accounts] table
   0|Id|INT|0||1
   1|AccountId|nchar(20)|0||0
   2|OfxAccountId|nvarchar(50)|0||0
   3|Name|nvarchar(80)|1||0
   4|Description|nvarchar(255)|0||0
   5|Type|INT|1||0
   6|OpeningBalance|money|0||0
   7|Currency|nchar(3)|0||0
   8|OnlineAccount|INT|0||0
   9|WebSite|nvarchar(512)|0||0
  10|ReconcileWarning|INT|0||0
  11|LastSync|datetime|0||0
  12|SyncGuid|uniqueidentifier|0||0
  13|Flags|INT|0||0
  14|LastBalance|datetime|0||0
  15|CategoryIdForPrincipal|INT|0||0
  16|CategoryIdForInterest|INT|0||0
*/
class Account extends MoneyObject {
  // 0
  // int MoneyEntity.Id

  // 1
  String accountId = '';

  // 2
  String ofxAccountId = '';

  // 3 -
  String name;

  // 4
  String description = '';

  // 5
  AccountType type = AccountType.checking;

  // 6
  double openingBalance = 0.00;

  // 7
  String currency = '';

  // 8
  int onlineAccount = -1;

  // 9
  String webSite = '';

  // 10
  int reconcileWarning = 0;

  // 11
  DateTime lastSync;

  // 12
  String syncGuid = '';

  // 13
  int flags = 0;

  // 14
  DateTime lastBalance;

  // 15
  int categoryIdForPrincipal = 0;

  // 16
  int categoryIdForInterest = 0;

  // Not serialized
  int count = 0;
  double balance = 0.00;

  /// Constructor
  Account({
    // 0
    required super.id,
    // 1
    required this.accountId,
    // 2
    required this.ofxAccountId,
    // 3
    required this.name,
    // 4
    required this.description,
    // 5
    required this.type,
    // 6
    required this.openingBalance,
    // 7
    required this.currency,
    // 8
    required this.onlineAccount,
    // 9
    required this.webSite,
    // 10
    required this.reconcileWarning,
    // 11
    required this.lastSync,
    // 12
    required this.syncGuid,
    // 13
    required this.flags,
    // 14
    required this.lastBalance,
    // 15
    required this.categoryIdForPrincipal,
    // 16
    required this.categoryIdForInterest,
  });

  /// Constructor from a SQLite row
  factory Account.fromSqlite(final Json row) {
    return Account(
      // 0
      id: jsonGetInt(row, 'Id'),
      // 1
      accountId: jsonGetString(row, 'AccountId'),
      // 2
      ofxAccountId: jsonGetString(row, 'OfxAccountId'),
      // 3
      name: jsonGetString(row, 'Name'),
      // 4
      description: jsonGetString(row, 'Description'),
      // 5
      type: AccountType.values[jsonGetInt(row, 'Type')],
      // 6
      openingBalance: jsonGetDouble(row, 'OpeningBalance'),
      // 7
      currency: jsonGetString(row, 'Currency'),
      // 8
      onlineAccount: jsonGetInt(row, 'OnlineAccount'),
      // 9
      webSite: jsonGetString(row, 'WebSite'),
      // 10
      reconcileWarning: jsonGetInt(row, 'ReconcileWarning'),
      // 11
      lastSync: jsonGetDate(row, 'LastSync'),
      // 12
      syncGuid: jsonGetString(row, 'SyncGuid'),
      // 13
      flags: jsonGetInt(row, 'Flags'),
      // 14
      lastBalance: jsonGetDate(row, 'LastBalance'),
      // 15
      categoryIdForPrincipal: jsonGetInt(row, 'CategoryIdForPrincipal'),
      // 16
      categoryIdForInterest: jsonGetInt(row, 'CategoryIdForInterest'),
    );
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
      return type != AccountType._notUsed_7 && type != AccountType.categoryFund;
    }
    return types.contains(type);
  }

  bool isBankAccount() {
    return type == AccountType.savings || type == AccountType.checking || type == AccountType.cash;
  }

  bool isActiveBankAccount() {
    return isBankAccount() && isActive();
  }

  getTypeAsText() {
    switch (type) {
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

  static FieldDefinitions<Account> getFieldDefinitions() {
    final FieldDefinitions<Account> fields = FieldDefinitions<Account>(definitions: <FieldDefinition<Account>>[
      // 0
      FieldDefinition<Account>(
        type: FieldType.numeric,
        name: 'Id',
        serializeName: 'id',
        useAsColumn: false,
        valueFromInstance: (final Account account) {
          return account.id;
        },
      ),
      // 1
      FieldDefinition<Account>(
        type: FieldType.text,
        name: 'Name',
        serializeName: 'name',
        align: TextAlign.left,
        valueFromInstance: (final Account account) {
          return account.name;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByString(
            a.name,
            b.name,
            sortAscending,
          );
        },
      ),
      // 2
      FieldDefinition<Account>(
        type: FieldType.text,
        name: 'Type',
        serializeName: 'type',
        align: TextAlign.center,
        valueFromInstance: (final Account account) {
          return account.getTypeAsText();
        },
        valueForSerialization: (final Account account) {
          return account.type.index;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByString(
            a.getTypeAsText(),
            b.getTypeAsText(),
            sortAscending,
          );
        },
      ),
      // 3
      FieldDefinition<Account>(
        type: FieldType.text,
        name: 'Currency',
        serializeName: 'currency',
        align: TextAlign.left,
        valueFromInstance: (final Account account) {
          return account.currency;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByString(
            a.currency,
            b.currency,
            sortAscending,
          );
        },
      ),
      // 4
      FieldDefinition<Account>(
        type: FieldType.text,
        name: 'Description',
        serializeName: 'Description',
        align: TextAlign.left,
        valueFromInstance: (final Account account) {
          return account.description;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByString(
            a.description,
            b.description,
            sortAscending,
          );
        },
      ),
      // 5
      FieldDefinition<Account>(
        type: FieldType.text,
        useAsColumn: false,
        name: 'WebSite',
        serializeName: 'website',
        align: TextAlign.left,
        valueFromInstance: (final Account account) {
          return account.webSite;
        },
      ),
      // 6
      FieldDefinition<Account>(
        type: FieldType.numericShorthand,
        name: 'Count',
        align: TextAlign.right,
        valueFromInstance: (final Account account) {
          return account.count;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByValue(
            a.count,
            b.count,
            sortAscending,
          );
        },
      ),
      // 7
      FieldDefinition<Account>(
        type: FieldType.amount,
        name: 'Balance',
        align: TextAlign.right,
        valueFromInstance: (final Account account) {
          return account.balance;
        },
        sort: (final Account a, final Account b, final bool sortAscending) {
          return sortByValue(
            a.balance,
            b.balance,
            sortAscending,
          );
        },
      ),
      // 8
      FieldDefinition<Account>(
          type: FieldType.text,
          name: 'Status',
          serializeName: 'status',
          align: TextAlign.center,
          useAsColumn: Settings().includeClosedAccounts,
          valueFromInstance: (final Account account) {
            return account.isClosed() ? 'Closed' : 'Active';
          },
          valueForSerialization: (final Account account) {
            return account.flags;
          },
          sort: (final Account a, final Account b, final bool sortAscending) {
            return sortByString(
              a.isClosed().toString(),
              b.isClosed().toString(),
              sortAscending,
            );
          }),
      // 9
    ]);

    return fields;
  }

  List<dynamic> toCSV() {
    return <dynamic>[
      accountId,
      flags,
      ofxAccountId,
      description,
      type.index,
    ];
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
