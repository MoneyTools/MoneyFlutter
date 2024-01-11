import 'dart:io';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/aliases/aliases.dart';
import 'package:money/models/data_io/file_systems.dart';
import 'package:money/models/rentals/rental_units.dart';

import 'package:money/models/rentals/rentals.dart';

import 'package:money/models/accounts/accounts.dart';
import 'package:money/models/categories/categories.dart';
import 'package:money/models/payees/payees.dart';
import 'package:money/models/transactions/transactions.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/splits.dart';
import 'package:money/models/data_io/data_others.dart'
    if (dart.library.html) 'package:money/models/data_io/data_web.dart';

class Data {
  Accounts accounts = Accounts();
  Payees payees = Payees();
  Aliases aliases = Aliases();
  Categories categories = Categories();
  Rentals rentals = Rentals();
  RentUnits rentUnits = RentUnits();
  Splits splits = Splits();
  Transactions transactions = Transactions();

  init({
    required final String? filePathToLoad,
    required final Function callbackWhenLoaded,
  }) async {
    if (filePathToLoad == null) {
      return callbackWhenLoaded(false);
    }

    if (filePathToLoad == Constants.demoData) {
      // Not supported on Web so generate some random data to see in the views
      accounts.loadDemoData();
      categories.loadDemoData();
      payees.loadDemoData();
      aliases.loadDemoData();
      rentals.loadDemoData();
      splits.loadDemoData();
      transactions.loadDemoData();
    } else {
      try {
        final String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePathToLoad);

        if (pathToDatabaseFile != null) {
          // Open or create the database
          final MyDatabase db = MyDatabase(pathToDatabaseFile);

          // Accounts
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Accounts');
            await accounts.load(result);
          }
          // Categories
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Categories');
            await categories.load(result);
          }

          // Payees
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Payees');
            await payees.load(result);
          }

          // Aliases
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Aliases');
            await aliases.load(result);
          }

          // Rentals
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM RentBuildings');
            await rentals.load(result);
          }

          // RentUnits
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM RentUnits');
            await rentUnits.load(result);
          }

          // Splits
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Splits');
            await splits.load(result);
          }

          // Transactions
          {
            final List<Map<String, Object?>> result = db.select('SELECT * FROM Transactions');
            await transactions.load(result);
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

    Accounts.onAllDataLoaded();
    Categories.onAllDataLoaded();
    Payees.onAllDataLoaded();
    Rentals.onAllDataLoaded();
    callbackWhenLoaded(true);
  }

  close() {
    accounts.clear();
    categories.clear();
    payees.clear();
    rentals.clear();
    splits.clear();
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
        MyFileSystems.append(folder, 'accounts.csv'),
        Accounts.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'categories.csv'),
        Categories.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'payees.csv'),
        Payees.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'aliases.csv'),
        Aliases.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'transactions.csv'),
        Transactions.toCSV(),
      );

      timeLapse.endAndPrint();
    });
  }
}
