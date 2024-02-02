part of 'data.dart';

extension DataFromSql on Data {
  Future<void> loadFromSql(String filePathToLoad) async {
    // Load from SQLite
    final String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePathToLoad);

    if (pathToDatabaseFile != null) {
      // Open or create the database
      final MyDatabase db = MyDatabase(pathToDatabaseFile);

      // Account_Aliases
      accountAliases.loadFromJson(db.select('SELECT * FROM AccountAliases'));

      // Accounts
      accounts.loadFromJson(db.select('SELECT * FROM Accounts'));

      // Aliases
      aliases.loadFromJson(db.select('SELECT * FROM Aliases'));

      // Categories
      categories.loadFromJson(db.select('SELECT * FROM Categories'));

      // Currencies
      currencies.loadFromJson(db.select('SELECT * FROM Currencies'));

      // Investments
      investments.loadFromJson(db.select('SELECT * FROM Investments'));

      // Loan Payments
      loanPayments.loadFromJson(db.select('SELECT * FROM LoanPayments'));

      // Online Accounts
      onlineAccounts.loadFromJson(db.select('SELECT * FROM OnlineAccounts'));

      // Payees
      payees.loadFromJson(db.select('SELECT * FROM Payees'));

      // Rent Buildings
      rentBuildings.loadFromJson(db.select('SELECT * FROM RentBuildings'));

      // Rent Units
      rentUnits.loadFromJson(db.select('SELECT * FROM RentUnits'));

      // Securities
      securities.loadFromJson(db.select('SELECT * FROM Securities'));

      // Splits
      splits.loadFromJson(db.select('SELECT * FROM Splits'));

      // Stock Splits
      stockSplits.loadFromJson(db.select('SELECT * FROM StockSplits'));

      // Transactions
      transactions.loadFromJson(db.select('SELECT * FROM Transactions'));

      // Transaction Extras{
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

        accounts.saveSql(db);
        // this.UpdateOnlineAccounts(money.OnlineAccounts);
        // this.UpdateAccounts(money.Accounts);
        // this.UpdatePayees(money.Payees);
        // this.UpdateAliases(money.Aliases);
        // this.UpdateAccountAliases(money.AccountAliases);
        // this.UpdateCategories(money.Categories);
        // this.UpdateCurrencies(money.Currencies);
        transactions.saveSql(db);
        // this.UpdateSecurities(money.Securities);
        // this.UpdateStockSplits(money.StockSplits);
        // this.UpdateBuildings(money.Buildings);
        // this.UpdateLoanPayments(money.LoanPayments);
        // this.UpdateTransactionExtras(money.TransactionExtras);
        db.dispose();
      }
    } catch (e) {
      debugLog(e.toString());
      rememberWhereTheDataCameFrom(null);
      callbackWhenLoaded(false);
    }

    return true;
  }
}
