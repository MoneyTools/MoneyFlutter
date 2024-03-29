// Imports
import 'dart:io';

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
      rentBuildings, // 10
      rentUnits, // 11
      securities, // 12
      splits, // 13
      stockSplits, // 14
      transactionExtras, // 15
      transactions, // 16
    ];
  } // private constructor

  /// singleton access
  factory Data() {
    return _instance;
  }

  /// All Field definitions
  Map<String, Field<dynamic, dynamic>> mapClassToFields = <String, Field<dynamic, dynamic>>{};

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

  void notifyTransactionChange({
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
      recalculateBalances();
      Settings().rebuild();
    }
  }

  void assessMutationsCountOfAllModels() {
    Settings().trackMutations.reset();

    for (final element in _listOfTables) {
      element.assessMutationsCounts();
    }
    Settings().rebuild();
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

  Future<String?> validateDataBasePathIsValidAndExist(final String? filePath) async {
    try {
      if (filePath != null) {
        if (File(filePath).existsSync()) {
          return filePath;
        }
      }
    } catch (e) {
      // next line will handle things
    }
    return null;
  }

  /// Automated detection of what type of storage to load the data from
  Future<bool> loadFromPath({required final String filePathToLoad}) async {
    try {
      // Sqlite
      if (filePathToLoad.toLowerCase().endsWith('.mmdb')) {
        // Load from SQLite
        if (await loadFromSql(filePathToLoad)) {
          Settings().fileManager.rememberWhereTheDataCameFrom(filePathToLoad);
        } else {
          Settings().fileManager.rememberWhereTheDataCameFrom('');
        }
      } else {
        // CSV
        // Load from a folder that contains CSV files
        await loadFromCsv(filePathToLoad);
        Settings().fileManager.rememberWhereTheDataCameFrom(filePathToLoad);
      }
    } catch (e) {
      debugLog(e.toString());
      SnackBarService.showSnackBar(autoDismiss: false, message: e.toString());
      // clear any previous file
      Settings().fileManager.rememberWhereTheDataCameFrom('');
      return false;
    }

    // All individual table were loaded, now let the cross reference money object create linked to other tables
    recalculateBalances();

    // Notify that loading is completed
    return true;
  }

  void removeTransfer(Transaction t) {
    if (t.transfer.value != -1) {
      t.transfer.value = -1;
      t.transferInstance = null;
    }
  }

  bool transferTo(Transaction transactionSource, Account destinationAccount) {
    if (transactionSource.accountId.value == destinationAccount.uniqueId) {
      debugLog("Cannot transfer to same account");
      return false;
    }

    removeTransfer(transactionSource);

    Transaction? relatedTransaction = Data().transactions.findExistingTransactionForAccount(
          accountId: destinationAccount.uniqueId,
          dateTime: transactionSource.dateTime.value!,
          amount: -transactionSource.amount.value,
        );

    // ignore: prefer_conditional_assignment
    if (relatedTransaction == null) {
      relatedTransaction = Transaction()
        ..accountId.value = destinationAccount.uniqueId
        ..amount.value = -transactionSource.amount.value
        ..categoryId.value = transactionSource.categoryId.value
        ..dateTime.value = transactionSource.dateTime.value
        ..fitid.value = transactionSource.fitid.value
        ..number.value = transactionSource.number.value
        ..memo.value = transactionSource.memo.value;
      //u.Status = t.Status; no !!!

      // Investment i = t.Investment;
      // if (i != null) {
      //   Investment j = u.GetOrCreateInvestment();
      //   j.Units = i.Units;
      //   j.UnitPrice = i.UnitPrice;
      //   j.Security = i.Security;
      //   switch (i.Type) {
      //     case InvestmentType.Add:
      //       j.Type = InvestmentType.Remove;
      //       break;
      //     case InvestmentType.Remove:
      //       j.Type = InvestmentType.Add;
      //       break;
      //     case InvestmentType.None: // assume it's a remove
      //       i.Type = InvestmentType.Remove;
      //       j.Type = InvestmentType.Add;
      //       break;
      //     case InvestmentType.Buy:
      //     case InvestmentType.Sell:
      //       throw new MoneyException("Transfer must be of type 'Add' or 'Remove'.");
      //   }
      //   u.Investment = j;
      // }
    }

    // must have a valid transaction id before we assign the transfers.
    relatedTransaction.transfer.value = transactionSource.id.value;
    relatedTransaction.transferInstance =
        Transfer(id: 0, source: relatedTransaction, related: transactionSource, isOrphan: false);

    transactionSource.transfer.value = transactionSource.id.value;
    transactionSource.transferInstance =
        Transfer(id: 0, source: transactionSource, related: relatedTransaction, isOrphan: false);
    // this needs to happen after the above
    final MoneyObject updateObjectId = transactions.appendNewMoneyObject(relatedTransaction);
    relatedTransaction.id.value = updateObjectId.uniqueId;
    return true;
  }

  void transferSplitTo(Split s, Account to) {
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
}
