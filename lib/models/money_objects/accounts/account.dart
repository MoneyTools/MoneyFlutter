// Imports
import 'package:flutter/material.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_objects/accounts/account_types.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/widgets/table_view/table_row_compact.dart';

// Exports
export 'package:money/models/money_objects/accounts/account_types.dart';

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
  Field<Account, int> id = Field<Account, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final Account instance) => instance.id.value,
  );

  // Account ID
  // 1|AccountId|nchar(20)|0||0
  Field<Account, String> accountId = Field<Account, String>(
    importance: 90,
    name: 'AccountId',
    serializeName: 'AccountId',
    defaultValue: '',
    useAsColumn: false,
    valueForSerialization: (final Account instance) => instance.accountId.value,
  );

  // OFX Account Id
  // 2|OfxAccountId|nvarchar(50)|0||0
  Field<Account, String> ofxAccountId = Field<Account, String>(
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
  Field<Account, String> name = Field<Account, String>(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    defaultValue: '',
    valueFromInstance: (final Account instance) => instance.name.value,
    valueForSerialization: (final Account instance) => instance.name.value,
  );

  // Description
  // 4|Description|nvarchar(255)|0||0
  Field<Account, String> description = Field<Account, String>(
    importance: 3,
    name: 'Description',
    serializeName: 'Description',
    defaultValue: '',
    valueFromInstance: (final Account instance) => instance.description.value,
    valueForSerialization: (final Account instance) => instance.description.value,
  );

  // Type of account
  // 5|Type|INT|1||0
  Field<Account, AccountType> type = Field<Account, AccountType>(
    importance: 2,
    type: FieldType.text,
    align: TextAlign.center,
    name: 'Type',
    serializeName: 'Type',
    defaultValue: AccountType.checking,
    valueFromInstance: (final Account instance) => getTypeAsText(instance.type.value),
    valueForSerialization: (final Account instance) => instance.type.value.index,
  );

  // 6 Open Balance
  Field<Account, double> openingBalance = Field<Account, double>(
    name: 'Opening Balance',
    serializeName: 'OpeningBalance',
    defaultValue: 0,
    useAsColumn: false,
    valueFromInstance: (final Account instance) => instance.openingBalance.value,
    valueForSerialization: (final Account instance) => instance.openingBalance.value,
  );

  // 7 Currency
  Field<Account, String> currency = Field<Account, String>(
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

  // 9 WebSite
  Field<Account, String> webSite = Field<Account, String>(
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
  Field<Account, DateTime> lastSync = Field<Account, DateTime>(
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
  Field<Account, DateTime> lastBalance = Field<Account, DateTime>(
    importance: 98,
    serializeName: 'LastBalance',
    defaultValue: DateTime.parse('1970-01-01'),
    useAsColumn: false,
    valueFromInstance: (final Account instance) => instance.lastBalance.value,
    valueForSerialization: (final Account instance) => instance.lastBalance.value,
  );

  /// categoryIdForPrincipal
  /// 15 | CategoryIdForPrincipal|INT|0||0
  Field<Account, int> categoryIdForPrincipal = Field<Account, int>(
    importance: 98,
    serializeName: 'CategoryIdForPrincipal',
    defaultValue: 0,
    useAsColumn: false,
    valueFromInstance: (final Account instance) => instance.categoryIdForPrincipal.value,
    valueForSerialization: (final Account instance) => instance.categoryIdForPrincipal.value,
  );

  /// categoryIdForInterest
  /// 16|CategoryIdForInterest|INT|0||0
  Field<Account, int> categoryIdForInterest = Field<Account, int>(
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
  Field<Account, int> count = Field<Account, int>(
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
  Field<Account, double> balance = Field<Account, double>(
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
  Account() {
    buildListWidgetForSmallScreen = () => TableRowCompact(
          leftTopAsWidget: Text(
            name.value,
            textAlign: TextAlign.left,
          ),
          leftBottomAsWidget: Text(
            getTypeAsText(type.value),
            textAlign: TextAlign.left,
          ),
          rightTopAsWidget: Text(getCurrencyText(balance.value)),
        );
  }

  /// Constructor from a SQLite row
  factory Account.fromSqlite(final MyJson row) {
    return Account()
      ..id.value = row.getInt('Id')
      ..accountId.value = row.getString('AccountId')
      ..ofxAccountId.value = row.getString('OfxAccountId')
      ..name.value = row.getString('Name')
      ..description.value = row.getString('Description')
      ..type.value = AccountType.values[row.getInt('Type')]
      ..openingBalance.value = row.getDouble('OpeningBalance')
      ..currency.value = row.getString('Currency')
      ..onlineAccount = row.getInt('OnlineAccount')
      ..webSite.value = row.getString('WebSite')
      ..reconcileWarning = row.getInt('ReconcileWarning')
      ..lastSync.value = row.getDate('LastSync')
      ..syncGuid = row.getString('SyncGuid')
      ..flags = row.getInt('Flags')
      ..lastBalance.value = row.getDate('LastBalance')
      ..categoryIdForPrincipal.value = row.getInt('CategoryIdForPrincipal')
      ..categoryIdForInterest.value = row.getInt('CategoryIdForInterest');
  }

  static String getName(final Account? instance) {
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
      return type.value != AccountType.notUsed_7 && type.value != AccountType.categoryFund;
    }
    return types.contains(type.value);
  }

  bool isBankAccount() {
    return type.value == AccountType.savings || type.value == AccountType.checking || type.value == AccountType.cash;
  }

  bool isActiveBankAccount() {
    return isBankAccount() && isActive();
  }
}
