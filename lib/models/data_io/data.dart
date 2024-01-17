import 'dart:io';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/money_objects/account_aliases/account_aliases.dart';
import 'package:money/models/money_objects/aliases/aliases.dart';
import 'package:money/models/data_io/file_systems.dart';
import 'package:money/models/money_objects/currencies/currencies.dart';
import 'package:money/models/money_objects/investments/investments.dart';
import 'package:money/models/money_objects/loan_payments/loan_payments.dart';
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
import 'package:money/models/data_io/data_others.dart'
    if (dart.library.html) 'package:money/models/data_io/data_web.dart';

class Data {
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

  static final Data _instance = Data._internal();

  Data._internal(); // private constructor

  factory Data() {
    return _instance;
  }

  init({
    required final String? filePathToLoad,
    required final Function callbackWhenLoaded,
  }) async {
    if (filePathToLoad == null) {
      return callbackWhenLoaded(false);
    }

    if (filePathToLoad == Constants.demoData) {
      // Not supported on Web so generate some random data to see in the views
      accountAliases.loadDemoData();
      accounts.loadDemoData();
      categories.loadDemoData();
      currencies.loadDemoData();
      investments.loadDemoData();
      loanPayments.loadDemoData();
      onlineAccounts.loadDemoData();
      payees.loadDemoData();
      aliases.loadDemoData();
      rentBuildings.loadDemoData();
      splits.loadDemoData();
      transactionExtras.loadDemoData();
      transactions.loadDemoData();
    } else {
      try {
        final String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePathToLoad);

        if (pathToDatabaseFile != null) {
          // Open or create the database
          final MyDatabase db = MyDatabase(pathToDatabaseFile);

          // Account_Aliases
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM AccountAliases');
            await accountAliases.load(result);
          }

          // Accounts
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Accounts');
            await accounts.load(result);
          }

          // Aliases
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Aliases');
            await aliases.load(result);
          }

          // Categories
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Categories');
            await categories.load(result);
          }

          // Currencies
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Currencies');
            await currencies.load(result);
          }

          // Investments
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Investments');
            await investments.load(result);
          }

          // Loan Payments
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM LoanPayments');
            await loanPayments.load(result);
          }

          // Online Accounts
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM OnlineAccounts');
            await onlineAccounts.load(result);
          }

          // Payees
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Payees');
            await payees.load(result);
          }

          // Rent Buildings
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM RentBuildings');
            await rentBuildings.load(result);
          }

          // Rent Units
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM RentUnits');
            await rentUnits.load(result);
          }

          // Securities
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Securities');
            await securities.load(result);
          }

          // Splits
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Splits');
            await splits.load(result);
          }

          // Stock Splits
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM StockSplits');
            await stockSplits.load(result);
          }

          // Transactions
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Transactions');
            await transactions.load(result);
          }

          // Transaction Extras
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM TransactionExtras');
            await transactionExtras.load(result);
          }

          // Close the database when done
          db.dispose();
        }
      } catch (e) {
        debugLog(e.toString());
        callbackWhenLoaded(false);
        return;
      }
    }

    accounts.onAllDataLoaded();
    categories.onAllDataLoaded();
    payees.onAllDataLoaded();
    aliases.onAllDataLoaded();
    rentBuildings.onAllDataLoaded();
    stockSplits.onAllDataLoaded();
    callbackWhenLoaded(true);
  }

  close() {
    aliases.clear();
    accounts.clear();
    categories.clear();
    investments.clear();
    onlineAccounts.clear();
    payees.clear();
    rentBuildings.clear();
    splits.clear();
    stockSplits.clear();
    transactionExtras.clear();
    transactions.clear();
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
