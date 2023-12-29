import 'dart:io';

import 'package:money/models/rentals.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:money/models/accounts.dart';
import 'package:money/models/categories.dart';
import 'package:money/models/payees.dart';
import 'package:money/models/transactions.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/splits.dart';

class Data {
  Accounts accounts = Accounts();
  Payees payees = Payees();
  Categories categories = Categories();
  Rentals rentals = Rentals();
  RentUnits rentUnits = RentUnits();
  Splits splits = Splits();
  Transactions transactions = Transactions();

  init(final String? filePathToLoad, final Function callbackWhenLoaded) async {
    if (filePathToLoad == null) {
      return callbackWhenLoaded(false);
    }

    if (filePathToLoad == Constants.demoData) {
      // Not supported on Web so generate some random data to see in the views
      accounts.loadDemoData();
      categories.loadDemoData();
      payees.loadDemoData();
      rentals.loadDemoData();
      splits.loadDemoData();
      transactions.loadDemoData();
    } else {
      try {
        if (Platform.isWindows || Platform.isLinux) {
          sqfliteFfiInit();
        }

        final DatabaseFactory databaseFactory = databaseFactoryFfi;
        final String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePathToLoad);
        if (pathToDatabaseFile != null) {
          final Database db = await databaseFactory.openDatabase(pathToDatabaseFile);

          // Accounts
          {
            final List<Map<String, Object?>> result = await db.query('Accounts');
            await accounts.load(result);
          }

          // Categories
          {
            final List<Map<String, Object?>> result = await db.query('Categories');
            await categories.load(result);
          }

          // Payees
          {
            final List<Map<String, Object?>> result = await db.query('Payees');
            await payees.load(result);
          }

          // Rentals
          {
            final List<Map<String, Object?>> result = await db.query('RentBuildings');
            await rentals.load(result);
          }

          // RentUnits
          {
            final List<Map<String, Object?>> result = await db.query('RentUnits');
            await rentUnits.load(result);
          }

          // Splits
          {
            final List<Map<String, Object?>> result = await db.query('Splits');
            await splits.load(result);
          }

          // Transactions
          {
            final List<Map<String, Object?>> result = await db.query('Transactions');
            await transactions.load(result);
          }

          await db.close();
        }
      } catch (e) {
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
}
