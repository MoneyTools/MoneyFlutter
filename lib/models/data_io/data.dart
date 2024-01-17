import 'dart:io';

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

class Data {
  /// singleton
  static final Data _instance = Data._internal();

  /// private constructor
  Data._internal() {
    _listOfTables = <MoneyObjects<dynamic>>[
      accountAliases,
      accounts,
      aliases,
      categories,
      currencies,
      investments,
      loanPayments,
      onlineAccounts,
      payees,
      rentBuildings,
      rentUnits,
      securities,
      splits,
      stockSplits,
      transactionExtras,
      transactions,
    ];
  } // private constructor

  /// singleton access
  factory Data() {
    return _instance;
  }

  // 1
  AccountAliases accountAliases = AccountAliases();

  // 2
  Accounts accounts = Accounts();

  // 3
  Aliases aliases = Aliases();

  // 4
  Categories categories = Categories();

  // 5
  Currencies currencies = Currencies();

  // 6
  Investments investments = Investments();

  // 7
  LoanPayments loanPayments = LoanPayments();

  // 8
  OnlineAccounts onlineAccounts = OnlineAccounts();

  // 9
  Payees payees = Payees();

  // 10
  RentBuildings rentBuildings = RentBuildings();

  // 11
  RentUnits rentUnits = RentUnits();

  // 12
  Securities securities = Securities();

  // 13
  Splits splits = Splits();

  // 14
  StockSplits stockSplits = StockSplits();

  // 15
  TransactionExtras transactionExtras = TransactionExtras();

  // 16
  Transactions transactions = Transactions();

  late final List<MoneyObjects<dynamic>> _listOfTables;

  init({
    required final String? filePathToLoad,
    required final Function callbackWhenLoaded,
  }) async {
    if (filePathToLoad == null) {
      return callbackWhenLoaded(false);
    }

    if (filePathToLoad == Constants.demoData) {
      // Generate a data set to demo the application
      for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
        moneyObjects.loadDemoData();
      }
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
      } catch (e) {
        debugLog(e.toString());
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
  close() {
    for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
      moneyObjects.clear();
    }
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

  void save(final String containerFolder) {
    final TimeLapse timeLapse = TimeLapse();

    final String folder = MyFileSystems.append(containerFolder, 'moneyCSV');

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
