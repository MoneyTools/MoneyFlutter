import 'dart:ui';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/accounts/accounts.dart';
import 'package:money/models/categories/categories.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/money_entity.dart';
import 'package:money/models/payees/payees.dart';

const String columnIdAccount = 'Accounts';
const String columnIdDate = 'Date';
const String columnIdPayee = 'Payee';
const String columnIdCategory = 'Category';
const String columnIdStatus = 'Status';
const String columnIdMemo = 'Memo';
const String columnIdAmount = 'Amount';
const String columnIdBalance = 'Balance';

class Transaction extends MoneyEntity {
  final int accountId;
  final DateTime dateTime;
  late final String dateTimeAsText;
  final int payeeId;
  String originalPayee = ''; // before auto-aliasing, helps with future merging.
  final int categoryId;
  final double amount;
  double balance;

  double salesTax = 0;
  TransactionStatus status = TransactionStatus.none;

  String memo;
  String fitid;

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

  Transaction(
    super.id,
    super.name, {
    required this.dateTime,
    this.accountId = -1,
    this.payeeId = -1,
    this.categoryId = -1,
    this.amount = 0.00,
    this.balance = 0.00,
    this.memo = '',
    this.fitid = '',
  }) {
    dateTimeAsText = getDateAsText(dateTime);
  }

  static FieldDefinition<Transaction> getFieldAccountName() {
    return FieldDefinition<Transaction>(
      name: columnIdAccount,
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final Transaction transaction) {
        return Accounts.getNameFromId(transaction.accountId);
      },
      sort: (final Transaction a, final Transaction b, final bool ascending) {
        return sortByString(Accounts.getNameFromId(a.accountId), Accounts.getNameFromId(b.accountId), ascending);
      },
    );
  }

  static FieldDefinition<Transaction> getFieldDate() {
    return FieldDefinition<Transaction>(
        name: columnIdDate,
        serializeName: 'date',
        type: FieldType.text,
        align: TextAlign.left,
        valueFromInstance: (final Transaction transaction) {
          return transaction.dateTimeAsText;
        },
        valueForSerialization: (final Transaction transaction) {
          return transaction.dateTime.toIso8601String();
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByDate(a.dateTime, b.dateTime, ascending);
        });
  }

  static FieldDefinition<Transaction> getFieldPayeeName() {
    return FieldDefinition<Transaction>(
      name: columnIdPayee,
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final Transaction transaction) {
        return Payees.getNameFromId(transaction.payeeId);
      },
      sort: (final Transaction a, final Transaction b, final bool ascending) {
        return sortByString(Payees.getNameFromId(a.payeeId), Payees.getNameFromId(b.payeeId), ascending);
      },
    );
  }

  static FieldDefinition<Transaction> getFieldCategoryName() {
    return FieldDefinition<Transaction>(
      name: columnIdCategory,
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final Transaction transaction) {
        return Categories.getNameFromId(transaction.categoryId);
      },
      sort: (final Transaction a, final Transaction b, final bool ascending) {
        return sortByString(Categories.getNameFromId(a.categoryId), Categories.getNameFromId(b.categoryId), ascending);
      },
    );
  }

  static FieldDefinition<Transaction> getFieldStatus() {
    return FieldDefinition<Transaction>(
      name: columnIdStatus,
      serializeName: 'status',
      type: FieldType.text,
      align: TextAlign.center,
      valueFromInstance: (final Transaction transaction) {
        return transaction.status.name[0].toUpperCase();
      },
      valueForSerialization: (final Transaction transaction) {
        return transaction.status.index;
      },
      sort: (final Transaction a, final Transaction b, final bool ascending) {
        return sortByValue(a.status.index, b.status.index, ascending);
      },
    );
  }

  static FieldDefinition<Transaction> getFieldAmount() {
    return FieldDefinition<Transaction>(
      name: columnIdAmount,
      type: FieldType.amount,
      align: TextAlign.right,
      valueFromInstance: (final Transaction transaction) {
        return transaction.amount;
      },
      sort: (final Transaction a, final Transaction b, final bool ascending) {
        return sortByValue(a.amount, b.amount, ascending);
      },
    );
  }

  static FieldDefinition<Transaction> getFieldBalance() {
    return FieldDefinition<Transaction>(
      name: columnIdBalance,
      type: FieldType.amount,
      align: TextAlign.right,
      valueFromInstance: (final Transaction transaction) {
        return transaction.balance;
      },
      sort: (final Transaction a, final Transaction b, final bool ascending) {
        return sortByValue(a.balance, b.balance, ascending);
      },
    );
  }

  static FieldDefinition<Transaction> getFieldMemo() {
    return FieldDefinition<Transaction>(
      name: columnIdMemo,
      serializeName: 'memo',
      type: FieldType.text,
      align: TextAlign.left,
      valueFromInstance: (final Transaction transaction) {
        return transaction.memo;
      },
      sort: (final Transaction a, final Transaction b, final bool ascending) {
        return sortByString(a.memo, b.memo, ascending);
      },
    );
  }

  static FieldDefinitions<Transaction> getFieldDefinitions() {
    final FieldDefinitions<Transaction> fields =
        FieldDefinitions<Transaction>(definitions: <FieldDefinition<Transaction>>[
      MoneyObjects<Transaction>().getFieldId(),
      MoneyObjects<Transaction>().getFieldName(),
      FieldDefinition<Transaction>(
        useAsColumn: false,
        name: 'AccountId',
        serializeName: 'accountId',
        type: FieldType.numeric,
        align: TextAlign.right,
        valueFromInstance: (final Transaction transaction) {
          return transaction.accountId;
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByValue(a.accountId, b.accountId, ascending);
        },
      ),
      FieldDefinition<Transaction>(
        useAsColumn: false,
        name: columnIdCategory,
        serializeName: 'categoryId',
        type: FieldType.numeric,
        align: TextAlign.right,
        valueFromInstance: (final Transaction transaction) {
          return transaction.categoryId;
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByValue(a.categoryId, b.categoryId, ascending);
        },
      ),
      getFieldAccountName(),
      getFieldDate(),
      getFieldPayeeName(),
      getFieldCategoryName(),
      getFieldStatus(),
      getFieldMemo(),
      getFieldAmount(),
      getFieldBalance(),
    ]);
    return fields;
  }

  static FieldDefinition<Transaction>? getFieldDefinitionFromId(
    final String id,
    final List<Transaction> Function() getList,
  ) {
    switch (id) {
      case columnIdAccount:
        return getFieldAccountName();
      case columnIdDate:
        return getFieldDate();
      case columnIdPayee:
        return getFieldPayeeName();
      case columnIdCategory:
        return getFieldCategoryName();
      case columnIdMemo:
        return getFieldMemo();
      case columnIdStatus:
        return getFieldStatus();
      case columnIdAmount:
        return getFieldAmount();
      case columnIdBalance:
        return getFieldBalance();
    }
    return null;
  }

  @override
  String toString([final bool multiline = false]) {
    final String delimiter = multiline ? '\n' : ', ';
    return '${getDateAsText(dateTime)}$delimiter${getCurrencyText(amount)}$delimiter$memo';
  }
}

enum TransactionStatus {
  none,
  electronic,
  cleared,
  reconciled,
  voided,
}

enum TransactionFlags {
  none, // 0
  unaccepted, // 1
  // 2
  budgeted,
  // 3
  filler3,
  // 4
  hasAttachment,
  // 5
  filler5,
  // 6
  filler6,
  // 7
  filler7,
  // 8
  notDuplicate,
  filler9,
  filler10,
  filler11,
  filler12,
  filler13,
  filler14,
  filler15,
  // 16
  hasStatement,
}
