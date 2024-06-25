// Imports
// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/fields/fields.dart';
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
import 'package:money/app/core/widgets/money_widget.dart';
import 'package:money/app/core/widgets/picker_edit_box_date.dart';

// Exports
export 'package:money/app/data/models/money_objects/transactions/transaction_types.dart';

/// Main source of information for this App
/// All transactions are loaded in this class [Transaction] and [Split]
class Transaction extends MoneyObject {
  static final Fields<Transaction> _fields = Fields<Transaction>();

  static get fields {
    if (_fields.isEmpty) {
      final tmp = Transaction.fromJSon({}, 0);
      _fields.setDefinitions(
        [
          tmp.id,
          tmp.dateTime,
          tmp.accountId,
          tmp.payee,
          tmp.originalPayee,
          tmp.categoryId,
          tmp.memo,
          tmp.number,
          tmp.reconciledDate,
          tmp.budgetBalanceDate,
          tmp.transfer,
          tmp.status,
          tmp.fitid,
          tmp.flags,
          tmp.currency,
          tmp.salesTax,
          tmp.transferSplit,
          tmp.mergeDate,
          tmp.amount,
          tmp.amountAsTextNormalized,
          tmp.balanceNative,
          tmp.balanceNormalized,
        ],
      );
    }
    return _fields;
  }

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    return getAccountName();
  }

  /// ID
  /// SQLite  0|Id|bigint|0||1
  FieldId id = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).uniqueId,
  );

  /// Account Id
  /// SQLite  1|Account|INT|1||0
  Field<int> accountId = Field<int>(
    importance: 1,
    type: FieldType.text,
    name: 'Account',
    serializeName: 'Account',
    defaultValue: -1,
    getValueForDisplay: (final MoneyObject instance) =>
        Data().accounts.getNameFromId((instance as Transaction).accountId.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).accountId.value,
  );

  /// Date
  /// SQLite 2|Date|datetime|1||0
  FieldDate dateTime = FieldDate(
    importance: 2,
    name: 'Date',
    serializeName: 'Date',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).dateTime.value,
    getValueForSerialization: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as Transaction).dateTime.value),
    getEditWidget: (final MoneyObject instance, Function onEdited) {
      return PickerEditBoxDate(
        initialValue: (instance as Transaction).dateTimeAsText,
        onChanged: (String? newDateSelected) {
          if (newDateSelected != null) {
            instance.dateTime.value = attemptToGetDateFromText(newDateSelected);
            onEdited();
          }
        },
      );
    },
  );

  /// Status N | E | C | R
  /// SQLite 3|Status|INT|0||0
  Field<TransactionStatus> status = Field<TransactionStatus>(
    importance: 20,
    type: FieldType.text,
    align: TextAlign.center,
    columnWidth: ColumnWidth.tiny,
    defaultValue: TransactionStatus.none,
    useAsDetailPanels: defaultCallbackValueFalse,
    name: columnIdStatus,
    serializeName: 'Status',
    getValueForDisplay: (final MoneyObject instance) =>
        transactionStatusToLetter((instance as Transaction).status.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).status.value.index,
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByString(
      transactionStatusToLetter((a as Transaction).status.value),
      transactionStatusToLetter((b as Transaction).status.value),
      ascending,
    ),
  );

  /// Payee Id (displayed as Text name of the Payee)
  /// SQLite 4|Payee|INT|0||0
  FieldInt payee = FieldInt(
    importance: 4,
    name: 'Payee/Transfer',
    serializeName: 'Payee',
    defaultValue: -1,
    type: FieldType.text,
    align: TextAlign.left,
    columnWidth: ColumnWidth.largest,
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) =>
        sortByString((a as Transaction).payeeName, (b as Transaction).payeeName, ascending),
    getValueForDisplay: (final MoneyObject instance) {
      return (instance as Transaction).getPayeeOrTransferCaption();
    },
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).payee.value,
    setValue: (MoneyObject instance, dynamic newValue) {
      if (newValue == -1) {
        // -1 means no payee, this is a Transfer
        // TODO - implement was solution given that the call back here only has one value use for the Payee ID
      } else {
        // Payee
        instance = instance as Transaction;
        instance.payee.value = (newValue as int); // Payee Id
        instance.transfer.value = -1;
        instance.transferInstance = null;
      }
    },
    getEditWidget: (MoneyObject instance, Function onEdited) {
      return SizedBox(
        width: 300,
        height: 80,
        child: PickPayeeOrTransfer(
          choice: (instance as Transaction).transfer.value == -1 ? TransactionFlavor.payee : TransactionFlavor.transfer,
          payee: Data().payees.get(instance.payee.value),
          account: instance.transferInstance?.getReceiverAccount(),
          amount: instance.amount.value.toDouble(),
          onSelected: (TransactionFlavor choice, Payee? selectedPayee, Account? account) {
            switch (choice) {
              case TransactionFlavor.payee:
                if (selectedPayee != null) {
                  instance.payee.value = selectedPayee.uniqueId;
                  instance.transfer.value = -1;
                  instance.transferInstance = null;
                }
              case TransactionFlavor.transfer:
                if (account != null) {
                  instance.payee.value = -1;
                  Data().makeTransferLinkage(instance, account);
                }
            }
            onEdited(); // notify container
          },
        ),
      );
    },
  );

  /// OriginalPayee
  /// before auto-aliasing, helps with future merging.
  /// SQLite 5|OriginalPayee|nvarchar(255)|0||0
  FieldString originalPayee = FieldString(
    importance: 10,
    name: 'Original Payee',
    serializeName: 'OriginalPayee',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).originalPayee.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).originalPayee.value,
  );

  /// Category Id
  /// SQLite 6|Category|INT|0||0
  Field<int> categoryId = Field<int>(
      importance: 10,
      type: FieldType.text,
      columnWidth: ColumnWidth.large,
      name: 'Category',
      serializeName: 'Category',
      defaultValue: -1,
      getValueForDisplay: (final MoneyObject instance) =>
          Data().categories.getNameFromId((instance as Transaction).categoryId.value),
      getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).categoryId.value,
      setValue: (final MoneyObject instance, dynamic newValue) =>
          (instance as Transaction).categoryId.value = newValue as int,
      getEditWidget: (final MoneyObject instance, Function onEdited) {
        return pickerCategory(
          itemSelected: Data().categories.get((instance as Transaction).categoryId.value),
          onSelected: (Category? newCategory) {
            if (newCategory != null) {
              instance.categoryId.value = newCategory.uniqueId;
              // notify container
              onEdited();
            }
          },
        );
      });

  /// Memo
  /// 7|Memo|nvarchar(255)|0||0
  FieldString memo = FieldString(
    importance: 80,
    name: 'Memo',
    serializeName: 'Memo',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).memo.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).memo.value,
  );

  /// Number
  /// 8|Number|nchar(10)|0||0
  FieldString number = FieldString(
    importance: 10,
    name: 'Number',
    serializeName: 'Number',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).number.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).number.value,
  );

  /// Reconciled Date
  /// 9|ReconciledDate|datetime|0||0
  FieldDate reconciledDate = FieldDate(
    importance: 10,
    name: 'ReconciledDate',
    serializeName: 'ReconciledDate',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as Transaction).reconciledDate.value),
    getValueForSerialization: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as Transaction).reconciledDate.value),
  );

  /// Budget Balance Date
  /// 10|BudgetBalanceDate|datetime|0||0
  FieldDate budgetBalanceDate = FieldDate(
    importance: 10,
    name: 'ReconciledDate',
    serializeName: 'ReconciledDate',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as Transaction).budgetBalanceDate.value),
    getValueForSerialization: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as Transaction).budgetBalanceDate.value),
  );

  /// Transfer
  /// 11|Transfer|bigint|0||0
  Field<int> transfer = Field<int>(
    importance: 10,
    name: 'Transfer',
    serializeName: 'Transfer',
    defaultValue: -1,
    useAsColumn: false,
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).transfer.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).transfer.value,
  );

  /// FITID
  /// 12|FITID|nchar(40)|0||0
  FieldString fitid = FieldString(
    importance: 20,
    name: 'FITID',
    serializeName: 'FITID',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).fitid.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).fitid.value,
  );

  /// Flags
  /// 13|Flags|INT|1||0
  FieldInt flags = FieldInt(
    importance: 20,
    name: 'Flags',
    serializeName: 'Flags',
    useAsColumn: false,
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).flags.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).flags.value,
  );

  /// Amount
  /// 14|Amount|money|1||0
  FieldMoney amount = FieldMoney(
    importance: 97,
    name: columnIdAmount,
    serializeName: 'Amount',
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).amount.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).amount.value.toDouble(),
    setValue: (final MoneyObject instance, dynamic newValue) =>
        (instance as Transaction).amount.value.setAmount(newValue),
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) =>
        sortByValue((a as Transaction).amount.value.toDouble(), (b as Transaction).amount.value.toDouble(), ascending),
  );

  /// Sales Tax
  /// 15|SalesTax|money|0||0
  FieldMoney salesTax = FieldMoney(
    importance: 95,
    name: 'Sales Tax',
    serializeName: 'SalesTax',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).salesTax.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).salesTax.value.toDouble(),
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) => sortByValue(
        (a as Transaction).salesTax.value.toDouble(), (b as Transaction).salesTax.value.toDouble(), ascending),
  );

  /// Transfer Split
  /// 16|TransferSplit|INT|0||0
  FieldInt transferSplit = FieldInt(
    importance: 10,
    name: 'TransferSplit',
    serializeName: 'TransferSplit',
    useAsColumn: false,
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => (instance as Transaction).transferSplit.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as Transaction).transferSplit.value,
  );

  /// MergeDate
  /// 17|MergeDate|datetime|0||0
  FieldDate mergeDate = FieldDate(
    importance: 10,
    name: 'Merge Date',
    serializeName: 'MergeDate',
    useAsDetailPanels: defaultCallbackValueFalse,
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as Transaction).mergeDate.value),
    getValueForSerialization: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as Transaction).mergeDate.value),
  );

  //------------------------------------------------------------------------
  // Not serialized
  // derived property used for display

  /// Amount Normalized to USD
  FieldMoney amountAsTextNormalized = FieldMoney(
    importance: 98,
    name: columnIdAmountNormalized,
    columnWidth: ColumnWidth.small,
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
        amount: (instance as Transaction).getNormalizedAmount(instance.amount.value.toDouble()),
        iso4217: Constants.defaultCurrency),
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) =>
        sortByValue((a as Transaction).amount.value.toDouble(), (b as Transaction).amount.value.toDouble(), ascending),
  );

  /// Balance native
  double balance = 0;

  /// Balance native
  FieldMoney balanceNative = FieldMoney(
    importance: 99,
    name: columnIdBalance,
    columnWidth: ColumnWidth.small,
    useAsColumn: false,
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as Transaction).balance,
      iso4217: instance.getCurrency(),
    ),
  );

  /// Balance Normalized to USD
  FieldMoney balanceNormalized = FieldMoney(
    importance: 99,
    name: 'Balance(USD)',
    columnWidth: ColumnWidth.small,
    useAsDetailPanels: defaultCallbackValueFalse,
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as Transaction).getNormalizedAmount((instance).balance),
      iso4217: Constants.defaultCurrency,
    ),
    sort: (final MoneyObject a, final MoneyObject b, final bool ascending) =>
        sortByValue((a as Transaction).balance, (b as Transaction).balance, ascending),
  );

  ///------------------------------------------------------
  /// Non persisted fields
  String get dateTimeAsText => dateToString(dateTime.value);
  String get amountAsText => amount.value.toString();

  Account? accountInstance;

  Account? getAccount() {
    if (accountInstance != null) {
      return accountInstance;
    }
    return Data().accounts.get(accountId.value);
  }

  String getAccountName() {
    if (getAccount() != null) {
      return getAccount()!.name.value;
    }
    return "???";
  }

  FieldString currency = FieldString(
    type: FieldType.widget,
    importance: 80,
    name: 'Currency',
    align: TextAlign.center,
    columnWidth: ColumnWidth.tiny,
    getValueForDisplay: (final MoneyObject instance) {
      return Currency.buildCurrencyWidget((instance as Transaction).getCurrency());
    },
  );

  /// Used for establishing relation between two transactions
  Transfer? transferInstance;

  Investment? investmentInstance;

  String? _transferName;

  String getCurrency() {
    if (this.accountInstance == null || this.accountInstance!.currency.value.isEmpty) {
      return Constants.defaultCurrency;
    }

    return this.accountInstance!.currency.value;
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

  Account? getRelatedAccount() {
    if (transferInstance != null) {
      if (transferInstance!.related != null) {
        return transferInstance!.related!.getAccount();
      }
    }
    return null;
  }

  String get payeeOrTransferCaption {
    return getPayeeOrTransferCaption();
  }

  // String? _pendingTransferAccountName;

  set payeeOrTransferCaption(final String value) {
    //   if (this.payeeOrTransferCaption() != value) {
    //     if (value.isEmpty) {
    //       this.payee.value = -1;
    //     } else if (IsTransferCaption(value)) {
    //       if (money != null) {
    //         string accountName = ExtractTransferAccountName(value);
    //         Account a = money.Accounts.FindAccount(accountName);
    //         if (a != null) {
    //           money.Transfer(this, a);
    //           money.Rebalance(a);
    //         }
    //       }
    //     } else {
    //       // find MyMoney container
    //       if (money != null) {
    //         this.Payee = money.Payees.FindPayee(value, true);
    //       }
    //     }
    //   }
  }

  String get payeeName => Data().payees.getNameFromId(payee.value);

  String getPayeeOrTransferCaption() {
    Investment? investment = investmentInstance;
    double amount = this.amount.value.toDouble();

    bool isFrom = false;
    if (transferInstance != null) {
      if (investment != null) {
        if (investment.investmentType.value == InvestmentType.add.index) {
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
    final String displayName = Data().payees.getNameFromId(payee.value);
    return displayName;
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
    caption += account.name.value;
    return caption;
  }

  List<MoneySplit> splits = [];

  bool get isSplit => this.splits.isNotEmpty;

  Transaction({
    final TransactionStatus status = TransactionStatus.none,
  }) {
    this.status.value = status;
    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: payeeName,
          leftBottomAsString: '${Data().categories.getNameFromId(categoryId.value)}\n${memo.value}',
          rightTopAsWidget: MoneyWidget(amountModel: amount.value, asTile: true),
          rightBottomAsString: '$dateTimeAsText\n${Account.getName(accountInstance)}',
        );
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  factory Transaction.fromJSon(final MyJson json, final double runningBalance) {
    final Transaction t = Transaction();
// 0 ID
    t.id.value = json.getInt('Id', -1);
// 1 Account ID
    t.accountId.value = json.getInt('Account', -1);
    t.accountInstance = Data().accounts.get(t.accountId.value);
// 2 Date Time
    t.dateTime.value = json.getDate('Date');
// 3 Status
    t.status.value = TransactionStatus.values[json.getInt('Status')];
// 4 Payee ID
    t.payee.value = json.getInt('Payee', -1);
// 5 Original Payee
    t.originalPayee.value = json.getString('OriginalPayee');
// 6 Category Id
    t.categoryId.value = json.getInt('Category', -1);
// 7 Memo
    t.memo.value = json.getString('Memo');
// 8 Number
    t.number.value = json.getString('Number');
// 9 Reconciled Date
    t.reconciledDate.value = json.getDate('ReconciledDate');
// 10 BudgetBalanceDate
    t.budgetBalanceDate.value = json.getDate('BudgetBalanceDate');
// 11 Transfer
    t.transfer.value = json.getInt('Transfer', -1);
// 12 FITID
    t.fitid.value = json.getString('FITID');
// 13 Flags
    t.flags.value = json.getInt('Flags');

// 14 Amount
    t.amount.value.setAmount(json.getDouble('Amount'));
// 15 Sales Tax
    t.salesTax.value.setAmount(json.getDouble('SalesTax'));
// 16 Transfer Split
    t.transferSplit.value = json.getInt('TransferSplit', -1);
// 17 Merge Date
    t.mergeDate.value = json.getDate('MergeDate');

// not serialized
    t.balance = runningBalance;

    return t;
  }

  @override
  MoneyObject rollup(List<MoneyObject> moneyObjectInstances) {
    if (moneyObjectInstances.isEmpty) {
      return Transaction();
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

  /// <summary>
  /// Find all the objects referenced by this Transaction and wire them back up
  /// </summary>
  /// <param name="money">The owner</param>
  /// <param name="parent">The container</param>
  /// <param name="from">The account this transaction belongs to</param>
  /// <param name="duplicateTransfers">How to handle transfers.  In a cut/paste situation you want
  /// to create new transfer transactions (true), but in a XmlStore.Load situation we do not (false)</param>
  postDeserializeFixup(bool duplicateTransfers) {
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

  static String getDefaultCurrency(final Account? accountInstance) {
// Convert the value to USD
    if (accountInstance == null || accountInstance.getCurrencyRatio() == 0) {
      return Constants.defaultCurrency;
    }
    return accountInstance.currency.value;
  }

  double getNormalizedAmount(double nativeValue) {
    // Convert the value to USD
    if (accountInstance == null || accountInstance?.getCurrencyRatio() == 0) {
      return nativeValue;
    }
    return nativeValue * accountInstance!.getCurrencyRatio();
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

  void checkTransfers(List dangling, List<Account> deletedAccounts) {
    //   bool added = false;
    //   if (this.to != null && this.Transfer == null) {
    //     if (IsDeletedAccount(this.to, money, deletedAccounts)) {
    //       this.Category =
    //           this.Amount < 0 ? Data().categories.TransferToDeletedAccount : money.Categories.TransferFromDeletedAccount;
    //       this.to = null;
    //     } else {
    //       added = true;
    //       dangling.Add(this);
    //     }
    //   }
    //
    //   if (this.Transfer != null) {
    //     Transaction other = this.transfer.Transaction;
    //     if (other.IsSplit) {
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
    //       }
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
    //     } else if ((other.transfer == null || other.transfer.Transaction != this) &&
    //         !this.AutoFixDandlingTransfer(null)) {
    //       added = true;
    //       dangling.add(this);
    //     }
    //   }
    //
    //   if (this.splits != null) {
    //     if (this.splits.CheckTransfers(money, dangling, deletedAccounts) && !added) {
    //       dangling.add(this); // only add transaction once.
    //     }
    //   }
  }

  bool isMatchingAnyOfTheseCategoris(List<int> cateogoriesToMatch) {
    if (cateogoriesToMatch.contains(categoryId.value)) {
      return true;
    }

    if (this.isSplit) {
      for (var s in this.splits) {
        if (cateogoriesToMatch.contains(s.categoryId.value)) {
          return true;
        }
      }
    }
    return false;
  }
}
