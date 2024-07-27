// Imports
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/file_systems.dart';
import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:money/app/data/models/money_objects/account_aliases/account_aliases.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/accounts/accounts.dart';
import 'package:money/app/data/models/money_objects/aliases/aliases.dart';
import 'package:money/app/data/models/money_objects/categories/categories.dart';
import 'package:money/app/data/models/money_objects/currencies/currencies.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/investments/investments.dart';
import 'package:money/app/data/models/money_objects/loan_payments/loan_payments.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/online_accounts/online_accounts.dart';
import 'package:money/app/data/models/money_objects/payees/payees.dart';
import 'package:money/app/data/models/money_objects/rent_buildings/rent_buildings.dart';
import 'package:money/app/data/models/money_objects/rental_unit/rental_units.dart';
import 'package:money/app/data/models/money_objects/securities/securities.dart';
import 'package:money/app/data/models/money_objects/splits/splits.dart';
import 'package:money/app/data/models/money_objects/stock_splits/stock_splits.dart';
import 'package:money/app/data/models/money_objects/transaction_extras/transaction_extras.dart';
import 'package:money/app/data/models/money_objects/transactions/transactions.dart';
import 'package:money/app/data/models/money_objects/transfers/transfer.dart';
import 'package:money/app/data/storage/data/data_simulator.dart';
import 'package:money/app/data/storage/database/database.dart';

// Exports
export 'package:money/app/core/helpers/json_helper.dart';
export 'package:money/app/data/models/money_objects/money_objects.dart';

part 'data_extension_csv.dart';
part 'data_extension_demo.dart';
part 'data_extension_sql.dart';

class Data {
  // private constructor

  /// singleton access
  factory Data() {
    return _instance;
  }

  /// private constructor
  Data._internal() {
    _listOfTables = <MoneyObjects<dynamic>>[
      accountAliases, // 1
      aliases, // 3
      categories, // 4
      currencies, // 5
      loanPayments, // 7
      onlineAccounts, // 8
      payees, // 9
      transactionExtras, // 15
      transactions, // 16
      // Keep in this order - must come after Transactions
      splits, // 13
      // Keep in this order
      stockSplits, // 14
      investments, // 6 Must be locate after [stockSplits]
      securities, // 12 Must be locate after [investments]

      accounts, // 2

      // Can be last
      rentBuildings, // 10
      rentUnits, // 11
    ];
  }

  /// 1 Account Aliases
  AccountAliases accountAliases = AccountAliases();

  /// 2 Accounts
  Accounts accounts = Accounts();

  /// 3 Aliases of Payees
  Aliases aliases = Aliases();

  /// 4 Categories of Transactions
  Categories categories = Categories();

  /// 5 Currencies definitions used in the money files
  Currencies currencies = Currencies();

  /// 6 Investment transactions
  Investments investments = Investments();

  /// 7
  LoanPayments loanPayments = LoanPayments();

  /// 8
  OnlineAccounts onlineAccounts = OnlineAccounts();

  /// 9
  Payees payees = Payees();

  /// 10
  RentBuildings rentBuildings = RentBuildings();

  /// 11
  RentUnits rentUnits = RentUnits();

  /// 12
  Securities securities = Securities();

  /// 13
  Splits splits = Splits();

  /// 14
  StockSplits stockSplits = StockSplits();

  /// 15
  TransactionExtras transactionExtras = TransactionExtras();

  /// 16 All Transactions in the Money file
  Transactions transactions = Transactions();

  late final List<MoneyObjects<dynamic>> _listOfTables;

  /// singleton
  static final Data _instance = Data._internal();

  void assessMutationsCountOfAllModels() {
    DataController.to.trackMutations.reset();

    for (final element in _listOfTables) {
      element.resetMutationStateOfObjects();
      element.assessMutationsCounts();
    }
    Data().updateAll();
  }

  void checkTransfers() {
    Set<Transaction> dangling = getDanglingTransfers();
    if (dangling.isNotEmpty) {
      SnackBarService.displayWarning(
        message: '$dangling Dangling transfers have been found',
        title: 'Dangling Transfers',
        autoDismiss: false,
      );
    }
  }

  void clear() {
    DataController.to.trackMutations.reset();

    for (final element in _listOfTables) {
      element.clear();
    }
  }

  void clearExistingData() {
    for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
      moneyObjects.clear();
    }
  }

  void clearTransferToAccount(Transaction t, Account a) {
    // TODO
    // if (t.isSplit) {
    //   for (MoneySplit s in t.splits) {
    //     if (s.Transfer != null && s.Transfer.Transaction.Account == a) {
    //       ClearTransferToAccount(s.Transfer);
    //       s.ClearTransfer();
    //       s.Category =
    //           s.Amount < 0 ? this.Categories.TransferToDeletedAccount : this.Categories.TransferFromDeletedAccount;
    //       if (string.IsNullOrEmpty(s.Memo)) {
    //         s.Memo = a.Name;
    //       }
    //     }
    //   }
    // }

    // if (t.Transfer != null && t.Transfer.Transaction.Account == a) {
    //   ClearTransferToAccount(t.Transfer);
    //   t.Transfer = null;
    //   if (!t.IsSplit) {
    //     t.Category =
    //         t.Amount < 0 ? this.Categories.TransferToDeletedAccount : this.Categories.TransferFromDeletedAccount;
    //   }
    //   if (string.IsNullOrEmpty(t.Memo)) {
    //     t.Memo = a.Name;
    //   }
    // }
  }

  /// Close data source
  void close() {
    clearExistingData();

    DataController.to.dataFileIsClosed();
    DataController.to.trackMutations.reset();
  }

  /// Bulk Delete
  void deleteItems(final List<MoneyObject> itemsToDelete) {
    for (final item in itemsToDelete) {
      Data().notifyMutationChanged(
        mutation: MutationType.deleted,
        moneyObject: item,
        recalculateBalances: false,
      );
    }
    Data().updateAll();
  }

  Set<Transaction> getDanglingTransfers() {
    Set<Transaction> dangling = {};
    List<Account> deletedaccounts = [];
    transactions.checkTransfers(dangling, deletedaccounts);
    for (Account a in deletedaccounts) {
      accounts.removeAccount(a);
    }
    return dangling;
  }

  DateTime? getLastDateTimeModified(final String fullPathToFile) {
    File file = File(fullPathToFile);
    // Get the last modified date and time of the file
    return file.lastModifiedSync();
  }

  List<MoneyObject> getMutatedInstances(MutationType typeOfMutation) {
    List<MoneyObject> mutated = [];
    for (final MoneyObjects listOfInstance in _listOfTables) {
      mutated.addAll(listOfInstance.getMutatedObjects(typeOfMutation));
    }
    return mutated;
  }

  List<MutationGroup> getMutationGroups(MutationType typeOfMutation) {
    List<MutationGroup> allMutationGroups = [];

    for (final MoneyObjects moneyObjects in _listOfTables) {
      final mutatedInstances = moneyObjects.getMutatedObjects(typeOfMutation);
      if (mutatedInstances.isNotEmpty) {
        MutationGroup mutationGroup = MutationGroup();
        mutationGroup.title = moneyObjects.collectionName;
        mutationGroup.whatWasMutated = moneyObjects.whatWasMutated(mutatedInstances);
        allMutationGroups.add(mutationGroup);
      }
    }
    return allMutationGroups;
  }

  MoneyModel getNetWorth() {
    final double sum = accounts.getSumOfAccountBalances();
    return MoneyModel(amount: sum);
  }

  Transaction? getOrCreateRelatedTransaction(
    Transaction transactionSource,
    Account destinationAccount,
  ) {
    if (transactionSource.accountId.value == destinationAccount.uniqueId) {
      logger.e('Cannot transfer to same account');
      return null;
    }

    Transaction? relatedTransaction = Data().transactions.findExistingTransaction(
          accountId: destinationAccount.uniqueId,
          dateRange: DateRange(
            min: transactionSource.dateTime.value!.startOfDay,
            max: transactionSource.dateTime.value!.endOfDay,
          ),
          amount: -transactionSource.amount.value.toDouble(),
        );
    // ignore: prefer_conditional_assignment
    if (relatedTransaction == null) {
      relatedTransaction = Transaction(date: transactionSource.dateTime.value)
        ..accountId.value = destinationAccount.uniqueId
        ..amount.value.setAmount(
              (transactionSource.amount.value.toDouble() * -1),
            ) // flip the sign
        ..categoryId.value = transactionSource.categoryId.value
        ..fitid.value = transactionSource.fitid.value
        ..number.value = transactionSource.number.value
        ..memo.value = transactionSource.memo.value;
      //u.Status = t.Status; no !!!
    }
    // Investment? i = relatedTransaction.investmentInstance;
    // if (i != null) {
    //   Investment j = transactionSource.getOrCreateInvestment();
    //   j.units = i.units;
    //   j.unitPrice = i.unitPrice;
    //   j.security = i.security;
    //   //   switch (i.Type) {
    //   //     case InvestmentType.Add:
    //   //       j.Type = InvestmentType.Remove;
    //   //       break;
    //   //     case InvestmentType.Remove:
    //   //       j.Type = InvestmentType.Add;
    //   //       break;
    //   //     case InvestmentType.None: // assume it's a remove
    //   //       i.Type = InvestmentType.Remove;
    //   //       j.Type = InvestmentType.Add;
    //   //       break;
    //   //     case InvestmentType.Buy:
    //   //     case InvestmentType.Sell:
    //   //       throw new MoneyException("Transfer must be of type 'Add' or 'Remove'.");
    //   //   }
    //   //   u.Investment = j;
    // }

    return relatedTransaction;
  }

  /// <summary>
  /// Get a list of all Investment transactions grouped by security
  /// </summary>
  /// <param name="filter">The account filter or null if you want them all</param>
  /// <param name="toDate">Get all transactions up to but not including this date</param>
  /// <returns></returns>
  Map<Security, List<Investment>> getTransactionsGroupedBySecurity(
    Function(Account)? filter,
    DateTime toDate,
  ) {
    Map<Security, List<Investment>> transactionsBySecurity = {};

    // Sort all add, remove, buy, sell transactions by date and by security.
    for (Transaction t in Data().transactions.getAllTransactionsByDate()) {
      if (t.dateTime.value!.millisecond < toDate.millisecond &&
          (filter == null || filter(t.accountInstance!)) &&
          t.investmentInstance != null &&
          t.investmentInstance!.investmentType.value != InvestmentType.none.index) {
        Investment i = t.investmentInstance!;
        Security? s = Data().securities.get(i.security.value);
        if (s != null) {
          List<Investment> list = transactionsBySecurity[s] ?? [];
          transactionsBySecurity[s] = list;
          list.add(i);
        }
      }
    }
    return transactionsBySecurity;
  }

  /// Automated detection of what type of storage to load the data from
  Future<bool> loadFromPath(final DataSource dateSource) async {
    try {
      final String fileExtension = MyFileSystems.getFileExtension(dateSource.filePath);
      switch (fileExtension.toLowerCase()) {
        // Sqlite
        case '.mmdb':
          // Load from SQLite
          if (await loadFromSql(dateSource.filePath, dateSource.fileBytes)) {
            PreferenceController.to.addToMRU(dateSource.filePath);
          }
        case '.mmcsv':
          // Zip CSV files
          await loadFromZippedCsv(dateSource.filePath, dateSource.fileBytes);
          PreferenceController.to.addToMRU(dateSource.filePath);

        default:
          SnackBarService.displayWarning(
            autoDismiss: false,
            message: 'Unsupported file type $fileExtension',
          );
          return false;
      }
    } catch (e) {
      logger.e(e.toString());
      SnackBarService.displayError(autoDismiss: false, message: e.toString());
      return false;
    }

    // All individual table were loaded, now let the cross reference money object create linked to other tables
    recalculateBalances();

    // Notify that loading is completed
    return true;
  }

  bool makeTransferLinkage(
    Transaction transactionSource,
    Account destinationAccount,
  ) {
    Transaction? relatedTransaction = getOrCreateRelatedTransaction(transactionSource, destinationAccount);

    if (relatedTransaction != null) {
      final Transfer transfer;

      if (transactionSource.amount.value.toDouble() < 0) {
        // transfer TO
        transfer = Transfer(
          id: 0,
          source: transactionSource,
          related: relatedTransaction,
          isOrphan: false,
        );
      } else {
        // transfer FROM
        transfer = Transfer(
          id: 0,
          source: relatedTransaction,
          related: transactionSource,
          isOrphan: false,
        );
      }

      // Keep track changes done
      relatedTransaction.stashValueBeforeEditing();
      relatedTransaction.payee.value = -1;
      relatedTransaction.transfer.value = transactionSource.id.value;
      relatedTransaction.transferInstance = transfer;

      if (relatedTransaction.uniqueId == -1) {
        // This is a new related transaction Append and get a new UniqueID
        transactions.appendNewMoneyObject(relatedTransaction);
      } else {
        Data().notifyMutationChanged(
          mutation: MutationType.changed,
          moneyObject: relatedTransaction,
          recalculateBalances: false,
        );
      }

      // this needs to happen last since the ID for a new Relation Transaction will be establish in the above
      // transactions.appendNewMoneyObject(relatedTransaction)
      transactionSource.payee.value = -1;
      transactionSource.transfer.value = relatedTransaction.id.value;
      transactionSource.transferInstance = transfer;
    }

    return true;
  }

  /// let the app know that something has changed
  void notifyMutationChanged({
    required MutationType mutation,
    required MoneyObject moneyObject,
    bool recalculateBalances = true,
  }) {
    switch (mutation) {
      case MutationType.inserted:
        moneyObject.mutation = MutationType.inserted;
        DataController.to.trackMutations.increaseNumber(increaseAdded: 1);
      case MutationType.changed:
        // ensure that we only count editing once and discard if this was edited on a new inserted items
        if (moneyObject.mutation == MutationType.none) {
          moneyObject.mutation = MutationType.changed;
          DataController.to.trackMutations.increaseNumber(increaseChanged: 1);
        } else {
          DataController.to.trackMutations.setLastEditToNow();
        }
      case MutationType.deleted:
        if (moneyObject.mutation == MutationType.inserted) {
          // in case the delete item was a revcently added item, we need to deduct it from the sum
          DataController.to.trackMutations.increaseNumber(increaseAdded: -1);
        }
        moneyObject.mutation = MutationType.deleted;
        DataController.to.trackMutations.increaseNumber(increaseDeleted: 1);
      default:
        break;
    }

    if (recalculateBalances) {
      updateAll();
    }
  }

  /// When Changes are done we can force a reevaluation of the balances
  void recalculateBalances() {
    for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
      moneyObjects.onAllDataLoaded();
    }

    // one last thing, Transfer are complex and we try to confirm or clean up any problem found
    checkTransfers();
  }

  bool removeTransaction(Transaction t) {
    if (t.status.value == TransactionStatus.reconciled && t.amount.value.toDouble() != 0) {
      throw Exception('Cannot removed reconciled transaction');
    }
    // TODO
    // this.removeTransfer(t);

    // this.transactions.RemoveTransaction(t);
    // if (t.Unaccepted) {
    //   if (t.Account != null) {
    //     t.Account.Unaccepted--;
    //   }
    //   if (t.Payee != null) {
    //     t.Payee.UnacceptedTransactions--;
    //   }
    // }

    // if (t.Category == null && t.Transfer == null && !t.IsSplit) {
    //   if (t.Payee != null) {
    //     t.Payee.UncategorizedTransactions--;
    //   }
    // }

    // this.Rebalance(t);
    return true;
  }

  void transferSplitTo(MoneySplit s, Account to) {
    // Transaction t = s.Transaction;
    // if (t.Account == to) {
    //   throw new MoneyException("Cannot transfer to same account");
    // }
    //
    // if (t.Transfer != null && t.Transfer.Split != null) {
    //   throw new MoneyException("This transaction is already the target of a split transfer.\n" +
    //       "MyMoney doesn't support splits being on both sides of a transfer\n" +
    //       "So if you really want to add a transfer to ths Splits in this transaction\n" +
    //       "then please remove the split transfer that is pointing to this transaction"
    //   );
    // }
    //
    // // try the remove transfer first, because it will throw if the other side is reconciled.
    // this.RemoveTransfer(t.Transfer);
    // t.Transfer = null;
    // this.RemoveTransfer(s.Transfer);
    // s.Transfer = null;
    //
    // Transaction u = this.Transactions.NewTransaction(to);
    // u.Date = t.Date;
    // u.FITID = t.FITID;
    // u.Investment = t.Investment;
    // u.Number = t.Number;
    // u.Memo = s.Memo;
    // u.Category = s.Category;
    // //u.Status = t.Status; // no !!!
    // u.Amount = this.Currencies.GetTransferAmount(-s.Amount, t.Account.Currency, to.Currency);
    // u.Transfer = new Transfer(0, u, t, s);
    // s.Transfer = new Transfer(0, t, s, u);
    // this.Transactions.AddTransaction(u);
    // this.Rebalance(to);
  }

  /// ReBalance all objects values
  /// and Rebuild the UI
  void updateAll() {
    recalculateBalances();
    DataController.to.update();
  }

  Future<String?> validateDataBasePathIsValidAndExist(
    final String? filePath,
    final Uint8List fileBytes,
  ) async {
    try {
      if (filePath != null) {
        if (fileBytes.isNotEmpty) {
          return filePath;
        }
        if (File(filePath).existsSync()) {
          return filePath;
        }
      }
    } catch (e) {
      // next line will handle things
    }
    return null;
  }
}
