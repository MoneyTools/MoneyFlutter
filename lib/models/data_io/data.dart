// Imports
import 'dart:io';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/data_io/database/database.dart';
import 'package:money/models/money_objects/account_aliases/account_aliases.dart';
import 'package:money/models/money_objects/aliases/aliases.dart';
import 'package:money/models/data_io/file_systems.dart';
import 'package:money/models/money_objects/currencies/currencies.dart';
import 'package:money/models/money_objects/investments/investments.dart';
import 'package:money/models/money_objects/loan_payments/loan_payments.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/online_accounts/online_accounts.dart';
import 'package:money/models/money_objects/rental_unit/rental_units.dart';
import 'package:money/models/money_objects/rent_buildings/rent_buildings.dart';
import 'package:money/models/money_objects/accounts/accounts.dart';
import 'package:money/models/money_objects/categories/categories.dart';
import 'package:money/models/money_objects/payees/payees.dart';
import 'package:money/models/money_objects/securities/securities.dart';
import 'package:money/models/money_objects/stock_splits/stock_splits.dart';
import 'package:money/models/money_objects/transaction_extras/transaction_extras.dart';
import 'package:money/models/money_objects/transactions/transactions.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/splits/splits.dart';
import 'package:money/models/settings.dart';
import 'package:path/path.dart' as p;

// Exports
export 'package:money/helpers/json_helper.dart';

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

  void notifyTransactionChange(ChangeType change, dynamic objectChanged) {
    // let the app know that something has changed
    version++;
    Settings().increaseNumberOfChanges(1);
  }

  // Where was the data loaded from
  String? fullPathToDataSource;
  String? fullPathToNextDataSave;

  Future<void> openDataSource({
    required final String? filePathToLoad,
    required final Function callbackWhenLoaded,
  }) async {
    rememberWhereTheDataCameFrom(null);

    if (filePathToLoad == null) {
      return callbackWhenLoaded(false);
    }

    if (filePathToLoad == Constants.demoData) {
      // Generate a data set to demo the application
      for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
        moneyObjects.loadDemoData();
      }

      rememberWhereTheDataCameFrom(Constants.demoData);
    } else {
      // Load from SQLite
      try {
        final String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePathToLoad);

        if (pathToDatabaseFile != null) {
          // Open or create the database
          final MyDatabase db = MyDatabase(pathToDatabaseFile);

          // Account_Aliases
          accountAliases.loadFromSql(db);

          // Accounts
          accounts.loadFromSql(db);

          // Aliases
          aliases.loadFromSql(db);

          // Categories
          categories.loadFromSql(db);

          // Currencies
          currencies.loadFromSql(db, 'SELECT * FROM Currencies');

          // Investments
          investments.loadFromSql(db, 'SELECT * FROM Investments');

          // Loan Payments
          loanPayments.loadFromSql(db, 'SELECT * FROM LoanPayments');

          // Online Accounts
          onlineAccounts.loadFromSql(db, 'SELECT * FROM OnlineAccounts');

          // Payees
          payees.loadFromSql(db, 'SELECT * FROM Payees');

          // Rent Buildings
          rentBuildings.loadFromSql(db, 'SELECT * FROM RentBuildings');

          // Rent Units
          rentUnits.loadFromSql(db, 'SELECT * FROM RentUnits');

          // Securities
          securities.loadFromSql(db, 'SELECT * FROM Securities');

          // Splits
          splits.loadFromSql(db, 'SELECT * FROM Splits');

          // Stock Splits
          stockSplits.loadFromSql(db, 'SELECT * FROM StockSplits');

          // Transactions
          transactions.loadFromSql(db, 'SELECT * FROM Transactions');

          // Transaction Extras{
          transactionExtras.loadFromSql(db, 'SELECT * FROM TransactionExtras');

          // Close the database when done
          db.dispose();
        }
        rememberWhereTheDataCameFrom(pathToDatabaseFile);
      } catch (e) {
        debugLog(e.toString());
        rememberWhereTheDataCameFrom(null);
        callbackWhenLoaded(false);
        return;
      }
    }

    // All individual table were loaded, now let the cross reference money object create linked to other tables
    for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
      moneyObjects.onAllDataLoaded();
    }

    // Notify that loading is completed
    callbackWhenLoaded(true);
  }

  /// Close all tables
  void close() {
    for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
      moneyObjects.clear();
    }
    rememberWhereTheDataCameFrom(null);
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

  void save() {
    if (fullPathToNextDataSave == null) {
      throw Exception('No container folder give for saving');
    }

    final TimeLapse timeLapse = TimeLapse();
    final String folder = fullPathToNextDataSave!;

    MyFileSystems.ensureFolderExist(folder).then((final _) {
      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'account_aliases.csv'),
        accountAliases.toCSV(),
      );
      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'accounts.csv'),
        accounts.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'aliases.csv'),
        Data().aliases.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'categories.csv'),
        Data().categories.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'currencies.csv'),
        currencies.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'investments.csv'),
        Data().investments.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'loan_payments.csv'),
        Data().loanPayments.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'online_accounts.csv'),
        Data().onlineAccounts.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'payees.csv'),
        Data().payees.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'securities.csv'),
        Data().securities.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'splits.csv'),
        Data().splits.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'stock_splits.csv'),
        Data().stockSplits.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'rent_units.csv'),
        Data().rentUnits.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'rent_buildings.csv'),
        Data().rentBuildings.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'rent_units.csv'),
        Data().rentUnits.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'transaction_extras.csv'),
        Data().transactionExtras.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'transactions.csv'),
        Data().transactions.toCSV(),
      );

      timeLapse.endAndPrint();
    });
  }
}
