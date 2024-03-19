// Imports
import 'dart:io';

import 'package:money/helpers/file_systems.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/account_aliases/account_aliases.dart';
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
import 'package:money/models/settings.dart';
import 'package:money/storage/database/database.dart';
import 'package:path/path.dart' as p;

// Exports
export 'package:money/helpers/json_helper.dart';

part 'data_extension_csv.dart';

part 'data_extension_demo.dart';

part 'data_extension_sql.dart';

class Data {
  int version = 1;

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
      Settings().fireOnChanged();
    }
  }

  void assessMutationsCountOfAllModels() {
    Settings().trackMutations.reset();

    for (final element in _listOfTables) {
      element.assessMutationsCounts();
    }

    Settings().fireOnChanged();
  }

  // Where was the data loaded from
  String? fullPathToDataSource;
  String? fullPathToNextDataSave;

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

  void rememberWhereTheDataCameFrom(final String? dataSource) async {
    if (dataSource == null) {
      fullPathToDataSource = null;
      fullPathToNextDataSave = null;
      return;
    }

    if (dataSource == Constants.demoData) {
      fullPathToDataSource = Constants.demoData;
      fullPathToNextDataSave = generateNextFolderToSaveTo(await getDocumentDirectory());
      return;
    }

    fullPathToDataSource = dataSource;
    final String folderOfLoadedDatabase = p.dirname(fullPathToDataSource!);
    fullPathToNextDataSave = generateNextFolderToSaveTo(folderOfLoadedDatabase);
  }

  String generateNextFolderToSaveTo(final String startingFolder) {
    return MyFileSystems.append(startingFolder, 'moneyCSV');
  }

  /// Automated detection of what type of storage to load the data from
  Future<void> loadFromPath({
    required final String? filePathToLoad,
    required final Function callbackWhenLoaded,
  }) async {
    rememberWhereTheDataCameFrom(null);

    if (filePathToLoad == null) {
      return callbackWhenLoaded(false);
    }

    try {
      if (filePathToLoad == Constants.demoData) {
        // Generate a data set to demo the application
        loadFromDemoData();
      } else if (filePathToLoad.toLowerCase().endsWith('.mymoney.mmdb')) {
        // Load from SQLite
        await loadFromSql(filePathToLoad);
      } else {
        // Load from a folder that contains CSV files
        await loadFromCsv(filePathToLoad);
      }
    } catch (e) {
      debugLog(e.toString());
      rememberWhereTheDataCameFrom(null);
      callbackWhenLoaded(false);
      return;
    }

    // All individual table were loaded, now let the cross reference money object create linked to other tables
    recalculateBalances();

    // Notify that loading is completed
    callbackWhenLoaded(true);
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
    rememberWhereTheDataCameFrom(null);
  }
}
