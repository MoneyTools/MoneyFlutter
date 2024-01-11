import 'dart:ui';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/accounts/accounts.dart';
import 'package:money/models/categories/categories.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/models/payees/payees.dart';
import 'package:money/models/transactions/transaction.dart';

const String columnIdAccount = 'Accounts';
const String columnIdDate = 'Date';
const String columnIdPayee = 'Payee';
const String columnIdCategory = 'Category';
const String columnIdMemo = 'Memo';
const String columnIdAmount = 'Amount';
const String columnIdBalance = 'Balance';

FieldDefinition<Transaction>? getFieldDefinitionFromId(
  final String id,
  final List<Transaction> Function() getList,
) {
  switch (id) {
    case columnIdAccount:
      return FieldDefinition<Transaction>(
        name: columnIdAccount,
        type: FieldType.text,
        align: TextAlign.left,
        valueFromList: (final int index) {
          return Accounts.getNameFromId((getList()[index]).accountId);
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByString(Accounts.getNameFromId(a.accountId), Accounts.getNameFromId(b.accountId), ascending);
        },
      );
    case columnIdDate:
      return FieldDefinition<Transaction>(
          name: columnIdDate,
          type: FieldType.text,
          align: TextAlign.left,
          valueFromList: (final int index) {
            return getList()[index].dateTimeAsText;
          },
          sort: (final Transaction a, final Transaction b, final bool ascending) {
            return sortByDate(a.dateTime, b.dateTime, ascending);
          });

    case columnIdPayee:
      return FieldDefinition<Transaction>(
        name: columnIdPayee,
        type: FieldType.text,
        align: TextAlign.left,
        valueFromList: (final int index) {
          return Payees.getNameFromId((getList()[index]).payeeId);
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByString(Payees.getNameFromId(a.payeeId), Payees.getNameFromId(b.payeeId), ascending);
        },
      );

    case columnIdCategory:
      return FieldDefinition<Transaction>(
        name: columnIdCategory,
        type: FieldType.text,
        align: TextAlign.left,
        valueFromList: (final int index) {
          return Categories.getNameFromId((getList()[index]).categoryId);
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByString(
              Categories.getNameFromId(a.categoryId), Categories.getNameFromId(b.categoryId), ascending);
        },
      );

    case columnIdMemo:
      return FieldDefinition<Transaction>(
        name: columnIdMemo,
        type: FieldType.text,
        align: TextAlign.left,
        valueFromList: (final int index) {
          return getList()[index].memo;
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByString(a.memo, b.memo, ascending);
        },
      );

    case columnIdAmount:
      return FieldDefinition<Transaction>(
        name: columnIdAmount,
        type: FieldType.amount,
        align: TextAlign.right,
        valueFromList: (final int index) {
          return (getList()[index]).amount;
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByValue(a.amount, b.amount, ascending);
        },
      );

    case columnIdBalance:
      return FieldDefinition<Transaction>(
        name: columnIdBalance,
        type: FieldType.amount,
        align: TextAlign.right,
        valueFromList: (final int index) {
          return (getList()[index]).balance;
        },
        sort: (final Transaction a, final Transaction b, final bool ascending) {
          return sortByValue(a.balance, b.balance, ascending);
        },
      );
  }
  return null;
}
