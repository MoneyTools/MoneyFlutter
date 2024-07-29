// Imports
// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/controller/selection_controller.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/widgets/money_widget.dart';
import 'package:money/app/core/widgets/picker_edit_box_date.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:money/app/core/widgets/suggestion_approval.dart';
import 'package:money/app/core/widgets/token_text.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/investments/investment.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/investments/investments.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/data/models/money_objects/splits/splits.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction_types.dart';
import 'package:money/app/data/models/money_objects/transfers/transfer.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item_card.dart';
import 'package:money/app/modules/home/sub_views/view_categories/picker_category.dart';
import 'package:money/app/modules/home/sub_views/view_payees/picker_payee_or_transfer.dart';

// Exports
export 'package:money/app/data/models/money_objects/transactions/transaction_types.dart';

/// Main source of information for this App
/// All transactions are loaded in this class [Transaction] and [Split]
class Transaction extends MoneyObject {
  Transaction({
    final TransactionStatus status = TransactionStatus.none,
    final int accountId = -1,
    required final DateTime? date,
  }) {
    // assert(date != null);
    this.fieldAccountId.value = accountId;
    this.dateTime.value = date;
    this.fieldStatus.value = status;
    this.fieldFlags.value = TransactionFlags.none.index;
  }

  factory Transaction.fromJSon(final MyJson json, final double runningBalance) {
    final Transaction t = Transaction(date: json.getDate('Date'));
// 0 ID
    t.fieldId.value = json.getInt('Id', -1);
// 1 Account ID
    t.fieldAccountId.value = json.getInt('Account', -1);
    t.fieldAccountInstance = Data().accounts.get(t.fieldAccountId.value);
// 3 Status
    t.fieldStatus.value = TransactionStatus.values[json.getInt('Status')];
// 4 Payee ID
    t.fieldPayee.value = json.getInt('Payee', -1);
// 5 Original Payee
    t.fieldOriginalPayee.value = json.getString('OriginalPayee');
// 6 Category Id
    t.fieldCategoryId.value = json.getInt('Category', -1);
// 7 Memo
    t.fieldMemo.value = json.getString('Memo');
// 8 Number
    t.fieldNumber.value = json.getString('Number');
// 9 Reconciled Date
    t.fieldReconciledDate.value = json.getDate('ReconciledDate');
// 10 BudgetBalanceDate
    t.fieldBudgetBalanceDate.value = json.getDate('BudgetBalanceDate');
// 11 Transfer
    t.fieldTransfer.value = json.getInt('Transfer', -1);
// 12 FITID
    t.fieldFitid.value = json.getString('FITID');
// 13 Flags
    t.fieldFlags.value = json.getInt('Flags');

// 14 Amount
    t.fieldAmount.value.setAmount(json.getDouble('Amount'));
// 15 Sales Tax
    t.fieldSalesTax.value.setAmount(json.getDouble('SalesTax'));
// 16 Transfer Split
    t.fieldTransferSplit.value = json.getInt('TransferSplit', -1);
// 17 Merge Date
    t.fieldMergeDate.value = json.getDate('MergeDate');

// not serialized
    t.balance = runningBalance;

    return t;
  }

  //------------------------------------------------------------------------
  // Not serialized
  // derived property used for display

  /// Amount Normalized to USD
  FieldMoney amountAsTextNormalized = FieldMoney(
    name: columnIdAmountNormalized,
    columnWidth: ColumnWidth.small,
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as Transaction).getNormalizedAmount(instance.fieldAmount.value.toDouble()),
      iso4217: Constants.defaultCurrency,
    ),
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByValue(
      (a as Transaction).fieldAmount.value.toDouble(),
      (b as Transaction).fieldAmount.value.toDouble(),
      ascending,
    ),
  );

  /// Balance native
  double balance = 0;

  /// Balance native
  FieldMoney balanceNative = FieldMoney(
    name: columnIdBalance,
    columnWidth: ColumnWidth.small,
    footer: FooterType.none,
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as Transaction).balance,
      iso4217: instance.getCurrency(),
    ),
  );

  /// Balance Normalized to USD
  FieldMoney balanceNormalized = FieldMoney(
    name: 'Balance(USD)',
    columnWidth: ColumnWidth.small,
    footer: FooterType.none,
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as Transaction).getNormalizedAmount((instance).balance),
      iso4217: Constants.defaultCurrency,
    ),
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByValue(
      (a as Transaction).balance,
      (b as Transaction).balance,
      ascending,
    ),
  );

  FieldString currency = FieldString(
    type: FieldType.widget,
    name: 'Currency',
    align: TextAlign.center,
    columnWidth: ColumnWidth.tiny,
    footer: FooterType.count,
    getValueForReading: (final MoneyObject instance) => (instance as Transaction).getCurrency(),
    getValueForDisplay: (final MoneyObject instance) {
      return Currency.buildCurrencyWidget(
        (instance as Transaction).getCurrency(),
      );
    },
  );

  /// Date
  /// SQLite 2|Date|datetime|1||0
  FieldDate dateTime = FieldDate(
    name: 'Date',
    serializeName: 'Date',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).dateTime.value,
    getValueForSerialization: (final MoneyObject instance) => dateToSqliteFormat(
      (instance as Transaction).dateTime.value,
    ),
    getEditWidget: (final MoneyObject instance, Function(bool wasModified) onEdited) {
      return PickerEditBoxDate(
        initialValue: (instance as Transaction).dateTimeAsText,
        onChanged: (String? newDateSelected) {
          if (newDateSelected != null) {
            instance.dateTime.value = attemptToGetDateFromText(newDateSelected);
            onEdited(true);
          }
        },
      );
    },
    setValue: (MoneyObject instance, dynamic newValue) =>
        (instance as Transaction).dateTime.value = attemptToGetDateFromText(newValue),
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) =>
        sortByDateTime(a as Transaction, b as Transaction, ascending),
  );

  /// Account Id
  /// SQLite  1|Account|INT|1||0
  FieldInt fieldAccountId = FieldInt(
    type: FieldType.text,
    name: 'Account',
    serializeName: 'Account',
    align: TextAlign.left,
    footer: FooterType.count,
    defaultValue: -1,
    getValueForDisplay: (final MoneyObject instance) =>
        Data().accounts.getNameFromId((instance as Transaction).fieldAccountId.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldAccountId.value,
    setValue: (MoneyObject instance, dynamic newValue) => (instance as Transaction).fieldAccountId.value = newValue,
  );

  /// Amount
  /// 14|Amount|money|1||0
  FieldMoney fieldAmount = FieldMoney(
    name: columnIdAmount,
    serializeName: 'Amount',
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as Transaction).fieldAmount.value.toDouble(),
      iso4217: instance.getCurrency(),
    ),
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldAmount.value.toDouble(),
    setValue: (final MoneyObject instance, dynamic newValue) =>
        (instance as Transaction).fieldAmount.value.setAmount(newValue),
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByValue(
      (a as Transaction).fieldAmount.value.toDouble(),
      (b as Transaction).fieldAmount.value.toDouble(),
      ascending,
    ),
  );

  /// Budget Balance Date
  /// 10|BudgetBalanceDate|datetime|0||0
  FieldDate fieldBudgetBalanceDate = FieldDate(
    name: 'ReconciledDate',
    serializeName: 'ReconciledDate',
    getValueForDisplay: (final MoneyObject instance) => dateToIso8601OrDefaultString(
      (instance as Transaction).fieldBudgetBalanceDate.value,
    ),
    getValueForSerialization: (final MoneyObject instance) => dateToIso8601OrDefaultString(
      (instance as Transaction).fieldBudgetBalanceDate.value,
    ),
  );

  /// Category Id
  /// SQLite 6|Category|INT|0||0
  FieldInt fieldCategoryId = FieldInt(
    type: FieldType.widget,
    columnWidth: ColumnWidth.large,
    align: TextAlign.left,
    footer: FooterType.count,
    name: 'Category',
    serializeName: 'Category',
    defaultValue: -1,
    getValueForDisplay: (final MoneyObject instance) {
      final t = (instance as Transaction);
      if (t.fieldCategoryId.value == -1 && t.possibleMatchingCategoryId != -1) {
        return SuggestionApproval(
          child: TokenText(Data().categories.getNameFromId(t.possibleMatchingCategoryId)),
          onApproved: () {
            // record the change
            t.stashValueBeforeEditing();

            // Make change
            t.fieldCategoryId.value = t.possibleMatchingCategoryId;
            t.possibleMatchingCategoryId = -1;

            // inform of changes
            Data().notifyMutationChanged(
              mutation: MutationType.changed,
              moneyObject: t,
              recalculateBalances: false,
            );
          },
          onRejected: () {
            t.possibleMatchingCategoryId = -1;
          },
        );
      } else {
        return TokenText(Data().categories.getNameFromId(t.fieldCategoryId.value));
      }
    },
    getValueForReading: (final MoneyObject instance) =>
        Data().categories.getNameFromId((instance as Transaction).fieldCategoryId.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldCategoryId.value,
    setValue: (final MoneyObject instance, dynamic newValue) =>
        (instance as Transaction).fieldCategoryId.value = newValue as int,
    getEditWidget: (final MoneyObject instance, Function(bool wasModified) onEdited) {
      return pickerCategory(
        itemSelected: Data().categories.get((instance as Transaction).fieldCategoryId.value),
        onSelected: (Category? newCategory) {
          if (newCategory != null) {
            instance.fieldCategoryId.value = newCategory.uniqueId;
            // notify container
            onEdited(true);
          }
        },
      );
    },
  );

  /// FITID
  /// 12|FITID|nchar(40)|0||0
  FieldString fieldFitid = FieldString(
    name: 'FITID',
    serializeName: 'FITID',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).fieldFitid.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldFitid.value,
  );

  /// Flags
  /// 13|Flags|INT|1||0
  FieldInt fieldFlags = FieldInt(
    name: 'Flags',
    serializeName: 'Flags',
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).fieldFlags.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldFlags.value,
  );

  /// ID
  /// SQLite  0|Id|bigint|0||1
  FieldId fieldId = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).uniqueId,
  );

  /// Memo
  /// 7|Memo|nvarchar(255)|0||0
  FieldString fieldMemo = FieldString(
    name: 'Memo',
    serializeName: 'Memo',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).fieldMemo.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldMemo.value,
    setValue: (MoneyObject instance, dynamic newValue) => (instance as Transaction).fieldMemo.value = newValue,
  );

  /// MergeDate
  /// 17|MergeDate|datetime|0||0
  FieldDate fieldMergeDate = FieldDate(
    name: 'Merge Date',
    serializeName: 'MergeDate',
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as Transaction).fieldMergeDate.value),
    getValueForSerialization: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as Transaction).fieldMergeDate.value),
  );

  /// Number
  /// 8|Number|nchar(10)|0||0
  FieldString fieldNumber = FieldString(
    name: 'Number',
    serializeName: 'Number',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).fieldNumber.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldNumber.value,
  );

  /// OriginalPayee
  /// before auto-aliasing, helps with future merging.
  /// SQLite 5|OriginalPayee|nvarchar(255)|0||0
  FieldString fieldOriginalPayee = FieldString(
    name: 'Original Payee',
    serializeName: 'OriginalPayee',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).fieldOriginalPayee.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldOriginalPayee.value,
  );

  /// Payee Id (displayed as Text name of the Payee)
  /// SQLite 4|Payee|INT|0||0
  FieldInt fieldPayee = FieldInt(
    name: 'Payee/Transfer',
    serializeName: 'Payee',
    defaultValue: -1,
    type: FieldType.text,
    footer: FooterType.count,
    align: TextAlign.left,
    columnWidth: ColumnWidth.largest,
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByString(
      (a as Transaction).payeeName,
      (b as Transaction).payeeName,
      ascending,
    ),
    getValueForDisplay: (final MoneyObject instance) {
      return (instance as Transaction).getPayeeOrTransferCaption();
    },
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldPayee.value,
    setValue: (MoneyObject instance, dynamic newValue) {
      instance = instance as Transaction;
      instance.stashOriginalPayee();
      if (newValue == -1 || newValue == Data().categories.transfer.uniqueId) {
        // -1 means no payee, this is a Transfer?
        // TODO - implement was solution given that the call back here only has one value use for the Payee ID
      } else {
        // Payee
        instance.fieldPayee.value = (newValue as int); // Payee Id
        instance.fieldTransfer.value = -1;
        instance.transferInstance = null;
      }
    },
    getEditWidget: (MoneyObject instance, Function(bool wasModified) onEdited) {
      return SizedBox(
        width: 300,
        height: 80,
        child: PickPayeeOrTransfer(
          choice: (instance as Transaction).fieldTransfer.value == -1
              ? TransactionFlavor.payee
              : TransactionFlavor.transfer,
          payee: Data().payees.get(instance.fieldPayee.value),
          account: instance.transferInstance?.getReceiverAccount(),
          amount: instance.fieldAmount.value.toDouble(),
          onSelected: (
            TransactionFlavor choice,
            Payee? selectedPayee,
            Account? account,
          ) {
            bool wasModified = false;

            switch (choice) {
              case TransactionFlavor.payee:
                if (selectedPayee != null) {
                  instance.fieldPayee.value = selectedPayee.uniqueId;
                  instance.fieldTransfer.value = -1;
                  instance.transferInstance = null;
                  wasModified = true;
                }
              case TransactionFlavor.transfer:
                if (account != null) {
                  if (instance.transferInstance != null) {
                    // this was already a transfer, lets see if the destination account has changed
                    if (instance.transferInstance?.getReceiverAccount()?.uniqueId == account.uniqueId) {
                      // same account do noting
                    } else {
                      // use the new account destination
                      Transaction relatedTransaction = instance.transferInstance!.related!;
                      instance.transferInstance!.related!.fieldAccountInstance = Data().accounts.get(
                            account.uniqueId,
                          );
                      relatedTransaction.mutateField(
                        'Account',
                        account.uniqueId,
                        false,
                      );
                      wasModified = true;
                    }
                  } else {
                    instance.fieldPayee.value = Data().categories.transfer.uniqueId;
                    Data().makeTransferLinkage(instance, account);
                  }
                }
            }
            onEdited(wasModified); // notify container
          },
        ),
      );
    },
  );

  /// Reconciled Date
  /// 9|ReconciledDate|datetime|0||0
  FieldDate fieldReconciledDate = FieldDate(
    name: 'ReconciledDate',
    serializeName: 'ReconciledDate',
    getValueForDisplay: (final MoneyObject instance) => dateToIso8601OrDefaultString(
      (instance as Transaction).fieldReconciledDate.value,
    ),
    getValueForSerialization: (final MoneyObject instance) => dateToIso8601OrDefaultString(
      (instance as Transaction).fieldReconciledDate.value,
    ),
  );

  /// Sales Tax
  /// 15|SalesTax|money|0||0
  FieldMoney fieldSalesTax = FieldMoney(
    name: 'Sales Tax',
    serializeName: 'SalesTax',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).fieldSalesTax.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldSalesTax.value.toDouble(),
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByValue(
      (a as Transaction).fieldSalesTax.value.toDouble(),
      (b as Transaction).fieldSalesTax.value.toDouble(),
      ascending,
    ),
  );

  /// Status N | E | C | R
  /// SQLite 3|Status|INT|0||0
  Field<TransactionStatus> fieldStatus = Field<TransactionStatus>(
    type: FieldType.widget,
    align: TextAlign.center,
    columnWidth: ColumnWidth.tiny,
    defaultValue: TransactionStatus.none,
    useAsDetailPanels: defaultCallbackValueFalse,
    name: columnIdStatus,
    serializeName: 'Status',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction)._buildStatusButtonToggle(),
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldStatus.value.index,
    setValue: (MoneyObject instance, dynamic newValue) => (instance as Transaction).fieldStatus.value = newValue,
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByString(
      transactionStatusToLetter((a as Transaction).fieldStatus.value),
      transactionStatusToLetter((b as Transaction).fieldStatus.value),
      ascending,
    ),
  );

  /// Transfer
  /// 11|Transfer|bigint|0||0
  Field<int> fieldTransfer = Field<int>(
    name: 'Transfer',
    serializeName: 'Transfer',
    defaultValue: -1,
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).fieldTransfer.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldTransfer.value,
  );

  /// Transfer Split
  /// 16|TransferSplit|INT|0||0
  FieldInt fieldTransferSplit = FieldInt(
    name: 'TransferSplit',
    serializeName: 'TransferSplit',
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).fieldTransferSplit.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fieldTransferSplit.value,
  );

  FieldString paidOn = FieldString(
    type: FieldType.text,
    name: columnIdPaidOn,
    align: TextAlign.right,
    columnWidth: ColumnWidth.tiny,
    footer: FooterType.none,
    getValueForDisplay: (final MoneyObject instance) {
      return (instance as Transaction).paidOn.value;
    },
  );

  int possibleMatchingCategoryId = -1;
  List<MoneySplit> splits = [];

  /// Used for establishing relation between two transactions
  Transfer? transferInstance;

  Account? fieldAccountInstance;
  Investment? investmentInstance;

  String? _transferName;

  @override
  Widget buildFieldsAsWidgetForSmallScreen() {
    return MyListItemAsCard(
      leftTopAsString: payeeName,
      leftBottomAsString: '${Data().categories.getNameFromId(fieldCategoryId.value)}\n${fieldMemo.value}',
      rightTopAsWidget: MoneyWidget(amountModel: fieldAmount.value, asTile: true),
      rightBottomAsString: '$dateTimeAsText\n${Account.getName(fieldAccountInstance)}',
    );
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  @override
  String getRepresentation() {
    return getAccountName();
  }

  @override
  MoneyObject rollup(List<MoneyObject> moneyObjectInstances) {
    if (moneyObjectInstances.isEmpty) {
      return Transaction(date: DateTime.now());
    }
    if (moneyObjectInstances.length == 1) {
      return moneyObjectInstances.first;
    }

    MyJson commonJson = moneyObjectInstances.first.getPersistableJSon();

    for (var t in moneyObjectInstances.skip(1)) {
      commonJson = compareAndGenerateCommonJson(commonJson, t.getPersistableJSon());
    }
    return Transaction.fromJSon(commonJson, 0);
  }

  @override
  int get uniqueId => fieldId.value;

  @override
  set uniqueId(value) => fieldId.value = value;

  static final Fields<Transaction> _fields = Fields<Transaction>();

  String get amountAsText => fieldAmount.value.toString();

  /// TODO - clean this up,
  void checkTransfers(Set<Transaction> dangling, List<Account> deletedAccounts) {
    if (fieldTransfer.value != -1 && this.transferInstance == null) {
      // transferInstance?.getReceiverAccount();
      // if (IsDeletedAccount(this.to, money, deletedAccounts)) {
      //   this.Category =
      //       this.Amount < 0 ? Data().categories.TransferToDeletedAccount : money.Categories.TransferFromDeletedAccount;
      //   this.to = null;
      // } else {
      dangling.add(this);
      // }
    }

    if (this.transferInstance != null) {
      Transaction other = this.transferInstance!.related!;
      if (other.isSplit) {
        //       int count = 0;
        //       Split splitXfer = null;
        //
        //       for (Split s in other.splits.GetSplits()) {
        //         if (s.transfer != null) {
        //           if (splitXfer == null) {
        //             splitXfer = s;
        //           }
        //           if (s.transfer.Transaction == this) {
        //             count++;
        //           }
        //         }
        // }
        //
        //       if (count == 0) {
        //         if (other.transfer != null && other.transfer.transaction == this) {
        //           // Ok, well it could be that the transfer is the whole transaction, but then
        //           // one side was itemized. For example, you transfer 500 from one account to
        //           // another, then on the deposit side you want to record what that was for
        //           // by itemizing the $500 in a split.  If this is the case then it is not dangling.
        //         } else if (!this.AutoFixDandlingTransfer(splitXfer)) {
        //           added = true;
        //           dangling.add(this);
        //         }
        //       }
      } else {
        if ((other.transferInstance == null || other.transferInstance?.related != this)) {
          dangling.add(this);
        } else {
          // one last check, the other side also needs to be correctly setup as a transafer
          if (other.fieldTransfer.value != this.uniqueId) {
            dangling.add(this);
          }
        }
      }
    }
  }

  bool containsTransferTo(Account a) {
    if (this.isSplit) {
      for (MoneySplit s in this.splits) {
        if (s.fieldTransferId.value != -1 && s.getTransferTransaction()?.fieldAccountId.value == a.uniqueId) {
          return true;
        }
      }
    }
    if (this.transferInstance != null && this.transferInstance?.related?.fieldAccountId.value == a.uniqueId) {
      return true;
    }
    return false;
  }

  ///------------------------------------------------------
  /// Non persisted fields
  String get dateTimeAsText => dateToString(dateTime.value);

  static Fields<Transaction> get fields {
    if (_fields.isEmpty) {
      final tmp = Transaction(date: DateTime.now());
      _fields.setDefinitions(
        [
          tmp.fieldId,
          tmp.dateTime,
          tmp.fieldAccountId,
          tmp.fieldPayee,
          tmp.fieldOriginalPayee,
          tmp.fieldCategoryId,
          tmp.fieldMemo,
          tmp.fieldNumber,
          tmp.fieldReconciledDate,
          tmp.fieldBudgetBalanceDate,
          tmp.fieldTransfer,
          tmp.fieldStatus,
          tmp.fieldFitid,
          tmp.fieldFlags,
          tmp.currency,
          tmp.fieldSalesTax,
          tmp.fieldTransferSplit,
          tmp.fieldMergeDate,
          tmp.fieldAmount,
          tmp.amountAsTextNormalized,
          tmp.balanceNative,
          tmp.balanceNormalized,
          tmp.paidOn,
        ],
      );
    }
    return _fields;
  }

  static Fields<Transaction> get fieldsForColumnView {
    final tmp = Transaction(date: DateTime.now());
    return Fields<Transaction>()
      ..setDefinitions(
        [
          tmp.dateTime,
          tmp.fieldAccountId,
          tmp.fieldPayee,
          tmp.fieldCategoryId,
          tmp.fieldNumber,
          tmp.fieldStatus,
          tmp.currency,
          tmp.fieldAmount,
          tmp.amountAsTextNormalized,
          tmp.balanceNormalized,
        ],
      );
  }

  Account? getAccount() {
    if (fieldAccountInstance != null) {
      return fieldAccountInstance;
    }
    return Data().accounts.get(fieldAccountId.value);
  }

  String getAccountName() {
    if (getAccount() != null) {
      return getAccount()!.fieldName.value;
    }
    return '???';
  }

  String getCurrency() {
    if (this.fieldAccountInstance == null || this.fieldAccountInstance!.currency.value.isEmpty) {
      return Constants.defaultCurrency;
    }

    return this.fieldAccountInstance!.currency.value;
  }

  static String getDefaultCurrency(final Account? accountInstance) {
// Convert the value to USD
    if (accountInstance == null || accountInstance.getCurrencyRatio() == 0) {
      return Constants.defaultCurrency;
    }
    return accountInstance.currency.value;
  }

  double getNormalizedAmount(double nativeValue) {
    // Convert the value to USD
    if (fieldAccountInstance == null || fieldAccountInstance?.getCurrencyRatio() == 0) {
      return nativeValue;
    }
    return nativeValue * fieldAccountInstance!.getCurrencyRatio();
  }

  Investment? getOrCreateInvestment() {
    if (this.investmentInstance == null) {
      this.investmentInstance = Data().investments.get(this.uniqueId);
      if (this.investmentInstance != null) {
        this.investmentInstance!.transactionInstance = this;
      }
    }
    return this.investmentInstance;
  }

  String getPayeeOrTransferCaption() {
    Investment? investment = investmentInstance;
    double amount = this.fieldAmount.value.toDouble();

    bool isFrom = false;
    if (transferInstance != null) {
      if (investment != null) {
        if (investment.fieldInvestmentType.value == InvestmentType.add.index) {
          isFrom = true;
        }
      } else if (amount > 0) {
        isFrom = true;
      }
      if (transferInstance!.related != null) {
        return getTransferCaption(
          transferInstance!.getReceiverAccount(),
          isFrom,
        );
      }
      return '';
    }
    final String displayName = Data().payees.getNameFromId(fieldPayee.value);
    return displayName;
  }

  Account? getRelatedAccount() {
    if (transferInstance != null) {
      if (transferInstance!.related != null) {
        return transferInstance!.related!.getAccount();
      }
    }
    return null;
  }

  String getTransferCaption(final Account? account, final bool isFrom) {
    String arrowDirection = isFrom ? ' ← ' : ' → ';

    String caption = 'Transfer$arrowDirection';
    if (account == null) {
      return '???';
    }
    if (account.isClosed()) {
      caption += 'Closed-Account: ';
    }
    caption += account.fieldName.value;
    return caption;
  }

  bool isMatchingAnyOfTheseCategoris(List<int> cateogoriesToMatch) {
    if (cateogoriesToMatch.contains(fieldCategoryId.value)) {
      return true;
    }

    if (this.isSplit) {
      for (var s in this.splits) {
        if (cateogoriesToMatch.contains(s.fieldCategoryId.value)) {
          return true;
        }
      }
    }
    return false;
  }

  bool get isSplit => this.splits.isNotEmpty;

  bool isTransfer() {
    return fieldTransfer.value != -1;
  }

  String get payeeName => Data().payees.getNameFromId(fieldPayee.value);

  /// <summary>
  /// Find all the objects referenced by this Transaction and wire them back up
  /// </summary>
  /// <param name="money">The owner</param>
  /// <param name="parent">The container</param>
  /// <param name="from">The account this transaction belongs to</param>
  /// <param name="duplicateTransfers">How to handle transfers.  In a cut/paste situation you want
  /// to create new transfer transactions (true), but in a XmlStore.Load situation we do not (false)</param>
  void postDeserializeFixup(bool duplicateTransfers) {
    // if (this.CategoryName != null)
    // {
    //   this.Category = money.Categories.GetOrCreateCategory(this.CategoryName, CategoryType.None);
    //   this.CategoryName = null;
    // }
    // if (from != null)
    // {
    //   this.Account = from;
    // }
    // else if (this.AccountName != null)
    // {
    //   this.Account = money.Accounts.FindAccount(this.AccountName);
    // }
    // this.AccountName = null;
    // if (this.PayeeName != null)
    // {
    //   this.Payee = money.Payees.FindPayee(this.PayeeName, true);
    //   this.PayeeName = null;
    // }
    //
    // // do not copy budgeting information outside of balancing the budget.
    // // (Note: setting IsBudgeted to false will screw up the budget balance).
    // this.flags &= ~TransactionFlags.Budgeted;
    //
    // if (duplicateTransfers)
    // {
    //   if (this.TransferName != null)
    //   {
    //     Account to = money.Accounts.FindAccount(this.TransferName);
    //     if (to == null)
    //     {
    //       to = money.Accounts.AddAccount(this.TransferName);
    //     }
    //     if (to != from)
    //     {
    //       money.Transfer(this, to);
    //       this.TransferName = null;
    //     }
    //   }
    // }
    // else if (this.TransferId != -1 && this.Transfer == null)
    // {
    //   Transaction other = money.Transactions.FindTransactionById(this.transferId);
    //   if (this.TransferSplit != -1)
    //   {
    //     // then the other side of this is a split.
    //     Split s = other.NonNullSplits.FindSplit(this.TransferSplit);
    //     if (s != null)
    //     {
    //       s.Transaction = other;
    //       this.Transfer = new Transfer(0, this, other, s);
    //       s.Transfer = new Transfer(0, other, s, this);
    //     }
    //   }
    //   else if (other != null)
    //   {
    //     this.Transfer = new Transfer(0, this, other);
    //     other.Transfer = new Transfer(0, other, this);
    //   }
    // }
    //
    // if (this.Investment != null)
    // {
    //   this.Investment.Parent = parent;
    //   this.Investment.Transaction = this;
    //   if (this.Investment.SecurityName != null)
    //   {
    //     this.Investment.Security = money.Securities.FindSecurity(this.Investment.SecurityName, true);
    //   }
    // }
    // if (this.categoryId == Data().categories.splitCategoryId()) {
    //   Data().this.Splits.Transaction = this;
    //   this.Splits.Parent = this;
    //   foreach (Split s in this.Splits.Items)
    //   {
    //     s.PostDeserializeFixup(money, this, duplicateTransfers);
    //   }
    // }
  }

  static int sortByDateTime(final Transaction a, final Transaction b, final bool ascending) {
    int result = sortByDate(
      a.dateTime.value,
      b.dateTime.value!,
      ascending,
    );
    // To ensure a predictable sort order, always include a tie-breaker
    if (result == 0) {
      result = sortByValue(a.uniqueId, b.uniqueId, ascending);
    }
    return result;
  }

  /// keep track of the original Payee information, only do this if the originalPayee info is empty
  void stashOriginalPayee() {
    if (this.fieldOriginalPayee.value.isEmpty) {
      this.fieldOriginalPayee.value = this.getPayeeOrTransferCaption();
    }
  }

  String get transferName {
    if (transferInstance == null) {
      return _transferName ?? '';
    } else {
      return transferInstance!.getReceiverAccountName();
    }
  }

  set transferName(final String? accountName) {
    _transferName = accountName;
  }

  Widget _buildStatusButtonToggle() {
    return TextButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero, // Remove all padding
      ),
      child: Text(transactionStatusToLetter(this.fieldStatus.value)),
      onPressed: () {
        if (this.fieldStatus.value == TransactionStatus.reconciled) {
          // do nothing, its not allowed to change a reconciled transaction
          SnackBarService.displayWarning(message: 'Reconcile Transaction Status are prevented from changed.');
          return;
        }
        if (this.fieldStatus.value == TransactionStatus.cleared) {
          // Attempt to restore/undo
          if (valueBeforeEdit != null) {
            // bring back the previous value
            int oldValue = valueBeforeEdit![this.fieldStatus.name] ?? 0;
            this.fieldStatus.value = TransactionStatus.values[oldValue];

            // if this was the only change to this instance we can undo the mutation state
            if (mutation == MutationType.changed && MoneyObject.isDataModified(this) == false) {
              mutation = MutationType.none;
              DataController.to.trackMutations.increaseNumber(increaseChanged: -1);
            } else {
              DataController.to.trackMutations.setLastEditToNow(); // still need to refresh the UI
            }
          }
        } else {
          mutateField(this.fieldStatus.name, TransactionStatus.cleared, false);
        }
        SelectionController.to.select(this.uniqueId);
      },
    );
  }
}
