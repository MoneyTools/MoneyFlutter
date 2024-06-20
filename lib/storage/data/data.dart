// Imports
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:money/helpers/file_systems.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_objects/account_aliases/account_aliases.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/accounts/accounts.dart';
import 'package:money/models/money_objects/aliases/aliases.dart';
import 'package:money/models/money_objects/categories/categories.dart';
import 'package:money/models/money_objects/currencies/currencies.dart';
import 'package:money/models/money_objects/investments/investments.dart';
import 'package:money/models/money_objects/investments/investment_types.dart';
import 'package:money/models/money_objects/loan_payments/loan_payments.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/online_accounts/online_accounts.dart';
import 'package:money/models/money_objects/payees/payees.dart';
import 'package:money/models/money_objects/rent_buildings/rent_buildings.dart';
import 'package:money/models/money_objects/rental_unit/rental_units.dart';
import 'package:money/models/money_objects/securities/securities.dart';
import 'package:money/models/money_objects/splits/splits.dart';
import 'package:money/models/money_objects/stock_splits/stock_splits.dart';
import 'package:money/models/money_objects/transaction_extras/transaction_extras.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/models/money_objects/transfers/transfer.dart';
import 'package:money/models/settings.dart';
import 'package:money/storage/database/database.dart';
import 'package:money/widgets/snack_bar.dart';

// Exports
export 'package:money/helpers/json_helper.dart';

part 'data_extension_csv.dart';

part 'data_extension_demo.dart';

part 'data_extension_sql.dart';

class Data {
  int version = 0;

  /// singleton
  static final Data _instance = Data._internal();

  /// private constructor
  Data._internal() {
    _listOfTables = <MoneyObjects<dynamic>>[
      accountAliases, // 1
      accounts, // 2
      aliases, // 3
      categories, // 4
      currencies, // 5
      investments, // 6
      loanPayments, // 7
      onlineAccounts, // 8
      payees, // 9
      securities, // 12
      stockSplits, // 14
      transactionExtras, // 15
      transactions, // 16
      // must come after Transactions
      splits, // 13
      rentBuildings, // 10
      rentUnits, // 11
    ];
  } // private constructor

  /// singleton access
  factory Data() {
    return _instance;
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

  void clear() {
    version = -1;
    Settings().trackMutations.reset();

    for (final element in _listOfTables) {
      element.clear();
    }
  }

  void notifyMutationChanged({
    required MutationType mutation,
    required MoneyObject moneyObject,
    bool fireNotification = true,
  }) {
    // let the app know that something has changed
    version++;

    switch (mutation) {
      case MutationType.inserted:
        moneyObject.mutation = MutationType.inserted;
        Settings().trackMutations.increaseNumber(increaseAdded: 1);
      case MutationType.changed:
        // this if is to ensure that we only count editing once and discard if this was edited on a new inserted items
        if (moneyObject.mutation == MutationType.none) {
          moneyObject.mutation = MutationType.changed;
          Settings().trackMutations.increaseNumber(increaseChanged: 1);
        }
      case MutationType.deleted:
        moneyObject.mutation = MutationType.deleted;
        Settings().trackMutations.increaseNumber(increaseDeleted: 1);
      default:
        break;
    }

    if (fireNotification) {
      updateAll();
    }
  }

  /// ReBalance all objects values
  /// and Rebuild the UI
  void updateAll() {
    recalculateBalances();
    Settings().rebuild();
  }

  /// Bulk Delete
  void deleteItems(final List<MoneyObject> itemsToDelete) {
    for (final item in itemsToDelete) {
      Data().notifyMutationChanged(mutation: MutationType.deleted, moneyObject: item, fireNotification: false);
    }
    Data().updateAll();
  }

  void assessMutationsCountOfAllModels() {
    Settings().trackMutations.reset();

    for (final element in _listOfTables) {
      element.resetMutationStateOfObjects();
      element.assessMutationsCounts();
    }
    Data().version++;
    Data().updateAll();
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

  Future<String?> validateDataBasePathIsValidAndExist(final String? filePath, final Uint8List fileBytes) async {
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

  DateTime? getLastDateTimeModified(final String fullPathToFile) {
    File file = File(fullPathToFile);
    // Get the last modified date and time of the file
    return file.lastModifiedSync();
  }

  /// Automated detection of what type of storage to load the data from
  Future<bool> loadFromPath({required final String filePathToLoad}) async {
    try {
      Settings().fileManager.dataFileLastUpdateDateTime = null;

      final String fileExtension = MyFileSystems.getFileExtension(filePathToLoad);
      switch (fileExtension.toLowerCase()) {
        // Sqlite
        case '.mmdb':
          // Load from SQLite
          if (await loadFromSql(filePathToLoad, Settings().fileManager.fileBytes)) {
            Settings().fileManager.rememberWhereTheDataCameFrom(filePathToLoad);
            Settings().fileManager.dataFileLastUpdateDateTime = getLastDateTimeModified(filePathToLoad);
          } else {
            Settings().fileManager.rememberWhereTheDataCameFrom('');
          }
        case '.mmcsv':
          // Zip CSV files
          await loadFromCsv(filePathToLoad);
          Settings().fileManager.rememberWhereTheDataCameFrom(filePathToLoad);
          Settings().fileManager.dataFileLastUpdateDateTime = getLastDateTimeModified(filePathToLoad);

        default:
          SnackBarService.displayWarning(autoDismiss: false, message: 'Unsupported file type $fileExtension');
          return false;
      }
    } catch (e) {
      debugLog(e.toString());
      SnackBarService.displayError(autoDismiss: false, message: e.toString());
      // clear any previous file
      Settings().fileManager.rememberWhereTheDataCameFrom('');
      return false;
    }

    // All individual table were loaded, now let the cross reference money object create linked to other tables
    recalculateBalances();

    // Notify that loading is completed
    return true;
  }

  Transaction? getOrCreateRelatedTransaction(Transaction transactionSource, Account destinationAccount) {
    if (transactionSource.accountId.value == destinationAccount.uniqueId) {
      debugLog("Cannot transfer to same account");
      return null;
    }

    Transaction? relatedTransaction = Data().transactions.findExistingTransactionForAccount(
          accountId: destinationAccount.uniqueId,
          dateTime: transactionSource.dateTime.value!,
          amount: -transactionSource.amount.value.toDouble(),
        );
    // ignore: prefer_conditional_assignment
    if (relatedTransaction == null) {
      relatedTransaction = Transaction()
        ..accountId.value = destinationAccount.uniqueId
        ..amount.value.setAmount((transactionSource.amount.value.toDouble() * -1)) // flip the sign
        ..categoryId.value = transactionSource.categoryId.value
        ..dateTime.value = transactionSource.dateTime.value
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

  bool makeTransferLinkage(Transaction transactionSource, Account destinationAccount) {
    Transaction? relatedTransaction = getOrCreateRelatedTransaction(transactionSource, destinationAccount);

    if (relatedTransaction != null) {
      final Transfer transfer;

      if (transactionSource.amount.value.toDouble() < 0) {
        // transfer TO
        transfer = Transfer(id: 0, source: transactionSource, related: relatedTransaction, isOrphan: false);
      } else {
        // transfer FROM
        transfer = Transfer(id: 0, source: relatedTransaction, related: transactionSource, isOrphan: false);
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

  /// When Changes are done we can force a reevaluation of the balances
  void recalculateBalances() {
    for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
      moneyObjects.onAllDataLoaded();
    }
  }

  /// Close data source
  void close() {
    for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
      moneyObjects.clear();
    }
    version = -1;

    Settings().trackMutations.reset();
    Settings().fileManager.rememberWhereTheDataCameFrom('');
  }

  /// <summary>
  /// Get a list of all Investment transactions grouped by security
  /// </summary>
  /// <param name="filter">The account filter or null if you want them all</param>
  /// <param name="toDate">Get all transactions up to but not including this date</param>
  /// <returns></returns>
  Map<Security, List<Investment>> getTransactionsGroupedBySecurity(Function(Account)? filter, DateTime toDate) {
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

  MoneyModel getNetWorth() {
    final double sum = accounts.getSumOfAccountBalances();
    return MoneyModel(amount: sum);
  }
}
