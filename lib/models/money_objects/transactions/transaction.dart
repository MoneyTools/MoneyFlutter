// Imports
import 'package:flutter/material.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/categories/category.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/investments/investment.dart';
import 'package:money/models/money_objects/investments/investments.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transaction_types.dart';
import 'package:money/models/money_objects/transfers/transfer.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_categories/picker_category.dart';
import 'package:money/views/view_payees/picker_payee_or_transfer.dart';
import 'package:money/widgets/list_view/list_item_card.dart';
import 'package:money/widgets/picker_edit_box_date.dart';

// Exports
export 'package:money/models/money_objects/transactions/transaction_types.dart';

/// Main source of information for this App
/// All transactions are loaded in this class [Transaction] and [Split]
class Transaction extends MoneyObject {
  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  @override
  String getRepresentation() {
    // TODO
    return accountInstance!.name.value;
  }

  /// ID
  /// SQLite  0|Id|bigint|0||1
  FieldId<Transaction> id = FieldId<Transaction>(
    valueForSerialization: (final Transaction instance) => instance.uniqueId,
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
    valueForSerialization: (final Transaction instance) => dateAsIso8601OrDefault(instance.dateTime.value),
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByDate(a.dateTime.value, b.dateTime.value, ascending),
    getEditWidget: (final Transaction instance, Function onEdited) {
      return PickerEditBoxDate(
        initialValue: instance.dateTimeAsText,
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
  Field<Transaction, TransactionStatus> status = Field<Transaction, TransactionStatus>(
    importance: 20,
    type: FieldType.text,
    align: TextAlign.center,
    columnWidth: ColumnWidth.small,
    defaultValue: TransactionStatus.none,
    useAsDetailPanels: false,
    name: 'Status',
    serializeName: 'Status',
    valueFromInstance: (final Transaction instance) => transactionStatusToLetter(instance.status.value),
    valueForSerialization: (final Transaction instance) => instance.status.value.index,
    sort: (final Transaction a, final Transaction b, final bool ascending) => sortByString(
      transactionStatusToLetter(a.status.value),
      transactionStatusToLetter(b.status.value),
      ascending,
    ),
  );

  /// Payee Id (displayed as Text name of the Payee)
  /// SQLite 4|Payee|INT|0||0
  Field<Transaction, int> payee = Field<Transaction, int>(
    importance: 4,
    name: 'Payee/Transfer',
    serializeName: 'Payee',
    defaultValue: -1,
    type: FieldType.text,
    valueFromInstance: (final Transaction instance) {
      return instance.getPayeeOrTransferCaption();
    },
    valueForSerialization: (final Transaction instance) => instance.payee.value,
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByString(a.payeeName, b.payeeName, ascending),
    getEditWidget: (final Transaction instance, Function onEdited) {
      return SizedBox(
        width: 300,
        height: 70,
        child: PickPayeeOrTransfer(
          choice: instance.transfer.value == -1 ? TransactionFlavor.payee : TransactionFlavor.transfer,
          payee: Data().payees.get(instance.payee.value),
          account: instance.transferInstance?.getAccount(),
          onSelected: (TransactionFlavor choice, Payee? selectedPayee, Account? account) {
            switch (choice) {
              case TransactionFlavor.payee:
                if (selectedPayee != null) {
                  instance.payee.value = selectedPayee.uniqueId;
                  instance.transfer.value = -1;
                  instance.transferInstance = null;
                }
              case TransactionFlavor.transfer:
                instance.payee.value = -1;
                instance.transfer.value = Data().categories.transfer.uniqueId;
                instance.transferTo = Account.getName(account);
                instance.transferInstance = null;
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
      getEditWidget: (final Transaction instance, Function onEdited) {
        return pickerCategory(
          itemSelected: Data().categories.get(instance.categoryId.value),
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
  FieldString<Transaction> number = FieldString<Transaction>(
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
    valueFromInstance: (final Transaction instance) => dateAsIso8601OrDefault(instance.reconciledDate.value),
    valueForSerialization: (final Transaction instance) => dateAsIso8601OrDefault(instance.reconciledDate.value),
  );

  /// Budget Balance Date
  /// 10|BudgetBalanceDate|datetime|0||0
  FieldDate<Transaction> budgetBalanceDate = FieldDate<Transaction>(
    importance: 10,
    name: 'ReconciledDate',
    serializeName: 'ReconciledDate',
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => dateAsIso8601OrDefault(instance.budgetBalanceDate.value),
    valueForSerialization: (final Transaction instance) => dateAsIso8601OrDefault(instance.budgetBalanceDate.value),
  );

  /// Transfer
  /// 11|Transfer|bigint|0||0
  Field<Transaction, int?> transfer = Field<Transaction, int?>(
    importance: 10,
    name: 'Transfer',
    serializeName: 'Transfer',
    defaultValue: null,
    useAsColumn: false,
    useAsDetailPanels: false,
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
    useAsDetailPanels: false,
    valueFromInstance: (final Transaction instance) => instance.flags.value,
    valueForSerialization: (final Transaction instance) => instance.flags.value,
  );

  /// Amount
  /// 14|Amount|money|1||0
  FieldAmount<Transaction> amount = FieldAmount<Transaction>(
    importance: 97,
    name: columnIdAmount,
    serializeName: 'Amount',
    valueFromInstance: (final Transaction instance) =>
        Currency.getAmountAsStringUsingCurrency(instance.amount.value, iso4217code: instance.amount.currency),
    valueForSerialization: (final Transaction instance) => instance.amount.value,
    setValue: (final Transaction instance, dynamic newValue) {
      instance.amount.value = attemptToGetDoubleFromText(newValue as String) ?? 0.00;
    },
    sort: (final Transaction a, final Transaction b, final bool ascending) =>
        sortByValue(a.amount.value, b.amount.value, ascending),
  );

  /// Sales Tax
  /// 15|SalesTax|money|0||0
  FieldAmount<Transaction> salesTax = FieldAmount<Transaction>(
    importance: 95,
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
    useAsDetailPanels: false,
    valueFromInstance: (final Transaction instance) => instance.transferSplit.value,
    valueForSerialization: (final Transaction instance) => instance.transferSplit.value,
  );

  /// MergeDate
  /// 17|MergeDate|datetime|0||0
  FieldDate<Transaction> mergeDate = FieldDate<Transaction>(
    importance: 10,
    name: 'Merge Date',
    serializeName: 'MergeDate',
    useAsDetailPanels: false,
    useAsColumn: false,
    valueFromInstance: (final Transaction instance) => dateAsIso8601OrDefault(instance.mergeDate.value),
    valueForSerialization: (final Transaction instance) => dateAsIso8601OrDefault(instance.mergeDate.value),
  );

  //------------------------------------------------------------------------
  // Not serialized
  // derived property used for display

  /// Amount Normalized to USD
  FieldString<Transaction> amountAsTextNormalized = FieldString<Transaction>(
    importance: 98,
    name: columnIdAmountNormalized,
    align: TextAlign.right,
    useAsDetailPanels: false,
    valueFromInstance: (final Transaction instance) => Currency.getAmountAsStringUsingCurrency(
        instance.getNormalizedAmount(instance.amount.value),
        iso4217code: Constants.defaultCurrency),
  );

  /// Balance native
  FieldDouble<Transaction> balance = FieldDouble<Transaction>(
    importance: 99,
    name: 'Balance',
    useAsColumn: false,
    useAsDetailPanels: false,
    valueFromInstance: (final Transaction instance) => instance.balance.value,
  );

  /// Balance native
  FieldString<Transaction> balanceAsTextNative = FieldString<Transaction>(
    importance: 99,
    name: 'Balance',
    align: TextAlign.right,
    useAsColumn: false,
    useAsDetailPanels: false,
    valueFromInstance: (final Transaction instance) =>
        Currency.getAmountAsStringUsingCurrency(instance.balance.value, iso4217code: instance.amount.currency),
  );

  /// Balance Normalized to USD
  FieldString<Transaction> balanceAsTextNormalized = FieldString<Transaction>(
    importance: 99,
    name: 'Balance(USD)',
    align: TextAlign.right,
    useAsDetailPanels: false,
    valueFromInstance: (final Transaction instance) => Currency.getAmountAsStringUsingCurrency(
        instance.getNormalizedAmount(instance.balance.value),
        iso4217code: Constants.defaultCurrency),
  );

  String get dateTimeAsText => getDateAsText(dateTime.value);

  Account? accountInstance;
  Transfer? transferInstance;
  Investment? investmentInstance;

  String? _transferName;

  String get transferName {
    if (transferInstance == null) {
      return _transferName ?? '';
    } else {
      return transferInstance!.getAccountName();
    }
  }

  set transferName(final String? accountName) {
    _transferName = accountName;
  }

  String get payeeOrTransferCaption {
    return getPayeeOrTransferCaption();
  }

  String? _pendingTransferAccountName;

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

  String get transferTo {
    if (_pendingTransferAccountName != null) {
      return _pendingTransferAccountName!;
    }

    if (transferInstance != null) {
      return transferInstance!.getAccountName();
    }
    return transferName;
  }

  set transferTo(final String accountName) {
    _pendingTransferAccountName = accountName;
    transferName = null;
  }

  String get payeeName => Data().payees.getNameFromId(payee.value);

  String getPayeeOrTransferCaption() {
    Transfer? transfer = transferInstance;
    Investment? investment = investmentInstance;
    double amount = this.amount.value;

    bool isFrom = false;
    if (transfer != null) {
      if (investment != null) {
        if (investment.investmentType.value == InvestmentType.add.index) {
          isFrom = true;
        }
      } else if (amount > 0) {
        isFrom = true;
      }
      return getTransferCaption(transfer.related!.accountInstance!, isFrom);
    }
    final String displayName = Data().payees.getNameFromId(payee.value);
    return displayName;
  }

  String getTransferCaption(final Account account, final bool isFrom) {
    String arrowDirection = isFrom ? ' ← ' : ' → ';

    String caption = 'Transfer$arrowDirection';

    if (account.isClosed()) {
      caption += 'Closed-Account: ';
    }
    caption += account.name.value;
    return caption;
  }

  Transaction({
    final TransactionStatus status = TransactionStatus.none,
  }) {
    this.status.value = status;
    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: payeeName,
          leftBottomAsString: '${Data().categories.getNameFromId(categoryId.value)}\n${memo.value}',
          rightTopAsString: Currency.getAmountAsStringUsingCurrency(amount.value),
          rightBottomAsString: '$dateTimeAsText\n${Account.getName(accountInstance)}',
        );
  }

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
    t.amount.value = json.getDouble('Amount');
    t.amount.currency = getDefaultCurrency(t.accountInstance);

// 15 Sales Tax
    t.salesTax.value = json.getDouble('SalesTax');
// 16 Transfer Split
    t.transferSplit.value = json.getInt('TransferSplit', -1);
// 17 Merge Date
    t.mergeDate.value = json.getDate('MergeDate');

// not serialized
    t.balance.value = runningBalance;

    return t;
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
    // // do not copy budgetting information outside of balancing the budget.
    // // (Note: setting IsBudgetted to false will screw up the budget balance).
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
    // if (this.IsSplit)
    // {
    //   this.Splits.Transaction = this;
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
}
