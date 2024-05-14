// Imports
import 'package:flutter/material.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_objects/accounts/account_types.dart';
import 'package:money/models/money_objects/accounts/picker_account_type.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_item_card.dart';

import 'account_types_enum.dart';

// Exports
export 'package:money/models/money_objects/accounts/account_types.dart';

/// Accounts like Banks
class Account extends MoneyObject {
  static final Fields<Account> _fields = Fields<Account>();

  static Fields<Account> get fields {
    if (_fields.isEmpty) {
      final tmp = Account.fromJson({});
      _fields.setDefinitions([
        tmp.id,
        tmp.name,
        tmp.accountId,
        tmp.description,
        tmp.type,
        tmp.openingBalance,
        tmp.onlineAccount,
        tmp.webSite,
        tmp.reconcileWarning,
        tmp.lastSync,
        tmp.syncGuid,
        tmp.flags,
        tmp.lastBalance,
        tmp.categoryIdForPrincipal,
        tmp.categoryIdForInterest,
        tmp.count,
        tmp.balanceNative,
        tmp.currency,
        tmp.balanceNormalized,
        tmp.isAccountOpen
      ]);
    }
    return _fields;
  }

  Map< /*year */ int, /*balance*/ double> maxBalancePerYears = {};
  Map< /*year */ int, /*balance*/ double> minBalancePerYears = {};

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    return name.value;
  }

  // Id
  // 0|Id|INT|0||1
  FieldId id = FieldId(
    valueForSerialization: (final MoneyObject instance) => (instance as Account).uniqueId,
  );

  // Account ID
  // 1|AccountId|nchar(20)|0||0
  FieldString accountId = FieldString(
    importance: 90,
    name: 'Account ID',
    serializeName: 'AccountId',
    useAsColumn: true,
    valueFromInstance: (final MoneyObject instance) => (instance as Account).accountId.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).accountId.value,
    setValue: (final MoneyObject instance, dynamic value) => (instance as Account).accountId.value = value as String,
  );

  // OFX Account Id
  // 2|OfxAccountId|nvarchar(50)|0||0
  FieldString ofxAccountId = FieldString(
    importance: 1,
    name: 'OfxAccountId',
    serializeName: 'OfxAccountId',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Account).ofxAccountId.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).ofxAccountId.value,
    setValue: (final MoneyObject instance, dynamic value) => (instance as Account).ofxAccountId.value = value as String,
  );

  // Name
  // 3|Name|nvarchar(80)|1||0
  FieldString name = FieldString(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    columnWidth: ColumnWidth.large,
    valueFromInstance: (final MoneyObject instance) => (instance as Account).name.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).name.value,
    setValue: (final MoneyObject instance, dynamic value) => (instance as Account).name.value = value as String,
  );

  // Description
  // 4|Description|nvarchar(255)|0||0
  FieldString description = FieldString(
    importance: 3,
    name: 'Description',
    serializeName: 'Description',
    setValue: (final MoneyObject instance, dynamic value) => (instance as Account).description.value = value as String,
    valueFromInstance: (final MoneyObject instance) => (instance as Account).description.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).description.value,
  );

  // Type of account
  // 5|Type|INT|1||0
  Field<AccountType> type = Field<AccountType>(
      importance: 2,
      type: FieldType.text,
      align: TextAlign.center,
      columnWidth: ColumnWidth.small,
      name: 'Type',
      serializeName: 'Type',
      defaultValue: AccountType.checking,
      valueFromInstance: (final MoneyObject instance) => getTypeAsText((instance as Account).type.value),
      valueForSerialization: (final MoneyObject instance) => (instance as Account).type.value.index,
      getEditWidget: (final MoneyObject instance, Function onEdited) {
        return pickerAccountType(
          itemSelected: (instance as Account).type.value,
          onSelected: (AccountType newSelection) {
            (instance).type.value = newSelection;
            onEdited(); // notify container
          },
        );
      });

  // 6 Open Balance
  // 6|OpeningBalance|money|0||0
  Field<double> openingBalance = Field<double>(
    name: 'Opening Balance',
    serializeName: 'OpeningBalance',
    defaultValue: 0,
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Account).openingBalance.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).openingBalance.value,
  );

  /// Currency
  /// 7|Currency|nchar(3)|0||0
  Field<String> currency = Field<String>(
    type: FieldType.widget,
    importance: 96,
    name: 'Currency',
    serializeName: 'Currency',
    align: TextAlign.center,
    columnWidth: ColumnWidth.tiny,
    defaultValue: '',
    useAsDetailPanels: true,
    valueFromInstance: (final MoneyObject instance) =>
        Currency.buildCurrencyWidget((instance as Account).getAccountCurrencyAsText()),
    valueForSerialization: (final MoneyObject instance) => (instance as Account).getAccountCurrencyAsText(),
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) =>
        sortByString((a as Account).getAccountCurrencyAsText(), (b as Account).getAccountCurrencyAsText(), ascending),
  );

  String getAccountCurrencyAsText() {
    return Currency.getCurrencyAsText(currency.value);
  }

  /// OnlineAccount
  /// 8|OnlineAccount|INT|0||0
  FieldInt onlineAccount = FieldInt(
    name: 'OnlineAccount',
    serializeName: 'OnlineAccount',
    useAsColumn: false,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).onlineAccount.value,
  );

  /// WebSite
  /// 9|WebSite|nvarchar(512)|0||0
  Field<String> webSite = Field<String>(
    importance: 4,
    name: 'WebSite',
    serializeName: 'WebSite',
    defaultValue: '',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Account).webSite.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).webSite.value,
  );

  /// ReconcileWarning
  /// 10|ReconcileWarning|INT|0||0
  FieldInt reconcileWarning = FieldInt(
    serializeName: 'ReconcileWarning',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).reconcileWarning.value,
  );

  /// LastSync Date & Time
  /// 11|LastSync|datetime|0||0
  FieldDate lastSync = FieldDate(
    importance: 90,
    serializeName: 'LastSync',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => dateAsIso8601OrDefault((instance as Account).lastSync.value),
    valueForSerialization: (final MoneyObject instance) => dateAsIso8601OrDefault((instance as Account).lastSync.value),
  );

  /// SyncGuid
  /// 12|SyncGuid|uniqueidentifier|0||0
  FieldString syncGuid = FieldString(
    serializeName: 'SyncGuid',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).syncGuid.value,
  );

  /// Flags
  /// 13|Flags|INT|0||0
  FieldInt flags = FieldInt(
    serializeName: 'Flags',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Account).flags.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).flags.value,
  );

  /// Last Balance date
  /// 14|LastBalance|datetime|0||0
  FieldDate lastBalance = FieldDate(
    importance: 98,
    serializeName: 'LastBalance',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => dateAsIso8601OrDefault((instance as Account).lastBalance.value),
    valueForSerialization: (final MoneyObject instance) =>
        dateAsIso8601OrDefault((instance as Account).lastBalance.value),
  );

  /// categoryIdForPrincipal
  /// 15 | CategoryIdForPrincipal|INT|0||0
  Field<int> categoryIdForPrincipal = Field<int>(
    importance: 98,
    serializeName: 'CategoryIdForPrincipal',
    defaultValue: 0,
    useAsColumn: false,
    useAsDetailPanels: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Account).categoryIdForPrincipal.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).categoryIdForPrincipal.value,
  );

  /// categoryIdForInterest
  /// 16|CategoryIdForInterest|INT|0||0
  Field<int> categoryIdForInterest = Field<int>(
    importance: -1,
    serializeName: 'CategoryIdForInterest',
    defaultValue: 0,
    useAsColumn: false,
    useAsDetailPanels: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Account).categoryIdForInterest.value,
    valueForSerialization: (final MoneyObject instance) => (instance as Account).categoryIdForInterest.value,
  );

  // ------------------------------------------------
  // Properties that are not persisted

  /// Transaction Count
  FieldQuantity count = FieldQuantity(
    importance: 98,
    name: 'Transactions',
    columnWidth: ColumnWidth.tiny,
    useAsDetailPanels: false,
    valueFromInstance: (final MoneyObject instance) => (instance as Account).count.value,
  );

  /// Balance
  double balance = 0.00;

  /// Balance in Native currency
  FieldMoney balanceNative = FieldMoney(
    importance: 98,
    name: 'BalanceN',
    valueFromInstance: (final MoneyObject instance) {
      final accountInstance = instance as Account;
      return MoneyModel(amount: accountInstance.balance, iso4217: accountInstance.getAccountCurrencyAsText());
    },
  );

  /// Balance Normalized use in the List view
  FieldMoney balanceNormalized = FieldMoney(
      importance: 99,
      name: 'Balance(USD)',
      useAsDetailPanels: false,
      valueFromInstance: (final MoneyObject instance) {
        final accountInstance = instance as Account;
        return MoneyModel(
            amount: accountInstance.getCurrencyRatio() * accountInstance.balance, iso4217: Constants.defaultCurrency);
      });

  Field<bool> isAccountOpen = Field<bool>(
    name: 'Account is open',
    defaultValue: false,
    useAsColumn: false,
    useAsDetailPanels: true,
    type: FieldType.toggle,
    valueFromInstance: (final MoneyObject instance) => !(instance as Account).isClosed(),
    setValue: (final MoneyObject instance, dynamic value) {
      (instance as Account).isOpen = value as bool;
      Data().notifyTransactionChange(mutation: MutationType.changed, moneyObject: instance);
    },
  );

  /// Constructor
  Account() {
    buildFieldsAsWidgetForSmallScreen = () {
      Widget? originalCurrencyAndValue;

      if (currency.value == Constants.defaultCurrency) {
        originalCurrencyAndValue = Currency.buildCurrencyWidget(currency.value);
      } else {
        double ratioCurrency = getCurrencyRatio();
        originalCurrencyAndValue = Tooltip(
          message: ratioCurrency.toString(),
          child: Row(
            children: [
              Text(Currency.getAmountAsStringUsingCurrency(balance / ratioCurrency, iso4217code: currency.value)),
              const SizedBox(width: 4),
              Currency.buildCurrencyWidget(currency.value),
            ],
          ),
        );
      }

      return MyListItemAsCard(
          leftTopAsString: name.value,
          leftBottomAsString: getTypeAsText(type.value),
          rightTopAsString: Currency.getAmountAsStringUsingCurrency(balance),
          rightBottomAsWidget: originalCurrencyAndValue);
    };
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  /// Constructor from a SQLite row
  factory Account.fromJson(final MyJson row) {
    return Account()
      ..id.value = row.getInt('Id')
      ..accountId.value = row.getString('AccountId')
      ..ofxAccountId.value = row.getString('OfxAccountId')
      ..name.value = row.getString('Name')
      ..description.value = row.getString('Description')
      ..type.value = AccountType.values[row.getInt('Type')]
      ..openingBalance.value = row.getDouble('OpeningBalance')
      ..currency.value = row.getString('Currency', Constants.defaultCurrency)
      ..onlineAccount.value = row.getInt('OnlineAccount')
      ..webSite.value = row.getString('WebSite')
      ..reconcileWarning.value = row.getInt('ReconcileWarning')
      ..lastSync.value = row.getDate('LastSync')
      ..syncGuid.value = row.getString('SyncGuid')
      ..flags.value = row.getInt('Flags')
      ..lastBalance.value = row.getDate('LastBalance')
      ..categoryIdForPrincipal.value = row.getInt('CategoryIdForPrincipal', -1)
      ..categoryIdForInterest.value = row.getInt('CategoryIdForInterest', -1);
  }

// cache the currency ratio
  double? ratio;

  double getCurrencyRatio() {
    return Data().currencies.getRatioFromSymbol(currency.value);
  }

  static String getName(final Account? instance) {
    return instance == null ? '' : (instance).name.value;
  }

  bool isBitOn(final int value, final int bitIndex) {
    return (value & bitIndex) == bitIndex;
  }

  bool isClosed() {
    return isBitOn(flags.value, AccountFlags.closed.index);
  }

  bool get isOpen {
    return !isClosed();
  }

  set isOpen(bool value) {
    if (value) {
      flags.value &= ~AccountFlags.closed.index; // Remove the bit at the specified position
    } else {
      flags.value |= AccountFlags.closed.index; // Set the bit at the specified position
    }
  }

  bool matchType(final List<AccountType> types) {
    if (types.isEmpty) {
      // All accounts except the fake ones
      return !isFakeAccount();
    }
    return types.contains(type.value);
  }

  bool isBankAccount() {
    return type.value == AccountType.savings || type.value == AccountType.checking || type.value == AccountType.cash;
  }

  bool isFakeAccount() {
    return type.value == AccountType.notUsed_7 || type.value == AccountType.categoryFund;
  }

  bool isActiveBankAccount() {
    return isBankAccount() && isOpen;
  }
}
