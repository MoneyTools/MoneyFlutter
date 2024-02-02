part of 'data.dart';

extension DataFromSql on Data {
  Future<void> loadFromSql(String filePathToLoad) async {
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
      splits.loadFromJson(db.select('SELECT * FROM Splits'));
      stockSplits.loadFromJson(db.select('SELECT * FROM StockSplits'));
      transactions.loadFromJson(db.select('SELECT * FROM Transactions'));
      transactionExtras.loadFromJson(db.select('SELECT * FROM TransactionExtras'));

      // Close the database when done
      db.dispose();
    }
    rememberWhereTheDataCameFrom(pathToDatabaseFile);
  }

  Future<bool> saveToSql({
    required final String? filePathToLoad,
    required final Function callbackWhenLoaded,
  }) async {
    try {
      final String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePathToLoad);

      if (pathToDatabaseFile != null) {
        final MyDatabase db = MyDatabase(pathToDatabaseFile);

        onlineAccounts.saveSql(db, 'OnlineAccounts');
        accounts.saveSql(db, 'Accounts');
        payees.saveSql(db, 'Payees');
        aliases.saveSql(db, 'Aliases');
        accountAliases.saveSql(db, 'AccountAliases');
        categories.saveSql(db, 'Categories');
        currencies.saveSql(db, 'Currencies');
        transactions.saveSql(db, 'Transactions');
        securities.saveSql(db, 'Securities');
        stockSplits.saveSql(db, 'StockSplits');
        rentBuildings.saveSql(db, 'Buildings');
        loanPayments.saveSql(db, 'LoanPayments');
        transactionExtras.saveSql(db, 'TransactionExtras');

        db.dispose();
      }
    } catch (e) {
      debugLog(e.toString());
      rememberWhereTheDataCameFrom(null);
      callbackWhenLoaded(false);
    }
    callbackWhenLoaded(true);
    return true;
  }
}
