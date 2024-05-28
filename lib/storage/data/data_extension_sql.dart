part of 'data.dart';

extension DataFromSql on Data {
  Future<bool> loadFromSql(String filePathToLoad) async {
    // Load from SQLite
    final String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePathToLoad);

    if (pathToDatabaseFile != null) {
      // Open or create the database
      final MyDatabase db = MyDatabase(pathToDatabaseFile);

      accountAliases.loadFromJson(db.select('SELECT * FROM AccountAliases'));
      accounts.loadFromJson(db.select('SELECT * FROM Accounts'));
      aliases.loadFromJson(db.select('SELECT * FROM Aliases'));
      categories.loadFromJson(db.select('SELECT * FROM Categories'));
      currencies.loadFromJson(db.select('SELECT * FROM Currencies'));
      investments.loadFromJson(db.select('SELECT * FROM Investments'));
      loanPayments.loadFromJson(db.select('SELECT * FROM LoanPayments'));
      onlineAccounts.loadFromJson(db.select('SELECT * FROM OnlineAccounts'));
      payees.loadFromJson(db.select('SELECT * FROM Payees'));
      rentBuildings.loadFromJson(db.select('SELECT * FROM RentBuildings'));
      rentUnits.loadFromJson(db.select('SELECT * FROM RentUnits'));
      securities.loadFromJson(db.select('SELECT * FROM Securities'));
      transactions.loadFromJson(db.select('SELECT * FROM Transactions'));
      transactionExtras.loadFromJson(db.select('SELECT * FROM TransactionExtras'));

      // Must come after Transactions are loaded
      splits.loadFromJson(db.select('SELECT * FROM Splits'));
      stockSplits.loadFromJson(db.select('SELECT * FROM StockSplits'));

      // Close the database when done
      db.dispose();
      return true;
    }
    return false;
  }

  Future<bool> saveToSql({
    required final String filePathToLoad,
    required final Function(bool, String) callbackWhenLoaded,
  }) async {
    try {
      final MyDatabase db = MyDatabase(filePathToLoad);

      // Save transaction first
      transactions.saveSql(db, 'Transactions');

      onlineAccounts.saveSql(db, 'OnlineAccounts');
      accounts.saveSql(db, 'Accounts');
      payees.saveSql(db, 'Payees');
      aliases.saveSql(db, 'Aliases');
      accountAliases.saveSql(db, 'AccountAliases');
      categories.saveSql(db, 'Categories');
      currencies.saveSql(db, 'Currencies');
      securities.saveSql(db, 'Securities');
      stockSplits.saveSql(db, 'StockSplits');
      rentBuildings.saveSql(db, 'Buildings');
      loanPayments.saveSql(db, 'LoanPayments');
      transactionExtras.saveSql(db, 'TransactionExtras');

      db.dispose();
    } catch (e) {
      callbackWhenLoaded(false, e.toString());
      return false;
    }

    callbackWhenLoaded(true, '');
    return true;
  }
}
